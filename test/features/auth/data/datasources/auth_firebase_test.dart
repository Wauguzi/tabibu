import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockTokenResult extends Mock implements IdTokenResult {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

/// The real constructor is protected; a subclass reaches it.
class _Refusal extends FirebaseFunctionsException {
  _Refusal(String reason, String code) : super(message: reason, code: code);
}

const _request = PatientSignUpRequest(
  firstName: 'Amina',
  middleName: '',
  lastName: 'Otieno',
  sex: Sex.female,
  dateOfBirth: '1990-05-14',
  phoneNumber: '0712345678',
  countyId: 47,
  subCountyId: null,
  language: AppLanguage.sw,
);

void main() {
  late _MockAuth auth;
  late FakeFirebaseFirestore firestore;
  late _MockFunctions functions;
  late _MockCallable callable;
  late AuthFirebase remote;

  setUp(() {
    auth = _MockAuth();
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    remote = AuthFirebase(
      auth: auth,
      firestore: firestore,
      functions: functions,
    );
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('roles', () {
    test('none when signed out', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect((await remote.roles()).hasRole, isFalse);
    });

    test('read from the ID token, refreshed on request', () async {
      final user = _MockUser();
      final token = _MockTokenResult();
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.getIdTokenResult(true)).thenAnswer((_) async => token);
      when(() => token.claims).thenReturn({'role': 'doctor'});

      expect((await remote.roles(forceRefresh: true)).isDoctor, isTrue);
      verify(() => user.getIdTokenResult(true)).called(1);
    });
  });

  group('profile reads', () {
    test("a patient's record is found by uid, not by document id", () async {
      final linked = PatientModel.empty().copyWith(
        patientId: 'clinic-1',
        uid: 'u1',
        firstName: 'Amina',
      );
      await firestore
          .collection('patients')
          .doc('clinic-1')
          .set(linked.toJson());
      final found = await remote.fetchOwnPatientRecord('u1');
      expect(found?.patientId, 'clinic-1');
      expect(await remote.fetchOwnPatientRecord('u2'), isNull);
    });

    test('a practitioner profile is read by uid', () async {
      final doctor = DoctorModel.empty().copyWith(uid: 'd1', lastName: 'Kamau');
      await firestore.collection('doctors').doc('d1').set(doctor.toJson());
      expect((await remote.fetchDoctorProfile('d1'))?.lastName, 'Kamau');
      expect(await remote.fetchDoctorProfile('d2'), isNull);
    });
  });

  group('callables', () {
    test('sends the request and reads a clinic-record match', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'clinicRecordExists'});
      when(
        () => callable.call<Map<String, dynamic>>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      expect(
        await remote.completePatientSignUp(_request),
        PatientSignUpOutcome.clinicRecordExists,
      );
      final sent =
          verify(
                () =>
                    callable.call<Map<String, dynamic>>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, Object?>;
      expect(sent['sex'], 'Female');
      expect(sent.containsKey('subCountyId'), isFalse);
      verify(() => functions.httpsCallable('completePatientSignUp')).called(1);
    });

    test("a refusal becomes the reason's translated AppError", () async {
      when(
        () => callable.call<Map<String, dynamic>>(any<dynamic>()),
      ).thenThrow(_Refusal('kmpdcNumberInUse', 'already-exists'));
      await expectLater(
        remote.completePatientSignUp(_request),
        throwsA(AppError.kmpdcNumberInUse),
      );
    });

    test('an unknown reason falls back to the Firebase code', () async {
      when(
        () => callable.call<Map<String, dynamic>>(any<dynamic>()),
      ).thenThrow(_Refusal('somethingNew', 'permission-denied'));
      await expectLater(
        remote.completePatientSignUp(_request),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  test('an Auth error code becomes its AppError', () async {
    when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'wrong-password'));
    await expectLater(
      remote.signInWithEmail(email: ' a@b.co ', password: 'x'),
      throwsA(AppError.wrongPassword),
    );
    verify(
      () => auth.signInWithEmailAndPassword(email: 'a@b.co', password: 'x'),
    ).called(1);
  });
}
