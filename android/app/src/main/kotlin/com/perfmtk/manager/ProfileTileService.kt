package com.perfmtk.manager

import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter

class ProfileTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()
        val current = getCurrentProfile()
        val next = when (current) {
            "balanced" -> "performance"
            "performance" -> "powersave"
            "powersave" -> "balanced"
            else -> "balanced"
        }

        applyProfile(next)
        updateTileState(next)
    }

    private fun getCurrentProfile(): String {
        return try {
            val c = Class.forName("android.os.SystemProperties")
            val m = c.getMethod("get", String::class.java, String::class.java)
            val v = m.invoke(null, "sys.perfmtk.current_profile", "balanced") as String
            if (v.isNotEmpty()) v else "balanced"
        } catch (e: Exception) {
            try {
                val process = Runtime.getRuntime().exec(arrayOf("getprop", "sys.perfmtk.current_profile"))
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val line = reader.readLine()?.trim()
                reader.close()
                process.waitFor()
                if (!line.isNullOrEmpty()) line else "balanced"
            } catch (ex: Exception) {
                "balanced"
            }
        }
    }

    private fun applyProfile(profile: String) {
        Thread {
            var socketSuccess = false
            try {
                val socket = LocalSocket()
                socket.soTimeout = 1500
                socket.connect(LocalSocketAddress("perfmtkd_ctrl", LocalSocketAddress.Namespace.ABSTRACT))
                val writer = OutputStreamWriter(socket.outputStream)
                writer.write("APPLY $profile\n")
                writer.flush()
                val reader = BufferedReader(InputStreamReader(socket.inputStream))
                val resp = reader.readLine()
                socket.close()
                socketSuccess = (resp != null && resp.startsWith("OK"))
            } catch (_: Exception) {
                socketSuccess = false
            }

            if (!socketSuccess) {
                try {
                    val p = Runtime.getRuntime().exec(arrayOf("su", "-c", "/data/adb/modules/perfmtk/system/bin/perfmtk $profile"))
                    p.waitFor()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    private fun updateTileState(overrideProfile: String? = null) {
        val tile = qsTile ?: return
        val profile = overrideProfile ?: getCurrentProfile()
        
        val displayName = profile.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        tile.label = "Perf: $displayName"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = displayName
        }

        when (profile.lowercase()) {
            "performance" -> {
                tile.state = Tile.STATE_ACTIVE
            }
            "balanced" -> {
                tile.state = Tile.STATE_ACTIVE
            }
            "powersave", "powersave+" -> {
                tile.state = Tile.STATE_INACTIVE
            }
            else -> {
                tile.state = Tile.STATE_INACTIVE
            }
        }
        tile.updateTile()
    }
}
