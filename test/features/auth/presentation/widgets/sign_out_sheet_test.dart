import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/presentation/widgets/sign_out_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('confirmSignOut', () {
    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => confirmSignOut(context, isPatient: true),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out of Tabibu?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
