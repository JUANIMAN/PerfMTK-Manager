package com.perfmtk.manager.apps

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

/** `com.perfmtk.manager/apps`: installed apps and their icons. */
class AppsChannelHandler(
    private val executor: ExecutorService,
    private val iconExecutor: ExecutorService,
    private val apps: InstalledApps,
    private val icons: IconStore,
    private val onMainThread: (Runnable) -> Unit,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInstalledApps" -> {
                val excludeSystemApps = call.argument<Boolean>("excludeSystemApps") ?: true
                executor.execute {
                    try {
                        val list = apps.list(excludeSystemApps)
                        onMainThread(Runnable { result.success(list) })
                    } catch (e: Throwable) {
                        onMainThread(Runnable { result.error("APPS_ERROR", e.message, null) })
                    }
                }
            }
            "getAppIcon" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                if (packageName.isBlank()) {
                    result.success(null)
                    return
                }
                icons.cached(packageName)?.let {
                    result.success(it)
                    return
                }
                iconExecutor.execute {
                    val bytes = icons.load(packageName)
                    onMainThread(Runnable { result.success(bytes) })
                }
            }
            "getAppIconsBatch" -> {
                val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                if (packageNames.isEmpty()) {
                    result.success(emptyMap<String, ByteArray>())
                    return
                }
                iconExecutor.execute {
                    val map = HashMap<String, ByteArray>()
                    for (pkg in packageNames) {
                        icons.load(pkg)?.let { map[pkg] = it }
                    }
                    onMainThread(Runnable { result.success(map) })
                }
            }
            "clearIconCache" -> {
                // Same observable behavior as before: memory is dropped immediately,
                // disk files are deleted on the icon worker.
                iconExecutor.execute { icons.clear() }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
