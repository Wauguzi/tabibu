import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart';
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockAuthFirebase extends Mock implements AuthFirebase {}

class _MockHiveHelper extends Mock implements HiveHelper {}

class _MockUser extends Mock implements User {}

class _MockProfileStorage extends Mock implements ProfileStorage {}

class _MockNotificationService extends Mock implements NotificationService {}

final _photo = UploadFile(bytes: Uint8List(4), contentType: 'image/jpeg');
final _scan = UploadFile(bytes: Uint8List(4), contentType: 'application/pdf');

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
  late _MockProfileStorage storage;
  late _MockNotificationService notifications;
  late AuthHelper helper;

  setUpAll(() {
    registerFallbackValue(PatientModel.empty());
    registerFallbackValue(DoctorModel.empty());
    registerFallbackValue(_request);
    registerFallbackValue(_photo);
  });

  setUp(() {
    remote = _MockAuthFirebase();
    cache = _MockHiveHelper();
    user = _MockUser();
    storage = _MockProfileStorage();
    notifications = _MockNotificationService();
    helper = AuthHelper(
      authFirebase: remote,
      hiveHelper: cache,
      profileStorage: storage,
      notificationService: notifications,
    );

    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('amina@example.com');
    when(() => user.emailVerified).thenReturn(false);
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

    test('the session carries whether the address is confirmed', () async {
      when(() => user.emailVerified).thenReturn(true);
      expect(
        await helper.resolveSession(),
        const SignUpIncompleteSession(
          email: 'amina@example.com',
          emailVerified: true,
        ),
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

  group('sign-out', () {
    setUp(() {
      when(() => remote.signOut()).thenAnswer((_) async {});
      when(() => cache.clearOnSignOut()).thenAnswer((_) async {});
      when(() => notifications.deviceToken()).thenAnswer((_) async => 't1');
      when(
        () => remote.removeFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});
    });

    test('leaves Firebase before the cache is wiped', () async {
      await helper.signOut();
      verifyInOrder([() => remote.signOut(), () => cache.clearOnSignOut()]);
      verifyNever(() => notifications.deviceToken());
    });

    test('removes this device token while it can still write it', () async {
      await helper.signOut(
        session: PatientSession(
          patient: _patient.copyWith(patientId: 'p9', fcmTokens: ['t1']),
          roles: _roles({'role': 'patient'}),
        ),
      );
      verifyInOrder([
        () => remote.removeFcmToken(
          collection: 'patients',
          docId: 'p9',
          token: 't1',
        ),
        () => remote.signOut(),
        () => cache.clearOnSignOut(),
      ]);
    });

    test('an offline token removal never blocks it', () async {
      when(
        () => remote.removeFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      ).thenThrow(AppError.noInternet);
      await helper.signOut(
        session: PractitionerSession(
          doctor: _doctor,
          roles: _roles({'role': 'doctor'}),
        ),
      );
      verify(() => remote.signOut()).called(1);
      verify(() => cache.clearOnSignOut()).called(1);
    });
  });

  group('registerDeviceToken', () {
    setUp(() {
      when(() => notifications.deviceToken()).thenAnswer((_) async => 'new');
      when(
        () => remote.addFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => remote.removeFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});
    });

    test('adds a token the profile does not hold', () async {
      await helper.registerDeviceToken(
        PendingVerificationSession(doctor: _doctor.copyWith(fcmTokens: ['a'])),
      );
      verify(
        () => remote.addFcmToken(
          collection: 'doctors',
          docId: 'u1',
          token: 'new',
        ),
      ).called(1);
      verifyNever(
        () => remote.removeFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      );
    });

    test('writes nothing for a token already held', () async {
      await helper.registerDeviceToken(
        PatientSession(
          patient: _patient.copyWith(fcmTokens: ['new']),
          roles: _roles({'role': 'patient'}),
        ),
      );
      verifyNever(
        () => remote.addFcmToken(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          token: any(named: 'token'),
        ),
      );
    });

    test('drops the oldest at the rules limit of ten', () async {
      final full = [for (var i = 0; i < 10; i++) 't$i'];
      await helper.registerDeviceToken(
        PractitionerSession(
          doctor: _doctor.copyWith(fcmTokens: full),
          roles: _roles({'role': 'doctor'}),
        ),
      );
      verifyInOrder([
        () => remote.removeFcmToken(
          collection: 'doctors',
          docId: 'u1',
          token: 't0',
        ),
        () => remote.addFcmToken(
          collection: 'doctors',
          docId: 'u1',
          token: 'new',
        ),
      ]);
    });

    test('an account with no profile has nowhere to keep one', () async {
      await helper.registerDeviceToken(
        const SignUpIncompleteSession(email: 'a@example.com'),
      );
      verifyNever(() => notifications.deviceToken());
    });
  });

  group('uploadSignUpFiles', () {
    test(
      'uploads the photo and each license into the caller folders',
      () async {
        when(
          () => storage.uploadProfilePicture(
            owner: any(named: 'owner'),
            file: any(named: 'file'),
          ),
        ).thenAnswer((_) async => 'photo-url');
        when(
          () => storage.uploadLicense(
            uid: any(named: 'uid'),
            index: any(named: 'index'),
            file: any(named: 'file'),
          ),
        ).thenAnswer((i) async => 'license-${i.namedArguments[#index]}');

        final files = await helper.uploadSignUpFiles(
          picture: _photo,
          licenses: [_scan, _photo],
        );

        expect(files.pictureUrl, 'photo-url');
        expect(files.licenseUrls, ['license-0', 'license-1']);
        verify(
          () => storage.uploadProfilePicture(owner: 'u1', file: _photo),
        ).called(1);
      },
    );

    test('refuses none or more than two license files', () async {
      for (final licenses in [
        <UploadFile>[],
        [_scan, _scan, _scan],
      ]) {
        await expectLater(
          helper.uploadSignUpFiles(picture: _photo, licenses: licenses),
          throwsA(AppError.invalidLicense),
        );
      }
    });

    test('refuses without a signed-in user', () async {
      when(() => remote.currentUser).thenReturn(null);
      await expectLater(
        helper.uploadSignUpFiles(picture: _photo, licenses: [_scan]),
        throwsA(AppError.unauthenticated),
      );
    });
  });

  group('changeLanguage', () {
    setUp(() {
      when(
        () =>
            cache.updateLanguage(languageString: any(named: 'languageString')),
      ).thenAnswer((_) async {});
      when(
        () => remote.updateLanguage(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          language: AppLanguage.sw,
        ),
      ).thenAnswer((_) async {});
    });

    test('saves on the device, then on the profile for push text', () async {
      await helper.changeLanguage(
        AppLanguage.sw,
        session: PatientSession(
          patient: _patient.copyWith(patientId: 'p9'),
          roles: _roles({'role': 'patient'}),
        ),
      );
      verifyInOrder([
        () => cache.updateLanguage(languageString: 'sw'),
        () => remote.updateLanguage(
          collection: 'patients',
          docId: 'p9',
          language: AppLanguage.sw,
        ),
      ]);
    });

    test('before sign-in, only the device keeps it', () async {
      await helper.changeLanguage(
        AppLanguage.sw,
        session: const SignedOutSession(),
      );
      verify(() => cache.updateLanguage(languageString: 'sw')).called(1);
      verifyNever(
        () => remote.updateLanguage(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          language: AppLanguage.sw,
        ),
      );
    });

    test('offline, the profile write is skipped without failing', () async {
      when(
        () => remote.updateLanguage(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          language: AppLanguage.sw,
        ),
      ).thenThrow(AppError.noInternet);
      await helper.changeLanguage(
        AppLanguage.sw,
        session: PendingVerificationSession(doctor: _doctor),
      );
      verify(() => cache.updateLanguage(languageString: 'sw')).called(1);
    });
  });

  group('addPatientPicture', () {
    final session = PatientSession(
      patient: _patient.copyWith(patientId: 'p9'),
      roles: _roles({'role': 'patient'}),
    );

    test('uploads into the record folder and saves the URL', () async {
      when(
        () => storage.uploadProfilePicture(
          owner: any(named: 'owner'),
          file: any(named: 'file'),
        ),
      ).thenAnswer((_) async => 'photo-url');
      when(
        () => remote.updateProfilePicture(
          collection: any(named: 'collection'),
          docId: any(named: 'docId'),
          url: any(named: 'url'),
        ),
      ).thenAnswer((_) async {});

      final updated = await helper.addPatientPicture(session, _photo);

      expect(updated.patient.profilePictureUrl, 'photo-url');
      verify(
        () => storage.uploadProfilePicture(owner: 'p9', file: _photo),
      ).called(1);
      verify(
        () => remote.updateProfilePicture(
          collection: 'patients',
          docId: 'p9',
          url: 'photo-url',
        ),
      ).called(1);
    });

    test('a failed upload never fails the sign-up', () async {
      when(
        () => storage.uploadProfilePicture(
          owner: any(named: 'owner'),
          file: any(named: 'file'),
        ),
      ).thenThrow(AppError.fileTooLarge);

      expect(await helper.addPatientPicture(session, _photo), same(session));
    });
  });

  group('email', () {
    test('a malformed address never reaches Firebase', () async {
      await expectLater(
        helper.signInWithEmail(email: 'amina@', password: 'x'),
        throwsA(AppError.invalidEmail),
      );
      await expectLater(
        helper.createAccount(email: 'a b@c.com', password: 'x'),
        throwsA(AppError.invalidEmail),
      );
      await expectLater(
        helper.sendPasswordReset(email: 'a@b'),
        throwsA(AppError.invalidEmail),
      );
      verifyNever(
        () => remote.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      verifyNever(
        () => remote.createAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      verifyNever(() => remote.sendPasswordReset(email: any(named: 'email')));
    });

    test(
      '"I have verified" reloads, then resolves the session again',
      () async {
        when(() => remote.reloadEmailVerified()).thenAnswer((_) async {
          when(() => user.emailVerified).thenReturn(true);
          return true;
        });

        final session = await helper.checkEmailVerified();

        expect(
          session,
          const SignUpIncompleteSession(
            email: 'amina@example.com',
            emailVerified: true,
          ),
        );
        verifyInOrder([
          () => remote.reloadEmailVerified(),
          () => remote.roles(forceRefresh: any(named: 'forceRefresh')),
        ]);
      },
    );

    test('resend asks Firebase for another link', () async {
      when(() => remote.sendEmailVerification()).thenAnswer((_) async {});
      await helper.resendVerificationEmail();
      verify(() => remote.sendEmailVerification()).called(1);
    });
  });
}
