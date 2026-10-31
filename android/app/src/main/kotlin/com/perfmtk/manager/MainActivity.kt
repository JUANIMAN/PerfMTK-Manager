package com.perfmtk.manager

import com.perfmtk.manager.apps.AppsChannelHandler
import com.perfmtk.manager.apps.IconStore
import com.perfmtk.manager.apps.InstalledApps
import com.perfmtk.manager.ipc.IpcChannelHandler
import com.perfmtk.manager.ipc.ShmLease
import com.perfmtk.manager.ipc.TelemetryStreamHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** Wires the Flutter platform channels to their native handlers. */
class MainActivity : FlutterActivity() {
    private val shm = ShmLease()

    /** Bounded: socket I/O and PackageManager queries never need unbounded fan-out. */
    private val executor = Executors.newFixedThreadPool(WORKER_THREADS) { r ->
        Thread(r, "perfmtk-worker")
    }

    /** Low priority so icon decoding never steals frame time from the UI thread. */
    private val iconExecutor = Executors.newFixedThreadPool(ICON_THREADS) { r ->
        Thread(r, "perfmtk-icon-worker").apply { priority = Thread.MIN_PRIORITY }
    }

    private val icons by lazy { IconStore(applicationContext) }
    private val apps by lazy { InstalledApps(applicationContext, icons) }

    private fun onMain(action: Runnable) = runOnUiThread(action)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, IPC_CHANNEL)
            .setMethodCallHandler(IpcChannelHandler(executor, shm, ::onMain))
        MethodChannel(messenger, APPS_CHANNEL)
            .setMethodCallHandler(AppsChannelHandler(executor, iconExecutor, apps, icons, ::onMain))
        EventChannel(messenger, STREAM_CHANNEL)
            .setStreamHandler(TelemetryStreamHandler(executor, ::onMain))
    }

    override fun onDestroy() {
        shm.release()
        super.onDestroy()
    }

    private companion object {
        const val IPC_CHANNEL = "com.perfmtk.manager/ipc"
        const val STREAM_CHANNEL = "com.perfmtk.manager/telemetry_stream"
        const val APPS_CHANNEL = "com.perfmtk.manager/apps"
        const val WORKER_THREADS = 6
        const val ICON_THREADS = 2
    }
}
