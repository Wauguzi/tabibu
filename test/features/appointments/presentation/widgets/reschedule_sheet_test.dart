import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/reschedule_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_picker.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// A sheet opens and closes on animations that never settle under a spinner.
Future<void> _settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

PractitionerModel _doctor() => const PractitionerModel(
  uid: 'd1',
  title: 'Dr.',
  firstName: 'Wanjiru',
  lastName: 'Kamau',
  profilePictureUrl: '',
  isPathologist: false,
  specialties: ['General surgery'],
  bio: '',
  facilityId: '',
  facilityMflCode: '',
  facilityName: 'Aga Khan',
  county: 'Nairobi',
  subCounty: 'Embakasi',
  geohash: '',
  isAvailable: true,
  appointmentsHandled: 0,
  ordersCreated: 0,
  reportsSigned: 0,
  lastUpdatedAt: '',
  workingDays: [1, 2, 3, 4, 5, 6, 7],
);

/// The pinned clock: a Tuesday mid-morning in Nairobi, so the planner's
/// lead lands mid-day whatever hour runs this.
final _fixedNow = DateTime.utc(2026, 10, 27, 7);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  group('RescheduleSheet', () {
    late MockDirectoryBloc directory;

    final appointment = AppointmentModel(
      uid: 'a1',
      status: 'Accepted',
      doctorUid: 'd1',
      doctorName: 'Dr. Wanjiru Kamau',
      facilityName: 'Aga Khan',
      scheduledStart: DateTime.now()
          .toUtc()
          .add(const Duration(days: 2))
          .toIso8601String(),
    );

    setUp(() {
      directory = MockDirectoryBloc();
      when(
        () => directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: [_doctor()]));
    });

    Widget sheet({required void Function(RescheduleChoice?) onChoice}) =>
        BlocProvider<DirectoryBloc>.value(
          value: directory,
          child: Builder(
            builder: (context) => TabibuButton.primary(
              label: 'open',
              onTap: () async => onChoice(
                await RescheduleSheet.show(
                  context,
                  appointment: appointment,
                  now: _fixedNow,
                ),
              ),
            ),
          ),
        );

    String whenText(DateTime start, [String language = 'en']) {
      final at = nairobiNow(start);
      return '${DateFormat('EEE d MMM', language).format(at)} · '
          "${DateFormat('h:mm a', language).format(at)}";
    }

    testWidgets('the move button stays off until a time is chosen', (
      tester,
    ) async {
      _useTallSurface(tester);
      RescheduleChoice? choice;
      await tester.pumpApp(sheet(onChoice: (picked) => choice = picked));
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.text(en.rescheduleTitle), findsOneWidget);
      // The "this cancels the current time" warning ships with the sheet.
      expect(find.text(en.rescheduleCancelsCurrent), findsOneWidget);
      expect(find.byType(SlotPicker), findsOneWidget);
      final button = find.widgetWithText(TabibuButton, en.rescheduleButton);
      expect(button, findsOneWidget);
      expect(tester.widget<TabibuButton>(button).onTap, isNull);
      expect(choice, isNull);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });

    testWidgets('choosing a time confirms the move', (tester) async {
      _useTallSurface(tester);
      RescheduleChoice? choice;
      await tester.pumpApp(sheet(onChoice: (picked) => choice = picked));
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      final days = const SlotPlanner().days(_doctor(), _fixedNow);
      final day = days.firstWhere((d) => d.available);
      final dayCell = find.text(DateFormat('d').format(day.date));
      await tester.scrollUntilVisible(
        dayCell,
        200,
        scrollable: find.descendant(
          of: find.byType(DayStrip),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(dayCell);
      await tester.pump();
      final slot = day.slots.firstWhere((s) => !s.taken);
      final chip = find.text(
        DateFormat('h:mm a').format(nairobiNow(slot.start)),
      );
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.descendant(
          of: find.byType(SlotChipRow),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(chip);
      await tester.pump();

      final moveTo = en.rescheduleMoveTo(whenText(slot.start));
      await tester.tap(find.widgetWithText(TabibuButton, moveTo));
      await _settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsNothing);
      expect(choice, (start: slot.start));
    });

    testWidgets('without the doctor the picker keeps loading', (tester) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(const DirectoryLoadSuccess());
      await tester.pumpApp(sheet(onChoice: (_) {}));
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.byType(SlotPicker), findsNothing);
      expect(find.byType(LoadingView), findsOneWidget);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });

    testWidgets('renders in Swahili, dark, at 1.3x text', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpApp(
        sheet(onChoice: (_) {}),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.text(sw.rescheduleTitle), findsOneWidget);
      expect(find.text(sw.rescheduleCancelsCurrent), findsOneWidget);
      expect(find.text(sw.rescheduleButton), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });
  });
}
