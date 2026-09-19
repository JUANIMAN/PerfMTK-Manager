package com.perfmtk.manager

import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter

class ChargeBypassTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()
        val isBypassOn = isBypassActive()
        val newState = !isBypassOn
        toggleBypass(newState)
        updateTileState(newState)
    }

    private fun isBypassActive(): Boolean {
        return try {
            val c = Class.forName("android.os.SystemProperties")
            val m = c.getMethod("get", String::class.java, String::class.java)
            val v = m.invoke(null, "sys.perfmtk.charge_bypass", "0") as String
            v == "1"
        } catch (e: Exception) {
            try {
                val process = Runtime.getRuntime().exec(arrayOf("getprop", "sys.perfmtk.charge_bypass"))
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val line = reader.readLine()?.trim()
                reader.close()
                process.waitFor()
                line == "1"
            } catch (ex: Exception) {
                false
            }
        }
    }

    private fun toggleBypass(enable: Boolean) {
        Thread {
            val arg = if (enable) "on" else "off"
            var socketSuccess = false
            try {
                val socket = LocalSocket()
                socket.soTimeout = 1500
                socket.connect(LocalSocketAddress("perfmtkd_ctrl", LocalSocketAddress.Namespace.ABSTRACT))
                val writer = OutputStreamWriter(socket.outputStream)
                writer.write("CHARGE_BYPASS $arg\n")
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
                    val p = Runtime.getRuntime().exec(arrayOf("su", "-c", "/data/adb/modules/perfmtk/system/bin/perfmtk -c $arg"))
                    p.waitFor()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    private fun updateTileState(overrideActive: Boolean? = null) {
        val tile = qsTile ?: return
        val active = overrideActive ?: isBypassActive()

        tile.label = "Charge Bypass"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = if (active) "Bypass Activo" else "Estándar"
        }

        tile.state = if (active) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.updateTile()
    }
}
