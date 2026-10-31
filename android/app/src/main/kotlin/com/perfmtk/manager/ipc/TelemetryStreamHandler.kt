package com.perfmtk.manager.ipc

import android.net.LocalSocket
import io.flutter.plugin.common.EventChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.util.concurrent.ExecutorService
import java.util.concurrent.atomic.AtomicBoolean

/** Streams `STREAM_JSON` telemetry lines from the daemon to Flutter. */
class TelemetryStreamHandler(
    private val executor: ExecutorService,
    private val onMainThread: (Runnable) -> Unit,
) : EventChannel.StreamHandler {
    private var streamSocket: LocalSocket? = null
    private val isStreaming = AtomicBoolean(false)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return
        val intervalMs = (arguments as? Map<*, *>)?.get("intervalMs") as? Int ?: 2000
        isStreaming.set(true)

        executor.execute {
            var socket: LocalSocket? = null
            try {
                socket = DaemonSocket.open()
                streamSocket = socket

                val writer = OutputStreamWriter(socket.outputStream)
                writer.write("STREAM_JSON $intervalMs\n")
                writer.flush()

                val reader = BufferedReader(InputStreamReader(socket.inputStream))
                while (isStreaming.get()) {
                    val line = reader.readLine() ?: break
                    onMainThread(Runnable { if (isStreaming.get()) events.success(line) })
                }
            } catch (e: Exception) {
                if (isStreaming.get()) {
                    onMainThread(Runnable { events.error("STREAM_ERROR", e.message, null) })
                }
            } finally {
                try { socket?.close() } catch (_: Exception) {}
                if (streamSocket == socket) streamSocket = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        isStreaming.set(false)
        try { streamSocket?.close() } catch (_: Exception) {}
        streamSocket = null
    }
}
