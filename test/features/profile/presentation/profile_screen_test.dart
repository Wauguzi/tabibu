import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_identity_card.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ProfileScreen', () {
    setUpAll(() => registerFallbackValue(const SignOutRequested()));

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    // Cupertino sheet routes never settle.
    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets("shows a patient's card and settings", (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();

      for (final text in [
        'Your profile',
        'Amina W.',
        '+254 712 *** ***',
        'Preferences',
        'English',
        'Embakasi, Nairobi',
        'Light, dark or device theme',
        'Alerts and security',
        'Notification settings',
        'Health notices for my area',
        'Help and account',
        'Privacy and data',
        'Help and support',
        'Sign out',
        'Delete account',
        'v1.0.02',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('a doctor who approves alerts is told so', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.doctor(isAlertApprover: true),
        '/doctor/profile',
      );
      await tester.pumpAndSettle();

      expect(find.text('My profile'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(
        find.text('General surgery · Aga Khan University Hospital'),
        findsOneWidget,
      );
      expect(find.text('KMPDC verified · A 12345'), findsOneWidget);
      expect(
        find.text('You can approve area alerts for Nairobi.'),
        findsOneWidget,
      );
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('only Biometrics stays hidden; its neighbours lead', (
      tester,
    ) async {
      tallView(tester);

      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();
      expect(find.text('Biometrics'), findsNothing);
      expect(find.text('Notification settings'), findsOneWidget);

      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile');
      await tester.pumpAndSettle();
      expect(find.text('Biometrics'), findsNothing);
      expect(find.text('Notification settings'), findsOneWidget);
      expect(find.text('Clinic hours'), findsOneWidget);

      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
      );
      await tester.pumpAndSettle();
      expect(find.text('Biometrics'), findsNothing);
      expect(find.text('Notification settings'), findsOneWidget);
      expect(find.text('Clinic hours'), findsNothing);
      expect(find.text('Alerts and security'), findsOneWidget);
    });

    testWidgets('a doctor who does not approve alerts sees no notice', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile');
      await tester.pumpAndSettle();

      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets("shows a pathologist's areas and lab", (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
      );
      await tester.pumpAndSettle();

      expect(find.text('Me'), findsOneWidget);
      expect(
        find.text('Pathologist · Lancet Kenya, Upper Hill'),
        findsOneWidget,
      );
      expect(find.text('Areas you report on'), findsOneWidget);
      expect(find.text('Histopathology'), findsOneWidget);
      expect(find.text('Cytology'), findsOneWidget);
      expect(find.text('Lab'), findsOneWidget);
      expect(find.text('Accept new cases'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Health notices for my area'), findsOneWidget);
    });

    testWidgets('areas read in Kiswahili', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
      );
      await tester.pumpAndSettle();

      expect(find.text('Histopatholojia'), findsOneWidget);
      expect(find.text('Saitolojia'), findsOneWidget);
    });

    testWidgets('Health notices dispatches its flips', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Health notices for my area'));
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

    testWidgets('Accept cases dispatches its flips', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept new cases'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const ProfileSettingChanged(
            setting: ProfileSetting.acceptCases,
            value: false,
          ),
        ),
      ).called(1);
    });

    testWidgets('the switches hold still while saving', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        states: [ProfileSettingChangeInProgress(session: RoleSessions.patient)],
      );
      await tester.pumpAndSettle();

      final row = find.descendant(
        of: find
            .ancestor(
              of: find.text('Health notices for my area'),
              matching: find.byType(GestureDetector),
            )
            .first,
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(row).onChanged, isNull);

      await tester.tap(find.text('Health notices for my area'));
      await tester.pumpAndSettle();
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a failed save says why', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        states: [
          ProfileSettingChangeFailure(
            session: RoleSessions.patient,
            error: AppError.noInternet,
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('Sign out asks first, then signs out', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await settleSheet(tester);
      expect(find.text('Sign out of Tabibu?'), findsOneWidget);
      verifyNever(() => bloc.add(any()));

      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.text('Sign out'),
        ),
      );
      await settleSheet(tester);

      verify(() => bloc.add(const SignOutRequested())).called(1);
    });

    testWidgets('Cancel keeps the person signed in', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await settleSheet(tester);
      expect(
        find.text(
          'Your cases and reports stay safe. Sign back in any time with '
          'your email or Google.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await settleSheet(tester);

      expect(find.text('Sign out of Tabibu?'), findsNothing);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a failed sign-out says why', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        states: [
          SignOutFailure(
            session: RoleSessions.patient,
            error: AppError.noInternet,
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('the patient rows open their screens', (tester) async {
      tallView(tester);
      const rows = {
        'Language':
            'Choose the language for the app, your results and health notices.',
        'My area':
            'We use your area to show doctors nearby and health notices. '
            'We never track your location.',
        'Theme': 'Same as my phone',
        'Notification settings': 'All notifications',
      };
      for (final entry in rows.entries) {
        await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
        await tester.pumpAndSettle();

        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
      }
    });

    testWidgets('the patient pencil opens the profile details', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();

      expect(find.text('About me'), findsOneWidget);
    });

    testWidgets('back from a settings screen returns to the tab', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.text('Kiswahili'), findsOneWidget);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('the doctor rows open hours and details', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile');
      await tester.pumpAndSettle();

      expect(find.text('Mon–Fri · 8:00 AM–5:00 PM'), findsOneWidget);

      await tester.tap(find.text('Clinic hours'));
      await tester.pumpAndSettle();
      expect(find.text('Accepting new patients'), findsOneWidget);

      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Only for Tabibu'), findsOneWidget);
    });

    testWidgets('the pathologist pencil opens the profile details', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();

      expect(find.text('Shown to doctors'), findsOneWidget);
    });

    testWidgets('the patient card raises by tone in dark mode', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(PatientIdentityCard));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(PatientIdentityCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (card.decoration as BoxDecoration).color,
        scheme.surfaceContainerHigh,
      );
    });

    testWidgets('renders in Swahili in dark mode at 2.0x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Mimi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('PatientIdentityCard.maskPhone', () {
    test('hides the last six digits of a Kenyan number', () {
      expect(
        PatientIdentityCard.maskPhone('+254712345678'),
        '+254 712 *** ***',
      );
    });

    test('leaves any other value as it is', () {
      expect(PatientIdentityCard.maskPhone(''), '');
      expect(PatientIdentityCard.maskPhone('0712345678'), '0712345678');
    });
  });

  group('PatientIdentityCard.shortName', () {
    test('keeps the first name with the last initial', () {
      expect(PatientIdentityCard.shortName('Amina', 'Wambui'), 'Amina W.');
    });

    test('without a last name shows the first alone', () {
      expect(PatientIdentityCard.shortName('Amina', ''), 'Amina');
    });
  });
}
