import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/features/reports/presentation/widgets/diff_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  Widget card() {
    return const DiffCard(
      field: 'Largest focus',
      aiLabel: 'AI draft',
      aiText: '2.6 mm',
      yoursLabel: 'Your report',
      yoursText: '2.1 mm',
      note: 'Tile E3 was stroma. You relabelled it.',
    );
  }

  group('DiffCard', () {
    testWidgets('shows field, both texts, note and H-5 surfaces', (
      tester,
    ) async {
      await tester.pumpApp(card());
      final status = Theme.of(
        tester.element(find.byType(DiffCard)),
      ).extension<AppStatusColors>()!;
      final colors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) {
            final decoration = box.decoration;
            return decoration is BoxDecoration ? decoration.color : null;
          })
          .whereType<Color>()
          .toSet();

      expect(find.text('Largest focus'), findsOneWidget);
      expect(find.text('AI draft'), findsOneWidget);
      expect(find.text('2.6 mm'), findsOneWidget);
      expect(find.text('Your report'), findsOneWidget);
      expect(find.text('2.1 mm'), findsOneWidget);
      expect(
        find.text('Tile E3 was stroma. You relabelled it.'),
        findsOneWidget,
      );
      expect(colors, contains(status.aiDraftContainer));
      expect(colors, contains(status.editedSurface));
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(card(), themeMode: mode);
        expect(find.byType(DiffCard), findsOneWidget);
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
          child: DiffCard(
            field: 'Impression',
            aiLabel: 'AI draft',
            aiText:
                'Metastatic carcinoma in 1 of 1 sentinel lymph node, '
                'macro-metastasis.',
            yoursLabel: 'Your report',
            yoursText:
                'Metastatic carcinoma in 1 of 1 sentinel lymph node, '
                'macro-metastasis (2.1 mm). No extension outside the node.',
            note: 'You added the size and the outside-node finding.',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
