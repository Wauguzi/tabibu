// cspell:ignore Ongezeko kila mwenye homa chandarua
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_draft_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

const _drafts = {
  'clinician_en': AlertTextModel(
    headline: 'Malaria rise in {county}',
    body: 'Test every febrile patient.',
  ),
  'patient_en': AlertTextModel(
    headline: 'More malaria than usual',
    body: 'Sleep under a treated net.',
  ),
  'clinician_sw': AlertTextModel(
    headline: 'Ongezeko la malaria',
    body: 'Pima kila mgonjwa mwenye homa.',
  ),
  'patient_sw': AlertTextModel(
    headline: 'Malaria zaidi ya kawaida',
    body: 'Lala chini ya chandarua.',
  ),
};

void main() {
  group('AlertDraftCard', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    Future<void> pump(
      WidgetTester tester, {
      String language = 'en',
      bool busy = false,
      VoidCallback? onEdit,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      Map<String, AlertTextModel> drafts = _drafts,
    }) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        AlertDraftCard(
          language: language,
          drafts: drafts,
          area: 'Embakasi',
          busy: busy,
          onEdit: onEdit ?? () {},
        ),
        themeMode: themeMode,
        locale: locale,
      );
    }

    testWidgets('shows both audiences verbatim inside one AI frame', (
      tester,
    ) async {
      await pump(tester);

      final frame = find.byType(AiDraftFrame);
      expect(frame, findsOneWidget);
      expect(
        tester.widget<AiDraftFrame>(frame).label,
        l10n.alertReviewAiDraftNotSent,
      );
      for (final text in [
        l10n.languageEn,
        l10n.alertReviewForDoctors('Embakasi'),
        l10n.alertReviewForPatients('Embakasi'),
        'Malaria rise in {county}',
        'Test every febrile patient.',
        'More malaria than usual',
        'Sleep under a treated net.',
      ]) {
        expect(
          find.descendant(of: frame, matching: find.text(text)),
          findsOneWidget,
          reason: text,
        );
      }
      // Never the other language's text.
      expect(find.text('Ongezeko la malaria'), findsNothing);
    });

    testWidgets('Kiswahili shows its own keys and language name', (
      tester,
    ) async {
      await pump(tester, language: 'sw');

      expect(find.text(l10n.languageSw), findsOneWidget);
      expect(find.text('Ongezeko la malaria'), findsOneWidget);
      expect(find.text('Malaria zaidi ya kawaida'), findsOneWidget);
      expect(find.text('Test every febrile patient.'), findsNothing);
    });

    testWidgets('Edit sits outside the frame and fires', (tester) async {
      var edits = 0;
      await pump(tester, onEdit: () => edits++);

      expect(
        find.descendant(
          of: find.byType(AiDraftFrame),
          matching: find.byType(TabibuButton),
        ),
        findsNothing,
      );
      await tester.tap(find.text(l10n.reviewEdit));
      expect(edits, 1);
    });

    testWidgets('busy turns Edit off', (tester) async {
      var edits = 0;
      await pump(tester, busy: true, onEdit: () => edits++);

      await tester.tap(find.text(l10n.reviewEdit), warnIfMissed: false);
      expect(edits, 0);
    });

    testWidgets('a missing key shows what the alert has', (tester) async {
      await pump(tester, drafts: {'patient_en': _drafts['patient_en']!});

      expect(find.text(l10n.alertReviewForDoctors('Embakasi')), findsNothing);
      expect(find.text('More malaria than usual'), findsOneWidget);
    });

    testWidgets('draws in dark mode', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);

      expect(find.byType(AiDraftFrame), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Swahili at 1.3x on a 390 dp screen does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 3000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpApp(
        AlertDraftCard(
          language: 'sw',
          drafts: _drafts,
          area: 'Embakasi',
          busy: false,
          onEdit: () {},
        ),
        locale: const Locale('sw'),
      );
      final sw = lookupAppLocalizations(const Locale('sw'));

      expect(find.text(sw.alertReviewAiDraftNotSent), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('alert draft keys', () {
    test('are the four the server requires, doctors first per language', () {
      expect(alertDraftKeys, [
        'clinician_en',
        'patient_en',
        'clinician_sw',
        'patient_sw',
      ]);
    });
  });
}
