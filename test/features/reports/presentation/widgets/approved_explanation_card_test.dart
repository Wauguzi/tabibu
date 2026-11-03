// cspell:ignore maelezo
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/approved_explanation_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ApprovedExplanationCard', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    testWidgets('shows the language, Approved and the text verbatim, never '
        'in an AI frame', (tester) async {
      await tester.pumpApp(
        const ApprovedExplanationCard(
          language: 'English',
          segments: ['  First segment  ', 'Second segment'],
        ),
      );

      expect(find.text('English'), findsOneWidget);
      expect(find.text(l10n.explanationApproved), findsOneWidget);
      expect(find.text('  First segment  '), findsOneWidget);
      expect(find.text('Second segment'), findsOneWidget);
      expect(find.byType(AiDraftFrame), findsNothing);
      expect(find.text(l10n.alertReviewAiDraftNotSent), findsNothing);
    });

    testWidgets('the Approved chip is the signed tone, not the AI one', (
      tester,
    ) async {
      await tester.pumpApp(
        const ApprovedExplanationCard(language: 'English', segments: ['Text']),
      );

      expect(
        tester.widget<StatusChip>(find.byType(StatusChip)).tone,
        StatusTone.signed,
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const ApprovedExplanationCard(
            language: 'English',
            segments: ['Text'],
          ),
          themeMode: mode,
        );
        expect(find.byType(ApprovedExplanationCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    for (final scale in const [1.3, 2.0]) {
      testWidgets(
        'Swahili at ${scale}x with long text does not overflow at 390 '
        'dp',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final long = List.filled(120, 'maelezo').join(' ');

          await tester.pumpApp(
            SingleChildScrollView(
              child: ApprovedExplanationCard(
                language: 'Kiswahili',
                segments: [long],
              ),
            ),
            locale: const Locale('sw'),
          );

          expect(tester.takeException(), isNull);
          expect(find.text(long), findsOneWidget);
        },
      );
    }
  });
}
