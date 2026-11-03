import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_evidence_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

const _evidence = AlertEvidenceModel(
  confirmedCount: 14,
  baselineMean: 4.6,
  windowWeeks: 8,
);

void main() {
  group('AlertEvidenceCard', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    Future<void> pump(
      WidgetTester tester, {
      AlertEvidenceModel evidence = _evidence,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) => tester.pumpApp(
      AlertEvidenceCard(
        evidence: evidence,
        area: 'Embakasi',
        test: 'malaria smears',
      ),
      themeMode: themeMode,
      locale: locale,
    );

    testWidgets('states the count and the usual level as plain facts', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text(l10n.alertReviewWhyThisAlert), findsOneWidget);
      expect(
        find.text(l10n.alertReviewSignalCases(14, 'malaria smears')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.alertReviewSignalBaseline('Embakasi', 5)),
        findsOneWidget,
      );
      expect(find.text(l10n.alertReviewAboveBaseline), findsOneWidget);
      expect(find.byType(AiDraftFrame), findsNothing);
    });

    testWidgets('no baseline shows no usual level and no chip', (tester) async {
      await pump(tester, evidence: const AlertEvidenceModel(confirmedCount: 3));

      expect(
        find.text(l10n.alertReviewSignalCases(3, 'malaria smears')),
        findsOneWidget,
      );
      expect(find.textContaining('usually'), findsNothing);
      expect(find.byType(StatusChip), findsNothing);
    });

    testWidgets('a count at the usual level carries no chip', (tester) async {
      await pump(
        tester,
        evidence: const AlertEvidenceModel(
          confirmedCount: 4,
          baselineMean: 5,
          windowWeeks: 8,
        ),
      );

      expect(find.text(l10n.alertReviewAboveBaseline), findsNothing);
    });

    testWidgets('draws in dark mode', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);

      expect(find.text(l10n.alertReviewWhyThisAlert), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Swahili at 1.3x on a 390 dp screen does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(tester, locale: const Locale('sw'));
      final sw = lookupAppLocalizations(const Locale('sw'));

      expect(find.text(sw.alertReviewAboveBaseline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
