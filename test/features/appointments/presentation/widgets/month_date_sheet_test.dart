import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/month_date_sheet.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

/// A Tuesday mid-morning in Nairobi: the window runs 27 Oct – 27 Nov 2026.
final _fixedNow = DateTime.utc(2026, 10, 27, 7);

void main() {
  group('MonthDateSheet', () {
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    List<PlannedDay> days() => const SlotPlanner().days(
      PractitionerModel.empty().copyWith(
        workingDays: const [1, 2, 3, 4, 5],
        dayStartMinute: 540,
        dayEndMinute: 960,
      ),
      _fixedNow,
    );

    DateTime firstFree(List<PlannedDay> planned) =>
        planned.firstWhere((d) => d.available).date;

    Future<void> openSheet(
      WidgetTester tester, {
      required List<PlannedDay> planned,
      required DateTime selected,
      required void Function(DateTime?) onChoice,
      Locale? locale,
      ThemeMode themeMode = ThemeMode.light,
    }) async {
      tallView(tester);
      await tester.pumpApp(
        Builder(
          builder: (context) => TabibuButton.primary(
            label: 'open',
            onTap: () async => onChoice(
              await MonthDateSheet.show(
                context,
                days: planned,
                selected: selected,
              ),
            ),
          ),
        ),
        locale: locale,
        themeMode: themeMode,
      );
      await tester.tap(find.text('open'));
      await settleSheet(tester);
    }

    String dayLabel(DateTime date) => DateFormat('EEE d MMM').format(date);

    testWidgets('opens on the selected day with times to show', (tester) async {
      final planned = days();
      final selected = firstFree(planned);
      await openSheet(
        tester,
        planned: planned,
        selected: selected,
        onChoice: (_) {},
      );

      expect(find.text('October 2026'), findsOneWidget);
      for (final header in ['M', 'T', 'W', 'F', 'S']) {
        expect(find.text(header), findsWidgets, reason: header);
      }
      expect(find.text(_en.datePickerTimesFree), findsOneWidget);
      expect(
        find.text(_en.datePickerShowTimes(dayLabel(selected))),
        findsOneWidget,
      );
    });

    testWidgets('picking a day and showing its times pops the date', (
      tester,
    ) async {
      final planned = days();
      final selected = firstFree(planned);
      final target = planned
          .where((d) => d.available && d.date != selected)
          .first
          .date;
      DateTime? picked;
      await openSheet(
        tester,
        planned: planned,
        selected: selected,
        onChoice: (date) => picked = date,
      );

      await tester.tap(find.bySemanticsLabel(dayLabel(target)));
      await tester.pump();
      expect(
        find.text(_en.datePickerShowTimes(dayLabel(target))),
        findsOneWidget,
      );

      await tester.tap(find.text(_en.datePickerShowTimes(dayLabel(target))));
      await settleSheet(tester);
      expect(picked, target);
    });

    testWidgets('a grey day cannot be picked', (tester) async {
      final planned = days();
      final selected = firstFree(planned);
      final dimmed = planned.firstWhere((d) => !d.available).date;
      DateTime? picked;
      await openSheet(
        tester,
        planned: planned,
        selected: selected,
        onChoice: (date) => picked = date,
      );

      await tester.tap(find.bySemanticsLabel(dayLabel(dimmed)));
      await tester.pump();
      expect(
        find.text(_en.datePickerShowTimes(dayLabel(selected))),
        findsOneWidget,
      );
      expect(picked, isNull);
    });

    testWidgets('an unavailable selection falls back to the first free day', (
      tester,
    ) async {
      final planned = days();
      final dimmed = planned.firstWhere((d) => !d.available).date;
      await openSheet(
        tester,
        planned: planned,
        selected: dimmed,
        onChoice: (_) {},
      );

      expect(
        find.text(_en.datePickerShowTimes(dayLabel(firstFree(planned)))),
        findsOneWidget,
      );
    });

    testWidgets('pages within the window only', (tester) async {
      final planned = days();
      await openSheet(
        tester,
        planned: planned,
        selected: firstFree(planned),
        onChoice: (_) {},
      );

      // October is the first month: back goes nowhere.
      await tester.tap(find.bySemanticsLabel('September 2026'));
      await tester.pump();
      expect(find.text('October 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('November 2026'));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);

      // November is the last month: forward goes nowhere.
      await tester.tap(find.bySemanticsLabel('December 2026'));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('October 2026'));
      await tester.pump();
      expect(find.text('October 2026'), findsOneWidget);
    });

    testWidgets('days past the horizon cannot be picked', (tester) async {
      final planned = days();
      final selected = firstFree(planned);
      await openSheet(
        tester,
        planned: planned,
        selected: selected,
        onChoice: (_) {},
      );

      await tester.tap(find.bySemanticsLabel('November 2026'));
      await tester.pump();
      // 30 Nov is past the 27 Nov horizon.
      await tester.tap(
        find.bySemanticsLabel(dayLabel(DateTime.utc(2026, 11, 30))),
      );
      await tester.pump();
      expect(
        find.text(_en.datePickerShowTimes(dayLabel(selected))),
        findsOneWidget,
      );
    });

    testWidgets('no free days anywhere: legend only, no button', (
      tester,
    ) async {
      // No working days: the whole window is dimmed.
      final planned = const SlotPlanner().days(
        PractitionerModel.empty().copyWith(workingDays: const []),
        _fixedNow,
      );
      expect(planned.any((d) => d.available), isFalse);
      await openSheet(
        tester,
        planned: planned,
        selected: planned.first.date,
        onChoice: (_) {},
      );

      expect(find.text(_en.datePickerTimesFree), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.byType(TabibuButton),
        ),
        findsNothing,
      );
    });

    testWidgets('renders in Swahili, dark', (tester) async {
      final planned = days();
      await openSheet(
        tester,
        planned: planned,
        selected: firstFree(planned),
        onChoice: (_) {},
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
      );

      expect(find.text(_sw.datePickerTimesFree), findsOneWidget);
      expect(
        find.text(
          _sw.datePickerShowTimes(
            DateFormat('EEE d MMM', 'sw').format(firstFree(planned)),
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
