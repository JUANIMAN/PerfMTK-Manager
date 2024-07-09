mixin AppLocale {
  static const String profiles = 'profiles';
  static const String thermal = 'thermal';
  static const String titleProfiles = 'titleProfiles';
  static const String currentProfile = 'currentProfile';
  static const String changeProfile = 'changeProfile';
  static const String performance = 'performance';
  static const String balanced = 'balanced';
  static const String powersave = 'powersave';
  static const String titleThermal = 'titleThermal';
  static const String thermalState = 'thermalState';
  static const String thermalControl = 'thermalControl';
  static const String enabled = 'enabled';
  static const String disabled = 'disabled';
  static const String enable = 'enable';
  static const String disable = 'disable';
  static const String enableSub = 'enableSub';
  static const String disableSub = 'disableSub';
  static const String snackBarText = 'snackBarText';
  static const String snackBarLabel = 'snackBarLabel';
  static const String downloadMess = 'downloadMess';

  static const Map<String, dynamic> EN = {
    profiles: 'Profiles',
    thermal: 'Thermal',
    titleProfiles: 'Power profiles',
    currentProfile: 'Current profile',
    changeProfile: 'Change profile',
    performance: 'Performance',
    balanced: 'Balanced',
    powersave: 'Powersave',
    titleThermal: 'Thermal management',
    thermalState: 'Thermal throttling',
    thermalControl: 'Thermal Control',
    enabled: 'Enabled',
    disabled: 'Disabled',
    enable: 'Enable thermal throttling',
    disable: 'Disable thermal throttling',
    enableSub: 'Helps maintain performance depending on device temperature.',
    disableSub: 'Not recommended, may worsen performance on some devices.',
    snackBarText: 'Install the latest version of the module.',
    snackBarLabel: 'Download',
    downloadMess: 'Could not open download link.'
  };

  static const Map<String, dynamic> ES = {
    profiles: 'Perfiles',
    thermal: 'Termal',
    titleProfiles: 'Perfiles de Energía',
    currentProfile: 'Perfil actual',
    changeProfile: 'Cambiar perfil',
    performance: 'Alto rendimiento',
    balanced: 'Balanceado',
    powersave: 'Ahorro de batería',
    titleThermal: 'Gestión térmica',
    thermalState: 'Limitación térmica',
    thermalControl: 'Control Térmico',
    enabled: 'Activada',
    disabled: 'Desactivada',
    enable: 'Activar limitación térmica',
    disable: 'Desactivar limitación térmica',
    enableSub: 'Ayuda a mantener el rendimiento dependiendo de la temperatura del dispositivo.',
    disableSub: 'No recomendado, puede empeorar el rendimiento en algunos dispositivos.',
    snackBarText: 'Instale la última versión del módulo.',
    snackBarLabel: 'Descargar',
    downloadMess: 'No se pudo abrir el enlace de descarga.'
  };

  static String getValue(String key) {
    return key;
  }
}
