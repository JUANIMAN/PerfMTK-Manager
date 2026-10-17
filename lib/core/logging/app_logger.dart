import 'dart:developer' as developer;

/// Minimal structured logger. Uses `dart:developer` so output shows up in
/// DevTools / `adb logcat` without tripping the `avoid_print` lint.
abstract final class AppLogger {
  static const int _levelDebug = 500;
  static const int _levelWarning = 900;
  static const int _levelError = 1000;

  static void debug(String tag, String message) =>
      developer.log(message, name: 'PerfMTK/$tag', level: _levelDebug);

  static void warn(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) => developer.log(
    message,
    name: 'PerfMTK/$tag',
    level: _levelWarning,
    error: error,
    stackTrace: stackTrace,
  );

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) => developer.log(
    message,
    name: 'PerfMTK/$tag',
    level: _levelError,
    error: error,
    stackTrace: stackTrace,
  );
}
