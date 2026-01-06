enum ProfileType {
  performance('performance'),
  balanced('balanced'),
  powersave('powersave'),
  powersavePlus('powersave+');

  const ProfileType(this.value);
  final String value;

  static ProfileType fromString(String value) {
    return ProfileType.values.firstWhere((profile) => profile.value == value,
        orElse: () => ProfileType.balanced);
  }

  String get displayName {
    switch (this) {
      case ProfileType.performance:
        return 'Performance';
      case ProfileType.balanced:
        return 'Balanced';
      case ProfileType.powersave:
        return 'Power Save';
      case ProfileType.powersavePlus:
        return 'Power Save+';
    }
  }
}
