/// Filesystem locations owned by the PerfMTK Magisk/KernelSU module.
abstract final class PerfMtkPaths {
  static const String moduleDir = '/data/adb/modules/perfmtk';
  static const String configDir = '$moduleDir/config';
  static const String deviceConf = '$configDir/device.conf';
  static const String profilesDir = '$configDir/profiles';
  static const String backupsDir = '$configDir/backups';
  static const String appProfilesConf = '$configDir/app_profiles.conf';
  static const String appProfilesFallbackConf = '/data/local/app_profiles.conf';
  static const String binary = '$moduleDir/system/bin/perfmtk';

  static String profileConf(String profileName) =>
      '$profilesDir/$profileName.conf';
}

/// Shell snippets for invoking the `perfmtk` CLI across the install layouts
/// found in the wild (Magisk module, KernelSU bin, PATH).
abstract final class PerfMtkShell {
  static const List<String> _binaries = [
    PerfMtkPaths.binary,
    '${PerfMtkPaths.moduleDir}/perfmtk',
    '/data/adb/ksu/bin/perfmtk',
    'perfmtk',
  ];

  /// `a --args || b --args || …` — first binary that succeeds wins.
  static String cliChain(String args, {bool lenient = false}) {
    final chain = _binaries.map((bin) => '$bin $args').join(' || ');
    return lenient ? '$chain || true' : chain;
  }

  /// Asks the daemon to re-read configuration files; never fails.
  static String get reload => '(${cliChain('--reload', lenient: true)})';

  /// Quotes [value] for safe use inside a double-quoted `su` shell command.
  static String quote(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll(r'$', r'\$')
        .replaceAll(String.fromCharCode(96), r'\`');
    return '"$escaped"';
  }
}
