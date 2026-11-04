import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/pattern_card.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/features/preread/presentation/widgets/measurement_hero_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const bands = [
    RangeBand(label: 'ITC', start: 0, end: 0.2),
    RangeBand(label: 'Micro 0.2–2 mm', start: 0.2, end: 0.7),
    RangeBand(label: 'Macro over 2 mm', start: 0.7, end: 1),
  ];

  Widget card({
    bool unsure = false,
    double position = 0.8,
    String? chipLabel = 'AI measured',
  }) {
    return MeasurementHeroCard(
      eyebrow: 'Largest focus',
      value: '2.6 mm',
      caption: 'Above 2 mm, the macro-metastasis range.',
      bands: bands,
      position: position,
      chipLabel: chipLabel,
      unsure: unsure,
    );
  }

  group('MeasurementHeroCard', () {
    testWidgets('teal variant uses PatternCard', (tester) async {
      await tester.pumpApp(card());

      expect(find.byType(PatternCard), findsOneWidget);
      expect(find.text('Largest focus'), findsOneWidget);
      expect(find.text('2.6 mm'), findsOneWidget);
      expect(find.text('AI measured'), findsOneWidget);
      expect(
        tester.widget<StatusChip>(find.byType(StatusChip)).tone,
        StatusTone.aiDraft,
      );
      expect(find.text('ITC'), findsOneWidget);
      expect(find.text('Macro over 2 mm'), findsOneWidget);
    });

    testWidgets('unsure variant drops PatternCard and keeps ink labels', (
      tester,
    ) async {
      await tester.pumpApp(card(unsure: true, chipLabel: 'AI unsure'));

      expect(find.byType(PatternCard), findsNothing);
      expect(find.text('Largest focus'), findsOneWidget);
      expect(find.text('AI unsure'), findsOneWidget);
    });

    testWidgets('marker clamps outside 0–1 without throwing', (tester) async {
      await tester.pumpApp(card(position: -0.5));
      expect(tester.takeException(), isNull);
      await tester.pumpApp(card(position: 1.7));
      expect(tester.takeException(), isNull);
      expect(find.byType(MeasurementHeroCard), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(card(), themeMode: mode);
        expect(find.byType(MeasurementHeroCard), findsOneWidget);
        await tester.pumpApp(card(unsure: true), themeMode: mode);
        expect(find.byType(MeasurementHeroCard), findsOneWidget);
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
          child: MeasurementHeroCard(
            eyebrow: 'Largest focus',
            value: '2.6 mm',
            caption:
                'Above 2 mm, the macro-metastasis range. Check tiles '
                'before you trust this reading.',
            bands: bands,
            position: 0.85,
            chipLabel: 'AI measured',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
