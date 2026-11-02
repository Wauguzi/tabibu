import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/core/widgets/top_bar.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TopBar', () {
    testWidgets('renders back, centred title and subtitle', (tester) async {
      await tester.pumpApp(
        TopBar(
          backLabel: 'Back',
          onBack: () {},
          title: 'Case TB-0231',
          subtitle: 'Amina Wambui',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Case TB-0231'), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
      final back = tester.widget<CircleIconButton>(
        find.byType(CircleIconButton),
      );
      expect(back.semanticLabel, 'Back');
      expect(back.icon, Assets.icons.backIcon);

      final title = tester.widget<Text>(find.text('Case TB-0231'));
      expect(title.textAlign, TextAlign.center);
      expect(title.style?.fontSize, 16);
      final subtitle = tester.widget<Text>(find.text('Amina Wambui'));
      expect(subtitle.textAlign, TextAlign.center);
      expect(subtitle.maxLines, 1);
      expect(subtitle.overflow, TextOverflow.ellipsis);
    });

    testWidgets('fires the back action', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        TopBar(backLabel: 'Back', onBack: () => taps++, title: 'Case TB-0231'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('keeps a 48dp spacer without a trailing', (tester) async {
      await tester.pumpApp(
        TopBar(backLabel: 'Back', onBack: () {}, title: 'Case TB-0231'),
      );
      await tester.pumpAndSettle();

      final row = tester.widget<Row>(find.byType(Row));
      final spacer = row.children.last as SizedBox;
      expect(spacer.width, 48);
      expect(spacer.height, 48);
    });

    testWidgets('renders the trailing instead of the spacer', (tester) async {
      await tester.pumpApp(
        TopBar(
          backLabel: 'Back',
          onBack: () {},
          title: 'Case TB-0231',
          trailing: const Text('Trailing'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trailing'), findsOneWidget);
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.last, isA<Text>());
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        TopBar(
          backLabel: 'Back',
          onBack: () {},
          title: 'Case TB-0231',
          subtitle: 'Amina Wambui',
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Case TB-0231'), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        TopBar(
          backLabel: 'Back',
          onBack: () {},
          title: 'Kesi TB-0231',
          subtitle: 'Amina Wambui',
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kesi TB-0231'), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        TopBar(
          backLabel: 'Back',
          onBack: () {},
          title: 'A very long title that wraps onto two lines',
          subtitle: 'A very long subtitle that stays on one line',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('MoreButton', () {
    testWidgets('uses the stand-in icon and announces its label', (
      tester,
    ) async {
      await tester.pumpApp(
        MoreButton(semanticLabel: 'More options', onTap: () {}),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<CircleIconButton>(
        find.byType(CircleIconButton),
      );
      expect(button.icon, Assets.icons.moreIcon);
      expect(
        tester.getSemantics(find.byType(MoreButton)),
        matchesSemantics(
          label: 'More options',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        MoreButton(semanticLabel: 'More options', onTap: () => taps++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MoreButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        MoreButton(semanticLabel: 'More options', onTap: () {}),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.byType(MoreButton), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        MoreButton(semanticLabel: 'More options', onTap: () {}),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
