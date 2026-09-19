import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:installed_apps/installed_apps.dart';

class _IconRequest {
  final String packageName;
  final Completer<Uint8List?> completer;

  _IconRequest(this.packageName, this.completer);
}

/// High-performance in-memory cache for app icons with throttled concurrency
/// and LIFO prioritization to ensure smooth 120Hz scrolling.
class AppIconCache {
  AppIconCache._();
  static final AppIconCache instance = AppIconCache._();

  static const int _maxConcurrent = 4;
  static const int _maxQueueSize = 40;

  final Map<String, Uint8List?> _cache = {};
  final Map<String, Completer<Uint8List?>> _activeCompleters = {};
  final ListQueue<_IconRequest> _queue = ListQueue<_IconRequest>();
  int _runningCount = 0;

  Uint8List? getCached(String packageName) => _cache[packageName];

  bool isCached(String packageName) => _cache.containsKey(packageName);

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

  /// Warm up the icon cache for a subset of packages (e.g. first 20 items)
  void warmup(Iterable<String> packageNames) {
    for (final pkg in packageNames) {
      if (!_cache.containsKey(pkg) && !_activeCompleters.containsKey(pkg)) {
        loadIcon(pkg);
      }
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
      InstalledApps.getAppInfo(pkg).then((info) {
        final icon = info?.icon;
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

  void clear() {
    _cache.clear();
    for (final req in _queue) {
      if (!req.completer.isCompleted) {
        req.completer.complete(null);
      }
    }
    _queue.clear();
    _activeCompleters.clear();
    _runningCount = 0;
  }
}
