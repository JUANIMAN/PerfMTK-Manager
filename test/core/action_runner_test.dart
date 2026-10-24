import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/ui/action_runner.dart';
import 'package:manager/l10n/l10n.dart';

Widget _app(Future<bool> Function(BuildContext) onTap) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => onTap(context),
        child: const Text('go'),
      ),
    ),
  ),
);

void main() {
  testWidgets('returns true and shows nothing when the action succeeds',
      (tester) async {
    var result = false;
    await tester.pumpWidget(
      _app((c) async => result = await runUiAction(c, () async {})),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(result, isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('reports an AppException message in a snackbar', (tester) async {
    var result = true;
    await tester.pumpWidget(
      _app(
        (c) async => result = await runUiAction(
          c,
          () async => throw const SystemCommandException('no daemon'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(result, isFalse);
    expect(find.text('Action failed: no daemon'), findsOneWidget);
  });

  testWidgets('also catches unexpected errors', (tester) async {
    await tester.pumpWidget(
      _app((c) => runUiAction(c, () async => throw StateError('boom'))),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.textContaining('boom'), findsOneWidget);
  });
}
