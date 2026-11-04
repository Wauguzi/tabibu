import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/bottom_action_bar.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

import '../../helpers/helpers.dart';

void main() {
  group('BottomActionBar', () {
    BottomActionBar bar({
      VoidCallback? onPrimary,
      VoidCallback? onSecondary,
      bool secondary = true,
    }) {
      return BottomActionBar(
        primary: TabibuButton.primary(
          label: 'Sign report',
          onTap: onPrimary ?? () {},
        ),
        secondary: secondary
            ? TabibuButton.secondary(
                label: 'Save draft',
                onTap: onSecondary ?? () {},
              )
            : null,
      );
    }

    testWidgets('lays secondary left and primary right over a fade', (
      tester,
    ) async {
      await tester.pumpApp(bar());
      await tester.pumpAndSettle();

      expect(find.text('Sign report'), findsOneWidget);
      expect(find.text('Save draft'), findsOneWidget);
      final buttons = find.byType(TabibuButton);
      expect(
        tester.getCenter(buttons.at(0)).dx,
        lessThan(tester.getCenter(buttons.at(1)).dx),
      );
      expect(tester.getSize(buttons.at(0)), tester.getSize(buttons.at(1)));
      expect(find.byType(SafeArea), findsOneWidget);

      final fade = tester.widget<DecoratedBox>(
        find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient is LinearGradient,
        ),
      );
      final context = tester.element(find.byType(BottomActionBar));
      final surface = Theme.of(context).colorScheme.surface;
      final gradient =
          (fade.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.colors, [surface.withValues(alpha: 0), surface]);
    });

    testWidgets('gives a lone primary the full width', (tester) async {
      await tester.pumpApp(bar(secondary: false));
      await tester.pumpAndSettle();

      expect(find.text('Sign report'), findsOneWidget);
      expect(find.text('Save draft'), findsNothing);
      final barWidth = tester.getSize(find.byType(BottomActionBar)).width;
      expect(
        tester.getSize(find.byType(TabibuButton)).width,
        barWidth - 2 * AppSpacing.screenMargin,
      );
    });

    testWidgets('fires both taps', (tester) async {
      var primaryTaps = 0;
      var secondaryTaps = 0;
      await tester.pumpApp(
        bar(onPrimary: () => primaryTaps++, onSecondary: () => secondaryTaps++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign report'));
      await tester.tap(find.text('Save draft'));
      await tester.pumpAndSettle();
      expect(primaryTaps, 1);
      expect(secondaryTaps, 1);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(bar(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Sign report'), findsOneWidget);
      expect(find.text('Save draft'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        BottomActionBar(
          primary: TabibuButton.primary(label: 'Chagua', onTap: () {}),
          secondary: TabibuButton.secondary(label: 'Karibu', onTap: () {}),
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chagua'), findsOneWidget);
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
        BottomActionBar(
          primary: TabibuButton.primary(
            label: 'Approve and send this alert now',
            onTap: () {},
          ),
          secondary: TabibuButton.secondary(
            label: 'Reject with a reason',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final buttons = find.byType(TabibuButton);
      expect(
        tester.getSize(buttons.at(0)).height,
        tester.getSize(buttons.at(1)).height,
      );
    });
  });
}
