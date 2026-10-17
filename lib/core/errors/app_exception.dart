/// Single exception hierarchy for every recoverable failure raised by the
/// data/platform layers. UI code can `catch (AppException)` and surface
/// [message] instead of matching feature-specific types.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// The persistent root shell failed, timed out or exited non-zero.
class RootShellException extends AppException {
  const RootShellException(super.message);
}

/// A PerfMTK daemon/CLI command failed.
class SystemCommandException extends AppException {
  const SystemCommandException(super.message);
}

/// `app_profiles.conf` could not be read.
class ConfigReadException extends AppException {
  const ConfigReadException(super.message);
}

/// `app_profiles.conf` could not be written.
class ConfigWriteException extends AppException {
  const ConfigWriteException(super.message);
}

/// Hardware or profile `.conf` files could not be read or written.
class PerfConfigException extends AppException {
  const PerfConfigException(super.message);
}

/// Backup listing/creation/restoration failed.
class BackupException extends AppException {
  const BackupException(super.message);
}
