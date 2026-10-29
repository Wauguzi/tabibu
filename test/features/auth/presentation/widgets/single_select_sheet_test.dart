import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/presentation/widgets/single_select_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showSingleSelectSheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showSingleSelectSheet<String>(
              context: context,
              title: 'Choose one',
              searchHint: 'Search',
              items: const ['Nairobi', 'Mombasa', 'Kisumu'],
              label: (item) => item,
              selected: null,
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('searching filters the list', (tester) async {
      await openSheet(tester);

      expect(find.text('Nairobi'), findsOneWidget);
      expect(find.text('Mombasa'), findsOneWidget);
      expect(find.text('Kisumu'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'MB');
      await tester.pumpAndSettle();

      expect(find.text('Mombasa'), findsOneWidget);
      expect(find.text('Nairobi'), findsNothing);
      expect(find.text('Kisumu'), findsNothing);
    });
  });
}
