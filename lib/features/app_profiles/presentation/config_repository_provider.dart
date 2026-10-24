import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/daemon_providers.dart';
import 'package:manager/features/app_profiles/data/config_repository.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(gateway: ref.watch(daemonGatewayProvider));
});
