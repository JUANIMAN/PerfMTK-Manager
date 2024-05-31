mixin AppLocale {
  static const String profiles = 'profiles';
  static const String thermal = 'thermal';
  static const String titleProfiles = 'titleProfiles';
  static const String currentProfile = 'currentProfile';
  static const String performance = 'performance';
  static const String balanced = 'balanced';
  static const String powerSave = 'powerSave';
  static const String titleThermal = 'titleThermal';
  static const String thermalState = 'thermalState';
  static const String enable = 'enable';
  static const String disable = 'disable';

  static const Map<String, dynamic> EN = {
    profiles: 'Profiles',
    thermal: 'Thermal',
    titleProfiles: 'Power Profiles',
    currentProfile: 'Current profile',
    performance: 'Performance',
    balanced: 'Balanced',
    powerSave: 'Power save',
    titleThermal: 'Thermal Management',
    thermalState: 'Thermal throttling',
    enable: 'Enable thermal throttling',
    disable: 'Disable thermal throttling'
  };

  static const Map<String, dynamic> ES = {
    profiles: 'Perfiles',
    thermal: 'Termal',
    titleProfiles: 'Perfiles de Energía',
    currentProfile: 'Perfil actual',
    performance: 'Alto Rendimiento',
    balanced: 'Equilibrado',
    powerSave: 'Ahorro de energía',
    titleThermal: 'Gertión Térmica',
    thermalState: 'Limitación térmica',
    enable: 'Activar limitación térmica',
    disable: 'Desactivar limitación térmica'
  };
}
