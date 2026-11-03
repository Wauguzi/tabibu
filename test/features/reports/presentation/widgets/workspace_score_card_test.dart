import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_score_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  Widget card({required bool saving, VoidCallback? onSave}) {
    final comment = TextEditingController();
    return WorkspaceScoreCard(
      findings: 'Accepted',
      impression: 'Accepted',
      urgency: 'Good',
      measurements: 'Accepted',
      tiles: 'Accepted',
      overall: 4,
      comment: comment,
      onFindings: (_) {},
      onImpression: (_) {},
      onUrgency: (_) {},
      onMeasurements: (_) {},
      onTiles: (_) {},
      onOverall: (_) {},
      onSave: onSave,
      saving: saving,
    );
  }

  Finder saveButton() => find.byWidgetPredicate(
    (w) => w is TabibuButton && w.label == en.scoreSave,
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1170, 8000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpApp(child);
    await tester.pump();
  }

  testWidgets('a complete score can be saved', (tester) async {
    var saves = 0;
    await pump(tester, card(saving: false, onSave: () => saves++));

    expect(tester.widget<TabibuButton>(saveButton()).isLoading, isFalse);
    await tester.tap(saveButton());
    expect(saves, 1);
  });

  testWidgets('while the score is on its way the button spins and waits', (
    tester,
  ) async {
    var saves = 0;
    await pump(tester, card(saving: true, onSave: () => saves++));

    final button = tester.widget<TabibuButton>(saveButton());
    expect(button.isLoading, isTrue);
    expect(button.onTap, isNull);
    expect(saves, 0);
  });
}
