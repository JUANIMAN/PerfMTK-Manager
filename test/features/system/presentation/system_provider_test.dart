import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/features/app_profiles/data/config_repository.dart';
import 'package:manager/features/system/data/system_repository.dart';
import 'package:manager/features/system/data/telemetry_stream_service.dart';
import 'package:manager/features/app_profiles/presentation/config_repository_provider.dart';
import 'package:manager/features/system/presentation/system_provider.dart';

import '../../../support/fakes.dart';

class _FakeTelemetry extends TelemetryStreamService {
  final StreamController<SystemState> controller =
      StreamController<SystemState>.broadcast();

  _FakeTelemetry() : super(ipcChannel: FakeNativeIpc());

  @override
  Stream<SystemState> get stream => controller.stream;

  @override
  Future<void> start() async {}

  @override
  void dispose() => controller.close();
}

class _FakeSystemRepository implements SystemRepository {
  SystemState snapshot = const SystemState(
    currentProfile: ProfileType.balanced,
    thermalState: ThermalState.enabled,
  );
  Completer<void>? gate;
  Object? failWith;

  Future<void> _maybeBlock() async {
    await gate?.future;
    if (failWith != null) throw failWith!;
  }

  @override
  Future<SystemState> getSystemState() async => snapshot;

  @override
  Future<void> setProfile(ProfileType profile) => _maybeBlock();

  @override
  Future<void> setThermal(ThermalState thermalState) => _maybeBlock();

  @override
  Future<void> setChargeBypass(bool enabled) => _maybeBlock();

  @override
  Future<void> setBatteryCare(bool enabled, int limitPct) => _maybeBlock();

  @override
  Future<void> setChargeCurrentLimit(int ma) => _maybeBlock();

  @override
  Future<ProfileType> getCurrentProfile() async => snapshot.currentProfile;

  @override
  Future<ThermalState> getCurrentThermal() async => snapshot.thermalState;
}

class _FakeConfigRepository implements ConfigRepository {
  @override
  Future<bool> configExists() async => false;

  @override
  Future<ConfigData> loadConfig() async => ConfigData.empty();

  @override
  Future<void> saveConfig(
    Map<String, AppProfileEntryData> entries,
    ProfileType defaultProfile,
    ProfileType screenOffProfile,
    int appDebounceMs,
  ) async {}

  @override
  Future<bool> updateDefaultProfile(ProfileType profile) async => true;

  @override
  Future<void> deleteConfig() async {}
}

void main() {
  late _FakeTelemetry telemetry;
  late _FakeSystemRepository repo;
  late ProviderContainer container;

  setUp(() async {
    telemetry = _FakeTelemetry();
    repo = _FakeSystemRepository();
    container = ProviderContainer(
      overrides: [
        telemetryStreamServiceProvider.overrideWithValue(telemetry),
        systemRepositoryProvider.overrideWithValue(repo),
        configRepositoryProvider.overrideWithValue(_FakeConfigRepository()),
        systemSettleGraceProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    await container.read(systemStateProvider.future);
  });

  SystemState current() => container.read(systemStateProvider).requireValue;
  SystemStateNotifier notifier() =>
      container.read(systemStateProvider.notifier);

  test('applies the change optimistically and marks the action pending',
      () async {
    repo.gate = Completer<void>();

    final future = notifier().setProfile(ProfileType.performance);
    await Future<void>.delayed(Duration.zero);

    expect(current().currentProfile, ProfileType.performance);
    expect(container.read(isChangingProfileProvider), isTrue);

    repo.gate!.complete();
    await future;

    expect(container.read(isChangingProfileProvider), isFalse);
  });

  test('rolls back and rethrows when the action fails', () async {
    repo.failWith = StateError('boom');

    await expectLater(
      notifier().setChargeBypass(true),
      throwsA(isA<StateError>()),
    );

    expect(current().chargeBypass, isFalse);
    expect(container.read(isChangingChargeBypassProvider), isFalse);
  });

  test('a telemetry tick cannot overwrite an in-flight change', () async {
    repo.gate = Completer<void>();

    final future = notifier().setProfile(ProfileType.performance);
    await Future<void>.delayed(Duration.zero);

    telemetry.controller.add(
      const SystemState(
        currentProfile: ProfileType.balanced,
        thermalState: ThermalState.enabled,
        batteryCapacityPct: 55,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(current().currentProfile, ProfileType.performance);
    expect(current().batteryCapacityPct, 55, reason: 'other fields still live');

    repo.gate!.complete();
    await future;
  });

  test('once settled, the daemon snapshot wins again', () async {
    await notifier().setProfile(ProfileType.performance);

    telemetry.controller.add(
      const SystemState(
        currentProfile: ProfileType.powersave,
        thermalState: ThermalState.enabled,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(current().currentProfile, ProfileType.powersave);
  });

  test('refresh keeps the current value and never emits a loading state',
      () async {
    final seen = <AsyncValue<SystemState>>[];
    container.listen(systemStateProvider, (_, next) => seen.add(next));

    repo.snapshot = const SystemState(
      currentProfile: ProfileType.powersave,
      thermalState: ThermalState.enabled,
    );
    await notifier().refresh();

    expect(seen.any((s) => s.isLoading), isFalse);
    expect(current().currentProfile, ProfileType.powersave);
  });

  test('overlapping actions keep the flag until the last one finishes',
      () async {
    final first = Completer<void>();
    repo.gate = first;

    final a = notifier().setBatteryCare(true, 80);
    final b = notifier().setBatteryCare(true, 85);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(isChangingBatteryCareProvider), isTrue);

    first.complete();
    await Future.wait([a, b]);
    expect(container.read(isChangingBatteryCareProvider), isFalse);
  });
}
