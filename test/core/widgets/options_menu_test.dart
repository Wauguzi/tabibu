import 'package:animations/animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/options_menu.dart';
import 'package:tabibu/core/widgets/options_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('showOptionsMenu', () {
    List<OptionsAction<String>> actions() => [
      OptionsAction(
        value: 'read',
        icon: Assets.icons.tickIcon,
        label: 'Mark all as read',
      ),
      OptionsAction(
        value: 'refresh',
        icon: Assets.icons.infoIcon,
        label: 'Refresh',
      ),
      OptionsAction(
        value: 'settings',
        icon: Assets.icons.notificationBellIcon,
        label: 'Notification settings',
      ),
      OptionsAction(
        value: 'delete',
        icon: Assets.icons.deleteIcon,
        label: 'Delete all',
        supporting: 'Removes every notification',
        destructive: true,
      ),
    ];

    Finder cardFinder() => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(AppRadii.tile),
    );

    // Results are captured, not awaited: awaiting a route's future inside a
    // widget test blocks until a pump that never comes.
    Future<List<String?>> openMenu(
      WidgetTester tester, {
      required GlobalKey anchor,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: Builder(
              builder: (context) => TextButton(
                key: anchor,
                onPressed: () => showOptionsMenu<String>(
                  context,
                  anchor: anchor,
                  actions: actions(),
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);
      return results;
    }

    ColorScheme schemeOf(WidgetTester tester) =>
        Theme.of(tester.element(find.text('Mark all as read'))).colorScheme;

    testWidgets('opens under the anchor with its rows', (tester) async {
      final anchor = GlobalKey();
      await openMenu(tester, anchor: anchor);

      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Notification settings'), findsOneWidget);
      expect(find.byType(AssetIcon), findsNWidgets(4));
      expect(find.byType(FadeScaleTransition), findsOneWidget);

      final anchorRect = tester.getRect(find.byKey(anchor));
      final menuRect = tester.getRect(cardFinder());
      expect(menuRect.top, anchorRect.bottom + AppSpacing.xs);
      expect(menuRect.right, anchorRect.right);

      final label = tester.widget<Text>(find.text('Mark all as read'));
      expect(label.style?.fontSize, 16);
      final scheme = schemeOf(tester);
      expect(label.style?.color, scheme.onSurface);
      final card = tester.widget<Container>(cardFinder());
      final decoration = card.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surfaceContainerLowest);
      expect(decoration.boxShadow, hasLength(1));
      expect(decoration.boxShadow!.single, AppShadows.card().single);
      final barrier = tester.widget<ModalBarrier>(
        find.byWidgetPredicate(
          (w) => w is ModalBarrier && w.color == AppShadows.barrierScrim,
        ),
      );
      expect(barrier.dismissible, isTrue);
    });

    testWidgets('tapping a row returns its value', (tester) async {
      final anchor = GlobalKey();
      final results = await openMenu(tester, anchor: anchor);

      await tester.tap(find.text('Refresh'));
      await settleSheet(tester);

      expect(results, ['refresh']);
      expect(cardFinder(), findsNothing);
    });

    testWidgets('an outside tap returns null', (tester) async {
      final anchor = GlobalKey();
      final results = await openMenu(tester, anchor: anchor);

      await tester.tapAt(const Offset(50, 500));
      await settleSheet(tester);

      expect(results, [null]);
      expect(cardFinder(), findsNothing);
    });

    testWidgets('back returns null', (tester) async {
      final anchor = GlobalKey();
      final results = await openMenu(tester, anchor: anchor);

      await tester.binding.handlePopRoute();
      await settleSheet(tester);

      expect(results, [null]);
      expect(cardFinder(), findsNothing);
    });

    testWidgets('paints a destructive row red', (tester) async {
      final anchor = GlobalKey();
      await openMenu(tester, anchor: anchor);

      final scheme = schemeOf(tester);
      final label = tester.widget<Text>(find.text('Delete all'));
      expect(label.style?.color, scheme.error);
      final icon = tester.widget<AssetIcon>(
        find.byWidgetPredicate(
          (w) => w is AssetIcon && w.asset == Assets.icons.deleteIcon,
        ),
      );
      expect(icon.color, scheme.error);
      expect(find.text('Removes every notification'), findsOneWidget);
    });

    testWidgets('renders in dark', (tester) async {
      final anchor = GlobalKey();
      await openMenu(tester, anchor: anchor, themeMode: ThemeMode.dark);

      expect(find.text('Mark all as read'), findsOneWidget);
      final card = tester.widget<Container>(cardFinder());
      expect(
        (card.decoration! as BoxDecoration).color,
        schemeOf(tester).surfaceContainerHigh,
      );
    });

    testWidgets('renders in Swahili', (tester) async {
      final anchor = GlobalKey();
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: Builder(
              builder: (context) => TextButton(
                key: anchor,
                onPressed: () => showOptionsMenu<String>(
                  context,
                  anchor: anchor,
                  actions: [
                    OptionsAction(
                      value: 'one',
                      icon: Assets.icons.tickIcon,
                      label: 'Chagua',
                    ),
                  ],
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        locale: const Locale('sw'),
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);

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

      final anchor = GlobalKey();
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: Builder(
              builder: (context) => TextButton(
                key: anchor,
                onPressed: () => showOptionsMenu<String>(
                  context,
                  anchor: anchor,
                  actions: [
                    OptionsAction(
                      value: 'one',
                      icon: Assets.icons.tickIcon,
                      label: 'A very long menu label that must wrap',
                      supporting:
                          'A very long supporting line that must wrap too',
                    ),
                  ],
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);

      expect(tester.takeException(), isNull);
    });
  });
}

/// Menu transitions keep scheduling frames, so pumpAndSettle never returns;
/// this pumps past the transition instead.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
