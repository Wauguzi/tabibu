import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SettingsRow', () {
    testWidgets('a trailing icon replaces the chevron', (tester) async {
      await tester.pumpApp(
        SettingsRow(
          icon: Assets.icons.facilityIcon,
          title: 'Facility',
          supporting: 'Mbagathi District Hospital',
          trailingIcon: Assets.icons.tickIcon,
        ),
      );

      bool icon(Widget w, SvgGenImage asset) =>
          w is AssetIcon && w.asset == asset;
      expect(
        find.byWidgetPredicate((w) => icon(w, Assets.icons.tickIcon)),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => icon(w, Assets.icons.forwardIcon)),
        findsNothing,
      );
    });

    testWidgets('activates with Enter and Space from the keyboard', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        SettingsRow(
          icon: Assets.icons.shieldIcon,
          title: 'Privacy',
          onTap: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(taps, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 2);
    });
  });

  group('SettingsSwitchRow', () {
    testWidgets('toggles with Enter and Space from the keyboard', (
      tester,
    ) async {
      var value = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => SettingsSwitchRow(
            icon: Assets.icons.shieldIcon,
            title: 'Biometrics',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(value, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isFalse);
    });
  });

  group('SettingsGroup', () {
    testWidgets('raises by tone in dark mode', (tester) async {
      await tester.pumpApp(
        SettingsGroup(
          title: 'Preferences',
          children: [
            SettingsRow(
              icon: Assets.icons.shieldIcon,
              title: 'Privacy',
              onTap: () {},
            ),
          ],
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SettingsGroup));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(SettingsGroup),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (card.decoration as BoxDecoration).color,
        scheme.surfaceContainerHigh,
      );
    });
  });

  group('SettingsCard', () {
    testWidgets('lays rows out with hairlines and no title', (tester) async {
      await tester.pumpApp(
        SettingsCard(
          children: [
            SettingsRow(
              icon: Assets.icons.shieldIcon,
              title: 'First',
              onTap: () {},
            ),
            SettingsRow(
              icon: Assets.icons.shieldIcon,
              title: 'Second',
              onTap: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('SettingsRow', () {
    testWidgets('an info row drops the chevron and stays put', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SettingsRow(
          icon: Assets.icons.clockIcon,
          title: 'Length',
          supporting: '30 min',
          chevron: false,
          onTap: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('30 min'), findsOneWidget);
      // No forward icon anywhere in the row.
      expect(
        find.descendant(
          of: find.byType(SettingsRow),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is AssetIcon && widget.asset == Assets.icons.forwardIcon,
          ),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('SettingsSwitchRow', () {
    testWidgets('shows its supporting line under the title', (tester) async {
      await tester.pumpApp(
        SettingsSwitchRow(
          icon: Assets.icons.testTubeIcon,
          title: 'Accepting',
          supporting: 'Patients can book you',
          value: true,
          onChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accepting'), findsOneWidget);
      expect(find.text('Patients can book you'), findsOneWidget);
    });
  });
}
