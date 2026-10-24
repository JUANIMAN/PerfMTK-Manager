import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/app/shell/nav_tab.dart';
import 'package:manager/features/app_profiles/presentation/app_profile_visibility_provider.dart';

class _Visibility extends AppProfileVisibilityNotifier {
  _Visibility(this.initial);
  final bool initial;

  @override
  Future<bool> build() async => initial;

  @override
  Future<void> hide() async => state = const AsyncData(false);
}

void main() {
  Future<ProviderContainer> make({required bool showAppProfiles}) async {
    final container = ProviderContainer(
      overrides: [
        appProfileVisibilityProvider.overrideWith(
          () => _Visibility(showAppProfiles),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appProfileVisibilityProvider.future);
    return container;
  }

  test('App Profiles tab is only offered when enabled', () async {
    final hidden = await make(showAppProfiles: false);
    expect(
      hidden.read(visibleNavTabsProvider),
      [NavTab.profiles, NavTab.battery, NavTab.perfConfig],
    );

    final shown = await make(showAppProfiles: true);
    expect(shown.read(visibleNavTabsProvider), contains(NavTab.appProfiles));
  });

  test('selecting a visible tab makes it effective', () async {
    final c = await make(showAppProfiles: true);
    c.read(selectedNavTabProvider.notifier).select(NavTab.appProfiles);
    expect(c.read(effectiveNavTabProvider), NavTab.appProfiles);
  });

  test('a tab that disappears falls back to Profiles for body and bar',
      () async {
    final c = await make(showAppProfiles: true);
    c.read(selectedNavTabProvider.notifier).select(NavTab.appProfiles);
    expect(c.read(effectiveNavTabProvider), NavTab.appProfiles);

    await c.read(appProfileVisibilityProvider.notifier).hide();

    expect(c.read(visibleNavTabsProvider), isNot(contains(NavTab.appProfiles)));
    expect(c.read(effectiveNavTabProvider), NavTab.profiles);
  });
}
