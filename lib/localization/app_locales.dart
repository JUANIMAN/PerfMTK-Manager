mixin AppLocale {
  static const String profiles = 'profiles';
  static const String thermal = 'thermal';
  static const String titleProfiles = 'titleProfiles';
  static const String currentProfile = 'currentProfile';
  static const String changeProfile = 'changeProfile';
  static const String performance = 'performance';
  static const String balanced = 'balanced';
  static const String powersave = 'powersave';
  static const String powersavePlus = 'powersave+';
  static const String performanceDsc = 'performanceDsc';
  static const String balancedDsc = 'balancedDsc';
  static const String powersaveDsc = 'powersaveDsc';
  static const String powersavePlusDsc = 'powersavePlusDsc';
  static const String performanceCard = 'performanceCard';
  static const String balancedCard = 'balancedCard';
  static const String powersaveCard = 'powersaveCard';
  static const String powersavePlusCard = 'powersavePlusCard';
  static const String titleThermal = 'titleThermal';
  static const String thermalState = 'thermalState';
  static const String thermalControl = 'thermalControl';
  static const String enabled = 'enabled';
  static const String disabled = 'disabled';
  static const String enable = 'enable';
  static const String disable = 'disable';
  static const String enableDsc = 'enableSub';
  static const String disableDsc = 'disableSub';
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
    powersave: 'Power Saver',
    powersavePlus: 'Ultra Power Saver',
    performanceCard: 'Maximum performance.',
    balancedCard: 'Good performance.',
    powersaveCard: 'Saves battery.',
    powersavePlusCard: 'Maximizes battery life.',
    performanceDsc: 'Unleashes maximum power for demanding tasks and benchmarks.',
    balancedDsc: 'Optimized for smooth gaming and daily tasks with improved efficiency.',
    powersaveDsc: 'Focuses on conserving battery by lowering performance, ideal for standard use.',
    powersavePlusDsc: 'Extends battery life to the fullest by minimizing system resources.',
    titleThermal: 'Thermal management',
    thermalState: 'Thermal throttling',
    thermalControl: 'Thermal Control',
    enabled: 'Enabled',
    disabled: 'Disabled',
    enable: 'Enable',
    disable: 'Disable',
    enableDsc: 'Enable temperature control; it is recommended to keep it activated',
    disableDsc: 'Disable temperature control; there may be no performance improvement',
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
    balanced: 'Equilibrado',
    powersave: 'Ahorro de energía',
    powersavePlus: 'Ahorro máximo de energía',
    performanceCard: 'Máximo rendimiento.',
    balancedCard: 'Buen rendimiento.',
    powersaveCard: 'Ahorra batería.',
    powersavePlusCard: 'Maximiza la vida de tu batería.',
    performanceDsc: 'Libera el máximo poder para tareas exigentes y benchmarks.',
    balancedDsc: 'Optimizado para un rendimiento fluido en juegos y tareas diarias con mayor eficiencia.',
    powersaveDsc: 'Se centra en conservar batería reduciendo el rendimiento, ideal para uso estándar.',
    powersavePlusDsc: 'Maximiza la duración de la batería minimizando los recursos del sistema.',
    titleThermal: 'Gestión térmica',
    thermalState: 'Limitación térmica',
    thermalControl: 'Control Térmico',
    enabled: 'Activada',
    disabled: 'Desactivada',
    enable: 'Activar',
    disable: 'Desactivar',
    enableDsc: 'Activa el control de temperatura; se recomienda mantenerlo activado',
    disableDsc: 'Desactiva el control de temperatura; es posible que no haya mejora en el rendimiento',
    snackBarText: 'Instale la última versión del módulo.',
    snackBarLabel: 'Descargar',
    downloadMess: 'No se pudo abrir el enlace de descarga.'
  };

  static String getValue(String key) {
    return key;
  }
}
