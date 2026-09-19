import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/root_shell_manager.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/repositories/config_repository.dart';

void main() {
  test('a stale app save cannot overwrite a newer global profile', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'perfmtk_config_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final shell = _FakeConfigShell('''
DEFAULT_PROFILE=balanced
SCREEN_OFF_PROFILE=powersave
APP_DEBOUNCE_MS=3000

com.example.existing=powersave
''');
    final repository = ConfigRepositoryImpl(
      shellManager: shell,
      getTempDirectory: () async => tempDirectory,
    );

    final globalUpdate = repository.updateDefaultProfile(
      ProfileType.performance,
    );
    final staleAppSave = repository.saveConfig(
      {
        'com.example.existing': const AppProfileEntryData(
          profile: ProfileType.powersave,
        ),
        'com.example.new': const AppProfileEntryData(
          profile: ProfileType.balanced,
        ),
      },
      ProfileType.balanced,
      ProfileType.powersave,
      3000,
    );

    await Future.wait([globalUpdate, staleAppSave]);

    expect(shell.content, contains('DEFAULT_PROFILE=performance'));
    expect(shell.content, isNot(contains('DEFAULT_PROFILE=balanced')));
    expect(shell.content, contains('com.example.new=balanced'));
  });

  test('parses and preserves app directives properly', () async {
    final shell = _FakeConfigShell('''
DEFAULT_PROFILE=balanced
SCREEN_OFF_PROFILE=powersave
APP_DEBOUNCE_MS=3000

com.kurogame.wutheringwaves=performance;gbe=1;charge_bypass=on;gentle_charge=500;render_boost=1;fps=120;thermal=off;touch=game
com.whatsapp=powersave;uclamp_max=40
''');
    final tempDirectory = await Directory.systemTemp.createTemp(
      'perfmtk_directives_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final repository = ConfigRepositoryImpl(
      shellManager: shell,
      getTempDirectory: () async => tempDirectory,
    );

    final config = await repository.loadConfig();
    final wuwa = config.entries['com.kurogame.wutheringwaves'];
    expect(wuwa, isNotNull);
    expect(wuwa!.profile, ProfileType.performance);
    expect(wuwa.directives.gbe, 1);
    expect(wuwa.directives.chargeBypass, isTrue);
    expect(wuwa.directives.gentleCharge, 500);
    expect(wuwa.directives.renderBoost, 1);
    expect(wuwa.directives.fps, 120);
    expect(wuwa.directives.disableThermal, isTrue);
    expect(wuwa.directives.touchGameMode, isTrue);

    final whatsapp = config.entries['com.whatsapp'];
    expect(whatsapp, isNotNull);
    expect(whatsapp!.profile, ProfileType.powersave);
    expect(whatsapp.directives.uclampMax, 40);

    // Verify serialization preserves all directives
    await repository.saveConfig(
      config.entries,
      config.defaultProfile,
      config.screenOffProfile,
      config.appDebounceMs,
    );
    expect(shell.content, contains('gentle_charge=500'));
    expect(shell.content, contains('render_boost=1'));
    expect(shell.content, contains('fps=120'));
    expect(shell.content, contains('thermal=off'));
    expect(shell.content, contains('touch=game'));
  });
}

class _FakeConfigShell implements ShellCommandExecutor {
  String content;
  bool exists = true;

  _FakeConfigShell(this.content);

  @override
  Future<void> initialize() async {}

  @override
  Future<String> executeCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (command.startsWith('test -f ')) {
      return exists ? 'exists' : 'not_exists';
    }
    if (command.startsWith('cat ')) return content;
    if (command.startsWith('rm -f ')) {
      exists = false;
      content = '';
      return '';
    }
    if (command.startsWith('cp ')) {
      final match = RegExp(r'^cp "([^"]+)"').firstMatch(command);
      if (match == null) throw StateError('Missing source path: $command');

      final sourcePath = match
          .group(1)!
          .replaceAll(r'\\', String.fromCharCode(92));
      content = await File(sourcePath).readAsString();
      exists = true;
      return '';
    }
    throw UnsupportedError('Unexpected command: $command');
  }
}
