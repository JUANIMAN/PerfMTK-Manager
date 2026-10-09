# Changelog

## v8.9.0

## English
- DVFSRC Interconnect & FSTB Quantile Frame Pacing:
  - Dedicated configuration controls for MediaTek DVFSRC Turbo QoS mode and direct DDR hardware OPP locks.
  - FSTB Tune Quantile slider (P95/P99 predictive CPU budgeting) with automatic BLC Boost and non-SurfaceFlinger bypass orchestration.
- Complete Purge of Thermal Guardian:
  - Fully removed obsolete Thermal Guardian UI cards, models, and INI serialization in alignment with native kernel DVFS and hardware cooling devices.
- Fine-Tuned Profile & App Directives Configuration:
  - Lowered minimum `watermark_scale_factor` slider threshold to 10 in `VmCard` for precision memory tuning.
  - Automatically sorted frequency lists for GPU and Devfreq sliders to ensure smooth and monotonic slider ranges.
  - Refined progressive disclosure in `ProfileSelectionSheet` with instant directive toggling and inheritance badges.
- Bilingual Localization Parity:
  - 100% updated Spanish and English localization for all new telemetry monitors, DVFSRC controls, and FSTB options.

## Español
- Controles de Interconexión DVFSRC y Frame Pacing por Cuantiles FSTB:
  - Controles dedicados para el modo Turbo QoS de MediaTek DVFSRC y bloqueo de OPP hardware de memoria DRAM.
  - Control deslizante para FSTB Tune Quantile (presupuesto predictivo de CPU P95/P99) con orquestación automática de BLC Boost y bypass no-SF.
- Purga Completa de Thermal Guardian:
  - Eliminación total de tarjetas de interfaz, modelos y serialización de Thermal Guardian en alineación con el control térmico nativo por kernel y cooling devices.
- Configuración Avanzada de Perfiles y Directivas:
  - Ajuste del umbral mínimo del deslizador `watermark_scale_factor` a 10 en `VmCard` para calibración fina de memoria.
  - Ordenación ascendente automática de frecuencias de GPU y Devfreq para deslizadores suaves y consistentes.
  - Refinamiento de la hoja de selección de perfiles con acordeón de excepciones y badges dinámicos de herencia.
- Paridad Bilingüe Total:
  - Localización completa en español e inglés para todos los nuevos monitores de telemetría, controles DVFSRC y opciones FSTB.
