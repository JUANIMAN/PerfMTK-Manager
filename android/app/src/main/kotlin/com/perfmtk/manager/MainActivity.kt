package com.perfmtk.manager

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.util.LruCache
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val ipcChannelName = "com.perfmtk.manager/ipc"
    private val streamChannelName = "com.perfmtk.manager/telemetry_stream"
    private val appsChannelName = "com.perfmtk.manager/apps"
    private val socketName = "perfmtkd_ctrl"

    private val executor = Executors.newCachedThreadPool()
    // Dedicated low-priority worker thread pool for background icon decoding and disk caching
    // so background image processing never steals frame time from the UI thread
    private val iconThreadPool = Executors.newFixedThreadPool(2) { r ->
        Thread(r, "perfmtk-icon-worker").apply {
            priority = Thread.MIN_PRIORITY
        }
    }
    // In-memory cache for app icons: holds up to 350 icons (~500 KB with WebP)
    private val iconCache = LruCache<String, ByteArray>(350)
    private val iconsDir: File by lazy {
        File(cacheDir, "app_icons").apply {
            if (!exists()) mkdirs()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ipcChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendCommand" -> {
                    val cmd = call.argument<String>("cmd") ?: ""
                    val arg = call.argument<String>("arg")
                    executor.execute {
                        val response = sendSocketCommand(cmd, arg)
                        runOnUiThread {
                            if (response != null) {
                                result.success(response)
                            } else {
                                result.error("SOCKET_ERROR", "Failed to communicate with perfmtkd", null)
                            }
                        }
                    }
                }
                "isDaemonRunning" -> {
                    executor.execute {
                        val response = sendSocketCommand("PING", null)
                        val isRunning = response?.trim() == "PONG"
                        runOnUiThread {
                            result.success(isRunning)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appsChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val excludeSystemApps = call.argument<Boolean>("excludeSystemApps") ?: true
                    executor.execute {
                        try {
                            val apps = getInstalledAppsList(excludeSystemApps)
                            runOnUiThread {
                                result.success(apps)
                            }
                        } catch (e: Throwable) {
                            runOnUiThread {
                                result.error("APPS_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    if (packageName.isBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    val cached = iconCache.get(packageName)
                    if (cached != null) {
                        result.success(cached)
                        return@setMethodCallHandler
                    }

                    iconThreadPool.execute {
                        val bytes = loadIconBytes(packageName)
                        runOnUiThread {
                            result.success(bytes)
                        }
                    }
                }
                "getAppIconsBatch" -> {
                    val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                    if (packageNames.isEmpty()) {
                        result.success(emptyMap<String, ByteArray>())
                        return@setMethodCallHandler
                    }

                    iconThreadPool.execute {
                        val resultMap = HashMap<String, ByteArray>()
                        for (pkg in packageNames) {
                            val bytes = loadIconBytes(pkg)
                            if (bytes != null) {
                                resultMap[pkg] = bytes
                            }
                        }
                        runOnUiThread {
                            result.success(resultMap)
                        }
                    }
                }
                "clearIconCache" -> {
                    iconCache.evictAll()
                    iconThreadPool.execute {
                        try {
                            iconsDir.listFiles()?.forEach { it.delete() }
                        } catch (_: Throwable) {}
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, streamChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var streamSocket: LocalSocket? = null
                private val isStreaming = AtomicBoolean(false)

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (events == null) return
                    val intervalMs = (arguments as? Map<*, *>)?.get("intervalMs") as? Int ?: 2000
                    isStreaming.set(true)

                    executor.execute {
                        var socket: LocalSocket? = null
                        try {
                            socket = LocalSocket()
                            socket.connect(LocalSocketAddress(socketName, LocalSocketAddress.Namespace.ABSTRACT))
                            streamSocket = socket

                            val writer = OutputStreamWriter(socket.outputStream)
                            writer.write("STREAM_JSON $intervalMs\n")
                            writer.flush()

                            val reader = BufferedReader(InputStreamReader(socket.inputStream))
                            while (isStreaming.get()) {
                                val line = reader.readLine() ?: break
                                runOnUiThread {
                                    if (isStreaming.get()) {
                                        events.success(line)
                                    }
                                }
                            }
                        } catch (e: Exception) {
                            if (isStreaming.get()) {
                                runOnUiThread {
                                    events.error("STREAM_ERROR", e.message, null)
                                }
                            }
                        } finally {
                            try {
                                socket?.close()
                            } catch (_: Exception) {}
                            if (streamSocket == socket) {
                                streamSocket = null
                            }
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    isStreaming.set(false)
                    try {
                        streamSocket?.close()
                    } catch (_: Exception) {}
                    streamSocket = null
                }
            }
        )
    }

    private fun sendSocketCommand(cmd: String, arg: String?): String? {
        var socket: LocalSocket? = null
        return try {
            socket = LocalSocket()
            socket.soTimeout = 3000
            socket.connect(LocalSocketAddress(socketName, LocalSocketAddress.Namespace.ABSTRACT))

            val writer = OutputStreamWriter(socket.outputStream)
            val fullCmd = if (arg != null && arg.isNotBlank()) "$cmd $arg\n" else "$cmd\n"
            writer.write(fullCmd)
            writer.flush()

            val reader = BufferedReader(InputStreamReader(socket.inputStream))
            val response = reader.readText()
            response.trim()
        } catch (e: Exception) {
            null
        } finally {
            try {
                socket?.close()
            } catch (_: Exception) {}
        }
    }

    private fun getInstalledAppsList(excludeSystemApps: Boolean): List<Map<String, Any?>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val launchablePackageNames = HashSet<String>(resolveInfos.size)
        for (info in resolveInfos) {
            info.activityInfo?.packageName?.let { launchablePackageNames.add(it) }
        }

        val packageInfos = pm.getInstalledPackages(0)
        val result = ArrayList<HashMap<String, Any?>>()
        val seen = HashSet<String>()

        for (pkg in packageInfos) {
            val appInfo = pkg.applicationInfo ?: continue
            val pkgName = pkg.packageName ?: continue
            if (!launchablePackageNames.contains(pkgName)) continue
            if (!seen.add(pkgName)) continue

            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            if (excludeSystemApps && isSystem) continue

            val label = pm.getApplicationLabel(appInfo).toString()
            val map = HashMap<String, Any?>()
            map["name"] = label
            map["package_name"] = pkgName
            map["is_system_app"] = isSystem
            map["version_name"] = pkg.versionName ?: "1.0.0"
            result.add(map)
        }

        // Sort alphabetically so the viewport matches the display order
        result.sortBy { (it["name"] as? String)?.lowercase() ?: "" }

        // Preload icons for the initial viewport (first 25 apps)
        val preloadLimit = minOf(result.size, 25)
        for (i in 0 until preloadLimit) {
            val pkg = result[i]["package_name"] as? String ?: continue
            val iconBytes = loadIconBytes(pkg)
            if (iconBytes != null) {
                result[i]["icon"] = iconBytes
            }
        }

        return result
    }

    private fun loadIconBytes(packageName: String): ByteArray? {
        val cached = iconCache.get(packageName)
        if (cached != null) return cached

        // Check persistent disk cache first (instant flash storage read, no IPC)
        val diskFile = File(iconsDir, "$packageName.webp")
        if (diskFile.exists() && diskFile.length() > 0) {
            try {
                val bytes = diskFile.readBytes()
                iconCache.put(packageName, bytes)
                return bytes
            } catch (_: Throwable) {}
        }

        return try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            val drawable = appInfo.loadIcon(pm)
            val size = 72
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream(2048)
            val format = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                Bitmap.CompressFormat.WEBP_LOSSY
            } else {
                @Suppress("DEPRECATION")
                Bitmap.CompressFormat.WEBP
            }
            bitmap.compress(format, 80, stream)
            val bytes = stream.toByteArray()
            bitmap.recycle()

            iconCache.put(packageName, bytes)

            // Save to persistent disk cache
            try {
                diskFile.outputStream().use { it.write(bytes) }
            } catch (_: Throwable) {}

            bytes
        } catch (_: Throwable) {
            null
        }
    }
}
