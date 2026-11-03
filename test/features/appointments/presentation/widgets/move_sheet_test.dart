import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/move_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_picker.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
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

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  group('MoveSheet', () {
    late MockAuthBloc authBloc;
    late MockAppointmentsBloc appointments;

    final appointment = AppointmentModel(
      uid: 'a1',
      status: 'Accepted',
      doctorUid: 'doctor-1',
      patientName: 'Esther Wanjiku',
      scheduledStart: DateTime.now()
          .toUtc()
          .add(const Duration(days: 2))
          .toIso8601String(),
    );

    setUp(() {
      final base = RoleSessions.doctor();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PractitionerSession(
            doctor: base.doctor.copyWith(
              uid: 'doctor-1',
              workingDays: const [1, 2, 3, 4, 5, 6, 7],
            ),
            roles: base.roles,
          ),
        ),
      );
      appointments = MockAppointmentsBloc();
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
    });

    Widget sheet({required void Function(MoveChoice?) onChoice}) =>
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<AppointmentsBloc>.value(value: appointments),
          ],
          child: Builder(
            builder: (context) => TabibuButton.primary(
              label: 'open',
              onTap: () async => onChoice(
                await MoveSheet.show(context, appointment: appointment),
              ),
            ),
          ),
        );

    /// The first free slot the sheet's own planner offers.
    PlannedSlot firstFree() {
      final base = RoleSessions.doctor();
      final planned = const SlotPlanner().days(
        PractitionerModel.empty().copyWith(
          workingDays: const [1, 2, 3, 4, 5, 6, 7],
          dayStartMinute: base.doctor.dayStartMinute,
          dayEndMinute: base.doctor.dayEndMinute,
        ),
        DateTime.now(),
      );
      final day = planned.firstWhere((d) => d.available);
      return day.slots.firstWhere((s) => !s.taken);
    }

    Future<void> pickSlot(WidgetTester tester, PlannedSlot slot) async {
      final nairobi = nairobiNow(slot.start);
      final day = find.text(DateFormat('d').format(nairobi));
      await tester.scrollUntilVisible(
        day,
        200,
        scrollable: find.descendant(
          of: find.byType(DayStrip),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(day);
      await tester.pump();
      final chip = find.text(DateFormat('h:mm a').format(nairobi));
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
    }

    testWidgets('a move needs a time first, then a reason', (tester) async {
      _useTallSurface(tester);
      MoveChoice? choice;
      await tester.pumpApp(sheet(onChoice: (picked) => choice = picked));
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      expect(find.text(en.rescheduleTitle), findsOneWidget);
      expect(find.byType(SlotPicker), findsOneWidget);
      final move = find.widgetWithText(
        TabibuButton,
        en.rescheduleMoveAndTell('Esther'),
      );
      expect(move, findsOneWidget);
      expect(tester.widget<TabibuButton>(move).onTap, isNull);

      final slot = firstFree();
      await pickSlot(tester, slot);
      await tester.tap(move);
      await tester.pump();

      expect(find.text(en.cancelAppointmentNeedReason), findsOneWidget);
      expect(find.byType(TabibuBottomSheet), findsOneWidget);

      await tester.tap(find.text(en.rescheduleReasonAsked));
      await tester.pump();
      await tester.tap(move);
      await _settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsNothing);
      expect(choice, (
        start: slot.start,
        reason: en.rescheduleReasonAsked,
        note: '',
      ));
    });

    testWidgets('a note alone explains the move', (tester) async {
      _useTallSurface(tester);
      MoveChoice? choice;
      await tester.pumpApp(sheet(onChoice: (picked) => choice = picked));
      await tester.tap(find.text('open'));
      await _settleSheet(tester);

      final slot = firstFree();
      await pickSlot(tester, slot);
      await tester.enterText(find.byType(TextField), 'Ward round ran over');
      await tester.pump();
      await tester.tap(
        find.widgetWithText(TabibuButton, en.rescheduleMoveAndTell('Esther')),
      );
      await _settleSheet(tester);

      expect(choice, (
        start: slot.start,
        reason: '',
        note: 'Ward round ran over',
      ));
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
      expect(find.text(sw.rescheduleMoveAndTell('Esther')), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await _settleSheet(tester);
    });
  });
}
