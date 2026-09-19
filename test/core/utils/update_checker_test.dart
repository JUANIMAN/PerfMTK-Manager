import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/utils/changelog_list.dart';
import 'package:manager/core/utils/update_checker.dart';

void main() {
  group('UpdateChecker._processChangelog', () {
    const sampleChangelog = '''
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
''';

    testWidgets('extracts English section items when currentLanguage is en', (tester) async {
      final checker = UpdateChecker(
        owner: 'JUANIMAN',
        repo: 'PerfMTK-Manager',
        currentVersion: '7.0.0',
        currentLanguage: 'en',
      );

      final widget = checker.processChangelogForTesting(sampleChangelog);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final changelogItems = tester.widgetList<ChangelogList>(find.byType(ChangelogList)).toList();
      expect(changelogItems.length, 10);
      expect(changelogItems.first.text, startsWith('Bento Telemetry Console:'));
      expect(changelogItems.last.text, startsWith('Build & Performance:'));
    });

    testWidgets('extracts Spanish section items when currentLanguage is es', (tester) async {
      final checker = UpdateChecker(
        owner: 'JUANIMAN',
        repo: 'PerfMTK-Manager',
        currentVersion: '7.0.0',
        currentLanguage: 'es',
      );

      final widget = checker.processChangelogForTesting(sampleChangelog);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final changelogItems = tester.widgetList<ChangelogList>(find.byType(ChangelogList)).toList();
      expect(changelogItems.length, 10);
      expect(changelogItems.first.text, startsWith('Consola Bento de Telemetría:'));
      expect(changelogItems.last.text, startsWith('Compilación y Rendimiento:'));
    });
  });
}
