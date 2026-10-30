import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/search_field.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SearchField', () {
    testWidgets('reports queries and clears', (tester) async {
      var value = '';
      await tester.pumpApp(
        SearchField(
          hint: 'Search areas',
          clearLabel: 'Clear search',
          onChanged: (v) => value = v,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search areas'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Kibra');
      await tester.pump();
      expect(value, 'Kibra');

      await tester.tap(find.byType(AssetIcon).last);
      await tester.pump();
      expect(value, '');
      expect(find.text('Kibra'), findsNothing);
    });

    testWidgets('announces the clear button', (tester) async {
      await tester.pumpApp(
        const SearchField(hint: 'Search areas', clearLabel: 'Clear search'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Kibra');
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(AssetIcon).last),
        matchesSemantics(
          label: 'Clear search',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(
        const SearchField(hint: 'Search', clearLabel: 'Clear search'),
      );

      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SearchField(
          hint: 'A long hint that must wrap, not clip',
          clearLabel: 'Clear search',
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('focus colours the icons and the cursor', (tester) async {
      await tester.pumpApp(
        const SearchField(hint: 'Search areas', clearLabel: 'Clear search'),
      );
      final scheme = Theme.of(
        tester.element(find.byType(TextField)),
      ).colorScheme;
      AssetIcon search() => tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(search().color, scheme.onSurfaceVariant);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(search().color, scheme.primary);
      expect(
        tester.widget<TextField>(find.byType(TextField)).cursorColor,
        scheme.primary,
      );
    });

    testWidgets('clears with Enter from the keyboard', (tester) async {
      final controller = TextEditingController(text: 'Kibra');
      addTearDown(controller.dispose);
      var value = 'Kibra';
      await tester.pumpApp(
        SearchField(
          hint: 'Search areas',
          clearLabel: 'Clear search',
          controller: controller,
          onChanged: (v) => value = v,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, '');
      expect(controller.text, '');
    });
  });
}
