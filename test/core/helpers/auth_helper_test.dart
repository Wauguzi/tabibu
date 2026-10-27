import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockAuthFirebase extends Mock implements AuthFirebase {}

class _MockHiveHelper extends Mock implements HiveHelper {}

class _MockUser extends Mock implements User {}

RoleHelper _roles(Map<String, dynamic> claims) => RoleHelper.fromClaims(claims);

final PatientModel _patient = PatientModel.empty().copyWith(
  patientId: 'u1',
  uid: 'u1',
);
final DoctorModel _doctor = DoctorModel.empty().copyWith(
  uid: 'u1',
  verificationStatus: 'Pending',
);

const _request = PatientSignUpRequest(
  firstName: 'Amina',
  middleName: '',
  lastName: 'Otieno',
  sex: Sex.female,
  dateOfBirth: '1990-05-14',
  phoneNumber: '0712345678',
  countyId: 47,
  subCountyId: 30,
  language: AppLanguage.sw,
);

void main() {
  late _MockAuthFirebase remote;
  late _MockHiveHelper cache;
  late _MockUser user;
  late AuthHelper helper;

  setUpAll(() {
    registerFallbackValue(PatientModel.empty());
    registerFallbackValue(DoctorModel.empty());
    registerFallbackValue(_request);
  });

  setUp(() {
    remote = _MockAuthFirebase();
    cache = _MockHiveHelper();
    user = _MockUser();
    helper = AuthHelper(authFirebase: remote, hiveHelper: cache);

    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('amina@example.com');
    when(() => remote.currentUser).thenReturn(user);
    when(() => cache.scopeTo(any())).thenAnswer((_) async {});
    when(
      () => cache.cachePatients(any(), fromCloud: any(named: 'fromCloud')),
    ).thenAnswer((_) async {});
    when(
      () => cache.cacheDoctorProfile(any(), fromCloud: any(named: 'fromCloud')),
    ).thenAnswer((_) async {});
    when(
      () => remote.roles(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => RoleHelper.none);
    when(
      () => remote.fetchOwnPatientRecord(any()),
    ).thenAnswer((_) async => null);
    when(() => remote.fetchDoctorProfile(any())).thenAnswer((_) async => null);
  });

  group('resolveSession', () {
    test('signed out when there is no Firebase user', () async {
      when(() => remote.currentUser).thenReturn(null);
      expect(await helper.resolveSession(), const SignedOutSession());
      verifyNever(() => cache.scopeTo(any()));
    });

    test('scopes the cache to the user before anything is read', () async {
      await helper.resolveSession();
      verify(() => cache.scopeTo('u1')).called(1);
    });

    test('a patient gets their record, which is cached', () async {
      final roles = _roles({'role': 'patient'});
      when(() => remote.roles()).thenAnswer((_) async => roles);
      when(
        () => remote.fetchOwnPatientRecord('u1'),
      ).thenAnswer((_) async => _patient);

      expect(
        await helper.resolveSession(),
        PatientSession(patient: _patient, roles: roles),
      );
      verify(() => cache.cachePatients([_patient], fromCloud: true)).called(1);
    });

    test('offline, the cached record stands in', () async {
      final roles = _roles({'role': 'patient'});
      when(() => remote.roles()).thenAnswer((_) async => roles);
      when(
        () => remote.fetchOwnPatientRecord('u1'),
      ).thenThrow(AppError.noInternet);
      when(
        () => cache.getCachedOwnPatientRecord('u1'),
      ).thenAnswer((_) async => _patient);

      expect(
        await helper.resolveSession(),
        PatientSession(patient: _patient, roles: roles),
      );
    });

    test('any other failure is not hidden by the cache', () async {
      when(
        () => remote.roles(),
      ).thenAnswer((_) async => _roles({'role': 'patient'}));
      when(
        () => remote.fetchOwnPatientRecord('u1'),
      ).thenThrow(AppError.permissionDenied);
      expect(helper.resolveSession, throwsA(AppError.permissionDenied));
      verifyNever(() => cache.getCachedOwnPatientRecord(any()));
    });

    test('a practitioner gets their profile', () async {
      final roles = _roles({'role': 'pathologist'});
      final verified = _doctor.copyWith(verificationStatus: 'Verified');
      when(() => remote.roles()).thenAnswer((_) async => roles);
      when(
        () => remote.fetchDoctorProfile('u1'),
      ).thenAnswer((_) async => verified);
      expect(
        await helper.resolveSession(),
        PractitionerSession(doctor: verified, roles: roles),
      );
    });

    test(
      'no role and a pending profile waits for verification (T-14)',
      () async {
        when(
          () => remote.fetchDoctorProfile('u1'),
        ).thenAnswer((_) async => _doctor);
        expect(
          await helper.resolveSession(),
          PendingVerificationSession(doctor: _doctor),
        );
      },
    );

    test(
      'a profile verified since the token was issued refreshes it',
      () async {
        final verified = _doctor.copyWith(verificationStatus: 'Verified');
        final roles = _roles({'role': 'doctor'});
        when(
          () => remote.fetchDoctorProfile('u1'),
        ).thenAnswer((_) async => verified);
        when(
          () => remote.roles(forceRefresh: true),
        ).thenAnswer((_) async => roles);

        expect(
          await helper.resolveSession(),
          PractitionerSession(doctor: verified, roles: roles),
        );
        verify(() => remote.roles(forceRefresh: true)).called(1);
      },
    );

    test('a rejected profile without a role stays pending', () async {
      final rejected = _doctor.copyWith(verificationStatus: 'Rejected');
      when(
        () => remote.fetchDoctorProfile('u1'),
      ).thenAnswer((_) async => rejected);
      expect(
        await helper.resolveSession(),
        PendingVerificationSession(doctor: rejected),
      );
    });

    test('no role and no profile means sign-up is not finished', () async {
      expect(
        await helper.resolveSession(),
        const SignUpIncompleteSession(email: 'amina@example.com'),
      );
    });

    test('a role with no profile opens nothing', () async {
      when(
        () => remote.roles(),
      ).thenAnswer((_) async => _roles({'role': 'doctor'}));
      expect(helper.resolveSession, throwsA(AppError.noRoleAssigned));
    });
  });

  group('sign-up', () {
    test('a clinic-record match stops before any session is read', () async {
      when(
        () => remote.completePatientSignUp(any()),
      ).thenAnswer((_) async => PatientSignUpOutcome.clinicRecordExists);
      expect(
        await helper.completePatientSignUp(_request),
        const ClinicRecordExistsSession(),
      );
      verifyNever(() => remote.roles(forceRefresh: any(named: 'forceRefresh')));
    });

    test('a registered patient is read with a refreshed token', () async {
      final roles = _roles({'role': 'patient'});
      when(
        () => remote.completePatientSignUp(any()),
      ).thenAnswer((_) async => PatientSignUpOutcome.registered);
      when(
        () => remote.roles(forceRefresh: true),
      ).thenAnswer((_) async => roles);
      when(
        () => remote.fetchOwnPatientRecord('u1'),
      ).thenAnswer((_) async => _patient);

      expect(
        await helper.completePatientSignUp(_request),
        PatientSession(patient: _patient, roles: roles),
      );
    });
  });

  test('a dismissed Google dialog is no session and no error', () async {
    when(() => remote.signInWithGoogle()).thenAnswer((_) async => false);
    expect(await helper.signInWithGoogle(), isNull);
  });

  test('sign-out leaves Firebase before the cache is wiped', () async {
    when(() => remote.signOut()).thenAnswer((_) async {});
    when(() => cache.clearOnSignOut()).thenAnswer((_) async {});
    await helper.signOut();
    verifyInOrder([() => remote.signOut(), () => cache.clearOnSignOut()]);
  });
}
