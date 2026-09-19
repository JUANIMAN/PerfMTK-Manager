import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shell_provider.dart';
import 'package:manager/data/repositories/config_repository.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(
    shellManager: ref.watch(shellExecutorProvider),
  );
});
