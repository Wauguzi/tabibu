import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/setting_toggle_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SettingToggleCard', () {
    testWidgets('mirrors the value and toggles from row and switch', (
      tester,
    ) async {
      var value = true;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => SettingToggleCard(
            icon: Assets.icons.notificationBellIcon,
            tone: IconTone.sky,
            title: 'Turn on notifications',
            supporting: 'Hear from your doctor',
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.text('Turn on notifications'));
      await tester.pump();
      expect(value, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('announces one toggled node for the row', (tester) async {
      await tester.pumpApp(
        SettingToggleCard(
          icon: Assets.icons.notificationBellIcon,
          tone: IconTone.sky,
          title: 'Turn on notifications',
          supporting: 'Hear from your doctor',
          value: true,
          onChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Turn on notifications')),
        matchesSemantics(
          label: 'Turn on notifications\nHear from your doctor',
          isImage: true,
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      // The switch mirrors the value visually but is not a second target.
      expect(
        tester.getSemantics(find.byType(Switch)),
        matchesSemantics(
          label: 'Turn on notifications\nHear from your doctor',
          isImage: true,
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: SettingToggleCard(
            icon: Assets.icons.notificationBellIcon,
            tone: IconTone.sky,
            title: 'A long title that must wrap, not clip',
            supporting: 'Supporting text that also wraps onto more lines',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
