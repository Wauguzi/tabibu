import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/datasources/appointment_firebase.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockRef extends Mock implements Reference {}

class _MockTaskSnapshot extends Mock implements TaskSnapshot {}

class _FakeUploadTask extends Fake implements UploadTask {
  _FakeUploadTask(this._snap);

  final TaskSnapshot _snap;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) => Future<R>.value(onValue(_snap));
}

class _Refusal extends FirebaseFunctionsException {
  _Refusal(String reason, String code) : super(message: reason, code: code);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFunctions functions;
  late _MockCallable callable;
  late _MockStorage storage;
  late AppointmentFirebase remote;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata(contentType: 'audio/mp4'));
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    storage = _MockStorage();
    remote = AppointmentFirebase(
      firestore: firestore,
      functions: functions,
      storage: storage,
    );
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('deltas', () {
    test('patient delta filters by patientUid and cursor', () async {
      await firestore.collection('appointments').doc('a1').set({
        'patientUid': 'p1',
        'doctorUid': 'd1',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });
      await firestore.collection('appointments').doc('a2').set({
        'patientUid': 'p1',
        'doctorUid': 'd1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('appointments').doc('a3').set({
        'patientUid': 'p2',
        'doctorUid': 'd1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchPatientDelta(
        patientUid: 'p1',
        cursor: '2026-11-01T11:00:00.000Z',
      );
      expect(rows.map((r) => r.uid), ['a2']);
    });

    test('doctor delta filters by doctorUid', () async {
      await firestore.collection('appointments').doc('a1').set({
        'patientUid': 'p1',
        'doctorUid': 'd1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('appointments').doc('a2').set({
        'patientUid': 'p1',
        'doctorUid': 'd2',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchDoctorDelta(doctorUid: 'd1');
      expect(rows.map((r) => r.uid), ['a1']);
    });
  });

  group('callables', () {
    test('requestAppointment sends the documented map', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.requestAppointment(
        appointmentUid: 'a1',
        type: 'Consultation',
        doctorUid: 'd1',
        scheduledStart: '2026-11-02T08:00:00.000Z',
        symptomText: 'Headache',
      );

      verify(() => functions.httpsCallable('requestAppointment')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent['appointmentUid'], 'a1');
      expect(sent['type'], 'Consultation');
      expect(sent['doctorUid'], 'd1');
      expect(sent['scheduledStart'], '2026-11-02T08:00:00.000Z');
    });

    test('a FirebaseFunctionsException maps to AppError', () async {
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenThrow(_Refusal('permission-denied', 'permission-denied'));
      await expectLater(
        remote.cancelAppointment(appointmentUid: 'a1'),
        throwsA(AppError.permissionDenied),
      );
    });

    test('transcribeSymptoms uploads then calls the callable', () async {
      final ref = _MockRef();
      final snap = _MockTaskSnapshot();
      when(() => storage.ref(any())).thenReturn(ref);
      when(
        () => ref.putData(any(), any()),
      ).thenAnswer((_) => _FakeUploadTask(snap));

      final result = _MockCallableResult();
      when(() => result.data).thenReturn({
        'transcriptionUid': 'tr-1',
        'transcript': 'hello',
        'detectedLanguage': 'en',
        'models': {'voice': 'v1'},
      });
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      final out = await remote.transcribeSymptoms(
        uid: 'u1',
        audioUid: 'aud-1',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(out.transcriptionUid, 'tr-1');
      verify(() => storage.ref('speechAudio/u1/aud-1.m4a')).called(1);
      verify(() => functions.httpsCallable('transcribeSymptoms')).called(1);
    });

    test('transcribeSymptoms refuses oversized audio before upload', () async {
      await expectLater(
        remote.transcribeSymptoms(
          uid: 'u1',
          audioUid: 'aud-1',
          bytes: Uint8List(AppointmentFirebase.maxSpeechBytes + 1),
        ),
        throwsA(AppError.fileTooLarge),
      );
      verifyZeroInteractions(storage);
    });
  });
}
