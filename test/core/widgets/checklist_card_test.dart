import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/checklist_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ChecklistCard', () {
    ChecklistCard card({bool inverse = false, bool leading = true}) {
      return ChecklistCard(
        title: 'Before you come',
        items: const ['Arrive 10 minutes early', 'Bring your ID'],
        leading: leading ? const Text('Badge') : null,
        inverse: inverse,
      );
    }

    Finder checkFinder() => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
          (w.decoration! as BoxDecoration).border is Border,
    );

    BoxDecoration cardDecoration(WidgetTester tester) {
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ChecklistCard),
              matching: find.byType(Container),
            )
            .first,
      );
      return card.decoration! as BoxDecoration;
    }

    testWidgets('renders a white card with teal checks', (tester) async {
      await tester.pumpApp(card());
      await tester.pumpAndSettle();

      expect(find.text('Before you come'), findsOneWidget);
      expect(find.text('Arrive 10 minutes early'), findsOneWidget);
      expect(find.text('Bring your ID'), findsOneWidget);
      expect(find.text('Badge'), findsOneWidget);

      final context = tester.element(find.byType(ChecklistCard));
      final scheme = Theme.of(context).colorScheme;
      expect(cardDecoration(tester).color, scheme.surfaceContainerLowest);

      final title = tester.widget<Text>(find.text('Before you come'));
      expect(title.style?.fontSize, 16);
      expect(title.style?.color, scheme.onSurface);
      final item = tester.widget<Text>(find.text('Arrive 10 minutes early'));
      expect(item.style?.fontSize, 14);
      expect(item.style?.color, scheme.onSurface);

      expect(checkFinder(), findsNWidgets(2));
      expect(tester.getSize(checkFinder().first), const Size(22, 22));
      final check = tester.widget<Container>(checkFinder().first);
      final ring = (check.decoration! as BoxDecoration).border!.top;
      expect(ring.color, scheme.primary);
      expect(ring.width, 2);
      final glyph = tester.widget<AssetIcon>(
        find
            .byWidgetPredicate(
              (w) => w is AssetIcon && w.asset == Assets.icons.tickIcon,
            )
            .first,
      );
      expect(glyph.size, 12);
      expect(glyph.color, scheme.primary);
    });

    testWidgets('renders the ink variant with white checks', (tester) async {
      await tester.pumpApp(card(inverse: true));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ChecklistCard));
      final status = Theme.of(context).extension<AppStatusColors>()!;
      expect(cardDecoration(tester).color, status.ink);

      final title = tester.widget<Text>(find.text('Before you come'));
      expect(title.style?.color, Colors.white);
      final item = tester.widget<Text>(find.text('Arrive 10 minutes early'));
      expect(item.style?.color, Colors.white);
      final check = tester.widget<Container>(checkFinder().first);
      final ring = (check.decoration! as BoxDecoration).border!.top;
      expect(ring.color, Colors.white);
    });

    testWidgets('keeps contrast in dark', (tester) async {
      await tester.pumpApp(card(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Before you come'), findsOneWidget);

      await tester.pumpApp(card(inverse: true), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ChecklistCard));
      final status = Theme.of(context).extension<AppStatusColors>()!;
      expect(cardDecoration(tester).color, status.ink);
      final title = tester.widget<Text>(find.text('Before you come'));
      expect(title.style?.color, AppColors.inkLight);
      final check = tester.widget<Container>(checkFinder().first);
      final ring = (check.decoration! as BoxDecoration).border!.top;
      expect(ring.color, AppColors.inkLight);
    });

    testWidgets('renders without a leading', (tester) async {
      await tester.pumpApp(card(leading: false));
      await tester.pumpAndSettle();

      expect(find.text('Before you come'), findsOneWidget);
      expect(find.text('Badge'), findsNothing);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const ChecklistCard(
          title: 'Matokeo yako',
          items: ['Chagua daktari', 'Karibu nyumbani'],
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo yako'), findsOneWidget);
      expect(find.text('Chagua daktari'), findsOneWidget);
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
        const ChecklistCard(
          title: 'A very long card title that must wrap across lines',
          items: [
            'A very long first item that must wrap across lines of text',
            'A very long second item that must wrap across lines of text',
          ],
          leading: Text('Badge'),
          inverse: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
