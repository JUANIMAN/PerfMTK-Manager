package com.perfmtk.manager.ipc

import android.net.LocalSocket
import android.system.Os
import android.system.OsConstants
import android.util.Log
import java.io.OutputStreamWriter

/**
 * Zero-copy telemetry: maps the daemon's `memfd` (received via SCM_RIGHTS) read-only
 * and keeps the control socket open as a liveness lease so `perfmtkd` notices when
 * the app pauses or exits (EPOLLRDHUP).
 */
class ShmLease {
    private val lock = Any()
    private var leaseSocket: LocalSocket? = null
    private var mappedAddress: Long = 0L

    /** Returns the mapped address, or 0 when unavailable. Replaces any existing lease. */
    fun subscribe(intervalMs: Int): Long = synchronized(lock) {
        releaseLocked()
        var socket: LocalSocket? = null
        try {
            socket = DaemonSocket.open()
            socket.soTimeout = ACK_TIMEOUT_MS

            val writer = OutputStreamWriter(socket.outputStream)
            writer.write("SUBSCRIBE_SHM $intervalMs\n")
            writer.flush()

            // Reading the 1-byte ACK triggers recvmsg() and populates ancillaryFileDescriptors.
            if (socket.inputStream.read() != '1'.code) {
                socket.close()
                return 0L
            }

            val fds = socket.ancillaryFileDescriptors
            if (fds == null || fds.isEmpty()) {
                socket.close()
                return 0L
            }

            val addr = try {
                Os.mmap(0L, PAGE_SIZE, OsConstants.PROT_READ, OsConstants.MAP_SHARED, fds[0], 0L)
            } finally {
                // The mapping keeps the kernel reference; drop our duplicate FDs.
                for (fd in fds) {
                    try { Os.close(fd) } catch (_: Throwable) {}
                }
            }

            if (addr == 0L) {
                socket.close()
                return 0L
            }

            leaseSocket = socket
            mappedAddress = addr
            addr
        } catch (e: Throwable) {
            Log.w(TAG, "subscribe failed: ${e.message}")
            try { socket?.close() } catch (_: Throwable) {}
            0L
        }
    }

    fun release() = synchronized(lock) { releaseLocked() }

    private fun releaseLocked() {
        val sock = leaseSocket
        leaseSocket = null
        if (sock != null) {
            try { sock.close() } catch (_: Throwable) {}
        }

        val addr = mappedAddress
        mappedAddress = 0L
        if (addr != 0L) {
            try { Os.munmap(addr, PAGE_SIZE) } catch (_: Throwable) {}
        }
    }

    private companion object {
        const val TAG = "PerfMTK-SHM"
        const val PAGE_SIZE = 4096L
        const val ACK_TIMEOUT_MS = 2000
    }
}
