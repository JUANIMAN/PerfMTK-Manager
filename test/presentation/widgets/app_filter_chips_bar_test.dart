import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/widgets/app_profiles/app_filter_chips_bar.dart';

void main() {
  testWidgets('AppFilterChipsBar renders count badges correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFilterChipsBar(
            selectedFilter: AppFilterType.all,
            includeSystemApps: false,
            isLoading: false,
            totalCount: 42,
            configuredCount: 12,
            notConfiguredCount: 30,
            onFilterSelected: (_) {},
            onToggleSystemApps: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });
}
