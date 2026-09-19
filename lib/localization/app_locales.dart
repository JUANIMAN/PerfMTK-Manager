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
  static const String profileApplied = 'profileApplied';
  static const String applying = 'applying';
  static const String includeSystemApps = 'includeSystemApps';
  static const String includeSystemAppsDesc = 'includeSystemAppsDesc';

  // Daemon settings
  static const String daemonSettings = 'daemonSettings';
  static const String screenOffProfile = 'screenOffProfile';
  static const String screenOffProfileDesc = 'screenOffProfileDesc';
  static const String appDebounceMs = 'appDebounceMs';
  static const String appDebounceMsDesc = 'appDebounceMsDesc';
  static const String milliseconds = 'milliseconds';

  // Perf config screen
  static const String perfConfig = 'perfConfig';
  static const String titlePerfConfig = 'titlePerfConfig';
  static const String perfConfigDescription = 'perfConfigDescription';
  static const String saveChanges = 'saveChanges';
  static const String configSaved = 'configSaved';
  static const String configSaveError = 'configSaveError';
  static const String savingConfig = 'savingConfig';
  static const String perfConfigError = 'perfConfigError';

  // Theme descriptions
  static const themeSystemDesc = 'themeSystemDesc';
  static const themeLightDesc = 'themeLightDesc';
  static const themeDarkDesc = 'themeDarkDesc';

  // Profile descriptions
  static const String defaultProfileDesc = 'defaultProfileDesc';
  static const String performanceDesc = 'performanceDesc';
  static const String balancedDesc = 'balancedDesc';
  static const String powersaveDesc = 'powersaveDesc';
  static const String powersavePlusDesc = 'powersavePlusDesc';

  // v16.0 Telemetry & Hardware
  static const String hardwareTelemetry = 'hardwareTelemetry';
  static const String activeEngine = 'activeEngine';
  static const String fgEnginePush = 'fgEnginePush';
  static const String fgEngineCgroup = 'fgEngineCgroup';
  static const String fgEnginePoller = 'fgEnginePoller';
  static const String dramFreq = 'dramFreq';
  static const String gpuFreq = 'gpuFreq';
  static const String cpuFreq = 'cpuFreq';
  static const String socTemp = 'socTemp';
  static const String batteryTemp = 'batteryTemp';

  // v16.0 Smart Fast Charge Bypass
  static const String chargeBypass = 'chargeBypass';
  static const String chargeBypassTitle = 'chargeBypassTitle';
  static const String chargeBypassDesc = 'chargeBypassDesc';
  static const String chargeBypassActive = 'chargeBypassActive';
  static const String chargeBypassInactive = 'chargeBypassInactive';
  static const String safetyGuardLimit = 'safetyGuardLimit';

  // v16.0 Knobs: UCLAMP, GBE, THERMAL_CHARGE
  static const String uclamp = 'uclamp';
  static const String uclampTitle = 'uclampTitle';
  static const String uclampTopAppMin = 'uclampTopAppMin';
  static const String uclampTopAppMax = 'uclampTopAppMax';
  static const String uclampFgMin = 'uclampFgMin';
  static const String uclampFgMax = 'uclampFgMax';
  static const String gbeTitle = 'gbeTitle';
  static const String gbeDesc = 'gbeDesc';
  static const String gbeEnable = 'gbeEnable';
  static const String gbeThermalHeadroom = 'gbeThermalHeadroom';
  static const String thermalChargeTitle = 'thermalChargeTitle';
  static const String unlockFpsThermal = 'unlockFpsThermal';
  static const String unlockFpsThermalDesc = 'unlockFpsThermalDesc';
  static const String bypassChargeThrottle = 'bypassChargeThrottle';
  static const String bypassChargeThrottleDesc = 'bypassChargeThrottleDesc';
  static const String batteryTempLimit = 'batteryTempLimit';
  static const String gameDirectives = 'gameDirectives';
  static const String dramFloor = 'dramFloor';

  // v16.1 Thermal Chart & Battery Care
  static const String thermalChartTitle = 'thermalChartTitle';
  static const String thermalChartSubtitle = 'thermalChartSubtitle';
  static const String socTempLabel = 'socTempLabel';
  static const String batteryTempLabel = 'batteryTempLabel';
  static const String batteryCareTitle = 'batteryCareTitle';
  static const String batteryCareDesc = 'batteryCareDesc';
  static const String batteryCareLimit = 'batteryCareLimit';
  static const String batteryCareSuspended = 'batteryCareSuspended';
  static const String batteryCareNormal = 'batteryCareNormal';

  // v16.2 HUD & Telemetry Console
  static const String switchProfileHeader = 'switchProfileHeader';
  static const String hardwareMonitorHeader = 'hardwareMonitorHeader';
  static const String siliconState = 'siliconState';
  static const String siliconStateSubtitle = 'siliconStateSubtitle';
  static const String liveBadge = 'liveBadge';
  static const String cpuClustersHeader = 'cpuClustersHeader';
  static const String gpuAndDramHeader = 'gpuAndDramHeader';
  static const String thermalAndPowerHeader = 'thermalAndPowerHeader';
  static const String socSilicon = 'socSilicon';
  static const String smartBypass = 'smartBypass';
  static const String powerRail = 'powerRail';
  static const String directSilicon = 'directSilicon';
  static const String cellIsolated = 'cellIsolated';
  static const String standardConsumption = 'standardConsumption';
  static const String batteryTempCell = 'batteryTempCell';
  static const String batteryPct = 'batteryPct';

  // v16.3 Hardware Profile Config & Directives Localization
  static const String minFreq = 'minFreq';
  static const String maxFreq = 'maxFreq';
  static const String governor = 'governor';
  static const String onlineCores = 'onlineCores';
  static const String freqMode = 'freqMode';
  static const String dvfsAuto = 'dvfsAuto';
  static const String fixedFreq = 'fixedFreq';
  static const String minFreqDram = 'minFreqDram';
  static const String ufsClkEnable = 'ufsClkEnable';
  static const String clockEnabled = 'clockEnabled';
  static const String clockDisabled = 'clockDisabled';
  static const String rateLimits = 'rateLimits';
  static const String downRateLimit = 'downRateLimit';
  static const String upRateLimit = 'upRateLimit';
  static const String forceOnOff = 'forceOnOff';
  static const String offOption = 'offOption';
  static const String onOption = 'onOption';
  static const String freeOption = 'freeOption';
  static const String taBoost = 'taBoost';
  static const String taBoostEnabled = 'taBoostEnabled';
  static const String taBoostDisabled = 'taBoostDisabled';
  static const String gbeActiveDesc = 'gbeActiveDesc';
  static const String gbeInactiveDesc = 'gbeInactiveDesc';
  static const String bypassChargeActiveDesc = 'bypassChargeActiveDesc';
  static const String bypassChargeInactiveDesc = 'bypassChargeInactiveDesc';
  static const String unlockFpsActiveDesc = 'unlockFpsActiveDesc';
  static const String unlockFpsInactiveDesc = 'unlockFpsInactiveDesc';
  static const String batterySafetyGuard = 'batterySafetyGuard';
  static const String gbeDirectiveSubtitle = 'gbeDirectiveSubtitle';
  static const String bypassDirectiveSubtitle = 'bypassDirectiveSubtitle';
  static const String thermalBypassTitle = 'thermalBypassTitle';
  static const String thermalBypassSubtitle = 'thermalBypassSubtitle';
  static const String modeGlobal = 'modeGlobal';
  static const String gpuCore = 'gpuCore';
  static const String busDram = 'busDram';
  static const String revertChanges = 'revertChanges';
  static const String systemAppTag = 'systemAppTag';
  static const String tabPerf = 'tabPerf';
  static const String tabBalanced = 'tabBalanced';
  static const String tabPowersave = 'tabPowersave';
  static const String tabPowersavePlus = 'tabPowersavePlus';

  // Profile switch card titles & subtitles
  static const String cardPerformance = 'cardPerformance';
  static const String cardBalanced = 'cardBalanced';
  static const String cardPowersave = 'cardPowersave';
  static const String cardPowersavePlus = 'cardPowersavePlus';

  static const String cardTagPerformance = 'cardTagPerformance';
  static const String cardTagBalanced = 'cardTagBalanced';
  static const String cardTagPowersave = 'cardTagPowersave';
  static const String cardTagPowersavePlus = 'cardTagPowersavePlus';

  // v16.4 Thermal Guardian & UI Localizations
  static const String fpsgoHeader = 'fpsgoHeader';
  static const String batteryOk = 'batteryOk';
  static const String tgPredictive = 'tgPredictive';
  static const String tgStatusDisabled = 'tgStatusDisabled';
  static const String tgStatusClamping = 'tgStatusClamping';
  static const String tgStatusCooldown = 'tgStatusCooldown';
  static const String tgStatusMonitoring = 'tgStatusMonitoring';
  static const String tgStatusNominal = 'tgStatusNominal';
  static const String tgSubDisabled = 'tgSubDisabled';
  static const String tgSubClamping = 'tgSubClamping';
  static const String tgSubCooldown = 'tgSubCooldown';
  static const String tgSubMonitoring = 'tgSubMonitoring';
  static const String tgSubNominal = 'tgSubNominal';
  static const String tgDescription = 'tgDescription';
  static const String tgRealtimeStatus = 'tgRealtimeStatus';
  static const String tgTrend = 'tgTrend';
  static const String tgTargetTemp = 'tgTargetTemp';
  static const String tgTempCool = 'tgTempCool';
  static const String tgTempRecommended = 'tgTempRecommended';
  static const String tgTempExtreme = 'tgTempExtreme';
  static const String tgClampingAggressiveness = 'tgClampingAggressiveness';
  static const String tgStep1Title = 'tgStep1Title';
  static const String tgStep1Subtitle = 'tgStep1Subtitle';
  static const String tgStep2Title = 'tgStep2Title';
  static const String tgStep2Subtitle = 'tgStep2Subtitle';
  static const String tgStep3Title = 'tgStep3Title';
  static const String tgStep3Subtitle = 'tgStep3Subtitle';
  static const String tgStepSummary1 = 'tgStepSummary1';
  static const String tgStepSummary2 = 'tgStepSummary2';
  static const String tgStepSummary3 = 'tgStepSummary3';

  // v16.2 Touch Booster
  static const String touchBoosterTitle = 'touchBoosterTitle';
  static const String touchBoosterSubtitle = 'touchBoosterSubtitle';
  static const String touchGameMode = 'touchGameMode';
  static const String touchGameModeDesc = 'touchGameModeDesc';
  static const String touchThpSmooth = 'touchThpSmooth';
  static const String touchThpSmoothDesc = 'touchThpSmoothDesc';
  static const String touchPinThreads = 'touchPinThreads';
  static const String touchPinThreadsDesc = 'touchPinThreadsDesc';
  static const String touchBadge = 'touchBadge';

  static const Map<String, dynamic> en = {
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
    noSearchResults: 'No apps found for your search',
    clearSearch: 'Clear Search',
    errorLoadingApps: 'Error loading applications',
    retry: 'Retry',
    profileSet: 'Profile for {app} set to {profile}',
    profileReset: 'Default profile restored for {app}',
    undo: 'Undo',
    changeProfile: 'Change profile',
    selectProfile: 'Select performance profile',
    profileApplied: '“{profile}” profile applied globally',
    applying: 'Applying...',
    includeSystemApps: 'Include system apps',
    includeSystemAppsDesc: 'Show system applications',

    daemonSettings: 'Daemon Settings',
    screenOffProfile: 'Screen-off profile',
    screenOffProfileDesc: 'Profile applied when the screen turns off',
    appDebounceMs: 'App switch delay',
    appDebounceMsDesc: 'Wait time before switching profiles when changing apps',
    milliseconds: 'ms',

    // Perf config
    perfConfig: 'Config',
    titlePerfConfig: 'Profile Editor',
    perfConfigDescription: 'Edit performance profile configuration files',
    saveChanges: 'Save',
    configSaved: 'Configuration saved successfully',
    configSaveError: 'Failed to save configuration',
    savingConfig: 'Saving...',
    perfConfigError: 'Could not load config files. Is the PerfMTK module installed?',

    themeSystemDesc: 'Use system settings',
    themeLightDesc: 'Light theme',
    themeDarkDesc: 'Dark theme',

    defaultProfileDesc: 'Use the global default profile setting',
    performanceDesc: 'Maximum CPU and GPU performance. Higher battery usage',
    balancedDesc: 'Balance between performance and battery life',
    powersaveDesc: 'Reduced performance for better battery life',
    powersavePlusDesc: 'Maximum battery savings with minimal performance',

    // v16.0 Telemetry
    hardwareTelemetry: 'Hardware Telemetry',
    activeEngine: 'Active Engine',
    fgEnginePush: 'LSPosed Hook (Push)',
    fgEngineCgroup: 'Kernel cgroup (Inotify)',
    fgEnginePoller: 'Adaptive Poller (Fallback)',
    dramFreq: 'DRAM Frequency',
    gpuFreq: 'GPU Frequency',
    cpuFreq: 'CPU Clusters',
    socTemp: 'SoC Temp',
    batteryTemp: 'Battery Temp',

    // v16.0 Fast Charge Bypass
    chargeBypass: 'Charge Bypass',
    chargeBypassTitle: 'Smart Fast Charge Bypass',
    chargeBypassDesc: 'Bypass thermal throttling during fast charging with safety temperature guard',
    chargeBypassActive: 'Bypass Active',
    chargeBypassInactive: 'Bypass Inactive',
    safetyGuardLimit: 'Safety Guard Limit',

    // v16.0 Knobs
    uclamp: 'EAS UCLAMP',
    uclampTitle: 'Task Placement & Frequency Clamping',
    uclampTopAppMin: 'Top-App UCLAMP Min',
    uclampTopAppMax: 'Top-App UCLAMP Max',
    uclampFgMin: 'Foreground UCLAMP Min',
    uclampFgMax: 'Foreground UCLAMP Max',
    gbeTitle: 'MediaTek Game Turbo (GBE)',
    gbeDesc: 'MediaTek Game Booster Engine frame forecasting & scheduling optimization',
    gbeEnable: 'GBE Optimization',
    gbeThermalHeadroom: 'Thermal Headroom Margin',
    thermalChargeTitle: 'Thermal Throttling & Charging Bypass',
    unlockFpsThermal: 'Unlock FPS Thermal Caps',
    unlockFpsThermalDesc: 'Prevent kernel thermal daemon from capping display refresh rate',
    bypassChargeThrottle: 'Bypass Charging Throttle',
    bypassChargeThrottleDesc: 'Force maximum charge current despite device temperature',
    batteryTempLimit: 'Battery Temperature Safety Guard (°C)',
    gameDirectives: 'Directives & Tuning Overrides',
    dramFloor: 'Minimum DRAM Clock',

    // v16.1 Thermal Chart & Battery Care
    thermalChartTitle: 'Real-time Thermal Telemetry',
    thermalChartSubtitle: 'Continuous SoC and Battery temperature curves (last 60s)',
    socTempLabel: 'SoC',
    batteryTempLabel: 'Battery',
    batteryCareTitle: 'Battery Health Care',
    batteryCareDesc: 'Automatically stops charging current when reaching the limit to preserve battery lifespan.',
    batteryCareLimit: 'Charge Limit',
    batteryCareSuspended: 'Charging Suspended (Care Active)',
    batteryCareNormal: 'Normal Charging (Up to 100%)',

    // v16.2 HUD & Telemetry Console
    switchProfileHeader: 'SWITCH PROFILE',
    hardwareMonitorHeader: 'LIVE HARDWARE MONITOR',
    siliconState: 'SILICON STATUS',
    siliconStateSubtitle: 'MediaTek SoC dynamic console',
    liveBadge: 'LIVE',
    cpuClustersHeader: 'CPU CLUSTERS',
    gpuAndDramHeader: 'GRAPHICS ENGINE & DRAM BUS',
    thermalAndPowerHeader: 'THERMAL STATE & POWER',
    socSilicon: 'SoC SILICON',
    smartBypass: 'SMART BYPASS',
    powerRail: 'POWER RAIL',
    directSilicon: '⚡ Direct Silicon',
    cellIsolated: 'Thermal cell isolated',
    standardConsumption: 'Standard consumption',
    batteryTempCell: '{temp}°C cell temp',
    batteryPct: '{pct}% Battery',

    // v16.3 Profile Config & Directives
    minFreq: 'Min Frequency',
    maxFreq: 'Max Frequency',
    governor: 'Governor',
    onlineCores: 'Online Cores',
    freqMode: 'Frequency Mode',
    dvfsAuto: 'DVFS — Auto',
    fixedFreq: 'Fixed Frequency',
    minFreqDram: 'Min Frequency (DVFSRC)',
    ufsClkEnable: 'UFS_CLK_ENABLE',
    clockEnabled: 'Clock enabled',
    clockDisabled: 'Clock disabled',
    rateLimits: 'Rate Limits',
    downRateLimit: 'DOWN (µs)',
    upRateLimit: 'UP (µs)',
    forceOnOff: 'FORCE_ONOFF',
    offOption: 'Off',
    onOption: 'On',
    freeOption: 'Free',
    taBoost: 'BOOST_TA',
    taBoostEnabled: 'TA boost enabled',
    taBoostDisabled: 'TA boost disabled',
    gbeActiveDesc: 'Real-time frame prediction & boost active',
    gbeInactiveDesc: 'GBE engine optimization disabled',
    bypassChargeActiveDesc: 'Charge speed maximized during high load',
    bypassChargeInactiveDesc: 'Standard thermal charge curve applied',
    unlockFpsActiveDesc: 'Display refresh rate preserved at high temps',
    unlockFpsInactiveDesc: 'Standard FPS thermal throttling enabled',
    batterySafetyGuard: 'Battery Temp Safety Cutoff Guard',
    gbeDirectiveSubtitle: 'Forces game frequencies and turbo GPU',
    bypassDirectiveSubtitle: 'Powers silicon directly without heating battery',
    thermalBypassTitle: 'Thermal Bypass (Disable Throttling)',
    thermalBypassSubtitle: 'Disables OEM thermal throttling services for max gaming performance',
    modeGlobal: 'Global Mode',
    gpuCore: 'GPU CORE',
    busDram: 'BUS DRAM',
    revertChanges: 'Revert changes',
    systemAppTag: 'System',
    tabPerf: 'Perf',
    tabBalanced: 'Balanced',
    tabPowersave: 'Save',
    tabPowersavePlus: 'Save+',

    // Profile switch card titles & subtitles
    cardPerformance: 'Performance',
    cardBalanced: 'Balanced',
    cardPowersave: 'Power Save',
    cardPowersavePlus: 'Power Save+',
    cardTagPerformance: 'High Power',
    cardTagBalanced: 'Daily Use',
    cardTagPowersave: 'Efficiency',
    cardTagPowersavePlus: 'Ultra Saver',

    // v16.4
    fpsgoHeader: 'REFRESH RATE / FPS (FPSGO)',
    batteryOk: 'Battery OK',
    tgPredictive: 'PREDICTIVE',
    tgStatusDisabled: 'DISABLED',
    tgStatusClamping: 'CLAMPING ACTIVE ({step}/{max})',
    tgStatusCooldown: 'COOLING DOWN',
    tgStatusMonitoring: 'MONITORING',
    tgStatusNominal: 'NOMINAL (OPTIMAL)',
    tgSubDisabled: 'Predictive thermal protection disabled',
    tgSubClamping: 'Attenuating frequencies (-{pct}%)',
    tgSubCooldown: 'Recovering baseline frequencies',
    tgSubMonitoring: 'Monitoring thermal gradient rise',
    tgSubNominal: 'Stable frequencies at maximum rate',
    tgDescription: 'Prevents sudden FPS drops (sawtooth) by smoothly stepping down frequencies before hard thermal throttling.',
    tgRealtimeStatus: 'REAL-TIME STATUS',
    tgTrend: 'TREND (ΔT/Δt)',
    tgTargetTemp: 'Target SoC Temperature:',
    tgTempCool: '65°C (Cool)',
    tgTempRecommended: '75°C (Recommended)',
    tgTempExtreme: '85°C (Extreme)',
    tgClampingAggressiveness: 'Clamping Aggressiveness:',
    tgStep1Title: '1 Step',
    tgStep1Subtitle: 'Gentle',
    tgStep2Title: '2 Steps',
    tgStep2Subtitle: 'Optimal',
    tgStep3Title: '3 Steps',
    tgStep3Subtitle: 'Strong',
    tgStepSummary1: '1 step (-12%)',
    tgStepSummary2: '2 steps (-24%)',
    tgStepSummary3: '3 steps (-36%)',
    touchBoosterTitle: 'Touch Booster',
    touchBoosterSubtitle: '480Hz polling rate & CPU affinity',
    touchGameMode: 'Gaming Mode & 480Hz Rate',
    touchGameModeDesc: 'Unlocks digitizer polling rate to 480Hz/2160Hz via hardware ioctl',
    touchThpSmooth: 'Host Processing Smoothing',
    touchThpSmoothDesc: 'Enables touch_thp_smooth driver filter for precise gesture tracking',
    touchPinThreads: 'Pin Touch Threads to Big Cores',
    touchPinThreadsDesc: 'Pins touch IRQ and InputReader/Dispatcher to Big Cores (Leave OFF for heavy games to prevent thread contention)',
    touchBadge: 'Touch',
  };

  static const Map<String, dynamic> es = {
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
    noSearchResults: 'No se encontraron apps para tu búsqueda',
    clearSearch: 'Limpiar Búsqueda',
    errorLoadingApps: 'Error al cargar aplicaciones',
    retry: 'Reintentar',
    profileSet: 'Perfil para {app} configurado a {profile}',
    profileReset: 'Perfil predeterminado restaurado para {app}',
    undo: 'Deshacer',
    changeProfile: 'Cambiar perfil',
    selectProfile: 'Seleccionar perfil de rendimiento',
    profileApplied: 'Perfil "{profile}" aplicado globalmente',
    applying: 'Aplicando...',
    includeSystemApps: 'Incluir aplicaciones del sistema',
    includeSystemAppsDesc: 'Mostrar aplicaciones críticas del sistema',

    daemonSettings: 'Ajustes del Daemon',
    screenOffProfile: 'Perfil con pantalla apagada',
    screenOffProfileDesc: 'Perfil que se aplica cuando la pantalla se apaga',
    appDebounceMs: 'Retardo al cambiar de app',
    appDebounceMsDesc: 'Tiempo de espera antes de cambiar el perfil al cambiar de aplicación',
    milliseconds: 'ms',

    // Perf config
    perfConfig: 'Config',
    titlePerfConfig: 'Editor de Perfiles',
    perfConfigDescription: 'Editar archivos de configuración de perfiles de rendimiento',
    saveChanges: 'Guardar',
    configSaved: 'Configuración guardada correctamente',
    configSaveError: 'Error al guardar la configuración',
    savingConfig: 'Guardando...',
    perfConfigError: '¿El módulo PerfMTK está instalado? No se pudo cargar la configuración.',

    themeSystemDesc: 'Usar configuración del sistema',
    themeLightDesc: 'Tema claro',
    themeDarkDesc: 'Tema oscuro',

    defaultProfileDesc: 'Usar la configuración predeterminada global',
    performanceDesc: 'Máximo rendimiento de CPU y GPU. Mayor consumo de batería',
    balancedDesc: 'Equilibrio entre rendimiento y duración de batería',
    powersaveDesc: 'Rendimiento reducido para mejor duración de batería',
    powersavePlusDesc: 'Máximo ahorro de batería con rendimiento mínimo',

    // v16.0 Telemetry
    hardwareTelemetry: 'Telemetría de Hardware',
    activeEngine: 'Motor de Detección',
    fgEnginePush: 'LSPosed Hook (Push)',
    fgEngineCgroup: 'Kernel cgroup (Inotify)',
    fgEnginePoller: 'Adaptive Poller (Fallback)',
    dramFreq: 'Frecuencia DRAM',
    gpuFreq: 'Frecuencia GPU',
    cpuFreq: 'Clústeres CPU',
    socTemp: 'Temp. SoC',
    batteryTemp: 'Temp. Batería',

    // v16.0 Fast Charge Bypass
    chargeBypass: 'Bypass de Carga',
    chargeBypassTitle: 'Smart Fast Charge Bypass',
    chargeBypassDesc: 'Evita la limitación térmica durante la carga rápida con protección de seguridad',
    chargeBypassActive: 'Bypass Activo',
    chargeBypassInactive: 'Bypass Inactivo',
    safetyGuardLimit: 'Límite de Guardia Térmica',

    // v16.0 Knobs
    uclamp: 'EAS UCLAMP',
    uclampTitle: 'Asignación de Tareas y Abrazaderas de Frecuencia',
    uclampTopAppMin: 'UCLAMP Mínimo Top-App',
    uclampTopAppMax: 'UCLAMP Máximo Top-App',
    uclampFgMin: 'UCLAMP Mínimo Foreground',
    uclampFgMax: 'UCLAMP Máximo Foreground',
    gbeTitle: 'MediaTek Game Turbo (GBE)',
    gbeDesc: 'Optimización de predicción de cuadros y programación del motor MediaTek GBE',
    gbeEnable: 'Optimización GBE',
    gbeThermalHeadroom: 'Margen Térmico de Seguridad',
    thermalChargeTitle: 'Límites Térmicos y Bypass de Carga',
    unlockFpsThermal: 'Desbloquear Límite FPS Térmico',
    unlockFpsThermalDesc: 'Evita que el daemon térmico limite la tasa de refresco de pantalla',
    bypassChargeThrottle: 'Bypass de Límite de Carga',
    bypassChargeThrottleDesc: 'Fuerza la máxima velocidad de carga ignorando la limitación térmica',
    batteryTempLimit: 'Límite Térmico de Seguridad de Batería (°C)',
    gameDirectives: 'Directives y Ajustes Específicos',
    dramFloor: 'Frecuencia Mínima DRAM',

    // v16.1 Thermal Chart & Battery Care
    thermalChartTitle: 'Telemetría Térmica en Tiempo Real',
    thermalChartSubtitle: 'Curvas continuas de temperatura de SoC y Batería (últimos 60s)',
    socTempLabel: 'SoC',
    batteryTempLabel: 'Batería',
    batteryCareTitle: 'Cuidado de Batería',
    batteryCareDesc: 'Pausa la corriente de carga automáticamente al alcanzar el límite para prolongar la vida útil de la batería.',
    batteryCareLimit: 'Límite de Carga',
    batteryCareSuspended: 'Carga Pausada (Protección Activa)',
    batteryCareNormal: 'Carga Normal (Hasta el 100%)',

    // v16.2 HUD & Telemetry Console
    switchProfileHeader: 'CAMBIAR PERFIL',
    hardwareMonitorHeader: 'MONITOR DE HARDWARE EN VIVO',
    siliconState: 'ESTADO DEL SILICIO',
    siliconStateSubtitle: 'Consola dinámica del SoC MediaTek',
    liveBadge: 'EN VIVO',
    cpuClustersHeader: 'CLÚSTERES DE CPU',
    gpuAndDramHeader: 'MOTOR GRÁFICO & BUS DRAM',
    thermalAndPowerHeader: 'ESTADO TÉRMICO & ENERGÍA',
    socSilicon: 'SoC SILICIO',
    smartBypass: 'SMART BYPASS',
    powerRail: 'ALIMENTACIÓN',
    directSilicon: '⚡ Silicio Directo',
    cellIsolated: 'Celda aislada de calor',
    standardConsumption: 'Consumo estándar',
    batteryTempCell: '{temp}°C temperatura celda',
    batteryPct: '{pct}% Batería',

    // v16.3 Profile Config & Directives
    minFreq: 'Frecuencia Mínima',
    maxFreq: 'Frecuencia Máxima',
    governor: 'Gobernador',
    onlineCores: 'Núcleos Activos',
    freqMode: 'Modo de Frecuencia',
    dvfsAuto: 'DVFS — Automático',
    fixedFreq: 'Frecuencia Fija',
    minFreqDram: 'Frecuencia Mínima (DVFSRC)',
    ufsClkEnable: 'UFS_CLK_ENABLE',
    clockEnabled: 'Reloj habilitado',
    clockDisabled: 'Reloj deshabilitado',
    rateLimits: 'Límites de Tasa',
    downRateLimit: 'DOWN (µs)',
    upRateLimit: 'UP (µs)',
    forceOnOff: 'FORCE_ONOFF',
    offOption: 'Apagado',
    onOption: 'Encendido',
    freeOption: 'Libre',
    taBoost: 'BOOST_TA',
    taBoostEnabled: 'TA boost activado',
    taBoostDisabled: 'TA boost desactivado',
    gbeActiveDesc: 'Predicción de cuadros en tiempo real y boost activo',
    gbeInactiveDesc: 'Optimización de motor GBE desactivada',
    bypassChargeActiveDesc: 'Velocidad de carga maximizada bajo alta carga',
    bypassChargeInactiveDesc: 'Curva estándar de carga térmica aplicada',
    unlockFpsActiveDesc: 'Tasa de refresco conservada a altas temperaturas',
    unlockFpsInactiveDesc: 'Limitación térmica FPS estándar activada',
    batterySafetyGuard: 'Protección de Corte Térmico de Batería',
    gbeDirectiveSubtitle: 'Fuerza frecuencias de juego y GPU turbo',
    bypassDirectiveSubtitle: 'Alimenta directo al silicio sin calentar la batería',
    thermalBypassTitle: 'Bypass Térmico (Desactivar Límite)',
    thermalBypassSubtitle: 'Desactiva los servicios térmicos del fabricante para máximo rendimiento en juegos',
    modeGlobal: 'Modo Global',
    gpuCore: 'NÚCLEO GPU',
    busDram: 'BUS DRAM',
    revertChanges: 'Revertir cambios',
    systemAppTag: 'Sistema',
    tabPerf: 'Perf',
    tabBalanced: 'Equil',
    tabPowersave: 'Ahorro',
    tabPowersavePlus: 'Ahorro+',

    // Profile switch card titles & subtitles
    cardPerformance: 'Rendimiento',
    cardBalanced: 'Equilibrado',
    cardPowersave: 'Ahorro',
    cardPowersavePlus: 'Ahorro+',
    cardTagPerformance: 'Potencia',
    cardTagBalanced: 'Uso diario',
    cardTagPowersave: 'Eficiencia',
    cardTagPowersavePlus: 'Ultra ahorro',

    // v16.4
    fpsgoHeader: 'TASA DE REFRESCO / FPS (FPSGO)',
    batteryOk: 'Batería OK',
    tgPredictive: 'PREDICTIVO',
    tgStatusDisabled: 'DESACTIVADO',
    tgStatusClamping: 'CLAMPING ACTIVO ({step}/{max})',
    tgStatusCooldown: 'ENFRIAMIENTO',
    tgStatusMonitoring: 'MONITOREANDO',
    tgStatusNominal: 'NOMINAL (ÓPTIMO)',
    tgSubDisabled: 'Protección predictiva desactivada',
    tgSubClamping: 'Atenuando frecuencias (-{pct}%)',
    tgSubCooldown: 'Recuperando frecuencias normales',
    tgSubMonitoring: 'Vigilando gradiente térmico',
    tgSubNominal: 'Frecuencias estables a máxima tasa',
    tgDescription: 'Previene caídas bruscas de FPS (sawtooth) escalonando frecuencias suavemente antes del hard throttling.',
    tgRealtimeStatus: 'ESTADO EN TIEMPO REAL',
    tgTrend: 'TENDENCIA (ΔT/Δt)',
    tgTargetTemp: 'Temperatura SoC Objetivo:',
    tgTempCool: '65°C (Frío)',
    tgTempRecommended: '75°C (Recomendado)',
    tgTempExtreme: '85°C (Extremo)',
    tgClampingAggressiveness: 'Agresividad de Clamping:',
    tgStep1Title: '1 Paso',
    tgStep1Subtitle: 'Suave',
    tgStep2Title: '2 Pasos',
    tgStep2Subtitle: 'Óptimo',
    tgStep3Title: '3 Pasos',
    tgStep3Subtitle: 'Fuerte',
    tgStepSummary1: '1 paso (-12%)',
    tgStepSummary2: '2 pasos (-24%)',
    tgStepSummary3: '3 pasos (-36%)',
    touchBoosterTitle: 'Acelerador Táctil',
    touchBoosterSubtitle: 'Muestreo a 480Hz y afinidad de CPU',
    touchGameMode: 'Modo Gaming y Tasa a 480Hz',
    touchGameModeDesc: 'Desbloquea el muestreo del digitalizador a 480Hz/2160Hz vía ioctl de hardware',
    touchThpSmooth: 'Suavizado THP del Host',
    touchThpSmoothDesc: 'Activa el filtro touch_thp_smooth para seguimiento preciso de gestos',
    touchPinThreads: 'Anclar Hilos Táctiles a Núcleos Big',
    touchPinThreadsDesc: 'Ancla la IRQ táctil e InputReader a núcleos Big (Recomendado APAGADO en juegos para evitar micro-tirones)',
    touchBadge: 'Touch',
  };

  static String getValue(String key) {
    return key;
  }
}
