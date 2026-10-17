import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/utils/app_icon_cache.dart';
import 'package:manager/data/services/app_native_service.dart';

/// Process-wide cache of launcher icons.
final appIconCacheProvider = Provider<AppIconCache>(
  (ref) => AppIconCache.instance,
);

/// Native PackageManager access for installed apps and their icons.
final appNativeServiceProvider = Provider<AppNativeService>(
  (ref) => AppNativeService(iconCache: ref.watch(appIconCacheProvider)),
);
