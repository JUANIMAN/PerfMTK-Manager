import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';

/// Ultra-fast native service for querying installed apps and icons.
/// Completely avoids opening or scanning APK ZIP files on the UI thread.
class AppNativeService {
  static const MethodChannel _channel = MethodChannel('com.perfmtk.manager/apps');

  /// Fetches launchable installed apps directly from Android PackageManager on a worker thread.
  static Future<List<AppInfo>> getInstalledApps({
    bool excludeSystemApps = true,
  }) async {
    try {
      final List<dynamic>? rawList = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
        {'excludeSystemApps': excludeSystemApps},
      );
      if (rawList == null) return [];
      return AppInfo.parseList(rawList);
    } catch (_) {
      return [];
    }
  }
}
