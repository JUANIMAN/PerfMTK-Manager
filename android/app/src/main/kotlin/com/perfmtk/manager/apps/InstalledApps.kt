package com.perfmtk.manager.apps

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo

/** Launchable apps with the first screenful of icons preloaded. */
class InstalledApps(private val context: Context, private val icons: IconStore) {

    fun list(excludeSystemApps: Boolean): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val launchable = HashSet<String>(resolveInfos.size)
        for (info in resolveInfos) {
            info.activityInfo?.packageName?.let { launchable.add(it) }
        }

        val result = ArrayList<HashMap<String, Any?>>()
        val seen = HashSet<String>()

        for (pkg in pm.getInstalledPackages(0)) {
            val appInfo = pkg.applicationInfo ?: continue
            val pkgName = pkg.packageName ?: continue
            if (!launchable.contains(pkgName)) continue
            if (!seen.add(pkgName)) continue

            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            if (excludeSystemApps && isSystem) continue

            result.add(
                hashMapOf(
                    "name" to pm.getApplicationLabel(appInfo).toString(),
                    "package_name" to pkgName,
                    "is_system_app" to isSystem,
                    "version_name" to (pkg.versionName ?: "1.0.0"),
                ),
            )
        }

        // Sorted so the preloaded viewport matches the display order.
        result.sortBy { (it["name"] as? String)?.lowercase() ?: "" }

        for (i in 0 until minOf(result.size, PRELOAD_LIMIT)) {
            val pkg = result[i]["package_name"] as? String ?: continue
            icons.load(pkg)?.let { result[i]["icon"] = it }
        }
        return result
    }

    private companion object {
        const val PRELOAD_LIMIT = 25
    }
}
