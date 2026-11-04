import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showSettledSheet', () {
    final results = <bool?>[];

    setUp(results.clear);

    Future<void> open(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showSettledSheet<bool>(
              context,
              title: 'Sheet title',
              subtitle: 'Sheet subtitle',
              cancelLabel: 'Cancel',
              builder: (sheet) => TextButton(
                onPressed: () => Navigator.of(sheet).pop(true),
                child: const Text('Confirm'),
              ),
            ).then(results.add),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('shows the title, subtitle and content', (tester) async {
      await open(tester);

      expect(find.text('Sheet title'), findsOneWidget);
      expect(find.text('Sheet subtitle'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('returns the result only after the sheet has slid away', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(results, isEmpty);
      expect(find.text('Sheet title'), findsOneWidget);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(results, [true]);
      expect(find.text('Sheet title'), findsNothing);
    });

    testWidgets('returns null when the sheet is cancelled', (tester) async {
      await open(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(results, [null]);
    });
  });
}
