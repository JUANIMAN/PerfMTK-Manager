import 'package:manager/data/models/profile.dart';

enum ThermalState {
  enabled('enabled'),
  disabled('disabled');

  const ThermalState(this.value);
  final String value;

  static ThermalState fromString(String value) {
    return ThermalState.values
        .firstWhere((state) => state.value == value,
        orElse: () => ThermalState.enabled);
  }
}

class SystemState {
  final ProfileType currentProfile;
  final ThermalState thermalState;

  const SystemState({
    required this.currentProfile,
    required this.thermalState,
  });

  SystemState copyWith({
    ProfileType? currentProfile,
    ThermalState? thermalState,
  }) {
    return SystemState(
      currentProfile: currentProfile ?? this.currentProfile,
      thermalState: thermalState ?? this.thermalState,
    );
  }
}