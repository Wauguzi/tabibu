import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/summary_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SummaryCard', () {
    testWidgets('renders title, rows and edit link', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SummaryCard(
          title: 'You',
          rows: const [
            ('Name', 'Dr. Wanjiru Kamau'),
            ('Email', 'w.kamau@example.com'),
          ],
          editLabel: 'Edit',
          onEdit: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      expect(taps, 1);
    });

    testWidgets('labels are muted small and values regular body', (
      tester,
    ) async {
      await tester.pumpApp(
        SummaryCard(
          title: 'You',
          rows: const [('Name', 'Dr. Wanjiru Kamau')],
          editLabel: 'Edit',
          onEdit: () {},
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Name'));
      final textTheme = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;

      final label = tester.widget<Text>(find.text('Name'));
      expect(
        label.style,
        textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
      final value = tester.widget<Text>(find.text('Dr. Wanjiru Kamau'));
      expect(value.style, textTheme.bodyMedium);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: SummaryCard(
            title: 'A long title that must wrap, not clip',
            rows: const [
              ('Label', 'A long value that must wrap onto more lines'),
            ],
            editLabel: 'Edit',
            onEdit: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('raises by tone in dark mode', (tester) async {
      await tester.pumpApp(
        SummaryCard(
          title: 'You',
          rows: const [('Name', 'Dr. Wanjiru Kamau')],
          editLabel: 'Edit',
          onEdit: () {},
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SummaryCard));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SummaryCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (card.decoration! as BoxDecoration).color,
        scheme.surfaceContainerHigh,
      );
    });

    testWidgets('edits with Enter from the keyboard', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SummaryCard(
          title: 'You',
          rows: const [('Name', 'Dr. Wanjiru Kamau')],
          editLabel: 'Edit',
          onEdit: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
