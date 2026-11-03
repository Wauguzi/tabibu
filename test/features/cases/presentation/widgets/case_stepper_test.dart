import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';

import '../../../../helpers/helpers.dart';

const _labels = ['Seen', 'Ordered', 'Pathologist', 'Signed', 'Discussed'];

void main() {
  group('CaseStepper', () {
    testWidgets('renders every label and the summary', (tester) async {
      await tester.pumpApp(
        const CaseStepper(
          labels: _labels,
          current: 2,
          semanticLabel: 'Step 3 of 5, Pathologist',
        ),
      );

      for (final label in _labels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(
        tester.getSemantics(find.byType(CaseStepper)),
        matchesSemantics(label: 'Step 3 of 5, Pathologist'),
      );
    });

    testWidgets('scrollable keeps every label on one line and opens on the '
        'current step', (tester) async {
      tester.view
        ..physicalSize = const Size(600, 1600)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      const labels = [
        'Consultation',
        'Ordered',
        'Pathologist',
        'Signed',
        'Discuss with the patient',
      ];
      await tester.pumpApp(
        const CaseStepper(
          labels: labels,
          current: 4,
          scrollable: true,
          semanticLabel: 'Step 5 of 5',
        ),
      );
      await tester.pump();
      await tester.pump();

      final lineHeight = tester.getSize(find.text('Ordered')).height;
      for (final label in labels) {
        expect(tester.getSize(find.text(label)).height, lineHeight);
      }
      // Wider than the 200 dp it has, so it scrolls, opening on the current.
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(CaseStepper),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      final stepper = tester.getRect(find.byType(CaseStepper));
      expect(
        (tester.getCenter(find.text(labels.last)).dx - stepper.center.dx).abs(),
        lessThan(1),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('paused keeps the summary and labels', (tester) async {
      await tester.pumpApp(
        const CaseStepper(
          labels: _labels,
          current: 1,
          paused: true,
          semanticLabel: 'Step 2 of 5, Ordered, paused',
        ),
      );
      expect(find.text('Ordered'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(CaseStepper)),
        matchesSemantics(label: 'Step 2 of 5, Ordered, paused'),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const CaseStepper(
            labels: _labels,
            current: 0,
            semanticLabel: 'Step 1 of 5, Seen',
          ),
          themeMode: mode,
        );
        expect(find.byType(CaseStepper), findsOneWidget);
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
          child: CaseStepper(
            labels: [
              'Seen already',
              'Order placed',
              'Pathologist review',
              'Report signed',
              'Discussed fully',
            ],
            current: 2,
            semanticLabel: 'Step 3 of 5, Pathologist review',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
