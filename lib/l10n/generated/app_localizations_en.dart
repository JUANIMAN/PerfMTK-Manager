// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profiles => 'Profiles';

  @override
  String get thermal => 'Thermal';

  @override
  String get titleProfiles => 'Power profiles';

  @override
  String get subtitleProfiles => 'Global profiles';

  @override
  String get currentProfile => 'Current profile';

  @override
  String get defaultProfile => 'Default profile';

  @override
  String get performance => 'Performance';

  @override
  String get balanced => 'Balanced';

  @override
  String get powersave => 'Power Saver';

  @override
  String get powersavePlus => 'Ultra Power Saver';

  @override
  String get performanceCard => 'Maximum performance.';

  @override
  String get balancedCard => 'Good performance.';

  @override
  String get powersaveCard => 'Saves battery.';

  @override
  String get powersavePlusCard => 'Maximizes battery life.';

  @override
  String get titleThermal => 'Thermal management';

  @override
  String get thermalState => 'Thermal throttling';

  @override
  String get thermalControl => 'Thermal Control';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get enableDsc =>
      'Enable temperature control; it is recommended to keep it activated';

  @override
  String get disableDsc =>
      'Disable temperature control; there may be no performance improvement';

  @override
  String get snackBarText => 'Install the latest version of the module.';

  @override
  String get snackBarLabel => 'Download';

  @override
  String get downloadMess => 'Could not open download link.';

  @override
  String get updateMess => 'New update available';

  @override
  String get updateNew => 'What\'s new:';

  @override
  String get updateCancel => 'Later';

  @override
  String get updateDown => 'Download';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get about => 'About';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get lockFreq => 'lock processor frequencies';

  @override
  String get lockFreqDescription =>
      'This setting only applies to the Performance profile.';

  @override
  String get defaultProfileDescription =>
      'Select the default profile to use when the app starts';

  @override
  String get aboutDescription =>
      'PerfMTK Manager is an app to manage your device\'s performance profiles and thermal settings.';

  @override
  String get back => 'Back';

  @override
  String get developer => 'Developer';

  @override
  String get compDevices => 'Compatible devices';

  @override
  String get appProfiles => 'App Profiles';

  @override
  String get titleAppProfiles => 'Application Profiles';

  @override
  String get searchApps => 'Search applications';

  @override
  String get noAppsFound => 'No applications found';

  @override
  String get appProfilesDescription =>
      'Configure performance profiles for individual apps';

  @override
  String get allApps => 'All Apps';

  @override
  String get configuredApps => 'Configured';

  @override
  String get notConfiguredApps => 'Not Configured';

  @override
  String get noSearchResults => 'No apps found for your search';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get errorLoadingApps => 'Error loading applications';

  @override
  String get retry => 'Retry';

  @override
  String profileSet(String app, String profile) {
    return 'Profile for $app set to $profile';
  }

  @override
  String profileReset(String app) {
    return 'Default profile restored for $app';
  }

  @override
  String get undo => 'Undo';

  @override
  String get changeProfile => 'Change profile';

  @override
  String get selectProfile => 'Select performance profile';

  @override
  String profileApplied(String profile) {
    return '“$profile” profile applied globally';
  }

  @override
  String get applying => 'Applying...';

  @override
  String get includeSystemApps => 'Include system apps';

  @override
  String get includeSystemAppsDesc => 'Show system applications';

  @override
  String get daemonSettings => 'Daemon Settings';

  @override
  String get screenOffProfile => 'Screen-off profile';

  @override
  String get screenOffProfileDesc =>
      'Profile applied when the screen turns off';

  @override
  String get appDebounceMs => 'App switch delay';

  @override
  String get appDebounceMsDesc =>
      'Wait time before switching profiles when changing apps';

  @override
  String get milliseconds => 'ms';

  @override
  String get perfConfig => 'Config';

  @override
  String get titlePerfConfig => 'Profile Editor';

  @override
  String get perfConfigDescription =>
      'Edit performance profile configuration files';

  @override
  String get saveChanges => 'Save';

  @override
  String get configSaved => 'Configuration saved successfully';

  @override
  String get configSaveError => 'Failed to save configuration';

  @override
  String get savingConfig => 'Saving...';

  @override
  String get perfConfigError =>
      'Could not load config files. Is the PerfMTK module installed?';

  @override
  String get themeSystemDesc => 'Use system settings';

  @override
  String get themeLightDesc => 'Light theme';

  @override
  String get themeDarkDesc => 'Dark theme';

  @override
  String get defaultProfileDesc => 'Use the global default profile setting';

  @override
  String get performanceDesc =>
      'Maximum CPU and GPU performance. Higher battery usage';

  @override
  String get balancedDesc => 'Balance between performance and battery life';

  @override
  String get powersaveDesc => 'Reduced performance for better battery life';

  @override
  String get powersavePlusDesc =>
      'Maximum battery savings with minimal performance';

  @override
  String get hardwareTelemetry => 'Hardware Telemetry';

  @override
  String get activeEngine => 'Active Engine';

  @override
  String get fgEnginePush => 'LSPosed Hook (Push)';

  @override
  String get fgEngineCgroup => 'Kernel cgroup (Inotify)';

  @override
  String get fgEnginePoller => 'Adaptive Poller (Fallback)';

  @override
  String get dramFreq => 'DRAM Frequency';

  @override
  String get gpuFreq => 'GPU Frequency';

  @override
  String get cpuFreq => 'CPU Clusters';

  @override
  String get socTemp => 'SoC Temp';

  @override
  String get batteryTemp => 'Battery Temp';

  @override
  String get chargeBypass => 'Charge Bypass';

  @override
  String get chargeBypassTitle => 'Smart Fast Charge Bypass';

  @override
  String get chargeBypassDesc =>
      'Bypass thermal throttling during fast charging with safety temperature guard';

  @override
  String get chargeBypassActive => 'Bypass Active';

  @override
  String get chargeBypassInactive => 'Bypass Inactive';

  @override
  String get safetyGuardLimit => 'Safety Guard Limit';

  @override
  String get uclamp => 'EAS UCLAMP';

  @override
  String get uclampTitle => 'Task Placement & Frequency Clamping';

  @override
  String get uclampTopAppMin => 'Top-App UCLAMP Min';

  @override
  String get uclampTopAppMax => 'Top-App UCLAMP Max';

  @override
  String get uclampFgMin => 'Foreground UCLAMP Min';

  @override
  String get uclampFgMax => 'Foreground UCLAMP Max';

  @override
  String get gbeTitle => 'MediaTek Game Turbo (GBE)';

  @override
  String get gbeDesc =>
      'MediaTek Game Booster Engine frame forecasting & scheduling optimization';

  @override
  String get gbeEnable => 'GBE Optimization';

  @override
  String get gbeThermalHeadroom => 'Thermal Headroom Margin';

  @override
  String get thermalChargeTitle => 'Thermal Throttling & Charging Bypass';

  @override
  String get thermalFastChargeTitle => 'Thermal Throttling & Fast Charging';

  @override
  String get unlockFpsThermal => 'Unlock FPS Thermal Caps';

  @override
  String get unlockFpsThermalDesc =>
      'Prevent kernel thermal daemon from capping display refresh rate';

  @override
  String get bypassChargeThrottle => 'Bypass Charging Throttle';

  @override
  String get bypassChargeThrottleDesc =>
      'Force maximum charge current despite device temperature';

  @override
  String get batteryTempLimit => 'Battery Temperature Safety Guard (°C)';

  @override
  String get gameDirectives => 'Directives & Tuning Overrides';

  @override
  String get dramFloor => 'Minimum DRAM Clock';

  @override
  String get thermalChartTitle => 'Real-time Thermal Telemetry';

  @override
  String get thermalChartSubtitle =>
      'Continuous SoC and Battery temperature curves (last 60s)';

  @override
  String get socTempLabel => 'SoC';

  @override
  String get batteryTempLabel => 'Battery';

  @override
  String get batteryCareTitle => 'Battery Health Care';

  @override
  String get batteryCareDesc =>
      'Automatically stops charging current when reaching the limit to preserve battery lifespan.';

  @override
  String get batteryCareLimit => 'Charge Limit';

  @override
  String get batteryCareSuspended => 'Charging Suspended (Care Active)';

  @override
  String get batteryCareNormal => 'Normal Charging (Up to 100%)';

  @override
  String get switchProfileHeader => 'SWITCH PROFILE';

  @override
  String get hardwareMonitorHeader => 'LIVE HARDWARE MONITOR';

  @override
  String get siliconState => 'SILICON STATUS';

  @override
  String get siliconStateSubtitle => 'MediaTek SoC dynamic console';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get cpuClustersHeader => 'CPU CLUSTERS';

  @override
  String get gpuAndDramHeader => 'GRAPHICS ENGINE & DRAM BUS';

  @override
  String get thermalAndPowerHeader => 'THERMAL STATE & POWER';

  @override
  String get socSilicon => 'SoC SILICON';

  @override
  String get smartBypass => 'SMART BYPASS';

  @override
  String get powerRail => 'POWER RAIL';

  @override
  String get directSilicon => '⚡ Direct Silicon';

  @override
  String get cellIsolated => 'Thermal cell isolated';

  @override
  String get standardConsumption => 'Standard consumption';

  @override
  String batteryTempCell(String temp) {
    return '$temp°C cell temp';
  }

  @override
  String batteryPct(String pct) {
    return '$pct% Battery';
  }

  @override
  String get minFreq => 'Min Frequency';

  @override
  String get maxFreq => 'Max Frequency';

  @override
  String get governor => 'Governor';

  @override
  String get onlineCores => 'Online Cores';

  @override
  String get freqMode => 'Frequency Mode';

  @override
  String get dvfsAuto => 'DVFS — Auto';

  @override
  String get fixedFreq => 'Fixed Frequency';

  @override
  String get minFreqDram => 'Min Frequency (DVFSRC)';

  @override
  String get ufsClkEnable => 'UFS_CLK_ENABLE';

  @override
  String get clockEnabled => 'Clock enabled';

  @override
  String get clockDisabled => 'Clock disabled';

  @override
  String get rateLimits => 'Rate Limits';

  @override
  String get downRateLimit => 'DOWN (µs)';

  @override
  String get upRateLimit => 'UP (µs)';

  @override
  String get forceOnOff => 'FORCE_ONOFF';

  @override
  String get offOption => 'Off';

  @override
  String get onOption => 'On';

  @override
  String get freeOption => 'Free';

  @override
  String get taBoost => 'BOOST_TA';

  @override
  String get taBoostEnabled => 'TA boost enabled';

  @override
  String get taBoostDisabled => 'TA boost disabled';

  @override
  String get gbeActiveDesc => 'Real-time frame prediction & boost active';

  @override
  String get gbeInactiveDesc => 'GBE engine optimization disabled';

  @override
  String get bypassChargeActiveDesc =>
      'Charge speed maximized during high load';

  @override
  String get bypassChargeInactiveDesc =>
      'Standard thermal charge curve applied';

  @override
  String get unlockFpsActiveDesc =>
      'Display refresh rate preserved at high temps';

  @override
  String get unlockFpsInactiveDesc => 'Standard FPS thermal throttling enabled';

  @override
  String get batterySafetyGuard => 'Battery Temp Safety Cutoff Guard';

  @override
  String get gbeDirectiveSubtitle => 'Forces game frequencies and turbo GPU';

  @override
  String get bypassDirectiveSubtitle =>
      'Powers silicon directly without heating battery';

  @override
  String get hwChargeBypassTitle => 'Hardware Charge Bypass';

  @override
  String get hwChargeBypassDesc =>
      'Direct AC power to motherboard without charging or heating battery';

  @override
  String get hwBypassActive => 'Hardware Bypass Active';

  @override
  String get hwBypassInactive => 'Standard Charging Active';

  @override
  String get hwBypassDirectiveSubtitle =>
      'Powers motherboard directly without heating battery';

  @override
  String get smartFastChargeTitle => 'Smart Fast Charge';

  @override
  String get smartFastChargeDesc =>
      'Maintains high charging speed during gaming by preventing thermal throttling';

  @override
  String get smartFastChargeActive => 'Fast Charge Active';

  @override
  String get smartFastChargeInactive => 'Thermal Throttling Active';

  @override
  String get smartFastChargeDirectiveSubtitle =>
      'Prevents charge speed drops due to temperature during gaming';

  @override
  String get smartFastChargeTelemetry => '⚡ Fast Charge Active';

  @override
  String get smartFastChargeTelemetryDesc => 'Thermal throttle bypassed';

  @override
  String get thermalBypassTitle => 'Thermal Bypass (Disable Throttling)';

  @override
  String get thermalBypassSubtitle =>
      'Disables OEM thermal throttling services for max gaming performance';

  @override
  String get modeGlobal => 'Global Mode';

  @override
  String get gpuCore => 'GPU CORE';

  @override
  String get busDram => 'BUS DRAM';

  @override
  String get revertChanges => 'Revert changes';

  @override
  String get systemAppTag => 'System';

  @override
  String get tabPerf => 'Perf';

  @override
  String get tabBalanced => 'Balanced';

  @override
  String get tabPowersave => 'Save';

  @override
  String get tabPowersavePlus => 'Save+';

  @override
  String get cardPerformance => 'Performance';

  @override
  String get cardBalanced => 'Balanced';

  @override
  String get cardPowersave => 'Power Save';

  @override
  String get cardPowersavePlus => 'Power Save+';

  @override
  String get cardTagPerformance => 'High Power';

  @override
  String get cardTagBalanced => 'Daily Use';

  @override
  String get cardTagPowersave => 'Efficiency';

  @override
  String get cardTagPowersavePlus => 'Ultra Saver';

  @override
  String get fpsgoHeader => 'REFRESH RATE / FPS (FPSGO)';

  @override
  String get batteryOk => 'Battery OK';

  @override
  String get tgPredictive => 'PREDICTIVE';

  @override
  String get tgStatusDisabled => 'DISABLED';

  @override
  String tgStatusClamping(String step, String max) {
    return 'CLAMPING ACTIVE ($step/$max)';
  }

  @override
  String get tgStatusCooldown => 'COOLING DOWN';

  @override
  String get tgStatusMonitoring => 'MONITORING';

  @override
  String get tgStatusNominal => 'NOMINAL (OPTIMAL)';

  @override
  String get tgSubDisabled => 'Predictive thermal protection disabled';

  @override
  String tgSubClamping(String pct) {
    return 'Attenuating frequencies (-$pct%)';
  }

  @override
  String get tgSubCooldown => 'Recovering baseline frequencies';

  @override
  String get tgSubMonitoring => 'Monitoring thermal gradient rise';

  @override
  String get tgSubNominal => 'Stable frequencies at maximum rate';

  @override
  String get tgDescription =>
      'Prevents sudden FPS drops (sawtooth) by smoothly stepping down frequencies before hard thermal throttling.';

  @override
  String get tgRealtimeStatus => 'REAL-TIME STATUS';

  @override
  String get tgTrend => 'TREND (ΔT/Δt)';

  @override
  String get tgTargetTemp => 'Target SoC Temperature:';

  @override
  String get tgTempCool => '65°C (Cool)';

  @override
  String get tgTempRecommended => '75°C (Recommended)';

  @override
  String get tgTempExtreme => '85°C (Extreme)';

  @override
  String get tgClampingAggressiveness => 'Clamping Aggressiveness:';

  @override
  String get tgStep1Title => '1 Step';

  @override
  String get tgStep1Subtitle => 'Gentle';

  @override
  String get tgStep2Title => '2 Steps';

  @override
  String get tgStep2Subtitle => 'Optimal';

  @override
  String get tgStep3Title => '3 Steps';

  @override
  String get tgStep3Subtitle => 'Strong';

  @override
  String get tgStepSummary1 => '1 step (-12%)';

  @override
  String get tgStepSummary2 => '2 steps (-24%)';

  @override
  String get tgStepSummary3 => '3 steps (-36%)';

  @override
  String get touchBoosterTitle => 'Touch Booster';

  @override
  String get touchBoosterSubtitle => '480Hz polling rate & CPU affinity';

  @override
  String get touchGameMode => 'Gaming Mode & 480Hz Rate';

  @override
  String get touchGameModeDesc =>
      'Unlocks digitizer polling rate to 480Hz/2160Hz via hardware ioctl';

  @override
  String get touchThpSmooth => 'Host Processing Smoothing';

  @override
  String get touchThpSmoothDesc =>
      'Enables touch_thp_smooth driver filter for precise gesture tracking';

  @override
  String get touchPinThreads => 'Pin Touch Threads to Big Cores';

  @override
  String get touchPinThreadsDesc =>
      'Pins touch IRQ and InputReader/Dispatcher to Big Cores (Leave OFF for heavy games to prevent thread contention)';

  @override
  String get touchBadge => 'Touch';

  @override
  String get vmTitle => 'Virtual Memory & Kernel';

  @override
  String get swappiness => 'Swappiness';

  @override
  String get swappinessDesc =>
      'Aggressiveness of memory page swapping (higher = more ZRAM usage)';

  @override
  String get mglru => 'Multi-Gen LRU (MGLRU)';

  @override
  String get mglruDesc =>
      'Modern kernel pagecache reclaim algorithm for smooth multitasking';

  @override
  String get watermarkScale => 'Watermark Scale Factor';

  @override
  String get watermarkScaleDesc =>
      'Memory pressure headroom before background kswapd wakeup';

  @override
  String get compactionProactiveness => 'Proactive Compaction';

  @override
  String get compactionProactivenessDesc =>
      'Proactively defragments system memory to prevent frame drops';

  @override
  String get compactOnLaunch => 'Compact Memory on Game Launch';

  @override
  String get compactOnLaunchDesc =>
      'Triggers proactive memory compaction when launching games';

  @override
  String get statInterval => 'VM Stat Interval';

  @override
  String get displayTitle => 'Display Refresh Rate';

  @override
  String get displayRefreshDesc =>
      'Target panel refresh rate when this profile is active';

  @override
  String get refreshRateAuto => 'Auto / Dynamic';

  @override
  String get refreshRate60 => '60 Hz';

  @override
  String get refreshRate90 => '90 Hz';

  @override
  String get refreshRate120 => '120 Hz';

  @override
  String get refreshRate144 => '144 Hz';

  @override
  String get maxFreqDram => 'Max DRAM Frequency';

  @override
  String get uncapped => 'Uncapped';

  @override
  String get disableThermalServices => 'Disable OEM Thermal Services';

  @override
  String get disableThermalServicesDesc =>
      'Eliminates OEM throttling services (e.g. mi_thermald) during gaming';

  @override
  String get gentleCharge => 'Gentle Charging';

  @override
  String get gentleChargeDesc =>
      'Restricts charging input to keep device cool while running games';

  @override
  String get gentleChargeDisabled => 'Disabled (Full Speed)';

  @override
  String get bypassMinBatt => 'Bypass Min Battery Level';

  @override
  String get rescueEnable => 'Frame Drop Rescue (FBT)';

  @override
  String get rescueEnableDesc =>
      'Instant frequency boost when a frame drop is forecasted';

  @override
  String get ultraRescue => 'Ultra Rescue';

  @override
  String get ultraRescueDesc =>
      'Aggressive CPU spike for heavy 3D rendering stutters';

  @override
  String get downThrottle => 'Suppress Down-Throttle';

  @override
  String get downThrottleDesc =>
      'Blocks CPU frequency reductions mid-frame render';

  @override
  String get tgProfileTitle => 'Thermal Guardian (Profile)';

  @override
  String get tgProfileEnableDesc =>
      'Proactive thermal headroom regulation for this profile';

  @override
  String get tgUclampStep => 'Uclamp Reduction per Step';

  @override
  String get renderBoost => 'RenderBooster';

  @override
  String get renderBoostDesc =>
      'Pins and elevates UI and render threads to Big/Prime cores for stutter-free frames';

  @override
  String get appOverridesTitle => 'App Overrides (Optional)';

  @override
  String get appOverridesSubtitle =>
      'Temporarily override profile settings for this app';

  @override
  String get appOverridesInherited => 'Inherits from profile';

  @override
  String get appOverridesActiveCount => 'active';

  @override
  String get appOverridesNotice =>
      'By default, the app inherits all settings from the selected profile. Enable these options only if you need specific exceptions for this app.';

  @override
  String get appOverridesReset => 'Clear Overrides';

  @override
  String get perfAndTouchSection => 'Performance & Touch';

  @override
  String get thermalChargeSection => 'Thermal & Charging';

  @override
  String get done => 'Done';

  @override
  String get vipPipelineHeader => 'GAME ENGINE VIP PIPELINE';

  @override
  String get bgJailedBadge => 'BG JAILED (LITTLE 0-3)';

  @override
  String get bgNormalBadge => 'STANDARD';

  @override
  String get bgJailedDesc =>
      'Background tasks quarantined to Little Cores with 20% uclamp';

  @override
  String get noVipThreads => 'Awaiting game engine thread spawn...';

  @override
  String get corePrime => 'Core 7 (Prime)';

  @override
  String get coreBig => 'Cores 4-6 (Big)';

  @override
  String get coreAllBig => 'Cores 4-7 (All Big)';

  @override
  String get dvfsrcTurboQosTitle => 'Turbo QoS Interconnect (DVFSRC)';

  @override
  String get dvfsrcTurboQosSubtitle =>
      'Forces maximum memory interconnect priority and full DRAM bandwidth';

  @override
  String get fstbTuneQuantileTitle => 'FSTB Frame Delivery Quantile';

  @override
  String get fstbTuneQuantileSubtitle =>
      'Statistical estimator percentile for frame rendering capacity (P95/P99 prevents micro-stutters)';

  @override
  String get quantileP50 => 'P50 (Median)';

  @override
  String get quantileP95 => 'P95 (Smooth)';

  @override
  String get quantileP99 => 'P99 (Extreme)';

  @override
  String get battery => 'Battery';

  @override
  String get titleBattery => 'Battery & Charging';

  @override
  String get batteryHeroSubtitle =>
      'Real-time telemetry and intelligent charging controls';

  @override
  String get chargeSpeedRegulator => 'Charging Speed Regulator';

  @override
  String get chargeSpeedDesc =>
      'Limit maximum charging current to preserve battery health and prevent heat during use or gaming';

  @override
  String get currentSpeed => 'Current Rate';

  @override
  String get currentVoltage => 'Voltage';

  @override
  String get currentPower => 'Power Draw';

  @override
  String get chargeStatus => 'Status';

  @override
  String get unlimitedTurbo => 'Turbo / Max (67W)';

  @override
  String get fastChargePreset => 'Fast (3000 mA)';

  @override
  String get balancedChargePreset => 'Balanced (2000 mA)';

  @override
  String get gentleChargePreset => 'Night / Gentle (1000 mA)';

  @override
  String get customLimit => 'Custom Limit';

  @override
  String get chargeLimitPct => 'Charge Cut-off Limit';

  @override
  String get chargingCurrent => 'Charging Current';

  @override
  String get dischargingCurrent => 'Discharging Current';

  @override
  String get batteryHealthGood => 'Battery Health';

  @override
  String get fastChargeStatus => 'Turbo Charge';

  @override
  String get batteryHealthTitle => 'Battery Health & Longevity';

  @override
  String get batteryHealthDesc =>
      'Hardware-verified BMS cell degradation, life cycles, and design capacity';

  @override
  String get batteryCycles => 'Charge Cycles';

  @override
  String get batteryDesignCapacity => 'Design Capacity';

  @override
  String get batteryActualCapacity => 'Current Capacity';

  @override
  String get batterySoh => 'State of Health (SOH)';

  @override
  String get timeToFull => 'Until Full (100%)';

  @override
  String get timeToProtection => 'Until Protection Limit';

  @override
  String get timeRemaining => 'Estimated Runtime';

  @override
  String get dischargeRate => 'Discharge Rate';

  @override
  String get chargingSpeed => 'Charging Rate';

  @override
  String get backupManager => 'Backups & Snapshots';

  @override
  String get backupTitle => 'Profile Snapshots';

  @override
  String get backupSubtitle =>
      'Save snapshots of your custom kernel profiles and restore them anytime with a single tap';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get createBackupDesc =>
      'Compress and archive all current .conf profiles into a timestamped snapshot';

  @override
  String get creatingBackup => 'Creating snapshot...';

  @override
  String get backupCreatedSuccess => 'Backup snapshot created successfully!';

  @override
  String get backupCreateError => 'Failed to create backup archive';

  @override
  String get restoreBackup => 'Restore';

  @override
  String get restoringBackup => 'Restoring profiles...';

  @override
  String get restoreSuccess => 'Profiles restored successfully!';

  @override
  String get restoreError => 'Failed to restore backup archive';

  @override
  String get confirmRestoreTitle => 'Restore Profile Snapshot?';

  @override
  String get confirmRestoreMessage =>
      'All current hardware profile configurations will be replaced by this snapshot and applied immediately.';

  @override
  String get resetStockTitle => 'Regenerate PerfMTK Profiles';

  @override
  String get resetStockDesc =>
      'Regenerates optimized default profiles for your MediaTek processor (an automatic safety backup will be created first).';

  @override
  String get resetStockConfirm =>
      'Are you sure you want to regenerate all profiles with PerfMTK recommended settings? An automatic safety backup will be created before proceeding.';

  @override
  String get resetStockSuccess =>
      'Recommended profiles regenerated and applied successfully!';

  @override
  String get noBackupsFound => 'No Backups Found';

  @override
  String get noBackupsDesc =>
      'Create your first profile backup snapshot to keep your custom configurations safe.';

  @override
  String get deleteBackupTitle => 'Delete Backup?';

  @override
  String get deleteBackupConfirm =>
      'Are you sure you want to permanently delete this profile snapshot? This action cannot be undone.';

  @override
  String get deleteAllBackupsTitle => 'Delete All Backups?';

  @override
  String get deleteAllBackupsConfirm =>
      'Are you sure you want to delete all saved profile backup snapshots? This action cannot be undone.';

  @override
  String get backupDeletedSuccess => 'Backup deleted successfully';

  @override
  String get backupDeleteError => 'Failed to delete backup snapshot';

  @override
  String get allBackupsDeletedSuccess => 'All backups have been deleted';

  @override
  String get backupLatestBadge => 'LATEST SNAPSHOT';

  @override
  String get backupProfilesCount => '4 profiles (.conf)';

  @override
  String get storageUsed => 'Total Storage';

  @override
  String get backupsCountLabel => 'Snapshots';

  @override
  String get delete => 'Delete';

  @override
  String updateVersionAvailable(String version) {
    return 'Version $version available for download';
  }

  @override
  String actionFailed(String reason) {
    return 'Action failed: $reason';
  }

  @override
  String errorLoadingBattery(String error) {
    return 'Error loading battery state: $error';
  }

  @override
  String get temperature => 'Temperature';

  @override
  String get storedEnergy => 'Stored Energy';

  @override
  String get refresh => 'Refresh';
}
