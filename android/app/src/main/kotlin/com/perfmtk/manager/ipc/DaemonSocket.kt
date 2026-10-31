package com.perfmtk.manager.ipc

import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter

/** Client for the `@perfmtkd_ctrl` abstract LocalSocket exposed by the daemon. */
object DaemonSocket {
    private const val TAG = "PerfMTK-IPC"
    const val SOCKET_NAME = "perfmtkd_ctrl"
    private const val COMMAND_TIMEOUT_MS = 3000

    /** Opens a connected socket; the caller owns it and must close it. */
    fun open(): LocalSocket {
        val socket = LocalSocket()
        try {
            socket.connect(LocalSocketAddress(SOCKET_NAME, LocalSocketAddress.Namespace.ABSTRACT))
        } catch (e: Throwable) {
            try { socket.close() } catch (_: Throwable) {}
            throw e
        }
        return socket
    }

    /** Sends one command line and returns the trimmed reply, or null on failure. */
    fun sendCommand(cmd: String, arg: String?): String? {
        var socket: LocalSocket? = null
        return try {
            socket = open()
            socket.soTimeout = COMMAND_TIMEOUT_MS

            val writer = OutputStreamWriter(socket.outputStream)
            writer.write(if (!arg.isNullOrBlank()) "$cmd $arg\n" else "$cmd\n")
            writer.flush()

            BufferedReader(InputStreamReader(socket.inputStream)).readText().trim()
        } catch (e: Exception) {
            Log.w(TAG, "sendCommand($cmd) failed: ${e.message}")
            null
        } finally {
            try { socket?.close() } catch (_: Exception) {}
        }
    }
}
