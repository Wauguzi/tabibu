import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/option_card.dart';
import 'package:tabibu/features/auth/presentation/widgets/specialty_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showSpecialtySheet', () {
    late Future<List<Specialty>?> shown;

    Future<void> openSheet(
      WidgetTester tester, {
      required List<Specialty> allowed,
      List<Specialty> initial = const [],
    }) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              shown = showSpecialtySheet(
                context: context,
                title: 'Choose',
                subtitle: (count) => '$count selected',
                searchHint: 'Search',
                doneLabel: (count) => 'Done · $count selected',
                initial: initial,
                allowed: allowed,
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    OptionCard card(WidgetTester tester, String title) =>
        tester.widget<OptionCard>(
          find.byWidgetPredicate((w) => w is OptionCard && w.title == title),
        );

    Future<void> tapOption(WidgetTester tester, String title) async {
      await tester.ensureVisible(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }

    testWidgets('the cap disables the rest', (tester) async {
      await openSheet(
        tester,
        allowed: const [
          Specialty.generalPractice,
          Specialty.familyMedicine,
          Specialty.internalMedicine,
          Specialty.generalSurgery,
          Specialty.paediatrics,
          Specialty.oncology,
        ],
      );

      for (final name in [
        'General practice',
        'Family medicine',
        'Internal medicine',
        'General surgery',
        'Paediatrics',
      ]) {
        await tapOption(tester, name);
      }

      expect(card(tester, 'Oncology').onTap, isNull);
      expect(card(tester, 'Paediatrics').onTap, isNotNull);
    });

    testWidgets('search filters by name', (tester) async {
      await openSheet(tester, allowed: Specialty.forRole(isPathologist: true));

      // Uppercase on purpose: the filter is case-insensitive.
      // cspell:disable-next-line
      await tester.enterText(find.byType(TextField), 'HISTO');
      await tester.pumpAndSettle();

      expect(find.text('Histopathology'), findsOneWidget);
      expect(find.text('Cytology'), findsNothing);
    });

    testWidgets('Done returns the selection', (tester) async {
      await openSheet(tester, allowed: Specialty.forRole(isPathologist: true));

      await tapOption(tester, 'Histopathology');
      await tapOption(tester, 'Cytology');
      await tester.tap(find.text('Done · 2 selected'));
      await tester.pumpAndSettle();

      expect(await shown, [Specialty.histopathology, Specialty.cytology]);
    });

    testWidgets('hints show under their names', (tester) async {
      await openSheet(tester, allowed: Specialty.forRole(isPathologist: true));

      expect(find.text('Tissue, including lymph nodes'), findsOneWidget);
      expect(find.text('Smears, FNA and Pap tests'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openSheet(tester, allowed: Specialty.values);

      expect(tester.takeException(), isNull);
    });
  });
}
