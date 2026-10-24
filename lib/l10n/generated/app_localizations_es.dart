// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get profiles => 'Perfiles';

  @override
  String get thermal => 'Termal';

  @override
  String get titleProfiles => 'Perfiles de Energía';

  @override
  String get subtitleProfiles => 'Perfiles globales';

  @override
  String get currentProfile => 'Perfil actual';

  @override
  String get defaultProfile => 'Perfil predeterminado';

  @override
  String get performance => 'Alto rendimiento';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get powersave => 'Ahorro de energía';

  @override
  String get powersavePlus => 'Ahorro máximo de energía';

  @override
  String get performanceCard => 'Máximo rendimiento.';

  @override
  String get balancedCard => 'Buen rendimiento.';

  @override
  String get powersaveCard => 'Ahorra batería.';

  @override
  String get powersavePlusCard => 'Maximiza la vida de tu batería.';

  @override
  String get titleThermal => 'Gestión térmica';

  @override
  String get thermalState => 'Limitación térmica';

  @override
  String get thermalControl => 'Control Térmico';

  @override
  String get enabled => 'Activada';

  @override
  String get disabled => 'Desactivada';

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get enableDsc =>
      'Activa el control de temperatura; se recomienda mantenerlo activado';

  @override
  String get disableDsc =>
      'Desactiva el control de temperatura; es posible que no haya mejora en el rendimiento';

  @override
  String get snackBarText => 'Instale la última versión del módulo.';

  @override
  String get snackBarLabel => 'Descargar';

  @override
  String get downloadMess => 'No se pudo abrir el enlace de descarga.';

  @override
  String get updateMess => 'Nueva actualización disponible';

  @override
  String get updateNew => 'Novedades:';

  @override
  String get updateCancel => 'Más tarde';

  @override
  String get updateDown => 'Descargar';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get profileSettings => 'Ajustes de Perfil';

  @override
  String get about => 'Acerca de';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get lockFreq => 'Bloquear frecuencias de procesador';

  @override
  String get lockFreqDescription =>
      'Este ajuste solo se aplica al perfil de Rendimiento.';

  @override
  String get defaultProfileDescription =>
      'Selecciona el perfil predeterminado al iniciar la aplicación';

  @override
  String get aboutDescription =>
      'PerfMTK Manager es una aplicación para gestionar los perfiles de rendimiento y ajustes térmicos de tu dispositivo.';

  @override
  String get back => 'Regresar';

  @override
  String get developer => 'Desarrollador';

  @override
  String get compDevices => 'Dispositivos compatibles';

  @override
  String get appProfiles => 'Perfiles de Apps';

  @override
  String get titleAppProfiles => 'Perfiles de Aplicación';

  @override
  String get searchApps => 'Buscar aplicaciones';

  @override
  String get noAppsFound => 'No se encontraron aplicaciones';

  @override
  String get appProfilesDescription =>
      'Configura perfiles de rendimiento para aplicaciones individuales';

  @override
  String get allApps => 'Todas las Apps';

  @override
  String get configuredApps => 'Configuradas';

  @override
  String get notConfiguredApps => 'Sin Configurar';

  @override
  String get noSearchResults => 'No se encontraron apps para tu búsqueda';

  @override
  String get clearSearch => 'Limpiar Búsqueda';

  @override
  String get errorLoadingApps => 'Error al cargar aplicaciones';

  @override
  String get retry => 'Reintentar';

  @override
  String profileSet(String app, String profile) {
    return 'Perfil para $app configurado a $profile';
  }

  @override
  String profileReset(String app) {
    return 'Perfil predeterminado restaurado para $app';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get changeProfile => 'Cambiar perfil';

  @override
  String get selectProfile => 'Seleccionar perfil de rendimiento';

  @override
  String profileApplied(String profile) {
    return 'Perfil \"$profile\" aplicado globalmente';
  }

  @override
  String get applying => 'Aplicando...';

  @override
  String get includeSystemApps => 'Incluir aplicaciones del sistema';

  @override
  String get includeSystemAppsDesc =>
      'Mostrar aplicaciones críticas del sistema';

  @override
  String get daemonSettings => 'Ajustes del Daemon';

  @override
  String get screenOffProfile => 'Perfil con pantalla apagada';

  @override
  String get screenOffProfileDesc =>
      'Perfil que se aplica cuando la pantalla se apaga';

  @override
  String get appDebounceMs => 'Retardo al cambiar de app';

  @override
  String get appDebounceMsDesc =>
      'Tiempo de espera antes de cambiar el perfil al cambiar de aplicación';

  @override
  String get milliseconds => 'ms';

  @override
  String get perfConfig => 'Config';

  @override
  String get titlePerfConfig => 'Editor de Perfiles';

  @override
  String get perfConfigDescription =>
      'Editar archivos de configuración de perfiles de rendimiento';

  @override
  String get saveChanges => 'Guardar';

  @override
  String get configSaved => 'Configuración guardada correctamente';

  @override
  String get configSaveError => 'Error al guardar la configuración';

  @override
  String get savingConfig => 'Guardando...';

  @override
  String get perfConfigError =>
      '¿El módulo PerfMTK está instalado? No se pudo cargar la configuración.';

  @override
  String get themeSystemDesc => 'Usar configuración del sistema';

  @override
  String get themeLightDesc => 'Tema claro';

  @override
  String get themeDarkDesc => 'Tema oscuro';

  @override
  String get defaultProfileDesc =>
      'Usar la configuración predeterminada global';

  @override
  String get performanceDesc =>
      'Máximo rendimiento de CPU y GPU. Mayor consumo de batería';

  @override
  String get balancedDesc =>
      'Equilibrio entre rendimiento y duración de batería';

  @override
  String get powersaveDesc =>
      'Rendimiento reducido para mejor duración de batería';

  @override
  String get powersavePlusDesc =>
      'Máximo ahorro de batería con rendimiento mínimo';

  @override
  String get hardwareTelemetry => 'Telemetría de Hardware';

  @override
  String get activeEngine => 'Motor de Detección';

  @override
  String get fgEnginePush => 'LSPosed Hook (Push)';

  @override
  String get fgEngineCgroup => 'Kernel cgroup (Inotify)';

  @override
  String get fgEnginePoller => 'Adaptive Poller (Fallback)';

  @override
  String get dramFreq => 'Frecuencia DRAM';

  @override
  String get gpuFreq => 'Frecuencia GPU';

  @override
  String get cpuFreq => 'Clústeres CPU';

  @override
  String get socTemp => 'Temp. SoC';

  @override
  String get batteryTemp => 'Temp. Batería';

  @override
  String get chargeBypass => 'Bypass de Carga';

  @override
  String get chargeBypassTitle => 'Smart Fast Charge Bypass';

  @override
  String get chargeBypassDesc =>
      'Evita la limitación térmica durante la carga rápida con protección de seguridad';

  @override
  String get chargeBypassActive => 'Bypass Activo';

  @override
  String get chargeBypassInactive => 'Bypass Inactivo';

  @override
  String get safetyGuardLimit => 'Límite de Guardia Térmica';

  @override
  String get uclamp => 'EAS UCLAMP';

  @override
  String get uclampTitle => 'Asignación de Tareas y Abrazaderas de Frecuencia';

  @override
  String get uclampTopAppMin => 'UCLAMP Mínimo Top-App';

  @override
  String get uclampTopAppMax => 'UCLAMP Máximo Top-App';

  @override
  String get uclampFgMin => 'UCLAMP Mínimo Foreground';

  @override
  String get uclampFgMax => 'UCLAMP Máximo Foreground';

  @override
  String get gbeTitle => 'MediaTek Game Turbo (GBE)';

  @override
  String get gbeDesc =>
      'Optimización de predicción de cuadros y programación del motor MediaTek GBE';

  @override
  String get gbeEnable => 'Optimización GBE';

  @override
  String get gbeThermalHeadroom => 'Margen Térmico de Seguridad';

  @override
  String get thermalChargeTitle => 'Límites Térmicos y Bypass de Carga';

  @override
  String get thermalFastChargeTitle => 'Límites Térmicos y Carga Rápida';

  @override
  String get unlockFpsThermal => 'Desbloquear Límite FPS Térmico';

  @override
  String get unlockFpsThermalDesc =>
      'Evita que el daemon térmico limite la tasa de refresco de pantalla';

  @override
  String get bypassChargeThrottle => 'Bypass de Límite de Carga';

  @override
  String get bypassChargeThrottleDesc =>
      'Fuerza la máxima velocidad de carga ignorando la limitación térmica';

  @override
  String get batteryTempLimit => 'Límite Térmico de Seguridad de Batería (°C)';

  @override
  String get gameDirectives => 'Directives y Ajustes Específicos';

  @override
  String get dramFloor => 'Frecuencia Mínima DRAM';

  @override
  String get thermalChartTitle => 'Telemetría Térmica en Tiempo Real';

  @override
  String get thermalChartSubtitle =>
      'Curvas continuas de temperatura de SoC y Batería (últimos 60s)';

  @override
  String get socTempLabel => 'SoC';

  @override
  String get batteryTempLabel => 'Batería';

  @override
  String get batteryCareTitle => 'Cuidado de Batería';

  @override
  String get batteryCareDesc =>
      'Pausa la corriente de carga automáticamente al alcanzar el límite para prolongar la vida útil de la batería.';

  @override
  String get batteryCareLimit => 'Límite de Carga';

  @override
  String get batteryCareSuspended => 'Carga Pausada (Protección Activa)';

  @override
  String get batteryCareNormal => 'Carga Normal (Hasta el 100%)';

  @override
  String get switchProfileHeader => 'CAMBIAR PERFIL';

  @override
  String get hardwareMonitorHeader => 'MONITOR DE HARDWARE EN VIVO';

  @override
  String get siliconState => 'ESTADO DEL SILICIO';

  @override
  String get siliconStateSubtitle => 'Consola dinámica del SoC MediaTek';

  @override
  String get liveBadge => 'EN VIVO';

  @override
  String get cpuClustersHeader => 'CLÚSTERES DE CPU';

  @override
  String get gpuAndDramHeader => 'MOTOR GRÁFICO & BUS DRAM';

  @override
  String get thermalAndPowerHeader => 'ESTADO TÉRMICO & ENERGÍA';

  @override
  String get socSilicon => 'SoC SILICIO';

  @override
  String get smartBypass => 'SMART BYPASS';

  @override
  String get powerRail => 'ALIMENTACIÓN';

  @override
  String get directSilicon => '⚡ Silicio Directo';

  @override
  String get cellIsolated => 'Celda aislada de calor';

  @override
  String get standardConsumption => 'Consumo estándar';

  @override
  String batteryTempCell(String temp) {
    return '$temp°C temperatura celda';
  }

  @override
  String batteryPct(String pct) {
    return '$pct% Batería';
  }

  @override
  String get minFreq => 'Frecuencia Mínima';

  @override
  String get maxFreq => 'Frecuencia Máxima';

  @override
  String get governor => 'Gobernador';

  @override
  String get onlineCores => 'Núcleos Activos';

  @override
  String get freqMode => 'Modo de Frecuencia';

  @override
  String get dvfsAuto => 'DVFS — Automático';

  @override
  String get fixedFreq => 'Frecuencia Fija';

  @override
  String get minFreqDram => 'Frecuencia Mínima (DVFSRC)';

  @override
  String get ufsClkEnable => 'UFS_CLK_ENABLE';

  @override
  String get clockEnabled => 'Reloj habilitado';

  @override
  String get clockDisabled => 'Reloj deshabilitado';

  @override
  String get rateLimits => 'Límites de Tasa';

  @override
  String get downRateLimit => 'DOWN (µs)';

  @override
  String get upRateLimit => 'UP (µs)';

  @override
  String get forceOnOff => 'FORCE_ONOFF';

  @override
  String get offOption => 'Apagado';

  @override
  String get onOption => 'Encendido';

  @override
  String get freeOption => 'Libre';

  @override
  String get taBoost => 'BOOST_TA';

  @override
  String get taBoostEnabled => 'TA boost activado';

  @override
  String get taBoostDisabled => 'TA boost desactivado';

  @override
  String get gbeActiveDesc =>
      'Predicción de cuadros en tiempo real y boost activo';

  @override
  String get gbeInactiveDesc => 'Optimización de motor GBE desactivada';

  @override
  String get bypassChargeActiveDesc =>
      'Velocidad de carga maximizada bajo alta carga';

  @override
  String get bypassChargeInactiveDesc =>
      'Curva estándar de carga térmica aplicada';

  @override
  String get unlockFpsActiveDesc =>
      'Tasa de refresco conservada a altas temperaturas';

  @override
  String get unlockFpsInactiveDesc =>
      'Limitación térmica FPS estándar activada';

  @override
  String get batterySafetyGuard => 'Protección de Corte Térmico de Batería';

  @override
  String get gbeDirectiveSubtitle => 'Fuerza frecuencias de juego y GPU turbo';

  @override
  String get bypassDirectiveSubtitle =>
      'Alimenta directo al silicio sin calentar la batería';

  @override
  String get hwChargeBypassTitle => 'Bypass de Carga (Hardware)';

  @override
  String get hwChargeBypassDesc =>
      'Alimenta directo a la placa base sin pasar por la batería';

  @override
  String get hwBypassActive => 'Bypass de Hardware Activo';

  @override
  String get hwBypassInactive => 'Carga Estándar Activa';

  @override
  String get hwBypassDirectiveSubtitle =>
      'Alimenta la placa directamente por cargador sin degradar la batería';

  @override
  String get smartFastChargeTitle => 'Carga Rápida en Juegos';

  @override
  String get smartFastChargeDesc =>
      'Evita que el sistema reduzca la velocidad de carga por temperatura mientras juegas (corte a 48°C)';

  @override
  String get smartFastChargeActive => 'Carga Rápida Activa';

  @override
  String get smartFastChargeInactive => 'Reducción Térmica Activa';

  @override
  String get smartFastChargeDirectiveSubtitle =>
      'Evita que caiga la velocidad de carga por temperatura en juegos';

  @override
  String get smartFastChargeTelemetry => '⚡ Carga Rápida Activa';

  @override
  String get smartFastChargeTelemetryDesc => 'Límite térmico anulado';

  @override
  String get thermalBypassTitle => 'Bypass Térmico (Desactivar Límite)';

  @override
  String get thermalBypassSubtitle =>
      'Desactiva los servicios térmicos del fabricante para máximo rendimiento en juegos';

  @override
  String get modeGlobal => 'Modo Global';

  @override
  String get gpuCore => 'NÚCLEO GPU';

  @override
  String get busDram => 'BUS DRAM';

  @override
  String get revertChanges => 'Revertir cambios';

  @override
  String get systemAppTag => 'Sistema';

  @override
  String get tabPerf => 'Perf';

  @override
  String get tabBalanced => 'Equil';

  @override
  String get tabPowersave => 'Ahorro';

  @override
  String get tabPowersavePlus => 'Ahorro+';

  @override
  String get cardPerformance => 'Rendimiento';

  @override
  String get cardBalanced => 'Equilibrado';

  @override
  String get cardPowersave => 'Ahorro';

  @override
  String get cardPowersavePlus => 'Ahorro+';

  @override
  String get cardTagPerformance => 'Potencia';

  @override
  String get cardTagBalanced => 'Uso diario';

  @override
  String get cardTagPowersave => 'Eficiencia';

  @override
  String get cardTagPowersavePlus => 'Ultra ahorro';

  @override
  String get fpsgoHeader => 'TASA DE REFRESCO / FPS (FPSGO)';

  @override
  String get batteryOk => 'Batería OK';

  @override
  String get tgPredictive => 'PREDICTIVO';

  @override
  String get tgStatusDisabled => 'DESACTIVADO';

  @override
  String tgStatusClamping(String step, String max) {
    return 'CLAMPING ACTIVO ($step/$max)';
  }

  @override
  String get tgStatusCooldown => 'ENFRIAMIENTO';

  @override
  String get tgStatusMonitoring => 'MONITOREANDO';

  @override
  String get tgStatusNominal => 'NOMINAL (ÓPTIMO)';

  @override
  String get tgSubDisabled => 'Protección predictiva desactivada';

  @override
  String tgSubClamping(String pct) {
    return 'Atenuando frecuencias (-$pct%)';
  }

  @override
  String get tgSubCooldown => 'Recuperando frecuencias normales';

  @override
  String get tgSubMonitoring => 'Vigilando gradiente térmico';

  @override
  String get tgSubNominal => 'Frecuencias estables a máxima tasa';

  @override
  String get tgDescription =>
      'Previene caídas bruscas de FPS (sawtooth) escalonando frecuencias suavemente antes del hard throttling.';

  @override
  String get tgRealtimeStatus => 'ESTADO EN TIEMPO REAL';

  @override
  String get tgTrend => 'TENDENCIA (ΔT/Δt)';

  @override
  String get tgTargetTemp => 'Temperatura SoC Objetivo:';

  @override
  String get tgTempCool => '65°C (Frío)';

  @override
  String get tgTempRecommended => '75°C (Recomendado)';

  @override
  String get tgTempExtreme => '85°C (Extremo)';

  @override
  String get tgClampingAggressiveness => 'Agresividad de Clamping:';

  @override
  String get tgStep1Title => '1 Paso';

  @override
  String get tgStep1Subtitle => 'Suave';

  @override
  String get tgStep2Title => '2 Pasos';

  @override
  String get tgStep2Subtitle => 'Óptimo';

  @override
  String get tgStep3Title => '3 Pasos';

  @override
  String get tgStep3Subtitle => 'Fuerte';

  @override
  String get tgStepSummary1 => '1 paso (-12%)';

  @override
  String get tgStepSummary2 => '2 pasos (-24%)';

  @override
  String get tgStepSummary3 => '3 pasos (-36%)';

  @override
  String get touchBoosterTitle => 'Acelerador Táctil';

  @override
  String get touchBoosterSubtitle => 'Muestreo a 480Hz y afinidad de CPU';

  @override
  String get touchGameMode => 'Modo Gaming y Tasa a 480Hz';

  @override
  String get touchGameModeDesc =>
      'Desbloquea el muestreo del digitalizador a 480Hz/2160Hz vía ioctl de hardware';

  @override
  String get touchThpSmooth => 'Suavizado THP del Host';

  @override
  String get touchThpSmoothDesc =>
      'Activa el filtro touch_thp_smooth para seguimiento preciso de gestos';

  @override
  String get touchPinThreads => 'Anclar Hilos Táctiles a Núcleos Big';

  @override
  String get touchPinThreadsDesc =>
      'Ancla la IRQ táctil e InputReader a núcleos Big (Recomendado APAGADO en juegos para evitar micro-tirones)';

  @override
  String get touchBadge => 'Touch';

  @override
  String get vmTitle => 'Memoria Virtual y Kernel';

  @override
  String get swappiness => 'Swappiness';

  @override
  String get swappinessDesc =>
      'Agresividad del intercambio de páginas de memoria (mayor = más uso de ZRAM)';

  @override
  String get mglru => 'Multi-Gen LRU (MGLRU)';

  @override
  String get mglruDesc =>
      'Algoritmo moderno de recuperación de caché de páginas para multitarea fluida';

  @override
  String get watermarkScale => 'Factor de Escala de Watermark';

  @override
  String get watermarkScaleDesc =>
      'Margen de presión de memoria antes del despertar de kswapd en segundo plano';

  @override
  String get compactionProactiveness => 'Compactación Proactiva';

  @override
  String get compactionProactivenessDesc =>
      'Desfragmenta la memoria proactivamente para evitar tirones de frames';

  @override
  String get compactOnLaunch => 'Compactar Memoria al Iniciar';

  @override
  String get compactOnLaunchDesc =>
      'Ejecuta compactación proactiva al abrir juegos exigentes';

  @override
  String get statInterval => 'Intervalo de Estadísticas VM';

  @override
  String get displayTitle => 'Tasa de Refresco de Pantalla';

  @override
  String get displayRefreshDesc =>
      'Tasa de refresco objetivo cuando este perfil está activo';

  @override
  String get refreshRateAuto => 'Auto / Dinámico';

  @override
  String get refreshRate60 => '60 Hz';

  @override
  String get refreshRate90 => '90 Hz';

  @override
  String get refreshRate120 => '120 Hz';

  @override
  String get refreshRate144 => '144 Hz';

  @override
  String get maxFreqDram => 'Frecuencia Máxima de DRAM';

  @override
  String get uncapped => 'Sin límite';

  @override
  String get disableThermalServices => 'Desactivar Servicios Térmicos OEM';

  @override
  String get disableThermalServicesDesc =>
      'Elimina servicios de throttling OEM (ej. mi_thermald) durante juegos';

  @override
  String get gentleCharge => 'Carga Suave (Gentle Charge)';

  @override
  String get gentleChargeDesc =>
      'Restringe la corriente de carga para mantener fresco el equipo al jugar conectado';

  @override
  String get gentleChargeDisabled => 'Desactivado (Velocidad completa)';

  @override
  String get bypassMinBatt => 'Nivel Mínimo de Batería para Bypass';

  @override
  String get rescueEnable => 'Rescate de Caída de FPS (FBT)';

  @override
  String get rescueEnableDesc =>
      'Aumento inmediato de frecuencias al prever una caída de frames';

  @override
  String get ultraRescue => 'Rescate Ultra';

  @override
  String get ultraRescueDesc =>
      'Pico agresivo de CPU ante tirones intensos en 3D';

  @override
  String get downThrottle => 'Suprimir Desaceleración en Frame';

  @override
  String get downThrottleDesc =>
      'Bloquea caídas de frecuencia de CPU a mitad del renderizado de frame';

  @override
  String get tgProfileTitle => 'Thermal Guardian (Perfil)';

  @override
  String get tgProfileEnableDesc =>
      'Regulación proactiva de margen térmico para este perfil';

  @override
  String get tgUclampStep => 'Reducción de Uclamp por Paso';

  @override
  String get renderBoost => 'RenderBooster';

  @override
  String get renderBoostDesc =>
      'Fija y eleva el hilo de UI y los hilos de render a núcleos Big/Prime para cero tirones';

  @override
  String get appOverridesTitle => 'Sobrescrituras por App (Opcional)';

  @override
  String get appOverridesSubtitle =>
      'Reemplaza temporalmente parámetros del perfil para esta app';

  @override
  String get appOverridesInherited => 'Hereda del perfil';

  @override
  String get appOverridesActiveCount => 'activas';

  @override
  String get appOverridesNotice =>
      'Por defecto, la aplicación hereda todos los ajustes del perfil. Activa estas opciones solo si requieres excepciones específicas para esta app.';

  @override
  String get appOverridesReset => 'Limpiar Sobrescrituras';

  @override
  String get perfAndTouchSection => 'Rendimiento y Táctil';

  @override
  String get thermalChargeSection => 'Térmico y Carga';

  @override
  String get done => 'Listo';

  @override
  String get vipPipelineHeader => 'CANAL VIP DEL MOTOR DE JUEGO';

  @override
  String get bgJailedBadge => 'BG AISLADO (LITTLE 0-3)';

  @override
  String get bgNormalBadge => 'ESTÁNDAR';

  @override
  String get bgJailedDesc =>
      'Tareas secundarias aisladas en núcleos Little al 20% de uclamp';

  @override
  String get noVipThreads => 'Esperando detección de hilos del motor...';

  @override
  String get corePrime => 'Núcleo 7 (Prime)';

  @override
  String get coreBig => 'Núcleos 4-6 (Big)';

  @override
  String get coreAllBig => 'Núcleos 4-7 (Todos Big)';

  @override
  String get dvfsrcTurboQosTitle => 'Turbo QoS del Bus (DVFSRC)';

  @override
  String get dvfsrcTurboQosSubtitle =>
      'Prioridad máxima de interconexión del bus de memoria y ancho de banda DDR completo';

  @override
  String get fstbTuneQuantileTitle => 'Cuantil de Entrega FSTB (P99/P95)';

  @override
  String get fstbTuneQuantileSubtitle =>
      'Percentil estadístico de capacidad de renderizado (P95/P99 elimina micro-tirones)';

  @override
  String get quantileP50 => 'P50 (Mediana)';

  @override
  String get quantileP95 => 'P95 (Suave)';

  @override
  String get quantileP99 => 'P99 (Extremo)';

  @override
  String get battery => 'Batería';

  @override
  String get titleBattery => 'Batería y Carga';

  @override
  String get batteryHeroSubtitle =>
      'Telemetría en tiempo real y gestión inteligente de carga';

  @override
  String get chargeSpeedRegulator => 'Regulador de Velocidad de Carga';

  @override
  String get chargeSpeedDesc =>
      'Limita la corriente máxima de carga para proteger la vida útil de la batería y evitar sobrecalentamiento';

  @override
  String get currentSpeed => 'Corriente';

  @override
  String get currentVoltage => 'Voltaje';

  @override
  String get currentPower => 'Potencia';

  @override
  String get chargeStatus => 'Estado';

  @override
  String get unlimitedTurbo => 'Turbo / Máx (67W)';

  @override
  String get fastChargePreset => 'Rápida (3000 mA)';

  @override
  String get balancedChargePreset => 'Equilibrada (2000 mA)';

  @override
  String get gentleChargePreset => 'Nocturna / Suave (1000 mA)';

  @override
  String get customLimit => 'Límite Personalizado';

  @override
  String get chargeLimitPct => 'Límite de Corte';

  @override
  String get chargingCurrent => 'Corriente de Carga';

  @override
  String get dischargingCurrent => 'Consumo Actual';

  @override
  String get batteryHealthGood => 'Salud de Batería';

  @override
  String get fastChargeStatus => 'Carga Rápida';

  @override
  String get batteryHealthTitle => 'Salud y Longevidad de la Batería';

  @override
  String get batteryHealthDesc =>
      'Degradación de celda verificada por el BMS, ciclos de vida y capacidad de diseño';

  @override
  String get batteryCycles => 'Ciclos de Carga';

  @override
  String get batteryDesignCapacity => 'Capacidad de Diseño';

  @override
  String get batteryActualCapacity => 'Capacidad Actual';

  @override
  String get batterySoh => 'Salud de la Celda (SOH)';

  @override
  String get timeToFull => 'Hasta carga completa (100%)';

  @override
  String get timeToProtection => 'Hasta corte de protección';

  @override
  String get timeRemaining => 'Autonomía Restante Estimada';

  @override
  String get dischargeRate => 'Ritmo de Descarga';

  @override
  String get chargingSpeed => 'Ritmo de Carga';

  @override
  String get backupManager => 'Copias de Seguridad';

  @override
  String get backupTitle => 'Snapshots de Perfiles';

  @override
  String get backupSubtitle =>
      'Guarda snapshots de tus configuraciones personalizadas del kernel y restáuralas en cualquier momento con un solo toque';

  @override
  String get createBackup => 'Crear Copia de Seguridad';

  @override
  String get createBackupDesc =>
      'Comprime y almacena todos los perfiles .conf actuales en un archivo fechado .tar.gz';

  @override
  String get creatingBackup => 'Creando copia...';

  @override
  String get backupCreatedSuccess =>
      '¡Copia de seguridad creada correctamente!';

  @override
  String get backupCreateError => 'Error al generar la copia de seguridad';

  @override
  String get restoreBackup => 'Restaurar';

  @override
  String get restoringBackup => 'Restaurando perfiles...';

  @override
  String get restoreSuccess =>
      '¡Perfiles restaurados y aplicados correctamente!';

  @override
  String get restoreError => 'Error al restaurar el archivo de copia';

  @override
  String get confirmRestoreTitle => '¿Restaurar esta Copia?';

  @override
  String get confirmRestoreMessage =>
      'Todas las configuraciones actuales de los perfiles serán reemplazadas por este snapshot y aplicadas de inmediato.';

  @override
  String get resetStockTitle => 'Regenerar Perfiles PerfMTK';

  @override
  String get resetStockDesc =>
      'Regenera los perfiles predeterminados y óptimos para tu procesador MediaTek (se creará una copia de seguridad automática antes de regenerar).';

  @override
  String get resetStockConfirm =>
      '¿Seguro que deseas regenerar los perfiles con los valores recomendados por PerfMTK? Se creará una copia de seguridad automática de tus perfiles actuales antes de continuar.';

  @override
  String get resetStockSuccess =>
      '¡Perfiles recomendados regenerados y aplicados con éxito!';

  @override
  String get noBackupsFound => 'No hay Copias Guardadas';

  @override
  String get noBackupsDesc =>
      'Crea tu primera copia de seguridad para resguardar tus configuraciones personalizadas de hardware.';

  @override
  String get deleteBackupTitle => '¿Eliminar esta Copia?';

  @override
  String get deleteBackupConfirm =>
      '¿Estás seguro de que deseas eliminar permanentemente este snapshot de perfiles? Esta acción no se puede deshacer.';

  @override
  String get deleteAllBackupsTitle => '¿Eliminar todas las Copias?';

  @override
  String get deleteAllBackupsConfirm =>
      '¿Estás seguro de que deseas eliminar todas las copias de seguridad de perfiles guardadas? Esta acción no se puede deshacer.';

  @override
  String get backupDeletedSuccess => 'Copia de seguridad eliminada con éxito';

  @override
  String get backupDeleteError => 'Error al eliminar la copia de seguridad';

  @override
  String get allBackupsDeletedSuccess =>
      'Todas las copias de seguridad fueron eliminadas';

  @override
  String get backupLatestBadge => 'ÚLTIMA COPIA';

  @override
  String get backupProfilesCount => '4 perfiles (.conf)';

  @override
  String get storageUsed => 'Espacio Ocupado';

  @override
  String get backupsCountLabel => 'Copias Guardadas';

  @override
  String get delete => 'Eliminar';

  @override
  String updateVersionAvailable(String version) {
    return 'Versión $version disponible para descargar';
  }

  @override
  String actionFailed(String reason) {
    return 'La acción falló: $reason';
  }

  @override
  String errorLoadingBattery(String error) {
    return 'Error al cargar el estado de la batería: $error';
  }

  @override
  String get temperature => 'Temperatura';

  @override
  String get storedEnergy => 'Energía almacenada';

  @override
  String get refresh => 'Actualizar';
}
