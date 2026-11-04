import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/features/reports/presentation/widgets/results_slide.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ResultsSlide', () {
    testWidgets('renders chip, title and body with an info chip', (
      tester,
    ) async {
      await tester.pumpApp(
        const ResultsSlide(
          chipLabel: 'With your doctor',
          title: 'Lymph node results',
          body: 'Dr. Kamau goes through them with you on Thu 29 Oct.',
          illustration: SizedBox(key: Key('illus'), width: 48, height: 48),
        ),
      );

      expect(find.text('With your doctor'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
      expect(find.byKey(const Key('illus')), findsOneWidget);
      expect(
        tester.widget<StatusChip>(find.byType(StatusChip)).tone,
        StatusTone.info,
      );
    });

    testWidgets('fires onTap and announces as a button', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        ResultsSlide(
          chipLabel: 'With your doctor',
          title: 'Lymph node results',
          body: 'Then you can read them here.',
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(ResultsSlide));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(ResultsSlide)),
        matchesSemantics(
          label: 'With your doctor, Lymph node results',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const ResultsSlide(
            chipLabel: 'With your doctor',
            title: 'Lymph node results',
            body: 'Then you can read them here.',
          ),
          themeMode: mode,
        );
        expect(find.byType(ResultsSlide), findsOneWidget);
      }
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SizedBox(
          width: 390,
          child: ResultsSlide(
            chipLabel: 'With your doctor',
            title: 'Lymph node results ready soon',
            body:
                'Dr. Kamau goes through them with you on Thursday '
                '29 October. Then you can read them here in full.',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
