import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/revision_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('AmendSheet', () {
    testWidgets('94: a tap outside the reason field dismisses the keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      const locale = Locale('en');
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AmendSheet.show(context),
            child: const Text('Open'),
          ),
        ),
        locale: locale,
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final l10n = lookupAppLocalizations(locale);

      final field = find.byType(TextField);
      await tester.tap(field);
      await tester.pump();
      final node = tester.widget<TextField>(field).focusNode!;
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      // The sheet title sits above the field, outside it.
      await tester.tap(find.text(l10n.signedCaseAmendTitle));
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });
  });
}
