import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_headline.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DeskHeadline', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'H-18 rule 1: the AI line wears the aiDraft colour and the sparkle, '
        'the fact line does not (${mode.name})',
        (tester) async {
          await tester.pumpApp(
            const DeskHeadline(
              first: '12 cases on desk.',
              second: 'AI read them first.',
            ),
            themeMode: mode,
          );
          final theme = Theme.of(tester.element(find.byType(DeskHeadline)));
          final status = theme.extension<AppStatusColors>()!;

          expect(
            tester.widget<Text>(find.text('AI read them first.')).style?.color,
            status.aiDraft,
          );
          expect(
            tester.widget<Text>(find.text('12 cases on desk.')).style?.color,
            theme.colorScheme.onSurface,
          );
          final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
          expect(icon.asset, Assets.icons.sparkleIcon);
          expect(icon.color, status.aiDraft);
        },
      );
    }

    testWidgets('H-18 rule 2: neither line wears the signed colour', (
      tester,
    ) async {
      await tester.pumpApp(const DeskHeadline(first: 'a', second: 'b'));
      final status = Theme.of(
        tester.element(find.byType(DeskHeadline)),
      ).extension<AppStatusColors>()!;
      final signed = {status.signed, status.signedContainer, status.signedDot};
      final used = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          t.style?.color,
        tester.widget<AssetIcon>(find.byType(AssetIcon)).color,
      ];
      expect(used.where(signed.contains), isEmpty);
    });

    testWidgets('is one header that reads both lines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const DeskHeadline(
          first: '3 cases on desk.',
          second: 'AI read them first.',
        ),
      );
      final node = tester.getSemantics(find.byType(DeskHeadline));
      expect(node.label, contains('3 cases on desk.'));
      expect(node.label, contains('AI read them first.'));
      handle.dispose();
    });

    testWidgets('grows at 1.3x in a long line without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final sw = lookupAppLocalizations(const Locale('sw'));

      await tester.pumpApp(
        locale: const Locale('sw'),
        DeskHeadline(
          first: sw.deskCasesOnDesk(128),
          second: sw.deskAiReadFirst,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
