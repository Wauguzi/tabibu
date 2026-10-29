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
        'Biometrics',
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
      expect(find.text('Clinic hours'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
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
      expect(find.text('Theme'), findsNothing);
      expect(find.text('Health notices for my area'), findsNothing);
    });

    testWidgets('a switch row toggles', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();
      Switch biometrics() => tester.widget<Switch>(
        find.descendant(
          of: find
              .ancestor(
                of: find.text('Biometrics'),
                matching: find.byType(GestureDetector),
              )
              .first,
          matching: find.byType(Switch),
        ),
      );
      expect(biometrics().value, isFalse);

      await tester.tap(find.text('Biometrics'));
      await tester.pumpAndSettle();

      expect(biometrics().value, isTrue);
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

    testWidgets('renders in dark mode at 2.0x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Me'), findsOneWidget);
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
}
