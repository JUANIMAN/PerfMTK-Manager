package com.perfmtk.manager.apps

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import android.util.LruCache
import java.io.ByteArrayOutputStream
import java.io.File

/** Launcher icons rendered to small WebP images with a memory and a disk cache. */
class IconStore(private val context: Context) {
    // Holds up to 350 icons (~500 KB with WebP).
    private val memory = LruCache<String, ByteArray>(350)

    private val dir: File by lazy {
        File(context.cacheDir, "app_icons").apply { if (!exists()) mkdirs() }
    }

    fun cached(packageName: String): ByteArray? = memory.get(packageName)

    /** Memory → disk → render. Returns null when the package has no loadable icon. */
    fun load(packageName: String): ByteArray? {
        memory.get(packageName)?.let { return it }

        // Persistent disk cache first (flash read, no PackageManager IPC).
        val diskFile = File(dir, "$packageName.webp")
        if (diskFile.exists() && diskFile.length() > 0) {
            try {
                val bytes = diskFile.readBytes()
                memory.put(packageName, bytes)
                return bytes
            } catch (_: Throwable) {}
        }

        return try {
            val pm = context.packageManager
            val drawable = pm.getApplicationInfo(packageName, 0).loadIcon(pm)
            val bitmap = Bitmap.createBitmap(ICON_SIZE, ICON_SIZE, Bitmap.Config.ARGB_8888)
            drawable.setBounds(0, 0, ICON_SIZE, ICON_SIZE)
            drawable.draw(Canvas(bitmap))

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

            memory.put(packageName, bytes)
            try {
                diskFile.outputStream().use { it.write(bytes) }
            } catch (_: Throwable) {}
            bytes
        } catch (_: Throwable) {
            null
        }
    }

    fun clear() {
        memory.evictAll()
        try {
            dir.listFiles()?.forEach { it.delete() }
        } catch (_: Throwable) {}
    }

    private companion object {
        const val ICON_SIZE = 72
    }
}
