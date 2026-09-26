# Changelog

## v8.2.0

## English
- App Profiles 120Hz Scroll Performance & Icon Pipeline Overhaul:
  - Transitioned native icon compression from CPU-heavy PNG to lightweight WebP Lossy (72x72 @ 80q), reducing icon payload by >90% and compression time to <0.5ms.
  - Implemented persistent disk caching (`cache/app_icons/`) to completely bypass Android `PackageManager` IPC Binder calls after first load.
  - Initial viewport icon preloading (first 25 apps) to eliminate placeholder pop-in and UI flashing on startup.
  - Removed GPU-intensive Gaussian `BoxShadow` from cards, eliminating offscreen `saveLayer` passes during 120 FPS scrolling.
  - Single-pass layout for profile chips: bypasses multi-pass `Wrap` widget when directives are absent.
- UI/UX & Architectural Modernization Across All Screens:
  - Preserved internal widget states in `ThermalScreen` by replacing unstable composite keys with stable identifiers on `ThermalGuardianCard`, `ThermalSwitch`, `ChargeBypassCard`, and `BatteryCareCard`.
  - Scoped high-frequency Riverpod telemetry updates in `ProfilesScreen`: isolated hardware monitor from the 2x2 profile selector and active banner, eliminating unnecessary full-screen layout passes every 2s.
  - Reclaimed ~40-65dp of vertical space across views by establishing dynamic `AppBar.title` cross-fades (`AnimatedSwitcher`) and removing redundant duplicate screen titles.
  - Eliminated Gaussian raster jank across 10+ collapsible cards in `SectionCard` (`PerfConfigScreen`) by removing heavy `BoxShadow` blur passes.
  - Optimized bottom navigation floating glass bar backdrop filter blur sigma to 14, maintaining frosted glass aesthetics with reduced GPU fill-rate impact.
  - Enhanced filter chips row in App Profiles with smooth `BouncingScrollPhysics` and fine-tuned edge paddings.

## Español
- Optimización de Desplazamiento a 120Hz y Pipeline de Iconos en App Profiles:
  - Migración de compresión de iconos nativa de PNG a WebP Lossy (72x72 @ 80q), reduciendo el peso en más del 90% y el tiempo de compresión a <0.5ms.
  - Implementación de caché persistente en disco flash (`cache/app_icons/`), eliminando por completo llamadas IPC Binder a `PackageManager` tras la primera carga.
  - Precarga de iconos para el viewport inicial (primeras 25 apps) eliminando el parpadeo de placeholders al abrir la pantalla.
  - Eliminación de `BoxShadow` con desenfoque gaussiano en las tarjetas, suprimiendo pasadas `saveLayer` fuera de pantalla durante el scroll a 120 FPS.
  - Layout en una sola pasada para chips de perfil: evita el sobrecoste del widget `Wrap` cuando no hay directivas adicionales.
  - Memoización de filtros y contadores evitando iteraciones innecesarias sobre más de 300 apps en cada reconstrucción de interfaz.
- Modernización de UI/UX y Optimización Arquitectónica Global:
  - Preservación de estados y animaciones en `ThermalScreen`: sustitución de keys dinámicas compuestas por keys estables en `ThermalGuardianCard`, `ThermalSwitch`, `ChargeBypassCard` y `BatteryCareCard`.
  - Desacoplamiento de telemetría de alta frecuencia en `ProfilesScreen`: aislamiento del monitor de hardware respecto a los 4 botones de perfiles táctiles y banner activo mediante selectores finos de Riverpod.
  - Recuperación de ~40-65dp de altura útil en pantalla integrando títulos dinámicos en el `AppBar` (`AnimatedSwitcher`) y eliminando cabeceras duplicadas innecesarias.
  - Eliminación de raster jank en más de 10 secciones del editor de rendimiento (`SectionCard`) suprimiendo sombras gaussianas pesadas.
  - Optimización de GPU en la barra de navegación flotante reduciendo el desenfoque de fondo a sigma 14 con idéntica estética frosted glass.
  - Desplazamiento natural con rebote (`BouncingScrollPhysics`) y ajuste milimétrico de padding en los chips de filtrado de apps.
