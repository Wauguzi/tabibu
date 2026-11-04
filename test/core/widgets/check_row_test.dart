import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/check_row.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CheckRow', () {
    testWidgets('the label toggles it, and it reads as checked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      bool? changed;
      await tester.pumpApp(
        CheckRow(
          label: 'The protocol is in place',
          value: false,
          onChanged: (value) => changed = value,
        ),
      );

      await tester.tap(find.text('The protocol is in place'));
      expect(changed, isTrue);
      expect(
        tester.getSemantics(find.byType(CheckRow)),
        isSemantics(
          label: 'The protocol is in place',
          hasCheckedState: true,
          isChecked: false,
          isEnabled: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('circle: the ticked and the empty circle replace the box', (
      tester,
    ) async {
      var on = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => CheckRow(
            circle: true,
            label: 'Critical finding',
            value: on,
            onChanged: (value) => setState(() => on = value),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsNothing);
      AssetIcon icon() => tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(icon().asset, Assets.icons.checkUnselectedIcon);

      await tester.tap(find.text('Critical finding'));
      await tester.pump();
      expect(on, isTrue);
      expect(icon().asset, Assets.icons.checkSelectedIcon);
    });

    testWidgets('circle: without onChanged it is muted and inert', (
      tester,
    ) async {
      await tester.pumpApp(
        const CheckRow(
          circle: true,
          label: 'Critical finding',
          value: true,
          onChanged: null,
        ),
      );

      await tester.tap(find.text('Critical finding'));
      await tester.pump();
      expect(
        tester.widget<AssetIcon>(find.byType(AssetIcon)).asset,
        Assets.icons.checkSelectedIcon,
      );
    });

    testWidgets('without onChanged it is disabled', (tester) async {
      await tester.pumpApp(
        const CheckRow(label: 'Terms', value: true, onChanged: null),
      );

      final box = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(box.onChanged, isNull);
      expect(box.value, isTrue);
    });
  });
}
