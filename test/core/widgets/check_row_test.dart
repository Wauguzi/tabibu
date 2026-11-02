import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/check_row.dart';

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
