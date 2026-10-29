import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

final _patient = PatientSession(
  patient: PatientModel.empty(),
  roles: RoleHelper.fromClaims(const {'role': 'patient'}),
);
final _doctor = PractitionerSession(
  doctor: DoctorModel.empty(),
  roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
);
final _pathologist = PractitionerSession(
  doctor: DoctorModel.empty(),
  roles: RoleHelper.fromClaims(const {'role': 'pathologist'}),
);
final _pending = PendingVerificationSession(doctor: DoctorModel.empty());
const _signedOut = SignedOutSession();
const _incomplete = SignUpIncompleteSession(
  email: 'a@example.com',
  emailVerified: true,
);
const _unverified = SignUpIncompleteSession(email: 'a@example.com');

void main() {
  group('resolveLanding', () {
    Landing land(
      AuthSession session, {
      bool update = false,
      bool onboarded = true,
    }) => resolveLanding(
      session: session,
      updateRequired: update,
      isOnboarded: onboarded,
    );

    test('an outdated build stops everyone, signed in or not', () {
      for (final session in [_signedOut, _patient, _doctor, _pending]) {
        expect(land(session, update: true), Landing.update);
      }
    });

    test('signed out: onboarding the first time, then sign-in', () {
      expect(land(_signedOut, onboarded: false), Landing.onboarding);
      expect(land(_signedOut), Landing.signIn);
    });

    test('each session lands where it belongs', () {
      expect(land(_unverified), Landing.verifyEmail);
      expect(land(_incomplete), Landing.finishSignUp);
      expect(land(const ClinicRecordExistsSession()), Landing.clinicRecord);
      expect(land(_pending), Landing.pending);
      expect(land(_patient), Landing.patientHome);
      expect(land(_doctor), Landing.doctorHome);
      expect(land(_pathologist), Landing.pathologistHome);
    });
  });

  group('guardLocation', () {
    String? guard(String location, AuthSession session) =>
        guardLocation(location: location, session: session);

    test('a role area needs that role claim', () {
      expect(guard('/patient', _patient), isNull);
      expect(guard('/doctor/cases/1', _doctor), isNull);
      expect(guard('/pathologist', _pathologist), isNull);

      expect(guard('/doctor', _patient), startsWith('/decision'));
      expect(guard('/pathologist', _doctor), startsWith('/decision'));
      expect(guard('/patient', _doctor), startsWith('/decision'));
    });

    test('a pending practitioner reaches no clinical route (T-14)', () {
      for (final area in ['/patient', '/doctor', '/pathologist']) {
        expect(guard(area, _pending), startsWith('/decision'));
      }
    });

    test('a prefix that only looks like a role area is not one', () {
      expect(guard('/doctors-directory', _signedOut), isNull);
    });

    test('a refused deep link is kept for after the decision', () {
      final redirect = guard('/doctor/cases/1?tab=report', _signedOut)!;
      expect(
        Uri.parse(redirect).queryParameters['from'],
        '/doctor/cases/1?tab=report',
      );
    });

    test('sign-up steps after the account need one', () {
      for (final step in accountSignUpSteps) {
        expect(guard('/sign-up/$step', _signedOut), startsWith('/decision'));
        expect(guard('/sign-up/$step', _incomplete), isNull);
      }
      expect(guard('/account/pending', _signedOut), startsWith('/decision'));
      expect(guard('/account/pending', _pending), isNull);
      expect(
        guard('/account/verify-email', _signedOut),
        startsWith('/decision'),
      );
      expect(guard('/account/verify-email', _unverified), isNull);
    });

    test('public screens are open to everyone', () {
      for (final path in [
        '/decision',
        '/update',
        '/language',
        '/sign-in',
        '/reset-password/sent',
        '/sign-up',
        '/sign-up/patient/name',
        '/sign-up/patient/account',
        '/sign-up/practitioner/details',
      ]) {
        expect(guard(path, _signedOut), isNull, reason: path);
      }
    });
  });
}
