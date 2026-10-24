import 'dart:async';

import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/utils/app_icon_cache.dart';

/// Ultra-fast native service for querying installed apps and icons.
/// Completely avoids opening or scanning APK ZIP files on the UI thread.
class AppNativeService {
  static const String _tag = 'AppNativeService';
  static const MethodChannel _channel = MethodChannel('com.perfmtk.manager/apps');

  final AppIconCache _iconCache;

  const AppNativeService({required AppIconCache iconCache})
    : _iconCache = iconCache;

  /// Fetches launchable installed apps directly from Android PackageManager on
  /// a worker thread, seeds the icon cache with the icons that came along and
  /// warms the remaining ones in the background.
  Future<List<AppInfo>> loadInstalledApps({
    required bool includeSystemApps,
  }) async {
    final apps = await getInstalledApps(excludeSystemApps: !includeSystemApps);

    for (final app in apps) {
      final icon = app.icon;
      if (icon != null) _iconCache.putCached(app.packageName, icon);
    }
    unawaited(_iconCache.preloadBatch(apps.map((a) => a.packageName).toList()));

    return apps;
  }

  /// Raw native query (no cache side effects). Empty list on failure.
  Future<List<AppInfo>> getInstalledApps({
    bool excludeSystemApps = true,
  }) async {
    try {
      final rawList = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
        {'excludeSystemApps': excludeSystemApps},
      );
      if (rawList == null) return [];
      return AppInfo.parseList(rawList);
    } on Exception catch (e) {
      AppLogger.warn(_tag, 'getInstalledApps failed', e);
      return [];
    }
  }
}
