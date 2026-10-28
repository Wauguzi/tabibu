import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/option_card.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('OptionCard', () {
    testWidgets('renders selected and unselected', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            OptionCard(
              title: 'On',
              supporting: 'Picked',
              icon: Assets.icons.heartIcon,
              selected: true,
              onTap: () {},
            ),
            OptionCard(
              title: 'Off',
              supporting: 'Skipped',
              icon: Assets.icons.personIcon,
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('On'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
      expect(find.byType(IconTile), findsNWidgets(2));
      expect(find.byType(StatusMark), findsNWidgets(2));
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        OptionCard(title: 'Tap', selected: false, onTap: () => taps++),
      );

      await tester.tap(find.text('Tap'));
      expect(taps, 1);
    });

    testWidgets('announces one selected button per card', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            OptionCard(
              title: 'On',
              supporting: 'Picked',
              selected: true,
              onTap: () {},
            ),
            OptionCard(
              title: 'Multi',
              selected: false,
              markLeading: true,
              onTap: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('On')),
        matchesSemantics(
          label: 'On\nPicked',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Multi')),
        matchesSemantics(
          label: 'Multi',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('leading mark drops the tile', (tester) async {
      await tester.pumpApp(
        OptionCard(
          title: 'Multi',
          selected: true,
          markLeading: true,
          onTap: () {},
        ),
      );

      expect(find.byType(IconTile), findsNothing);
      expect(find.byType(StatusMark), findsOneWidget);
    });

    testWidgets('trailing overrides the mark', (tester) async {
      await tester.pumpApp(
        OptionCard(
          title: 'Chevron',
          selected: false,
          trailing: const Text('>'),
          onTap: () {},
        ),
      );

      expect(find.byType(StatusMark), findsNothing);
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(
        OptionCard(title: 'Tall', selected: false, onTap: () {}),
      );

      expect(
        tester.getSize(find.byType(OptionCard)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: OptionCard(
            title: 'A long title that must wrap, not clip',
            supporting: 'Supporting text that also wraps onto more lines',
            icon: Assets.icons.heartIcon,
            selected: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
