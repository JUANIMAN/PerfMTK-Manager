import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shell_provider.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/repositories/perf_config_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final perfConfigRepositoryProvider = Provider<PerfConfigRepository>((ref) {
  return PerfConfigRepository(
    shellManager: ref.watch(shellExecutorProvider),
  );
});

// ── Device config ─────────────────────────────────────────────────────────────

final deviceConfigProvider = FutureProvider<DeviceConfig>((ref) async {
  return ref.read(perfConfigRepositoryProvider).loadDeviceConfig();
});

// ── Profile config (loaded from disk) ────────────────────────────────────────

final profileConfigProvider = FutureProvider.family<ProfileConfig, ProfileType>(
  (ref, profile) async {
    // Profile parsing depends on GPU units and driver type from device.conf.
    await ref.watch(deviceConfigProvider.future);
    return ref.read(perfConfigRepositoryProvider).loadProfileConfig(profile);
  },
);

// ── Editor state ──────────────────────────────────────────────────────────────

class ProfileEditorState {
  final ProfileConfig? config;
  final bool isDirty;
  final bool isSaving;
  final String? errorMessage;

  const ProfileEditorState({
    this.config,
    this.isDirty = false,
    this.isSaving = false,
    this.errorMessage,
  });

  ProfileEditorState copyWith({
    ProfileConfig? config,
    bool? isDirty,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileEditorState(
      config: config ?? this.config,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileEditorNotifier extends Notifier<ProfileEditorState> {
  final ProfileType profile;
  ProfileEditorNotifier(this.profile);

  @override
  ProfileEditorState build() {
    return const ProfileEditorState();
  }

  /// Called once when the profile is first loaded from disk.
  void initialize(ProfileConfig config) {
    if (state.config == null) {
      state = ProfileEditorState(config: config);
    }
  }

  /// Replace the entire in-memory config and mark as dirty.
  void update(ProfileConfig newConfig) {
    state = state.copyWith(config: newConfig, isDirty: true);
  }

  /// Persist current state to disk.
  Future<bool> save() async {
    final config = state.config;
    if (config == null || state.isSaving) return false;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(perfConfigRepositoryProvider)
          .saveProfileConfig(profile, config);
      state = state.copyWith(isSaving: false, isDirty: false);
      // Invalidate so the next read picks up the fresh file.
      ref.invalidate(profileConfigProvider(profile));
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Discard in-memory changes and reset to the last saved state.
  void revert(ProfileConfig savedConfig) {
    state = ProfileEditorState(config: savedConfig);
  }
}

final profileEditorProvider =
    NotifierProvider.family<
      ProfileEditorNotifier,
      ProfileEditorState,
      ProfileType
    >((profile) => ProfileEditorNotifier(profile));
