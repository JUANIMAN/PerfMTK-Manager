# Changelog

## v8.1.0

## English
- Dual GPU DVFS Min/Max Sliders: independent control of minimum and maximum GPU frequencies when DVFS is enabled, allowing precise frequency floor and ceiling configuration.
- Legacy MediaTek `gpufreq` Support: auto-detection of older Helio SoCs (e.g. Helio G80/G85/G90), using `0` sentinel for DVFS and cleanly hiding unsupported min/max frequency tuneables.
- Real-time Kernel Game FPS Telemetry: added live game frame rate display (`gameFps`) sourced directly from MediaTek kernel FPSGO (`/sys/kernel/fpsgo/fstb/fpsgo_status`).
- Profile Configuration & Serialization: enhanced parser robustness for GPU configuration round-trips and profile synchronization.
- Unit Testing: comprehensive test coverage for legacy vs modern GPU configurations and telemetry models (37/37 passing).

## Español
- Sliders Duales de GPU DVFS Min/Max: control independiente de frecuencias mínima y máxima cuando DVFS está activo, permitiendo definir pisos y techos de frecuencia exactos.
- Soporte para MediaTek `gpufreq` Legacy: autodetección de SoCs Helio antiguos (ej. Helio G80/G85/G90), utilizando el centinela `0` para DVFS y ocultando opciones no soportadas.
- Telemetría de FPS Reales de Juegos del Kernel: visualización en vivo de la tasa de cuadros (`gameFps`) leída directamente desde MediaTek FPSGO en el kernel.
- Configuración y Serialización de Perfiles: mayor robustez en el guardado y sincronización de configuraciones de GPU.
- Pruebas Unitarias: suite completa de pruebas para configuraciones legacy vs modernas y modelos de telemetría (37/37 pruebas aprobadas).

## v8.0.0

## English
- Bento Telemetry Console: real-time monitoring of CPU cluster frequencies, Mali GPU clock, and LPDDR5X DRAM bus speeds.
- Live Silicon Analytics: continuous rolling thermal charts for SoC temperature and battery cell temperature.
- Charge Bypass: play games while plugged in without overheating or battery wear, with configurable thermal cutoff protection.
- Battery Care: set custom maximum charge limits (e.g., 80%) to prolong battery health and lifespan.
- MediaTek Touch Booster: direct touch sampling rate selection (480Hz/2160Hz) and touch smoothing filter toggles.
- Quick Settings Tiles: switch performance profiles and toggle Charge Bypass directly from your notification panel.
- Redesigned Profile Editor: modular tabbed controls for CPU governors, frequencies, uclamp, devfreq, and UFS storage.
- Smart App Profiles: streamlined per-app profile assignments with quick search, category filter chips, and screen-off profile settings.
- Real-time IPC Engine: low-latency communication with the native PerfMTK v16.2 daemon (`perfmtkd`).
- Build & Performance: upgraded dependencies, optimized animations, and full Android 14+ HyperOS support.

## Español
- Consola Bento de Telemetría: monitoreo en tiempo real de frecuencias de CPU por clúster, GPU Mali y bus de memoria LPDDR5X.
- Analíticas Térmicas en Vivo: gráficas continuas en tiempo real de la temperatura del procesador (SoC) y la batería.
- Charge Bypass: juega conectado sin sobrecalentar el dispositivo ni degradar la batería, con protección de corte térmico configurable.
- Cuidado de Batería: límite máximo de carga personalizable (ej. 80%) para extender la vida útil de la batería.
- MediaTek Touch Booster: selector directo de tasa de muestreo táctil (480Hz/2160Hz) y filtro de suavizado de gestos.
- Tiles de Ajustes Rápidos: cambia perfiles y activa Charge Bypass directamente desde la barra de notificaciones.
- Editor de Perfiles Rediseñado: interfaz modular por pestañas para gobernadores de CPU, frecuencias, uclamp, devfreq y almacenamiento UFS.
- Perfiles por Aplicación Inteligentes: asignación simplificada con búsqueda rápida, filtros por categoría y perfil con pantalla apagada.
- Motor IPC en Tiempo Real: comunicación de ultra-baja latencia con el daemon nativo de PerfMTK v16.2 (`perfmtkd`).
- Compilación y Rendimiento: dependencias actualizadas, animaciones optimizadas y compatibilidad total con Android 14+ HyperOS.

**Full Changelog**: https://github.com/JUANIMAN/PerfMTK-Manager/compare/v7.0.0...v8.0.0
