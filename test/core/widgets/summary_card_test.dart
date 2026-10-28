import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/summary_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SummaryCard', () {
    testWidgets('renders title, rows and edit link', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SummaryCard(
          title: 'You',
          rows: const [
            ('Name', 'Dr. Wanjiru Kamau'),
            ('Email', 'w.kamau@example.com'),
          ],
          editLabel: 'Edit',
          onEdit: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      expect(taps, 1);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: SummaryCard(
            title: 'A long title that must wrap, not clip',
            rows: const [
              ('Label', 'A long value that must wrap onto more lines'),
            ],
            editLabel: 'Edit',
            onEdit: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
