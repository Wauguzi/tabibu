import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/password_field.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PasswordField', () {
    testWidgets('obscures by default and reveals on toggle', (tester) async {
      await tester.pumpApp(
        const PasswordField(
          label: 'Password',
          showLabel: 'Show password',
          hideLabel: 'Hide password',
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'secret');
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );

      await tester.tap(find.byType(AssetIcon).last);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isFalse,
      );
    });

    testWidgets('announces the action the toggle will take', (tester) async {
      await tester.pumpApp(
        const PasswordField(
          label: 'Password',
          showLabel: 'Show password',
          hideLabel: 'Hide password',
          autofillHints: [AutofillHints.newPassword],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(AssetIcon).last),
        matchesSemantics(
          label: 'Show password',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).autofillHints, [
        AutofillHints.newPassword,
      ]);

      await tester.tap(find.byType(AssetIcon).last);
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(AssetIcon).last),
        matchesSemantics(
          label: 'Hide password',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpApp(
        const PasswordField(
          label: 'Password',
          showLabel: 'Show password',
          hideLabel: 'Hide password',
          errorText: 'No match',
        ),
      );

      expect(find.text('No match'), findsOneWidget);
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(
        const PasswordField(
          label: 'Password',
          showLabel: 'Show password',
          hideLabel: 'Hide password',
        ),
      );

      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const PasswordField(
          label: 'A long label that must wrap, not clip',
          showLabel: 'Show password',
          hideLabel: 'Hide password',
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
