import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('NotificationSettingsScreen', () {
    setUpAll(
      () => registerFallbackValue(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: false,
        ),
      ),
    );

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    PatientSession quietPatient() => PatientSession(
      patient: RoleSessions.patient.patient.copyWith(
        receiveNotifications: false,
      ),
      roles: RoleSessions.patient.roles,
    );

    testWidgets('the master switch flips through the shared event', (
      tester,
    ) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/notifications',
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification settings'), findsOneWidget);
      expect(find.text('All notifications'), findsOneWidget);
      expect(find.text('Turn everything on or off.'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      await tester.tap(find.text('All notifications'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const ProfileSettingChanged(
            setting: ProfileSetting.healthNotices,
            value: false,
          ),
        ),
      ).called(1);
    });

    testWidgets('off shows the patient warning', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        quietPatient(),
        '/patient/profile/notifications',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Everything is off. You may miss reminders and results.'),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('each role reads its own warning', (tester) async {
      tallView(tester);
      final base = RoleSessions.doctor();
      final quietDoctor = PractitionerSession(
        doctor: base.doctor.copyWith(receiveNotifications: false),
        roles: base.roles,
      );
      await tester.pumpRoleApp(quietDoctor, '/doctor/profile/notifications');
      await tester.pumpAndSettle();
      expect(
        find.text('Everything is off. You may miss reports and bookings.'),
        findsOneWidget,
      );

      final quietPathologist = PractitionerSession(
        doctor: RoleSessions.pathologist.doctor.copyWith(
          receiveNotifications: false,
        ),
        roles: RoleSessions.pathologist.roles,
      );
      await tester.pumpRoleApp(
        quietPathologist,
        '/pathologist/profile/notifications',
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Everything is off. You may miss new cases and messages.'),
        findsOneWidget,
      );
    });

    testWidgets('no per-category rows: the backend keeps none', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/notifications',
      );
      await tester.pumpAndSettle();

      for (final text in [
        'Appointment reminders',
        'Results shared with me',
        'Appointment chat',
        'Health notices',
        'Also send by SMS',
        'Private notifications',
      ]) {
        expect(find.text(text), findsNothing, reason: text);
      }
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('the switch holds still while saving', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/notifications',
        states: [ProfileSettingChangeInProgress(session: RoleSessions.patient)],
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);

      await tester.tap(find.text('All notifications'));
      await tester.pumpAndSettle();
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a failed flip says why', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/notifications',
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All notifications'));
      await tester.pump();
      answers.add(
        ProfileSettingChangeFailure(
          session: RoleSessions.patient,
          error: AppError.noInternet,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
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
        RoleSessions.patient,
        '/patient/profile/notifications',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Mipangilio ya arifa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
