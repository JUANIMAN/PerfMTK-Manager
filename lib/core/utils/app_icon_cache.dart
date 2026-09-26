import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';

class _IconRequest {
  final String packageName;
  final Completer<Uint8List?> completer;

  _IconRequest(this.packageName, this.completer);
}

/// Ultra-fast in-memory cache for app icons backed by native background loading.
/// Eliminates UI-thread blocking and ZIP file scanning for smooth 120Hz scrolling.
class AppIconCache {
  AppIconCache._();
  static final AppIconCache instance = AppIconCache._();

  static const MethodChannel _channel = MethodChannel('com.perfmtk.manager/apps');

  static const int _maxConcurrent = 4;
  static const int _maxQueueSize = 40;

  final Map<String, Uint8List?> _cache = {};
  final Map<String, Completer<Uint8List?>> _activeCompleters = {};
  final ListQueue<_IconRequest> _queue = ListQueue<_IconRequest>();
  int _runningCount = 0;

  Uint8List? getCached(String packageName) => _cache[packageName];

  bool isCached(String packageName) => _cache.containsKey(packageName);

  /// Seeds or updates the cache with a known icon (e.g. from initial preload).
  void putCached(String packageName, Uint8List icon) {
    _cache[packageName] = icon;
    final c = _activeCompleters.remove(packageName);
    if (c != null && !c.isCompleted) {
      c.complete(icon);
    }
  }

  /// Preloads a list of packages in chunks natively on background worker threads.
  Future<void> preloadBatch(List<String> packageNames, {int chunkSize = 35}) async {
    for (var i = 0; i < packageNames.length; i += chunkSize) {
      final end = (i + chunkSize < packageNames.length) ? i + chunkSize : packageNames.length;
      final chunk = packageNames.sublist(i, end);
      final needed = chunk.where((p) => !_cache.containsKey(p)).toList();
      if (needed.isEmpty) continue;

      try {
        final result = await _channel.invokeMethod<Map<Object?, Object?>>(
          'getAppIconsBatch',
          {'packageNames': needed},
        );
        if (result != null) {
          result.forEach((key, val) {
            if (key is String && val is Uint8List) {
              _cache[key] = val;
              final c = _activeCompleters.remove(key);
              if (c != null && !c.isCompleted) {
                c.complete(val);
              }
            }
          });
        }
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  /// Loads an icon on-demand with LIFO prioritization during scrolling.
  Future<Uint8List?> loadIcon(String packageName) {
    if (_cache.containsKey(packageName)) {
      return Future.value(_cache[packageName]);
    }

    if (_activeCompleters.containsKey(packageName)) {
      return _activeCompleters[packageName]!.future;
    }

    final completer = Completer<Uint8List?>();
    _activeCompleters[packageName] = completer;

    // Prune tail if queue exceeded capacity during fast scrolling fling
    if (_queue.length >= _maxQueueSize) {
      final dropped = _queue.removeLast();
      _activeCompleters.remove(dropped.packageName);
      if (!dropped.completer.isCompleted) {
        dropped.completer.complete(null);
      }
    }

    // Add to front (LIFO) so currently visible viewport items are prioritized
    _queue.addFirst(_IconRequest(packageName, completer));
    _processNext();

    return completer.future;
  }

  /// Warm up the icon cache for a subset of packages
  void warmup(Iterable<String> packageNames) {
    final needed = packageNames.where((p) => !_cache.containsKey(p) && !_activeCompleters.containsKey(p)).toList();
    if (needed.isNotEmpty) {
      preloadBatch(needed);
    }
  }

  void _processNext() {
    while (_runningCount < _maxConcurrent && _queue.isNotEmpty) {
      final request = _queue.removeFirst();
      final pkg = request.packageName;

      if (_cache.containsKey(pkg)) {
        _activeCompleters.remove(pkg);
        if (!request.completer.isCompleted) {
          request.completer.complete(_cache[pkg]);
        }
        continue;
      }

      _runningCount++;
      _fetchNativeIcon(pkg).then((icon) {
        _cache[pkg] = icon;
        if (!request.completer.isCompleted) {
          request.completer.complete(icon);
        }
      }).catchError((_) {
        _cache[pkg] = null;
        if (!request.completer.isCompleted) {
          request.completer.complete(null);
        }
      }).whenComplete(() {
        _runningCount--;
        _activeCompleters.remove(pkg);
        _processNext();
      });
    }
  }

  Future<Uint8List?> _fetchNativeIcon(String packageName) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'getAppIcon',
        {'packageName': packageName},
      );
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _cache.clear();
    for (final req in _queue) {
      if (!req.completer.isCompleted) {
        req.completer.complete(null);
      }
    }
    _queue.clear();
    _activeCompleters.clear();
    _runningCount = 0;
    try {
      await _channel.invokeMethod('clearIconCache');
    } catch (_) {}
  }
}
