package com.perfmtk.manager.ipc

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService

/** `com.perfmtk.manager/ipc`: daemon commands and the shared-memory lease. */
class IpcChannelHandler(
    private val executor: ExecutorService,
    private val shm: ShmLease,
    private val onMainThread: (Runnable) -> Unit,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendCommand" -> {
                val cmd = call.argument<String>("cmd") ?: ""
                val arg = call.argument<String>("arg")
                runAsync {
                    val response = DaemonSocket.sendCommand(cmd, arg)
                    onMainThread(Runnable {
                        if (response != null) {
                            result.success(response)
                        } else {
                            result.error("SOCKET_ERROR", "Failed to communicate with perfmtkd", null)
                        }
                    })
                }
            }
            "isDaemonRunning" -> runAsync {
                val running = DaemonSocket.sendCommand("PING", null)?.trim() == "PONG"
                onMainThread(Runnable { result.success(running) })
            }
            "subscribeShm" -> {
                val intervalMs = call.argument<Int>("intervalMs") ?: 1000
                runAsync {
                    val addr = shm.subscribe(intervalMs)
                    onMainThread(Runnable {
                        if (addr != 0L) {
                            result.success(addr)
                        } else {
                            result.error("SHM_ERROR", "Failed to map shared memory telemetry", null)
                        }
                    })
                }
            }
            "unsubscribeShm" -> runAsync {
                shm.release()
                onMainThread(Runnable { result.success(true) })
            }
            else -> result.notImplemented()
        }
    }

    private fun runAsync(block: () -> Unit) = executor.execute(block)
}
