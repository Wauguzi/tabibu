import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/presentation/widgets/document_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showDocumentSheet', () {
    late Future<DocumentSource?> shown;

    Future<void> openSheet(WidgetTester tester, {String? subtitle}) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              shown = showDocumentSheet(context, subtitle: subtitle);
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('each row returns its source', (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();
      expect(await shown, DocumentSource.camera);

      await openSheet(tester);
      await tester.tap(find.text('Upload a file'));
      await tester.pumpAndSettle();
      expect(await shown, DocumentSource.file);
    });

    testWidgets('Cancel returns null', (tester) async {
      await openSheet(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await shown, isNull);
    });

    testWidgets('shows the passed subtitle', (tester) async {
      await openSheet(tester, subtitle: 'Role subtitle');

      expect(find.text('Role subtitle'), findsOneWidget);
    });

    testWidgets("defaults to the doctor's subtitle", (tester) async {
      await openSheet(tester);

      expect(
        find.text('Practising licence or specialist certificate. Up to two.'),
        findsOneWidget,
      );
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openSheet(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
