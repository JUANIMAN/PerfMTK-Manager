mixin AppLocale {
  static const String profiles = 'profiles';
  static const String thermal = 'thermal';
  static const String titleProfiles = 'titleProfiles';
  static const String subtitleProfiles = "subtitleProfiles";
  static const String currentProfile = 'currentProfile';
  static const String defaultProfile = 'defaultProfile';
  static const String performance = 'performance';
  static const String balanced = 'balanced';
  static const String powersave = 'powersave';
  static const String powersavePlus = 'powersave+';
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
  static const String updateMess = 'updateMess';
  static const String updateNew = 'updateNew';
  static const String updateCancel = 'updateCancel';
  static const String updateDown = 'updateDown';
  static const String settings = 'settings';
  static const String appearance = 'appearance';
  static const String language = 'language';
  static const String profileSettings = 'profileSettings';
  static const String about = 'about';
  static const String themeMode = 'themeMode';
  static const String themeSystem = 'themeSystem';
  static const String themeLight = 'themeLight';
  static const String themeDark = 'themeDark';
  static const String selectTheme = 'selectTheme';
  static const String selectLanguage = 'selectLanguage';
  static const String lockFreq = 'autoProfileSwitch';
  static const String lockFreqDescription = 'autoProfileDescription';
  static const String defaultProfileDescription = 'defaultProfileDescription';
  static const String aboutDescription = 'aboutDescription';
  static const String back = 'back';
  static const String developer = 'developer';
  static const String compDevices = 'compDevices';
  static const String appProfiles = 'appProfiles';
  static const String titleAppProfiles = 'titleAppProfiles';
  static const String searchApps = 'searchApps';
  static const String noAppsFound = 'noAppsFound';
  static const String appProfilesDescription = 'appProfilesDescription';
  static const String allApps = 'allApps';
  static const String configuredApps = 'configuredApps';
  static const String notConfiguredApps = 'notConfiguredApps';
  static const String noSearchResults = 'noSearchResults';
  static const String clearSearch = 'clearSearch';
  static const String errorLoadingApps = 'errorLoadingApps';
  static const String retry = 'retry';
  static const String profileSet = 'profileSet';
  static const String profileReset = 'profileReset';
  static const String undo = 'undo';
  static const String changeProfile = 'changeProfile';
  static const String selectProfile = 'selectProfile';

  // Profile descriptions
  static const String defaultProfileDesc = 'defaultProfileDesc';
  static const String performanceDesc = 'performanceDesc';
  static const String balancedDesc = 'balancedDesc';
  static const String powersaveDesc = 'powersaveDesc';
  static const String powersavePlusDesc = 'powersavePlusDesc';

  static const Map<String, dynamic> EN = {
    profiles: 'Profiles',
    thermal: 'Thermal',
    titleProfiles: 'Power profiles',
    subtitleProfiles: 'Global profiles',
    currentProfile: 'Current profile',
    defaultProfile: 'Default profile',
    performance: 'Performance',
    balanced: 'Balanced',
    powersave: 'Power Saver',
    powersavePlus: 'Ultra Power Saver',
    performanceCard: 'Maximum performance.',
    balancedCard: 'Good performance.',
    powersaveCard: 'Saves battery.',
    powersavePlusCard: 'Maximizes battery life.',
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
    downloadMess: 'Could not open download link.',
    updateMess: 'New update available',
    updateNew: 'What\'s new:',
    updateCancel: 'Later',
    updateDown: 'Download',
    settings: 'Settings',
    appearance: 'Appearance',
    language: 'Language',
    profileSettings: 'Profile Settings',
    about: 'About',
    themeMode: 'Theme Mode',
    themeSystem: 'System',
    themeLight: 'Light',
    themeDark: 'Dark',
    selectTheme: 'Select Theme',
    selectLanguage: 'Select Language',
    lockFreq: 'lock processor frequencies',
    lockFreqDescription: 'This setting only applies to the Performance profile.',
    defaultProfileDescription: 'Select the default profile to use when the app starts',
    aboutDescription: 'PerfMTK Manager is an app to manage your device\'s performance profiles and thermal settings.',
    back: 'Back',
    developer: 'Developer',
    compDevices: 'Compatible devices',
    appProfiles: 'App Profiles',
    titleAppProfiles: 'Application Profiles',
    searchApps: 'Search applications',
    noAppsFound: 'No applications found',
    appProfilesDescription: 'Configure performance profiles for individual apps',
    allApps: 'All Apps',
    configuredApps: 'Configured',
    notConfiguredApps: 'Not Configured',
    noSearchResults : 'No apps found for your search',
    clearSearch: 'Clear Search',
    errorLoadingApps: 'Error loading applications',
    retry: 'Retry',
    profileSet: 'Profile for {app} set to {profile}',
    profileReset: 'Default profile restored for {app}',
    undo: 'Undo',
    changeProfile: 'Change profile',
    selectProfile: 'Select performance profile',

    defaultProfileDesc: 'Use the global default profile setting',
    performanceDesc: 'Maximum CPU and GPU performance. Higher battery usage',
    balancedDesc: 'Balance between performance and battery life',
    powersaveDesc: 'Reduced performance for better battery life',
    powersavePlusDesc: 'Maximum battery savings with minimal performance',
  };

  static const Map<String, dynamic> ES = {
    profiles: 'Perfiles',
    thermal: 'Termal',
    titleProfiles: 'Perfiles de Energía',
    subtitleProfiles: 'Perfiles globales',
    currentProfile: 'Perfil actual',
    defaultProfile: 'Perfil predeterminado',
    performance: 'Alto rendimiento',
    balanced: 'Equilibrado',
    powersave: 'Ahorro de energía',
    powersavePlus: 'Ahorro máximo de energía',
    performanceCard: 'Máximo rendimiento.',
    balancedCard: 'Buen rendimiento.',
    powersaveCard: 'Ahorra batería.',
    powersavePlusCard: 'Maximiza la vida de tu batería.',
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
    downloadMess: 'No se pudo abrir el enlace de descarga.',
    updateMess: 'Nueva actualización disponible',
    updateNew: 'Novedades:',
    updateCancel: 'Más tarde',
    updateDown: 'Descargar',
    settings: 'Ajustes',
    appearance: 'Apariencia',
    language: 'Idioma',
    profileSettings: 'Ajustes de Perfil',
    about: 'Acerca de',
    themeMode: 'Tema',
    themeSystem: 'Sistema',
    themeLight: 'Claro',
    themeDark: 'Oscuro',
    selectTheme: 'Seleccionar Tema',
    selectLanguage: 'Seleccionar Idioma',
    lockFreq: 'Bloquear frecuencias de procesador',
    lockFreqDescription: 'Este ajuste solo se aplica al perfil de Rendimiento.',
    defaultProfileDescription: 'Selecciona el perfil predeterminado al iniciar la aplicación',
    aboutDescription: 'PerfMTK Manager es una aplicación para gestionar los perfiles de rendimiento y ajustes térmicos de tu dispositivo.',
    back: 'Regresar',
    developer: 'Desarrollador',
    compDevices: 'Dispositivos compatibles',
    appProfiles: 'Perfiles de Apps',
    titleAppProfiles: 'Perfiles de Aplicación',
    searchApps: 'Buscar aplicaciones',
    noAppsFound: 'No se encontraron aplicaciones',
    appProfilesDescription: 'Configura perfiles de rendimiento para aplicaciones individuales',
    allApps: 'Todas las Apps',
    configuredApps: 'Configuradas',
    notConfiguredApps: 'Sin Configurar',
    noSearchResults : 'No se encontraron apps para tu búsqueda',
    clearSearch: 'Limpiar Búsqueda',
    errorLoadingApps: 'Error al cargar aplicaciones',
    retry: 'Reintentar',
    profileSet: 'Perfil para {app} configurado a {profile}',
    profileReset: 'Perfil predeterminado restaurado para {app}',
    undo: 'Deshacer',
    changeProfile: 'Cambiar perfil',
    selectProfile: 'Seleccionar perfil de rendimiento',

    defaultProfileDesc: 'Usar la configuración predeterminada global',
    performanceDesc: 'Máximo rendimiento de CPU y GPU. Mayor consumo de batería',
    balancedDesc: 'Equilibrio entre rendimiento y duración de batería',
    powersaveDesc: 'Rendimiento reducido para mejor duración de batería',
    powersavePlusDesc: 'Máximo ahorro de batería con rendimiento mínimo',
  };

  static String getValue(String key) {
    return key;
  }
}
