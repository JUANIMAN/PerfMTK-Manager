import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @thermal.
  ///
  /// In en, this message translates to:
  /// **'Thermal'**
  String get thermal;

  /// No description provided for @titleProfiles.
  ///
  /// In en, this message translates to:
  /// **'Power profiles'**
  String get titleProfiles;

  /// No description provided for @subtitleProfiles.
  ///
  /// In en, this message translates to:
  /// **'Global profiles'**
  String get subtitleProfiles;

  /// No description provided for @currentProfile.
  ///
  /// In en, this message translates to:
  /// **'Current profile'**
  String get currentProfile;

  /// No description provided for @defaultProfile.
  ///
  /// In en, this message translates to:
  /// **'Default profile'**
  String get defaultProfile;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @powersave.
  ///
  /// In en, this message translates to:
  /// **'Power Saver'**
  String get powersave;

  /// No description provided for @powersavePlus.
  ///
  /// In en, this message translates to:
  /// **'Ultra Power Saver'**
  String get powersavePlus;

  /// No description provided for @performanceCard.
  ///
  /// In en, this message translates to:
  /// **'Maximum performance.'**
  String get performanceCard;

  /// No description provided for @balancedCard.
  ///
  /// In en, this message translates to:
  /// **'Good performance.'**
  String get balancedCard;

  /// No description provided for @powersaveCard.
  ///
  /// In en, this message translates to:
  /// **'Saves battery.'**
  String get powersaveCard;

  /// No description provided for @powersavePlusCard.
  ///
  /// In en, this message translates to:
  /// **'Maximizes battery life.'**
  String get powersavePlusCard;

  /// No description provided for @titleThermal.
  ///
  /// In en, this message translates to:
  /// **'Thermal management'**
  String get titleThermal;

  /// No description provided for @thermalState.
  ///
  /// In en, this message translates to:
  /// **'Thermal throttling'**
  String get thermalState;

  /// No description provided for @thermalControl.
  ///
  /// In en, this message translates to:
  /// **'Thermal Control'**
  String get thermalControl;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enableDsc.
  ///
  /// In en, this message translates to:
  /// **'Enable temperature control; it is recommended to keep it activated'**
  String get enableDsc;

  /// No description provided for @disableDsc.
  ///
  /// In en, this message translates to:
  /// **'Disable temperature control; there may be no performance improvement'**
  String get disableDsc;

  /// No description provided for @snackBarText.
  ///
  /// In en, this message translates to:
  /// **'Install the latest version of the module.'**
  String get snackBarText;

  /// No description provided for @snackBarLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get snackBarLabel;

  /// No description provided for @downloadMess.
  ///
  /// In en, this message translates to:
  /// **'Could not open download link.'**
  String get downloadMess;

  /// No description provided for @updateMess.
  ///
  /// In en, this message translates to:
  /// **'New update available'**
  String get updateMess;

  /// No description provided for @updateNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get updateNew;

  /// No description provided for @updateCancel.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateCancel;

  /// No description provided for @updateDown.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDown;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @lockFreq.
  ///
  /// In en, this message translates to:
  /// **'lock processor frequencies'**
  String get lockFreq;

  /// No description provided for @lockFreqDescription.
  ///
  /// In en, this message translates to:
  /// **'This setting only applies to the Performance profile.'**
  String get lockFreqDescription;

  /// No description provided for @defaultProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the default profile to use when the app starts'**
  String get defaultProfileDescription;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'PerfMTK Manager is an app to manage your device\'s performance profiles and thermal settings.'**
  String get aboutDescription;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @compDevices.
  ///
  /// In en, this message translates to:
  /// **'Compatible devices'**
  String get compDevices;

  /// No description provided for @appProfiles.
  ///
  /// In en, this message translates to:
  /// **'App Profiles'**
  String get appProfiles;

  /// No description provided for @titleAppProfiles.
  ///
  /// In en, this message translates to:
  /// **'Application Profiles'**
  String get titleAppProfiles;

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search applications'**
  String get searchApps;

  /// No description provided for @noAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No applications found'**
  String get noAppsFound;

  /// No description provided for @appProfilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure performance profiles for individual apps'**
  String get appProfilesDescription;

  /// No description provided for @allApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get allApps;

  /// No description provided for @configuredApps.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get configuredApps;

  /// No description provided for @notConfiguredApps.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get notConfiguredApps;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No apps found for your search'**
  String get noSearchResults;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @errorLoadingApps.
  ///
  /// In en, this message translates to:
  /// **'Error loading applications'**
  String get errorLoadingApps;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @profileSet.
  ///
  /// In en, this message translates to:
  /// **'Profile for {app} set to {profile}'**
  String profileSet(String app, String profile);

  /// No description provided for @profileReset.
  ///
  /// In en, this message translates to:
  /// **'Default profile restored for {app}'**
  String profileReset(String app);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @changeProfile.
  ///
  /// In en, this message translates to:
  /// **'Change profile'**
  String get changeProfile;

  /// No description provided for @selectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select performance profile'**
  String get selectProfile;

  /// No description provided for @profileApplied.
  ///
  /// In en, this message translates to:
  /// **'“{profile}” profile applied globally'**
  String profileApplied(String profile);

  /// No description provided for @applying.
  ///
  /// In en, this message translates to:
  /// **'Applying...'**
  String get applying;

  /// No description provided for @includeSystemApps.
  ///
  /// In en, this message translates to:
  /// **'Include system apps'**
  String get includeSystemApps;

  /// No description provided for @includeSystemAppsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show system applications'**
  String get includeSystemAppsDesc;

  /// No description provided for @daemonSettings.
  ///
  /// In en, this message translates to:
  /// **'Daemon Settings'**
  String get daemonSettings;

  /// No description provided for @screenOffProfile.
  ///
  /// In en, this message translates to:
  /// **'Screen-off profile'**
  String get screenOffProfile;

  /// No description provided for @screenOffProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Profile applied when the screen turns off'**
  String get screenOffProfileDesc;

  /// No description provided for @appDebounceMs.
  ///
  /// In en, this message translates to:
  /// **'App switch delay'**
  String get appDebounceMs;

  /// No description provided for @appDebounceMsDesc.
  ///
  /// In en, this message translates to:
  /// **'Wait time before switching profiles when changing apps'**
  String get appDebounceMsDesc;

  /// No description provided for @milliseconds.
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get milliseconds;

  /// No description provided for @perfConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get perfConfig;

  /// No description provided for @titlePerfConfig.
  ///
  /// In en, this message translates to:
  /// **'Profile Editor'**
  String get titlePerfConfig;

  /// No description provided for @perfConfigDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit performance profile configuration files'**
  String get perfConfigDescription;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChanges;

  /// No description provided for @configSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved successfully'**
  String get configSaved;

  /// No description provided for @configSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save configuration'**
  String get configSaveError;

  /// No description provided for @savingConfig.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingConfig;

  /// No description provided for @perfConfigError.
  ///
  /// In en, this message translates to:
  /// **'Could not load config files. Is the PerfMTK module installed?'**
  String get perfConfigError;

  /// No description provided for @themeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Use system settings'**
  String get themeSystemDesc;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLightDesc;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkDesc;

  /// No description provided for @defaultProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the global default profile setting'**
  String get defaultProfileDesc;

  /// No description provided for @performanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum CPU and GPU performance. Higher battery usage'**
  String get performanceDesc;

  /// No description provided for @balancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Balance between performance and battery life'**
  String get balancedDesc;

  /// No description provided for @powersaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduced performance for better battery life'**
  String get powersaveDesc;

  /// No description provided for @powersavePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum battery savings with minimal performance'**
  String get powersavePlusDesc;

  /// No description provided for @hardwareTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Hardware Telemetry'**
  String get hardwareTelemetry;

  /// No description provided for @activeEngine.
  ///
  /// In en, this message translates to:
  /// **'Active Engine'**
  String get activeEngine;

  /// No description provided for @fgEnginePush.
  ///
  /// In en, this message translates to:
  /// **'LSPosed Hook (Push)'**
  String get fgEnginePush;

  /// No description provided for @fgEngineCgroup.
  ///
  /// In en, this message translates to:
  /// **'Kernel cgroup (Inotify)'**
  String get fgEngineCgroup;

  /// No description provided for @fgEnginePoller.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Poller (Fallback)'**
  String get fgEnginePoller;

  /// No description provided for @dramFreq.
  ///
  /// In en, this message translates to:
  /// **'DRAM Frequency'**
  String get dramFreq;

  /// No description provided for @gpuFreq.
  ///
  /// In en, this message translates to:
  /// **'GPU Frequency'**
  String get gpuFreq;

  /// No description provided for @cpuFreq.
  ///
  /// In en, this message translates to:
  /// **'CPU Clusters'**
  String get cpuFreq;

  /// No description provided for @socTemp.
  ///
  /// In en, this message translates to:
  /// **'SoC Temp'**
  String get socTemp;

  /// No description provided for @batteryTemp.
  ///
  /// In en, this message translates to:
  /// **'Battery Temp'**
  String get batteryTemp;

  /// No description provided for @chargeBypass.
  ///
  /// In en, this message translates to:
  /// **'Charge Bypass'**
  String get chargeBypass;

  /// No description provided for @chargeBypassTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Fast Charge Bypass'**
  String get chargeBypassTitle;

  /// No description provided for @chargeBypassDesc.
  ///
  /// In en, this message translates to:
  /// **'Bypass thermal throttling during fast charging with safety temperature guard'**
  String get chargeBypassDesc;

  /// No description provided for @chargeBypassActive.
  ///
  /// In en, this message translates to:
  /// **'Bypass Active'**
  String get chargeBypassActive;

  /// No description provided for @chargeBypassInactive.
  ///
  /// In en, this message translates to:
  /// **'Bypass Inactive'**
  String get chargeBypassInactive;

  /// No description provided for @safetyGuardLimit.
  ///
  /// In en, this message translates to:
  /// **'Safety Guard Limit'**
  String get safetyGuardLimit;

  /// No description provided for @uclamp.
  ///
  /// In en, this message translates to:
  /// **'EAS UCLAMP'**
  String get uclamp;

  /// No description provided for @uclampTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Placement & Frequency Clamping'**
  String get uclampTitle;

  /// No description provided for @uclampTopAppMin.
  ///
  /// In en, this message translates to:
  /// **'Top-App UCLAMP Min'**
  String get uclampTopAppMin;

  /// No description provided for @uclampTopAppMax.
  ///
  /// In en, this message translates to:
  /// **'Top-App UCLAMP Max'**
  String get uclampTopAppMax;

  /// No description provided for @uclampFgMin.
  ///
  /// In en, this message translates to:
  /// **'Foreground UCLAMP Min'**
  String get uclampFgMin;

  /// No description provided for @uclampFgMax.
  ///
  /// In en, this message translates to:
  /// **'Foreground UCLAMP Max'**
  String get uclampFgMax;

  /// No description provided for @gbeTitle.
  ///
  /// In en, this message translates to:
  /// **'MediaTek Game Turbo (GBE)'**
  String get gbeTitle;

  /// No description provided for @gbeDesc.
  ///
  /// In en, this message translates to:
  /// **'MediaTek Game Booster Engine frame forecasting & scheduling optimization'**
  String get gbeDesc;

  /// No description provided for @gbeEnable.
  ///
  /// In en, this message translates to:
  /// **'GBE Optimization'**
  String get gbeEnable;

  /// No description provided for @gbeThermalHeadroom.
  ///
  /// In en, this message translates to:
  /// **'Thermal Headroom Margin'**
  String get gbeThermalHeadroom;

  /// No description provided for @thermalChargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Thermal Throttling & Charging Bypass'**
  String get thermalChargeTitle;

  /// No description provided for @thermalFastChargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Thermal Throttling & Fast Charging'**
  String get thermalFastChargeTitle;

  /// No description provided for @unlockFpsThermal.
  ///
  /// In en, this message translates to:
  /// **'Unlock FPS Thermal Caps'**
  String get unlockFpsThermal;

  /// No description provided for @unlockFpsThermalDesc.
  ///
  /// In en, this message translates to:
  /// **'Prevent kernel thermal daemon from capping display refresh rate'**
  String get unlockFpsThermalDesc;

  /// No description provided for @bypassChargeThrottle.
  ///
  /// In en, this message translates to:
  /// **'Bypass Charging Throttle'**
  String get bypassChargeThrottle;

  /// No description provided for @bypassChargeThrottleDesc.
  ///
  /// In en, this message translates to:
  /// **'Force maximum charge current despite device temperature'**
  String get bypassChargeThrottleDesc;

  /// No description provided for @batteryTempLimit.
  ///
  /// In en, this message translates to:
  /// **'Battery Temperature Safety Guard (°C)'**
  String get batteryTempLimit;

  /// No description provided for @gameDirectives.
  ///
  /// In en, this message translates to:
  /// **'Directives & Tuning Overrides'**
  String get gameDirectives;

  /// No description provided for @dramFloor.
  ///
  /// In en, this message translates to:
  /// **'Minimum DRAM Clock'**
  String get dramFloor;

  /// No description provided for @thermalChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Thermal Telemetry'**
  String get thermalChartTitle;

  /// No description provided for @thermalChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continuous SoC and Battery temperature curves (last 60s)'**
  String get thermalChartSubtitle;

  /// No description provided for @socTempLabel.
  ///
  /// In en, this message translates to:
  /// **'SoC'**
  String get socTempLabel;

  /// No description provided for @batteryTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get batteryTempLabel;

  /// No description provided for @batteryCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Health Care'**
  String get batteryCareTitle;

  /// No description provided for @batteryCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically stops charging current when reaching the limit to preserve battery lifespan.'**
  String get batteryCareDesc;

  /// No description provided for @batteryCareLimit.
  ///
  /// In en, this message translates to:
  /// **'Charge Limit'**
  String get batteryCareLimit;

  /// No description provided for @batteryCareSuspended.
  ///
  /// In en, this message translates to:
  /// **'Charging Suspended (Care Active)'**
  String get batteryCareSuspended;

  /// No description provided for @batteryCareNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Charging (Up to 100%)'**
  String get batteryCareNormal;

  /// No description provided for @switchProfileHeader.
  ///
  /// In en, this message translates to:
  /// **'SWITCH PROFILE'**
  String get switchProfileHeader;

  /// No description provided for @hardwareMonitorHeader.
  ///
  /// In en, this message translates to:
  /// **'LIVE HARDWARE MONITOR'**
  String get hardwareMonitorHeader;

  /// No description provided for @siliconState.
  ///
  /// In en, this message translates to:
  /// **'SILICON STATUS'**
  String get siliconState;

  /// No description provided for @siliconStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MediaTek SoC dynamic console'**
  String get siliconStateSubtitle;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @cpuClustersHeader.
  ///
  /// In en, this message translates to:
  /// **'CPU CLUSTERS'**
  String get cpuClustersHeader;

  /// No description provided for @gpuAndDramHeader.
  ///
  /// In en, this message translates to:
  /// **'GRAPHICS ENGINE & DRAM BUS'**
  String get gpuAndDramHeader;

  /// No description provided for @thermalAndPowerHeader.
  ///
  /// In en, this message translates to:
  /// **'THERMAL STATE & POWER'**
  String get thermalAndPowerHeader;

  /// No description provided for @socSilicon.
  ///
  /// In en, this message translates to:
  /// **'SoC SILICON'**
  String get socSilicon;

  /// No description provided for @smartBypass.
  ///
  /// In en, this message translates to:
  /// **'SMART BYPASS'**
  String get smartBypass;

  /// No description provided for @powerRail.
  ///
  /// In en, this message translates to:
  /// **'POWER RAIL'**
  String get powerRail;

  /// No description provided for @directSilicon.
  ///
  /// In en, this message translates to:
  /// **'⚡ Direct Silicon'**
  String get directSilicon;

  /// No description provided for @cellIsolated.
  ///
  /// In en, this message translates to:
  /// **'Thermal cell isolated'**
  String get cellIsolated;

  /// No description provided for @standardConsumption.
  ///
  /// In en, this message translates to:
  /// **'Standard consumption'**
  String get standardConsumption;

  /// No description provided for @batteryTempCell.
  ///
  /// In en, this message translates to:
  /// **'{temp}°C cell temp'**
  String batteryTempCell(String temp);

  /// No description provided for @batteryPct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Battery'**
  String batteryPct(String pct);

  /// No description provided for @minFreq.
  ///
  /// In en, this message translates to:
  /// **'Min Frequency'**
  String get minFreq;

  /// No description provided for @maxFreq.
  ///
  /// In en, this message translates to:
  /// **'Max Frequency'**
  String get maxFreq;

  /// No description provided for @governor.
  ///
  /// In en, this message translates to:
  /// **'Governor'**
  String get governor;

  /// No description provided for @onlineCores.
  ///
  /// In en, this message translates to:
  /// **'Online Cores'**
  String get onlineCores;

  /// No description provided for @freqMode.
  ///
  /// In en, this message translates to:
  /// **'Frequency Mode'**
  String get freqMode;

  /// No description provided for @dvfsAuto.
  ///
  /// In en, this message translates to:
  /// **'DVFS — Auto'**
  String get dvfsAuto;

  /// No description provided for @fixedFreq.
  ///
  /// In en, this message translates to:
  /// **'Fixed Frequency'**
  String get fixedFreq;

  /// No description provided for @minFreqDram.
  ///
  /// In en, this message translates to:
  /// **'Min Frequency (DVFSRC)'**
  String get minFreqDram;

  /// No description provided for @ufsClkEnable.
  ///
  /// In en, this message translates to:
  /// **'UFS_CLK_ENABLE'**
  String get ufsClkEnable;

  /// No description provided for @clockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Clock enabled'**
  String get clockEnabled;

  /// No description provided for @clockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Clock disabled'**
  String get clockDisabled;

  /// No description provided for @rateLimits.
  ///
  /// In en, this message translates to:
  /// **'Rate Limits'**
  String get rateLimits;

  /// No description provided for @downRateLimit.
  ///
  /// In en, this message translates to:
  /// **'DOWN (µs)'**
  String get downRateLimit;

  /// No description provided for @upRateLimit.
  ///
  /// In en, this message translates to:
  /// **'UP (µs)'**
  String get upRateLimit;

  /// No description provided for @forceOnOff.
  ///
  /// In en, this message translates to:
  /// **'FORCE_ONOFF'**
  String get forceOnOff;

  /// No description provided for @offOption.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offOption;

  /// No description provided for @onOption.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onOption;

  /// No description provided for @freeOption.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeOption;

  /// No description provided for @taBoost.
  ///
  /// In en, this message translates to:
  /// **'BOOST_TA'**
  String get taBoost;

  /// No description provided for @taBoostEnabled.
  ///
  /// In en, this message translates to:
  /// **'TA boost enabled'**
  String get taBoostEnabled;

  /// No description provided for @taBoostDisabled.
  ///
  /// In en, this message translates to:
  /// **'TA boost disabled'**
  String get taBoostDisabled;

  /// No description provided for @gbeActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time frame prediction & boost active'**
  String get gbeActiveDesc;

  /// No description provided for @gbeInactiveDesc.
  ///
  /// In en, this message translates to:
  /// **'GBE engine optimization disabled'**
  String get gbeInactiveDesc;

  /// No description provided for @bypassChargeActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Charge speed maximized during high load'**
  String get bypassChargeActiveDesc;

  /// No description provided for @bypassChargeInactiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard thermal charge curve applied'**
  String get bypassChargeInactiveDesc;

  /// No description provided for @unlockFpsActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Display refresh rate preserved at high temps'**
  String get unlockFpsActiveDesc;

  /// No description provided for @unlockFpsInactiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard FPS thermal throttling enabled'**
  String get unlockFpsInactiveDesc;

  /// No description provided for @batterySafetyGuard.
  ///
  /// In en, this message translates to:
  /// **'Battery Temp Safety Cutoff Guard'**
  String get batterySafetyGuard;

  /// No description provided for @gbeDirectiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forces game frequencies and turbo GPU'**
  String get gbeDirectiveSubtitle;

  /// No description provided for @bypassDirectiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powers silicon directly without heating battery'**
  String get bypassDirectiveSubtitle;

  /// No description provided for @hwChargeBypassTitle.
  ///
  /// In en, this message translates to:
  /// **'Hardware Charge Bypass'**
  String get hwChargeBypassTitle;

  /// No description provided for @hwChargeBypassDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct AC power to motherboard without charging or heating battery'**
  String get hwChargeBypassDesc;

  /// No description provided for @hwBypassActive.
  ///
  /// In en, this message translates to:
  /// **'Hardware Bypass Active'**
  String get hwBypassActive;

  /// No description provided for @hwBypassInactive.
  ///
  /// In en, this message translates to:
  /// **'Standard Charging Active'**
  String get hwBypassInactive;

  /// No description provided for @hwBypassDirectiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powers motherboard directly without heating battery'**
  String get hwBypassDirectiveSubtitle;

  /// No description provided for @smartFastChargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Fast Charge'**
  String get smartFastChargeTitle;

  /// No description provided for @smartFastChargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintains high charging speed during gaming by preventing thermal throttling'**
  String get smartFastChargeDesc;

  /// No description provided for @smartFastChargeActive.
  ///
  /// In en, this message translates to:
  /// **'Fast Charge Active'**
  String get smartFastChargeActive;

  /// No description provided for @smartFastChargeInactive.
  ///
  /// In en, this message translates to:
  /// **'Thermal Throttling Active'**
  String get smartFastChargeInactive;

  /// No description provided for @smartFastChargeDirectiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevents charge speed drops due to temperature during gaming'**
  String get smartFastChargeDirectiveSubtitle;

  /// No description provided for @smartFastChargeTelemetry.
  ///
  /// In en, this message translates to:
  /// **'⚡ Fast Charge Active'**
  String get smartFastChargeTelemetry;

  /// No description provided for @smartFastChargeTelemetryDesc.
  ///
  /// In en, this message translates to:
  /// **'Thermal throttle bypassed'**
  String get smartFastChargeTelemetryDesc;

  /// No description provided for @thermalBypassTitle.
  ///
  /// In en, this message translates to:
  /// **'Thermal Bypass (Disable Throttling)'**
  String get thermalBypassTitle;

  /// No description provided for @thermalBypassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disables OEM thermal throttling services for max gaming performance'**
  String get thermalBypassSubtitle;

  /// No description provided for @modeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global Mode'**
  String get modeGlobal;

  /// No description provided for @gpuCore.
  ///
  /// In en, this message translates to:
  /// **'GPU CORE'**
  String get gpuCore;

  /// No description provided for @busDram.
  ///
  /// In en, this message translates to:
  /// **'BUS DRAM'**
  String get busDram;

  /// No description provided for @revertChanges.
  ///
  /// In en, this message translates to:
  /// **'Revert changes'**
  String get revertChanges;

  /// No description provided for @systemAppTag.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemAppTag;

  /// No description provided for @tabPerf.
  ///
  /// In en, this message translates to:
  /// **'Perf'**
  String get tabPerf;

  /// No description provided for @tabBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get tabBalanced;

  /// No description provided for @tabPowersave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tabPowersave;

  /// No description provided for @tabPowersavePlus.
  ///
  /// In en, this message translates to:
  /// **'Save+'**
  String get tabPowersavePlus;

  /// No description provided for @cardPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get cardPerformance;

  /// No description provided for @cardBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get cardBalanced;

  /// No description provided for @cardPowersave.
  ///
  /// In en, this message translates to:
  /// **'Power Save'**
  String get cardPowersave;

  /// No description provided for @cardPowersavePlus.
  ///
  /// In en, this message translates to:
  /// **'Power Save+'**
  String get cardPowersavePlus;

  /// No description provided for @cardTagPerformance.
  ///
  /// In en, this message translates to:
  /// **'High Power'**
  String get cardTagPerformance;

  /// No description provided for @cardTagBalanced.
  ///
  /// In en, this message translates to:
  /// **'Daily Use'**
  String get cardTagBalanced;

  /// No description provided for @cardTagPowersave.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get cardTagPowersave;

  /// No description provided for @cardTagPowersavePlus.
  ///
  /// In en, this message translates to:
  /// **'Ultra Saver'**
  String get cardTagPowersavePlus;

  /// No description provided for @fpsgoHeader.
  ///
  /// In en, this message translates to:
  /// **'REFRESH RATE / FPS (FPSGO)'**
  String get fpsgoHeader;

  /// No description provided for @batteryOk.
  ///
  /// In en, this message translates to:
  /// **'Battery OK'**
  String get batteryOk;

  /// No description provided for @tgPredictive.
  ///
  /// In en, this message translates to:
  /// **'PREDICTIVE'**
  String get tgPredictive;

  /// No description provided for @tgStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get tgStatusDisabled;

  /// No description provided for @tgStatusClamping.
  ///
  /// In en, this message translates to:
  /// **'CLAMPING ACTIVE ({step}/{max})'**
  String tgStatusClamping(String step, String max);

  /// No description provided for @tgStatusCooldown.
  ///
  /// In en, this message translates to:
  /// **'COOLING DOWN'**
  String get tgStatusCooldown;

  /// No description provided for @tgStatusMonitoring.
  ///
  /// In en, this message translates to:
  /// **'MONITORING'**
  String get tgStatusMonitoring;

  /// No description provided for @tgStatusNominal.
  ///
  /// In en, this message translates to:
  /// **'NOMINAL (OPTIMAL)'**
  String get tgStatusNominal;

  /// No description provided for @tgSubDisabled.
  ///
  /// In en, this message translates to:
  /// **'Predictive thermal protection disabled'**
  String get tgSubDisabled;

  /// No description provided for @tgSubClamping.
  ///
  /// In en, this message translates to:
  /// **'Attenuating frequencies (-{pct}%)'**
  String tgSubClamping(String pct);

  /// No description provided for @tgSubCooldown.
  ///
  /// In en, this message translates to:
  /// **'Recovering baseline frequencies'**
  String get tgSubCooldown;

  /// No description provided for @tgSubMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring thermal gradient rise'**
  String get tgSubMonitoring;

  /// No description provided for @tgSubNominal.
  ///
  /// In en, this message translates to:
  /// **'Stable frequencies at maximum rate'**
  String get tgSubNominal;

  /// No description provided for @tgDescription.
  ///
  /// In en, this message translates to:
  /// **'Prevents sudden FPS drops (sawtooth) by smoothly stepping down frequencies before hard thermal throttling.'**
  String get tgDescription;

  /// No description provided for @tgRealtimeStatus.
  ///
  /// In en, this message translates to:
  /// **'REAL-TIME STATUS'**
  String get tgRealtimeStatus;

  /// No description provided for @tgTrend.
  ///
  /// In en, this message translates to:
  /// **'TREND (ΔT/Δt)'**
  String get tgTrend;

  /// No description provided for @tgTargetTemp.
  ///
  /// In en, this message translates to:
  /// **'Target SoC Temperature:'**
  String get tgTargetTemp;

  /// No description provided for @tgTempCool.
  ///
  /// In en, this message translates to:
  /// **'65°C (Cool)'**
  String get tgTempCool;

  /// No description provided for @tgTempRecommended.
  ///
  /// In en, this message translates to:
  /// **'75°C (Recommended)'**
  String get tgTempRecommended;

  /// No description provided for @tgTempExtreme.
  ///
  /// In en, this message translates to:
  /// **'85°C (Extreme)'**
  String get tgTempExtreme;

  /// No description provided for @tgClampingAggressiveness.
  ///
  /// In en, this message translates to:
  /// **'Clamping Aggressiveness:'**
  String get tgClampingAggressiveness;

  /// No description provided for @tgStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1 Step'**
  String get tgStep1Title;

  /// No description provided for @tgStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get tgStep1Subtitle;

  /// No description provided for @tgStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2 Steps'**
  String get tgStep2Title;

  /// No description provided for @tgStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get tgStep2Subtitle;

  /// No description provided for @tgStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3 Steps'**
  String get tgStep3Title;

  /// No description provided for @tgStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get tgStep3Subtitle;

  /// No description provided for @tgStepSummary1.
  ///
  /// In en, this message translates to:
  /// **'1 step (-12%)'**
  String get tgStepSummary1;

  /// No description provided for @tgStepSummary2.
  ///
  /// In en, this message translates to:
  /// **'2 steps (-24%)'**
  String get tgStepSummary2;

  /// No description provided for @tgStepSummary3.
  ///
  /// In en, this message translates to:
  /// **'3 steps (-36%)'**
  String get tgStepSummary3;

  /// No description provided for @touchBoosterTitle.
  ///
  /// In en, this message translates to:
  /// **'Touch Booster'**
  String get touchBoosterTitle;

  /// No description provided for @touchBoosterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'480Hz polling rate & CPU affinity'**
  String get touchBoosterSubtitle;

  /// No description provided for @touchGameMode.
  ///
  /// In en, this message translates to:
  /// **'Gaming Mode & 480Hz Rate'**
  String get touchGameMode;

  /// No description provided for @touchGameModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlocks digitizer polling rate to 480Hz/2160Hz via hardware ioctl'**
  String get touchGameModeDesc;

  /// No description provided for @touchThpSmooth.
  ///
  /// In en, this message translates to:
  /// **'Host Processing Smoothing'**
  String get touchThpSmooth;

  /// No description provided for @touchThpSmoothDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables touch_thp_smooth driver filter for precise gesture tracking'**
  String get touchThpSmoothDesc;

  /// No description provided for @touchPinThreads.
  ///
  /// In en, this message translates to:
  /// **'Pin Touch Threads to Big Cores'**
  String get touchPinThreads;

  /// No description provided for @touchPinThreadsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pins touch IRQ and InputReader/Dispatcher to Big Cores (Leave OFF for heavy games to prevent thread contention)'**
  String get touchPinThreadsDesc;

  /// No description provided for @touchBadge.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get touchBadge;

  /// No description provided for @vmTitle.
  ///
  /// In en, this message translates to:
  /// **'Virtual Memory & Kernel'**
  String get vmTitle;

  /// No description provided for @swappiness.
  ///
  /// In en, this message translates to:
  /// **'Swappiness'**
  String get swappiness;

  /// No description provided for @swappinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Aggressiveness of memory page swapping (higher = more ZRAM usage)'**
  String get swappinessDesc;

  /// No description provided for @mglru.
  ///
  /// In en, this message translates to:
  /// **'Multi-Gen LRU (MGLRU)'**
  String get mglru;

  /// No description provided for @mglruDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern kernel pagecache reclaim algorithm for smooth multitasking'**
  String get mglruDesc;

  /// No description provided for @watermarkScale.
  ///
  /// In en, this message translates to:
  /// **'Watermark Scale Factor'**
  String get watermarkScale;

  /// No description provided for @watermarkScaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Memory pressure headroom before background kswapd wakeup'**
  String get watermarkScaleDesc;

  /// No description provided for @compactionProactiveness.
  ///
  /// In en, this message translates to:
  /// **'Proactive Compaction'**
  String get compactionProactiveness;

  /// No description provided for @compactionProactivenessDesc.
  ///
  /// In en, this message translates to:
  /// **'Proactively defragments system memory to prevent frame drops'**
  String get compactionProactivenessDesc;

  /// No description provided for @compactOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Compact Memory on Game Launch'**
  String get compactOnLaunch;

  /// No description provided for @compactOnLaunchDesc.
  ///
  /// In en, this message translates to:
  /// **'Triggers proactive memory compaction when launching games'**
  String get compactOnLaunchDesc;

  /// No description provided for @statInterval.
  ///
  /// In en, this message translates to:
  /// **'VM Stat Interval'**
  String get statInterval;

  /// No description provided for @displayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display Refresh Rate'**
  String get displayTitle;

  /// No description provided for @displayRefreshDesc.
  ///
  /// In en, this message translates to:
  /// **'Target panel refresh rate when this profile is active'**
  String get displayRefreshDesc;

  /// No description provided for @refreshRateAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto / Dynamic'**
  String get refreshRateAuto;

  /// No description provided for @refreshRate60.
  ///
  /// In en, this message translates to:
  /// **'60 Hz'**
  String get refreshRate60;

  /// No description provided for @refreshRate90.
  ///
  /// In en, this message translates to:
  /// **'90 Hz'**
  String get refreshRate90;

  /// No description provided for @refreshRate120.
  ///
  /// In en, this message translates to:
  /// **'120 Hz'**
  String get refreshRate120;

  /// No description provided for @refreshRate144.
  ///
  /// In en, this message translates to:
  /// **'144 Hz'**
  String get refreshRate144;

  /// No description provided for @maxFreqDram.
  ///
  /// In en, this message translates to:
  /// **'Max DRAM Frequency'**
  String get maxFreqDram;

  /// No description provided for @uncapped.
  ///
  /// In en, this message translates to:
  /// **'Uncapped'**
  String get uncapped;

  /// No description provided for @disableThermalServices.
  ///
  /// In en, this message translates to:
  /// **'Disable OEM Thermal Services'**
  String get disableThermalServices;

  /// No description provided for @disableThermalServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Eliminates OEM throttling services (e.g. mi_thermald) during gaming'**
  String get disableThermalServicesDesc;

  /// No description provided for @gentleCharge.
  ///
  /// In en, this message translates to:
  /// **'Gentle Charging'**
  String get gentleCharge;

  /// No description provided for @gentleChargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Restricts charging input to keep device cool while running games'**
  String get gentleChargeDesc;

  /// No description provided for @gentleChargeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled (Full Speed)'**
  String get gentleChargeDisabled;

  /// No description provided for @bypassMinBatt.
  ///
  /// In en, this message translates to:
  /// **'Bypass Min Battery Level'**
  String get bypassMinBatt;

  /// No description provided for @rescueEnable.
  ///
  /// In en, this message translates to:
  /// **'Frame Drop Rescue (FBT)'**
  String get rescueEnable;

  /// No description provided for @rescueEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant frequency boost when a frame drop is forecasted'**
  String get rescueEnableDesc;

  /// No description provided for @ultraRescue.
  ///
  /// In en, this message translates to:
  /// **'Ultra Rescue'**
  String get ultraRescue;

  /// No description provided for @ultraRescueDesc.
  ///
  /// In en, this message translates to:
  /// **'Aggressive CPU spike for heavy 3D rendering stutters'**
  String get ultraRescueDesc;

  /// No description provided for @downThrottle.
  ///
  /// In en, this message translates to:
  /// **'Suppress Down-Throttle'**
  String get downThrottle;

  /// No description provided for @downThrottleDesc.
  ///
  /// In en, this message translates to:
  /// **'Blocks CPU frequency reductions mid-frame render'**
  String get downThrottleDesc;

  /// No description provided for @tgProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Thermal Guardian (Profile)'**
  String get tgProfileTitle;

  /// No description provided for @tgProfileEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Proactive thermal headroom regulation for this profile'**
  String get tgProfileEnableDesc;

  /// No description provided for @tgUclampStep.
  ///
  /// In en, this message translates to:
  /// **'Uclamp Reduction per Step'**
  String get tgUclampStep;

  /// No description provided for @renderBoost.
  ///
  /// In en, this message translates to:
  /// **'RenderBooster'**
  String get renderBoost;

  /// No description provided for @renderBoostDesc.
  ///
  /// In en, this message translates to:
  /// **'Pins and elevates UI and render threads to Big/Prime cores for stutter-free frames'**
  String get renderBoostDesc;

  /// No description provided for @appOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'App Overrides (Optional)'**
  String get appOverridesTitle;

  /// No description provided for @appOverridesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporarily override profile settings for this app'**
  String get appOverridesSubtitle;

  /// No description provided for @appOverridesInherited.
  ///
  /// In en, this message translates to:
  /// **'Inherits from profile'**
  String get appOverridesInherited;

  /// No description provided for @appOverridesActiveCount.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get appOverridesActiveCount;

  /// No description provided for @appOverridesNotice.
  ///
  /// In en, this message translates to:
  /// **'By default, the app inherits all settings from the selected profile. Enable these options only if you need specific exceptions for this app.'**
  String get appOverridesNotice;

  /// No description provided for @appOverridesReset.
  ///
  /// In en, this message translates to:
  /// **'Clear Overrides'**
  String get appOverridesReset;

  /// No description provided for @perfAndTouchSection.
  ///
  /// In en, this message translates to:
  /// **'Performance & Touch'**
  String get perfAndTouchSection;

  /// No description provided for @thermalChargeSection.
  ///
  /// In en, this message translates to:
  /// **'Thermal & Charging'**
  String get thermalChargeSection;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @vipPipelineHeader.
  ///
  /// In en, this message translates to:
  /// **'GAME ENGINE VIP PIPELINE'**
  String get vipPipelineHeader;

  /// No description provided for @bgJailedBadge.
  ///
  /// In en, this message translates to:
  /// **'BG JAILED (LITTLE 0-3)'**
  String get bgJailedBadge;

  /// No description provided for @bgNormalBadge.
  ///
  /// In en, this message translates to:
  /// **'STANDARD'**
  String get bgNormalBadge;

  /// No description provided for @bgJailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Background tasks quarantined to Little Cores with 20% uclamp'**
  String get bgJailedDesc;

  /// No description provided for @noVipThreads.
  ///
  /// In en, this message translates to:
  /// **'Awaiting game engine thread spawn...'**
  String get noVipThreads;

  /// No description provided for @corePrime.
  ///
  /// In en, this message translates to:
  /// **'Core 7 (Prime)'**
  String get corePrime;

  /// No description provided for @coreBig.
  ///
  /// In en, this message translates to:
  /// **'Cores 4-6 (Big)'**
  String get coreBig;

  /// No description provided for @coreAllBig.
  ///
  /// In en, this message translates to:
  /// **'Cores 4-7 (All Big)'**
  String get coreAllBig;

  /// No description provided for @dvfsrcTurboQosTitle.
  ///
  /// In en, this message translates to:
  /// **'Turbo QoS Interconnect (DVFSRC)'**
  String get dvfsrcTurboQosTitle;

  /// No description provided for @dvfsrcTurboQosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Forces maximum memory interconnect priority and full DRAM bandwidth'**
  String get dvfsrcTurboQosSubtitle;

  /// No description provided for @fstbTuneQuantileTitle.
  ///
  /// In en, this message translates to:
  /// **'FSTB Frame Delivery Quantile'**
  String get fstbTuneQuantileTitle;

  /// No description provided for @fstbTuneQuantileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Statistical estimator percentile for frame rendering capacity (P95/P99 prevents micro-stutters)'**
  String get fstbTuneQuantileSubtitle;

  /// No description provided for @quantileP50.
  ///
  /// In en, this message translates to:
  /// **'P50 (Median)'**
  String get quantileP50;

  /// No description provided for @quantileP95.
  ///
  /// In en, this message translates to:
  /// **'P95 (Smooth)'**
  String get quantileP95;

  /// No description provided for @quantileP99.
  ///
  /// In en, this message translates to:
  /// **'P99 (Extreme)'**
  String get quantileP99;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @titleBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery & Charging'**
  String get titleBattery;

  /// No description provided for @batteryHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time telemetry and intelligent charging controls'**
  String get batteryHeroSubtitle;

  /// No description provided for @chargeSpeedRegulator.
  ///
  /// In en, this message translates to:
  /// **'Charging Speed Regulator'**
  String get chargeSpeedRegulator;

  /// No description provided for @chargeSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Limit maximum charging current to preserve battery health and prevent heat during use or gaming'**
  String get chargeSpeedDesc;

  /// No description provided for @currentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Current Rate'**
  String get currentSpeed;

  /// No description provided for @currentVoltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get currentVoltage;

  /// No description provided for @currentPower.
  ///
  /// In en, this message translates to:
  /// **'Power Draw'**
  String get currentPower;

  /// No description provided for @chargeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chargeStatus;

  /// No description provided for @unlimitedTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo / Max (67W)'**
  String get unlimitedTurbo;

  /// No description provided for @fastChargePreset.
  ///
  /// In en, this message translates to:
  /// **'Fast (3000 mA)'**
  String get fastChargePreset;

  /// No description provided for @balancedChargePreset.
  ///
  /// In en, this message translates to:
  /// **'Balanced (2000 mA)'**
  String get balancedChargePreset;

  /// No description provided for @gentleChargePreset.
  ///
  /// In en, this message translates to:
  /// **'Night / Gentle (1000 mA)'**
  String get gentleChargePreset;

  /// No description provided for @customLimit.
  ///
  /// In en, this message translates to:
  /// **'Custom Limit'**
  String get customLimit;

  /// No description provided for @chargeLimitPct.
  ///
  /// In en, this message translates to:
  /// **'Charge Cut-off Limit'**
  String get chargeLimitPct;

  /// No description provided for @chargingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Charging Current'**
  String get chargingCurrent;

  /// No description provided for @dischargingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Discharging Current'**
  String get dischargingCurrent;

  /// No description provided for @batteryHealthGood.
  ///
  /// In en, this message translates to:
  /// **'Battery Health'**
  String get batteryHealthGood;

  /// No description provided for @fastChargeStatus.
  ///
  /// In en, this message translates to:
  /// **'Turbo Charge'**
  String get fastChargeStatus;

  /// No description provided for @batteryHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Health & Longevity'**
  String get batteryHealthTitle;

  /// No description provided for @batteryHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Hardware-verified BMS cell degradation, life cycles, and design capacity'**
  String get batteryHealthDesc;

  /// No description provided for @batteryCycles.
  ///
  /// In en, this message translates to:
  /// **'Charge Cycles'**
  String get batteryCycles;

  /// No description provided for @batteryDesignCapacity.
  ///
  /// In en, this message translates to:
  /// **'Design Capacity'**
  String get batteryDesignCapacity;

  /// No description provided for @batteryActualCapacity.
  ///
  /// In en, this message translates to:
  /// **'Current Capacity'**
  String get batteryActualCapacity;

  /// No description provided for @batterySoh.
  ///
  /// In en, this message translates to:
  /// **'State of Health (SOH)'**
  String get batterySoh;

  /// No description provided for @timeToFull.
  ///
  /// In en, this message translates to:
  /// **'Until Full (100%)'**
  String get timeToFull;

  /// No description provided for @timeToProtection.
  ///
  /// In en, this message translates to:
  /// **'Until Protection Limit'**
  String get timeToProtection;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Estimated Runtime'**
  String get timeRemaining;

  /// No description provided for @dischargeRate.
  ///
  /// In en, this message translates to:
  /// **'Discharge Rate'**
  String get dischargeRate;

  /// No description provided for @chargingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Charging Rate'**
  String get chargingSpeed;

  /// No description provided for @backupManager.
  ///
  /// In en, this message translates to:
  /// **'Backups & Snapshots'**
  String get backupManager;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Snapshots'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save snapshots of your custom kernel profiles and restore them anytime with a single tap'**
  String get backupSubtitle;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @createBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Compress and archive all current .conf profiles into a timestamped snapshot'**
  String get createBackupDesc;

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating snapshot...'**
  String get creatingBackup;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup snapshot created successfully!'**
  String get backupCreatedSuccess;

  /// No description provided for @backupCreateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup archive'**
  String get backupCreateError;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreBackup;

  /// No description provided for @restoringBackup.
  ///
  /// In en, this message translates to:
  /// **'Restoring profiles...'**
  String get restoringBackup;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profiles restored successfully!'**
  String get restoreSuccess;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup archive'**
  String get restoreError;

  /// No description provided for @confirmRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Profile Snapshot?'**
  String get confirmRestoreTitle;

  /// No description provided for @confirmRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'All current hardware profile configurations will be replaced by this snapshot and applied immediately.'**
  String get confirmRestoreMessage;

  /// No description provided for @resetStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate PerfMTK Profiles'**
  String get resetStockTitle;

  /// No description provided for @resetStockDesc.
  ///
  /// In en, this message translates to:
  /// **'Regenerates optimized default profiles for your MediaTek processor (an automatic safety backup will be created first).'**
  String get resetStockDesc;

  /// No description provided for @resetStockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to regenerate all profiles with PerfMTK recommended settings? An automatic safety backup will be created before proceeding.'**
  String get resetStockConfirm;

  /// No description provided for @resetStockSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recommended profiles regenerated and applied successfully!'**
  String get resetStockSuccess;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No Backups Found'**
  String get noBackupsFound;

  /// No description provided for @noBackupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your first profile backup snapshot to keep your custom configurations safe.'**
  String get noBackupsDesc;

  /// No description provided for @deleteBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup?'**
  String get deleteBackupTitle;

  /// No description provided for @deleteBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this profile snapshot? This action cannot be undone.'**
  String get deleteBackupConfirm;

  /// No description provided for @deleteAllBackupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Backups?'**
  String get deleteAllBackupsTitle;

  /// No description provided for @deleteAllBackupsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved profile backup snapshots? This action cannot be undone.'**
  String get deleteAllBackupsConfirm;

  /// No description provided for @backupDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted successfully'**
  String get backupDeletedSuccess;

  /// No description provided for @backupDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete backup snapshot'**
  String get backupDeleteError;

  /// No description provided for @allBackupsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All backups have been deleted'**
  String get allBackupsDeletedSuccess;

  /// No description provided for @backupLatestBadge.
  ///
  /// In en, this message translates to:
  /// **'LATEST SNAPSHOT'**
  String get backupLatestBadge;

  /// No description provided for @backupProfilesCount.
  ///
  /// In en, this message translates to:
  /// **'4 profiles (.conf)'**
  String get backupProfilesCount;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Total Storage'**
  String get storageUsed;

  /// No description provided for @backupsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Snapshots'**
  String get backupsCountLabel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @updateVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} available for download'**
  String updateVersionAvailable(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
