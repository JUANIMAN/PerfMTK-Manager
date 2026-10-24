import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manager/app/shell/app_shell.dart';
import 'package:manager/features/backup/presentation/backup_screen.dart';
import 'package:manager/features/settings/presentation/settings_screen.dart';

/// Route paths. Tabs are internal to the shell; only full-screen pages that
/// push on top of it are routes.
abstract final class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String backup = '/backup';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AppShell(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'backup',
            builder: (context, state) => const BackupScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
