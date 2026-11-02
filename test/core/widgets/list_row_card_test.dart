import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/list_row_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ListRowCard', () {
    ListRowCard card({
      VoidCallback? onTap,
      bool unread = false,
      bool chevron = true,
    }) {
      return ListRowCard(
        title: 'TB-0219 · Blood smear',
        leading: IconTile(icon: Assets.icons.documentIcon, tone: IconTone.mint),
        subtitle: 'Parasitemia 4.2% · High 94%',
        chip: const Text('Shared'),
        trailingText: '2h 05m',
        unread: unread,
        chevron: chevron,
        onTap: onTap,
      );
    }

    Finder dotFinder(ColorScheme scheme) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
          (w.decoration! as BoxDecoration).color == scheme.primary,
    );

    Finder chevronFinder() => find.byWidgetPredicate(
      (w) => w is AssetIcon && w.asset == Assets.icons.forwardIcon,
    );

    Finder buttonFinder() => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.button == true,
    );

    ColorScheme schemeOf(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(ListRowCard))).colorScheme;

    testWidgets('renders every slot in a white card', (tester) async {
      await tester.pumpApp(card(onTap: () {}));
      await tester.pumpAndSettle();

      expect(find.text('TB-0219 · Blood smear'), findsOneWidget);
      expect(find.text('Parasitemia 4.2% · High 94%'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
      expect(find.text('2h 05m'), findsOneWidget);
      expect(find.byType(IconTile), findsOneWidget);

      final scheme = schemeOf(tester);
      final cardBox = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ListRowCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = cardBox.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerLowest);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.card));
      expect(decoration.boxShadow, hasLength(1));
      expect(decoration.boxShadow!.single, AppShadows.card().single);

      final title = tester.widget<Text>(find.text('TB-0219 · Blood smear'));
      expect(title.style?.fontSize, 14);
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      final subtitle = tester.widget<Text>(
        find.text('Parasitemia 4.2% · High 94%'),
      );
      expect(subtitle.style?.fontSize, 13);
      expect(subtitle.maxLines, 3);
      expect(subtitle.overflow, TextOverflow.ellipsis);
      final trailing = tester.widget<Text>(find.text('2h 05m'));
      expect(trailing.style?.fontSize, 12);
      expect(trailing.maxLines, 1);
      expect(trailing.overflow, TextOverflow.ellipsis);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(card(onTap: () => taps++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TB-0219 · Blood smear'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('is a button only with a tap', (tester) async {
      await tester.pumpApp(card());
      await tester.pumpAndSettle();
      expect(buttonFinder(), findsNothing);

      await tester.pumpApp(card(onTap: () {}));
      await tester.pumpAndSettle();
      expect(buttonFinder(), findsOneWidget);
    });

    testWidgets('shows the unread dot only when unread', (tester) async {
      await tester.pumpApp(card(onTap: () {}));
      await tester.pumpAndSettle();
      expect(dotFinder(schemeOf(tester)), findsNothing);

      await tester.pumpApp(card(onTap: () {}, unread: true));
      await tester.pumpAndSettle();
      final dot = dotFinder(schemeOf(tester));
      expect(dot, findsOneWidget);
      expect(tester.getSize(dot), const Size(8, 8));
      expect(
        tester.getTopLeft(dot).dy,
        greaterThan(tester.getBottomLeft(find.text('2h 05m')).dy),
      );
    });

    testWidgets('shows the chevron bottom-right only when asked', (
      tester,
    ) async {
      await tester.pumpApp(card(onTap: () {}, chevron: false));
      await tester.pumpAndSettle();
      expect(chevronFinder(), findsNothing);

      await tester.pumpApp(card(onTap: () {}));
      await tester.pumpAndSettle();
      expect(chevronFinder(), findsOneWidget);
      final chevron = tester.widget<AssetIcon>(chevronFinder());
      expect(chevron.size, 22);
      expect(chevron.scaleUp, isFalse);
      expect(chevron.color, schemeOf(tester).onSurfaceVariant);

      final cardCorner = tester.getBottomRight(find.byType(ListRowCard));
      final chevronCorner = tester.getBottomRight(chevronFinder());
      expect(cardCorner.dx - chevronCorner.dx, AppStyles.cardPadding.right);
      expect(cardCorner.dy - chevronCorner.dy, AppStyles.cardPadding.bottom);
    });

    testWidgets('renders a minimal row', (tester) async {
      await tester.pumpApp(
        const ListRowCard(title: 'TB-0219 · Blood smear', chevron: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('TB-0219 · Blood smear'), findsOneWidget);
      expect(chevronFinder(), findsNothing);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        card(onTap: () {}, unread: true),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('TB-0219 · Blood smear'), findsOneWidget);
      expect(dotFinder(schemeOf(tester)), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        ListRowCard(
          title: 'Kesi TB-0231',
          leading: IconTile(
            icon: Assets.icons.documentIcon,
            tone: IconTone.mint,
          ),
          subtitle: 'Daktari Kamau',
          chip: const Text('Tayari'),
          trailingText: 'Leo',
          onTap: () {},
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kesi TB-0231'), findsOneWidget);
      expect(find.text('Daktari Kamau'), findsOneWidget);
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
        ListRowCard(
          title:
              'A very long row title that wraps past two lines '
              'of text',
          leading: IconTile(
            icon: Assets.icons.documentIcon,
            tone: IconTone.mint,
          ),
          subtitle:
              'A very long row subtitle that wraps past three '
              'lines of small muted text',
          chip: const Text('Shared'),
          trailingText: 'A very long trailing text',
          unread: true,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
