import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

AppStatusColors _status(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(AiMark))).extension<AppStatusColors>()!;

void main() {
  group('AiMark', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'H-18 rule 1: wears the aiDraft container, the sparkle and the aiDraft '
        'text (${mode.name})',
        (tester) async {
          await tester.pumpApp(
            const AiMark(label: 'AI draft ready'),
            themeMode: mode,
          );
          final status = _status(tester);

          final fills = tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(AiMark),
                  matching: find.byType(Container),
                ),
              )
              .map((c) => (c.decoration as BoxDecoration?)?.color);
          expect(fills, contains(status.aiDraftContainer));

          final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
          expect(icon.asset, Assets.icons.sparkleIcon);
          expect(icon.color, status.aiDraft);

          expect(
            tester.widget<Text>(find.text('AI draft ready')).style?.color,
            status.aiDraft,
          );
          expect(find.byType(DashedBorder), findsOneWidget);
        },
      );
    }

    testWidgets('H-18 rule 2: never the signed colour', (tester) async {
      await tester.pumpApp(const AiMark(label: 'High 94%'));
      final status = _status(tester);
      final signed = {status.signed, status.signedContainer, status.signedDot};

      final used = <Color?>[
        for (final c in tester.widgetList<Container>(
          find.descendant(
            of: find.byType(AiMark),
            matching: find.byType(Container),
          ),
        ))
          (c.decoration as BoxDecoration?)?.color,
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          t.style?.color,
        for (final i in tester.widgetList<AssetIcon>(find.byType(AssetIcon)))
          i.color,
      ];
      expect(used.where(signed.contains), isEmpty);
    });

    testWidgets('H-18 rule 6: reads the label, or the longer reading given', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const Column(
          children: [
            AiMark(label: 'AI draft ready'),
            AiMark(
              label: 'High 94%',
              semanticLabel: 'AI draft ready · High 94%',
            ),
          ],
        ),
      );
      expect(find.bySemanticsLabel('AI draft ready'), findsOneWidget);
      expect(
        find.bySemanticsLabel('AI draft ready · High 94%'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('grows at 1.3x without overflow at 390 dp', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SizedBox(
          width: 150,
          child: AiMark(label: 'Low confidence · 52% and a long tail'),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
