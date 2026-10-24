import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/app_info.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/utils/update_checker.dart';
import 'package:manager/features/system/presentation/system_provider.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Wraps the app shell with process-level behaviors:
///  * checks GitHub for a newer release once, after the first frame;
///  * refreshes the system state when the app returns to the foreground
///    (debounced, and skipped while an action is in flight).
class AppLifecycleGate extends ConsumerStatefulWidget {
  const AppLifecycleGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLifecycleGate> createState() => _AppLifecycleGateState();
}

class _AppLifecycleGateState extends ConsumerState<AppLifecycleGate>
    with WidgetsBindingObserver {
  static const String _tag = 'AppLifecycleGate';
  static const Duration _resumeDebounce = Duration(seconds: 2);

  DateTime? _lastResumeRefresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkForUpdates());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final now = DateTime.now();
    final last = _lastResumeRefresh;
    if (last != null && now.difference(last) < _resumeDebounce) return;
    _lastResumeRefresh = now;

    if (ref.read(isChangingProfileProvider) ||
        ref.read(isChangingThermalProvider) ||
        ref.read(systemStateProvider).isLoading) {
      return;
    }
    unawaited(ref.read(systemStateProvider.notifier).refresh());
  }

  Future<void> _checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      final checker = UpdateChecker(
        owner: AppInfo.githubOwner,
        repo: AppInfo.githubRepo,
        currentVersion: packageInfo.version,
        currentLanguage: ref.read(localeProvider).languageCode,
      );
      await checker.checkForUpdates(context);
    } on Exception catch (e) {
      // Update checks must never interrupt the main application flow.
      AppLogger.debug(_tag, 'update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
