import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SettingsRow', () {
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
}
