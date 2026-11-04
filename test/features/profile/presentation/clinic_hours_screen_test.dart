import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ClinicHoursScreen', () {
    setUpAll(() {
      registerFallbackValue(
        const ClinicHoursChanged(
          workingDays: [],
          dayStartMinute: 0,
          dayEndMinute: 0,
        ),
      );
      registerFallbackValue(
        const ProfileSettingChanged(
          setting: ProfileSetting.acceptCases,
          value: false,
        ),
      );
    });

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    // Sheets and picker dialogs never settle.
    Future<void> settleOverlaid(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    /// Weekdays on the books, the weekend shut.
    PractitionerSession weekdays() {
      final base = RoleSessions.doctor();
      return PractitionerSession(
        doctor: base.doctor.copyWith(workingDays: [1, 2, 3, 4, 5]),
        roles: base.roles,
      );
    }

    Future<void> openSheet(WidgetTester tester, String group) async {
      await tester.tap(find.text(group));
      await settleOverlaid(tester);
      expect(find.text(group), findsWidgets);
    }

    testWidgets('shows the groups, the fixed length and accepting', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile/hours');
      await tester.pumpAndSettle();

      expect(find.text('Clinic hours'), findsOneWidget);
      expect(find.text('Monday to Friday'), findsOneWidget);
      expect(find.text('8:00 AM–5:00 PM'), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Closed'), findsNWidgets(2));
      expect(find.text('Appointment length'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('Accepting new patients'), findsOneWidget);
      expect(find.text('Only your current patients can book'), findsOneWidget);
    });

    testWidgets('the length row opens nothing', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile/hours');
      await tester.pumpAndSettle();

      final row = tester
          .widgetList<SettingsRow>(find.byType(SettingsRow))
          .firstWhere((row) => row.title == 'Appointment length');
      expect(row.chevron, isFalse);
      expect(row.onTap, isNull);
    });

    testWidgets('accepting flips at once through the setting path', (
      tester,
    ) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/hours',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accepting new patients'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const ProfileSettingChanged(
            setting: ProfileSetting.acceptCases,
            value: true,
          ),
        ),
      ).called(1);
    });

    testWidgets('closing a group empties its days', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(weekdays(), '/doctor/profile/hours');
      await tester.pumpAndSettle();

      await openSheet(tester, 'Monday to Friday');
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('5:00 PM'), findsOneWidget);
      expect(
        find.text(
          'Booked appointments stay as they are. New hours apply to new '
          'bookings.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();
      expect(find.text("Closed · patients can't book"), findsOneWidget);

      await tester.tap(find.text('Save').last);
      await settleOverlaid(tester);
      expect(find.text('Monday to Friday'), findsOneWidget);
      expect(find.text('8:00 AM–5:00 PM'), findsNothing);
    });

    testWidgets('reopening keeps the shared range', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(weekdays(), '/doctor/profile/hours');
      await tester.pumpAndSettle();

      await openSheet(tester, 'Saturday');
      expect(find.text("Closed · patients can't book"), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('5:00 PM'), findsOneWidget);
      await tester.tap(find.text('Save').last);
      await settleOverlaid(tester);

      expect(find.text('8:00 AM–5:00 PM'), findsNWidgets(2));
    });

    testWidgets('a backwards range is refused in the sheet', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(weekdays(), '/doctor/profile/hours');
      await tester.pumpAndSettle();

      // The dial paints its numbers, so the taps land by angle from its
      // rendered center: hour h at h o'clock, minute m at m minutes.
      Future<void> tapDial(int hour12, int minute) async {
        Offset at(double oClockMinutes) {
          final dial = find.descendant(
            of: find.byType(TimePickerDialog),
            matching: find.byWidgetPredicate(
              (widget) => widget is AspectRatio && widget.aspectRatio == 1,
            ),
          );
          final box = tester.element(dial).renderObject! as RenderBox;
          final origin = box.localToGlobal(box.size.center(Offset.zero));
          final angle = oClockMinutes / 60 * 2 * math.pi;
          final radius = box.size.shortestSide * 0.3;
          return origin +
              Offset(radius * math.sin(angle), -radius * math.cos(angle));
        }

        await tester.tapAt(at((hour12 % 12 * 5).toDouble()));
        await tester.pump();
        await tester.tapAt(at(minute.toDouble()));
        await tester.pump();
      }

      Future<void> pickTime(String button, int hour12, String period) async {
        await tester.tap(find.text(button));
        await settleOverlaid(tester);
        await tapDial(hour12, 0);
        await tester.tap(find.text(period));
        await tester.pump();
        await tester.tap(find.text('OK'));
        await settleOverlaid(tester);
      }

      // A 4 PM opening against the 5 PM close is fine, then the 9 AM
      // close breaks the range.
      await openSheet(tester, 'Monday to Friday');
      await pickTime('8:00 AM', 4, 'PM');
      expect(find.text('4:00 PM'), findsOneWidget);

      await pickTime('5:00 PM', 9, 'AM');

      await tester.tap(find.text('Save').last);
      await tester.pump();
      expect(
        find.text('Closing must be at least 30 minutes after opening.'),
        findsOneWidget,
      );
      // Still on the sheet: nothing saved.
      expect(find.text('Monday to Friday'), findsWidgets);
    });

    testWidgets('no open day refuses the main Save', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        weekdays(),
        '/doctor/profile/hours',
      );
      await tester.pumpAndSettle();

      // Saturday and Sunday start closed; weekdays close here.
      await openSheet(tester, 'Monday to Friday');
      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Save').last);
      await settleOverlaid(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Pick at least one working day.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('Save dispatches the sorted days and range', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        weekdays(),
        '/doctor/profile/hours',
      );
      await tester.pumpAndSettle();

      await openSheet(tester, 'Saturday');
      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Save').last);
      await settleOverlaid(tester);

      await tester.tap(find.text('Save'));
      // No answer: the button spins, so the tree never settles.
      await tester.pump();

      final sent =
          verify(() => bloc.add(captureAny())).captured.single
              as ClinicHoursChanged;
      expect(sent.workingDays, [1, 2, 3, 4, 5, 6]);
      expect(sent.dayStartMinute, 480);
      expect(sent.dayEndMinute, 1020);
    });

    testWidgets('partial days read open and normalize on save', (tester) async {
      tallView(tester);
      final base = RoleSessions.doctor();
      final partial = PractitionerSession(
        doctor: base.doctor.copyWith(workingDays: [3, 1, 2]),
        roles: base.roles,
      );
      final bloc = await tester.pumpRoleApp(partial, '/doctor/profile/hours');
      await tester.pumpAndSettle();

      // Some weekday is bookable, so the group reads open.
      expect(find.text('8:00 AM–5:00 PM'), findsOneWidget);

      // Saving the group at Open fills the missing days.
      await openSheet(tester, 'Monday to Friday');
      await tester.tap(find.text('Save').last);
      await settleOverlaid(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();

      final sent =
          verify(() => bloc.add(captureAny())).captured.single
              as ClinicHoursChanged;
      expect(sent.workingDays, [1, 2, 3, 4, 5]);
    });

    testWidgets('a saved edit returns to the tab', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(weekdays(), '/doctor/profile', answers: answers);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clinic hours'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(ProfileSaveSuccess(session: weekdays()));
      await tester.pumpAndSettle();

      expect(find.text('My profile'), findsOneWidget);
    });

    testWidgets('a failed save says why and stays', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        weekdays(),
        '/doctor/profile/hours',
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(
        ProfileSaveFailure(session: weekdays(), error: AppError.noInternet),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      expect(find.text('Clinic hours'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        weekdays(),
        '/doctor/profile/hours',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Saa za kliniki'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
