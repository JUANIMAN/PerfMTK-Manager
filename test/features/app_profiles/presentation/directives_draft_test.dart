import 'package:flutter_test/flutter_test.dart';
import 'package:manager/features/app_profiles/data/app_profile.dart';
import 'package:manager/features/app_profiles/presentation/widgets/directives_draft.dart';

void main() {
  test('round-trips editable directives and preserves hidden ones', () {
    const source = AppDirectives(
      gbe: 1,
      chargeBypass: true,
      gentleCharge: 500,
      fps: 120,
      dramMin: 800,
      uclampMax: 40,
    );

    final draft = DirectivesDraft.from(source);
    final back = draft.toDirectives(base: source);

    expect(draft.activeCount, 4);
    expect(back.gbe, 1);
    expect(back.chargeBypass, isTrue);
    expect(back.gentleCharge, 500);
    expect(back.fps, 120);
    expect(back.dramMin, 800);
    expect(back.uclampMax, 40);
  });

  test('clear resets every editable directive', () {
    final draft = DirectivesDraft.from(
      const AppDirectives(gbe: 1, renderBoost: 1, fps: 90),
    )..clear();

    expect(draft.activeCount, 0);
    expect(draft.toDirectives().isEmpty, isTrue);
  });

  test('null source yields an empty draft', () {
    expect(DirectivesDraft.from(null).activeCount, 0);
  });
}
