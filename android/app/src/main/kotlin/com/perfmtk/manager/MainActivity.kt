package com.perfmtk.manager

import android.net.LocalSocket
import android.net.LocalSocketAddress
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val ipcChannelName = "com.perfmtk.manager/ipc"
    private val streamChannelName = "com.perfmtk.manager/telemetry_stream"
    private val socketName = "perfmtkd_ctrl"

    private val executor = Executors.newCachedThreadPool()

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
}
