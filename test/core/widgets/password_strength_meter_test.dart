import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/password_strength_meter.dart';

import '../../helpers/helpers.dart';

const _meter = PasswordStrengthMeter(
  password: 'Password1',
  strengthWord: 'Good',
  lengthLabel: 'At least 8 characters',
  numberLabel: 'Includes a number',
  symbolLabel: 'Includes a symbol',
);

void main() {
  group('PasswordStrengthMeter', () {
    testWidgets('renders nothing while empty', (tester) async {
      await tester.pumpApp(
        const PasswordStrengthMeter(
          password: '',
          strengthWord: 'Good',
          lengthLabel: 'At least 8 characters',
          numberLabel: 'Includes a number',
          symbolLabel: 'Includes a symbol',
        ),
      );

      expect(find.text('Good'), findsNothing);
    });

    testWidgets('shows bars, word and checklist', (tester) async {
      await tester.pumpApp(_meter);

      expect(find.text('Good'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('Includes a number'), findsOneWidget);
      expect(find.text('Includes a symbol'), findsOneWidget);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const SingleChildScrollView(child: _meter));

      expect(tester.takeException(), isNull);
    });
  });
}
