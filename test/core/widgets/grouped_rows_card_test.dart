import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/grouped_rows_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('GroupedRowsCard', () {
    GroupedRowsCard card({String? title = 'From this appointment'}) {
      return GroupedRowsCard(
        title: title,
        children: const [Text('One'), Text('Two'), Text('Three')],
      );
    }

    ColorScheme schemeOf(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(GroupedRowsCard))).colorScheme;

    testWidgets('renders the title above a divided card', (tester) async {
      await tester.pumpApp(card());
      await tester.pumpAndSettle();

      expect(find.text('From this appointment'), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);

      final scheme = schemeOf(tester);
      final title = tester.widget<Text>(find.text('From this appointment'));
      expect(title.style?.fontSize, 16);
      expect(title.style?.color, scheme.onSurfaceVariant);
      expect(
        tester.getBottomLeft(find.text('From this appointment')).dy,
        lessThan(tester.getTopLeft(find.text('One')).dy),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.header == true,
        ),
        findsOneWidget,
      );

      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      expect(dividers.length, 2);
      for (final divider in dividers) {
        expect(divider.height, 1);
        expect(divider.color, scheme.outlineVariant);
        expect(divider.indent, AppSpacing.md);
        expect(divider.endIndent, AppSpacing.md);
      }
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(GroupedRowsCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerLowest);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.card));
    });

    testWidgets('renders rows without a title', (tester) async {
      await tester.pumpApp(card(title: null));
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.header == true,
        ),
        findsNothing,
      );
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(card(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('From this appointment'), findsOneWidget);
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(GroupedRowsCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).color,
        schemeOf(tester).surfaceContainerHigh,
      );
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const GroupedRowsCard(
          title: 'Matokeo yako',
          children: [Text('Moja'), Text('Ripoti'), Text('Tayari')],
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo yako'), findsOneWidget);
      expect(find.text('Moja'), findsOneWidget);
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
        const GroupedRowsCard(
          title: 'A very long section title that must wrap across lines',
          children: [
            Text('A very long first row that must wrap across lines'),
            Text('A very long second row that must wrap across lines'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
