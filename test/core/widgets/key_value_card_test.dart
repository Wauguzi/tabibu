import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/key_value_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('KeyValueCard', () {
    KeyValueCard card() {
      return const KeyValueCard(
        title: 'Order summary',
        rows: [('Test', 'Blood test'), ('Priority', 'Routine')],
        footer: Text('See details'),
      );
    }

    testWidgets('renders title, rows and footer', (tester) async {
      await tester.pumpApp(card());
      await tester.pumpAndSettle();

      expect(find.text('Order summary'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Blood test'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Routine'), findsOneWidget);
      expect(find.text('See details'), findsOneWidget);

      final context = tester.element(find.text('Test'));
      final textTheme = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;
      final label = tester.widget<Text>(find.text('Test'));
      expect(
        label.style,
        textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
      final value = tester.widget<Text>(find.text('Blood test'));
      expect(value.style, textTheme.labelMedium);
      final title = tester.widget<Text>(find.text('Order summary'));
      expect(title.style?.fontSize, 16);
    });

    testWidgets('renders rows without title or footer', (tester) async {
      await tester.pumpApp(const KeyValueCard(rows: [('Test', 'Blood test')]));
      await tester.pumpAndSettle();

      expect(find.text('Order summary'), findsNothing);
      expect(find.text('See details'), findsNothing);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Blood test'), findsOneWidget);
    });

    testWidgets('never shows an edit button', (tester) async {
      await tester.pumpApp(card());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.button == true,
        ),
        findsNothing,
      );
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(card(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Order summary'), findsOneWidget);
      expect(find.text('Blood test'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const KeyValueCard(
          title: 'Matokeo',
          rows: [('Tarehe', 'Namba 3')],
          footer: Text('Karibu'),
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo'), findsOneWidget);
      expect(find.text('Tarehe'), findsOneWidget);
      expect(find.text('Karibu'), findsOneWidget);
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
        const KeyValueCard(
          title: 'A very long card title that must wrap across lines',
          rows: [
            (
              'Label',
              'A very long value that must wrap onto more lines of text',
            ),
          ],
          footer: Text('A very long footer that must wrap across lines'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
