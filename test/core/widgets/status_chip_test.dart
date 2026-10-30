import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';
import 'package:tabibu/core/widgets/status_chip.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StatusChip', () {
    testWidgets('renders every tone', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: Column(
            children: [
              for (final tone in StatusTone.values)
                StatusChip(label: 'Label $tone', tone: tone),
            ],
          ),
        ),
      );

      for (final tone in StatusTone.values) {
        expect(find.text('Label $tone'), findsOneWidget);
      }
    });

    testWidgets('outlines only the draft tone', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const Column(
            children: [
              StatusChip(label: 'Draft', tone: StatusTone.aiDraft),
              StatusChip(label: 'Signed', tone: StatusTone.signed),
            ],
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();

        final frame = tester.widget<DashedBorder>(find.byType(DashedBorder));
        final status = Theme.of(
          tester.element(find.text('Draft')),
        ).extension<AppStatusColors>()!;
        expect(frame.color, status.draftBorder);
        expect(find.byType(DashedBorder), findsOneWidget);
      }
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const StatusChip(
          label: 'A long label that wraps',
          tone: StatusTone.info,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
