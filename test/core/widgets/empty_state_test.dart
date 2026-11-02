import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/empty_state.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('EmptyState', () {
    EmptyState state() => EmptyState(
      title: 'No doctors match',
      icon: Assets.icons.searchRoundedIcon,
      body: 'Check the spelling, or search by hospital or town.',
      actions: [
        const Text('Did you mean'),
        SuggestionPill(label: 'Cardiologist', onTap: () {}),
      ],
      tips: const TipsCard(
        title: 'Try this',
        tips: ['Try a surgeon', 'Search a hospital'],
      ),
    );

    testWidgets('renders visual, title, body, actions and tips', (
      tester,
    ) async {
      await tester.pumpApp(state());
      await tester.pumpAndSettle();

      expect(find.byType(IconTile), findsOneWidget);
      expect(tester.getSize(find.byType(IconTile)), const Size(56, 56));
      expect(find.text('No doctors match'), findsOneWidget);
      expect(
        find.text('Check the spelling, or search by hospital or town.'),
        findsOneWidget,
      );
      expect(find.text('Did you mean'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('Try this'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);

      final title = tester.widget<Text>(find.text('No doctors match'));
      expect(title.style?.fontSize, 22);
      expect(title.textAlign, TextAlign.center);
      final body = tester.widget<Text>(
        find.text('Check the spelling, or search by hospital or town.'),
      );
      expect(body.style?.fontSize, 14);
      expect(body.textAlign, TextAlign.center);
      expect(
        tester.getTopLeft(find.text('No doctors match')).dy,
        lessThan(tester.getTopLeft(find.text('Did you mean')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Did you mean')).dy,
        lessThan(tester.getTopLeft(find.text('Try this')).dy),
      );
    });

    testWidgets('shows the illustration instead of the icon tile', (
      tester,
    ) async {
      await tester.pumpApp(
        EmptyState(
          title: 'Your desk is empty',
          icon: Assets.icons.searchRoundedIcon,
          illustration: const Text('Art'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Art'), findsOneWidget);
      expect(find.byType(IconTile), findsNothing);
    });

    testWidgets('renders without a visual', (tester) async {
      await tester.pumpApp(const EmptyState(title: 'Nothing here'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(IconTile), findsNothing);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(state(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('No doctors match'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        EmptyState(
          title: 'Matokeo yako',
          icon: Assets.icons.searchRoundedIcon,
          body: 'Ripoti tayari',
          actions: [SuggestionPill(label: 'Chagua', onTap: () {})],
          tips: const TipsCard(title: 'Karibu', tips: ['Moja']),
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo yako'), findsOneWidget);
      expect(find.text('Chagua'), findsOneWidget);
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
        SingleChildScrollView(
          child: EmptyState(
            title: 'A very long empty title that must wrap across lines',
            icon: Assets.icons.searchRoundedIcon,
            body: 'A very long empty body that must wrap across lines too',
            actions: [
              SuggestionPill(label: 'A very long suggestion', onTap: () {}),
              SuggestionPill(label: 'Another long suggestion', onTap: () {}),
            ],
            tips: const TipsCard(
              title: 'Try this',
              tips: [
                'A very long first tip that must wrap across lines of text',
                'A very long second tip that must wrap across lines of text',
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('SuggestionPill', () {
    testWidgets('renders an outlined pill with its arrow', (tester) async {
      await tester.pumpApp(SuggestionPill(label: 'Cardiologist', onTap: () {}));
      await tester.pumpAndSettle();

      expect(find.text('Cardiologist'), findsOneWidget);
      final context = tester.element(find.byType(SuggestionPill));
      final scheme = Theme.of(context).colorScheme;
      final pillBox = find.descendant(
        of: find.byType(SuggestionPill),
        matching: find.byType(Container),
      );
      final pill = tester.widget<Container>(pillBox);
      final decoration = pill.decoration! as BoxDecoration;
      expect(decoration.border?.top.color, scheme.outline);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.pill));
      expect(tester.getSize(pillBox).height, greaterThanOrEqualTo(48));

      final label = tester.widget<Text>(find.text('Cardiologist'));
      expect(label.style?.fontSize, 16);
      expect(label.style?.color, scheme.onSurface);
      final arrow = tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(arrow.asset, Assets.icons.forwardIcon);
      expect(arrow.size, 18);
      expect(arrow.color, scheme.onSurface);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SuggestionPill(label: 'Cardiologist', onTap: () => taps++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cardiologist'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('announces a button', (tester) async {
      await tester.pumpApp(SuggestionPill(label: 'Cardiologist', onTap: () {}));
      await tester.pumpAndSettle();

      final button = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true,
      );
      expect(button, findsOneWidget);
      expect(tester.widget<Semantics>(button).properties.enabled, isTrue);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        SuggestionPill(label: 'Cardiologist', onTap: () {}),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Cardiologist'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        SuggestionPill(label: 'Chagua', onTap: () {}),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chagua'), findsOneWidget);
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
        SuggestionPill(
          label: 'A very long suggestion that must wrap inside the pill',
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('TipsCard', () {
    testWidgets('renders the title with tick rows', (tester) async {
      await tester.pumpApp(
        const TipsCard(
          title: 'Try this',
          tips: ['Try a surgeon', 'Search a hospital'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try this'), findsOneWidget);
      expect(find.text('Try a surgeon'), findsOneWidget);
      expect(find.text('Search a hospital'), findsOneWidget);

      final context = tester.element(find.byType(TipsCard));
      final scheme = Theme.of(context).colorScheme;
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(TipsCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerLow);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.notice));
      expect(decoration.boxShadow, isNull);
      expect(box.padding, AppStyles.cardPadding);

      final title = tester.widget<Text>(find.text('Try this'));
      expect(title.style?.fontSize, 16);
      expect(title.style?.color, scheme.onSurface);
      final tip = tester.widget<Text>(find.text('Try a surgeon'));
      expect(tip.style?.fontSize, 14);
      expect(tip.style?.color, scheme.onSurfaceVariant);
      final ticks = find.byType(AssetIcon);
      expect(ticks, findsNWidgets(2));
      final tick = tester.widget<AssetIcon>(ticks.first);
      expect(tick.asset, Assets.icons.tickIcon);
      expect(tick.size, 12);
      expect(tick.color, scheme.primary);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        const TipsCard(title: 'Try this', tips: ['Try a surgeon']),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Try this'), findsOneWidget);
      final context = tester.element(find.byType(TipsCard));
      final scheme = Theme.of(context).colorScheme;
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(TipsCard),
          matching: find.byType(Container),
        ),
      );
      expect(
        (box.decoration! as BoxDecoration).color,
        scheme.surfaceContainerLow,
      );
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const TipsCard(title: 'Karibu', tips: ['Chagua daktari']),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Karibu'), findsOneWidget);
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
        const TipsCard(
          title: 'A very long tips title that must wrap across lines',
          tips: [
            'A very long first tip that must wrap across lines of text',
            'A very long second tip that must wrap across lines of text',
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
