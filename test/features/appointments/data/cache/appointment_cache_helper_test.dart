import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/appointments/data/cache/appointment_cache_helper.dart';
import 'package:tabibu/features/appointments/data/datasources/appointment_firebase.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_model.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_hive.dart';

class _MockAppointmentFirebase extends Mock implements AppointmentFirebase {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

AppointmentModel _appt(
  String uid, {
  String patientUid = 'p1',
  String doctorUid = 'd1',
  String stamp = _t1,
  bool synced = true,
  String status = 'Requested',
}) => AppointmentModel.empty().copyWith(
  uid: uid,
  patientUid: patientUid,
  doctorUid: doctorUid,
  lastUpdatedAt: stamp,
  synced: synced,
  status: status,
);

AppointmentIntakeModel _intake(
  String appointmentUid, {
  String doctorUid = 'd1',
  String stamp = _t1,
  bool synced = true,
}) => AppointmentIntakeModel.empty().copyWith(
  appointmentUid: appointmentUid,
  doctorUid: doctorUid,
  lastUpdatedAt: stamp,
  synced: synced,
);

void main() {
  late Directory dir;
  late _MockAppointmentFirebase remote;
  late AppointmentCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(AppointmentHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(AppointmentIntakeHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(IntakeDraftHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_appt_cache_');
    Hive.init(dir.path);
    await Hive.openBox<AppointmentHive>(HiveHelperImpl.appointmentsBox);
    await Hive.openBox<AppointmentIntakeHive>(
      HiveHelperImpl.appointmentIntakesBox,
    );
    remote = _MockAppointmentFirebase();
    helper = AppointmentCacheHelper(db: DBHelperImpl(), remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('merge guard', () {
    test('an unsynced row survives a newer cloud row', () async {
      await helper.cacheAppointments([
        _appt('a1', synced: false),
      ], fromCloud: false);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('a1', stamp: _t3)]);

      await helper.syncPatientAppointments('p1');

      final rows = await helper.getPatientAppointments('p1');
      expect(rows, hasLength(1));
      expect(rows.single.lastUpdatedAt, _t1);
      expect(rows.single.synced, isFalse);
    });

    test('a synced row is replaced by a newer cloud row', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('a1', stamp: _t3, status: 'Accepted')]);

      await helper.syncPatientAppointments('p1');

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.lastUpdatedAt, _t3);
      expect(rows.single.status, 'Accepted');
      expect(rows.single.synced, isTrue);
    });

    test('a synced row is kept against an older cloud row', () async {
      await helper.cacheAppointments([
        _appt('a1', stamp: _t3),
      ], fromCloud: true);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('a1', status: 'Accepted')]);

      await helper.syncPatientAppointments('p1');

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.lastUpdatedAt, _t3);
      expect(rows.single.status, 'Requested');
    });
  });

  group('scope', () {
    test("another patient's rows are never returned", () async {
      await helper.cacheAppointments([
        _appt('a1'),
        _appt('a2', patientUid: 'p2'),
      ], fromCloud: true);

      expect((await helper.getPatientAppointments('p1')).map((a) => a.uid), [
        'a1',
      ]);
      expect(await helper.getPatientAppointments(''), isEmpty);
    });

    test("another doctor's rows are never returned", () async {
      await helper.cacheAppointments([
        _appt('a1'),
        _appt('a2', doctorUid: 'd2'),
      ], fromCloud: true);

      expect((await helper.getDoctorAppointments('d1')).map((a) => a.uid), [
        'a1',
      ]);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      final rows = await helper.syncPatientAppointments('p1');

      expect(rows.map((a) => a.uid), ['a1']);
    });

    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncPatientAppointments('p1'),
        throwsA(AppError.serviceUnavailable),
      );
    });

    test('a refusal rethrows even with a cache', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.fetchDoctorDelta(
          doctorUid: 'd1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncDoctorAppointments('d1'),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('cursors', () {
    test('the cursor trails the newest cached row by a day', () async {
      await helper.cacheAppointments([
        _appt('a1'),
        _appt('a2', stamp: _t3),
      ], fromCloud: true);

      expect(
        await helper.patientAppointmentsCursor('p1'),
        '2026-11-02T10:00:00.000Z',
      );
    });

    test('no rows means no cursor', () async {
      expect(await helper.patientAppointmentsCursor('p1'), isNull);
      expect(await helper.doctorAppointmentsCursor('d1'), isNull);
    });

    test('an explicit since overrides the cursor', () async {
      when(
        () => remote.fetchPatientDelta(patientUid: 'p1', cursor: 'custom'),
      ).thenAnswer((_) async => <AppointmentModel>[]);

      await helper.syncPatientAppointments('p1', since: 'custom');

      verify(
        () => remote.fetchPatientDelta(patientUid: 'p1', cursor: 'custom'),
      ).called(1);
    });
  });

  group('decisions', () {
    test('an accept sends and marks the row synced', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.respondToAppointment(
          appointmentUid: 'a1',
          decision: 'Accept',
          declineReason: any(named: 'declineReason'),
          declineNote: any(named: 'declineNote'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});

      final decided = await helper.saveAppointmentDecision(
        appointmentUid: 'a1',
        accept: true,
      );

      expect(decided.status, 'Accepted');
      expect(decided.acceptedAt, isNotEmpty);
      expect(decided.synced, isTrue);
      verify(
        () => remote.respondToAppointment(
          appointmentUid: 'a1',
          decision: 'Accept',
        ),
      ).called(1);
    });

    test('an offline decision stays queued without throwing', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.respondToAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          decision: any(named: 'decision'),
          declineReason: any(named: 'declineReason'),
          declineNote: any(named: 'declineNote'),
        ),
      ).thenThrow(AppError.noInternet);

      final decided = await helper.saveAppointmentDecision(
        appointmentUid: 'a1',
        accept: false,
        declineReason: 'SlotTaken',
      );

      expect(decided.status, 'Declined');
      expect(decided.declineReason, 'SlotTaken');
      expect(decided.synced, isFalse);
      final cached = await helper.getPatientAppointments('p1');
      expect(cached.single.synced, isFalse);
    });

    test('a refused decision drops for the server truth', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.respondToAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          decision: any(named: 'decision'),
          declineReason: any(named: 'declineReason'),
          declineNote: any(named: 'declineNote'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('a1', stamp: _t3, status: 'Cancelled')]);

      await expectLater(
        helper.saveAppointmentDecision(appointmentUid: 'a1', accept: true),
        throwsA(AppError.permissionDenied),
      );

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.status, 'Cancelled');
      expect(rows.single.synced, isTrue);
    });

    test('a denied refetch evicts the row', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.respondToAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          decision: any(named: 'decision'),
          declineReason: any(named: 'declineReason'),
          declineNote: any(named: 'declineNote'),
        ),
      ).thenThrow(AppError.dataNotFound);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.saveAppointmentDecision(appointmentUid: 'a1', accept: true),
        throwsA(AppError.dataNotFound),
      );

      expect(await helper.getPatientAppointments('p1'), isEmpty);
    });

    test('a transient refetch failure leaves the queued row', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.respondToAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          decision: any(named: 'decision'),
          declineReason: any(named: 'declineReason'),
          declineNote: any(named: 'declineNote'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.saveAppointmentDecision(appointmentUid: 'a1', accept: true),
        throwsA(AppError.permissionDenied),
      );

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.status, 'Accepted');
      expect(rows.single.synced, isFalse);
    });

    test('a decision on a missing row throws', () async {
      await expectLater(
        helper.saveAppointmentDecision(appointmentUid: 'nope', accept: true),
        throwsA(AppError.dataNotFound),
      );
    });
  });

  group('cancel', () {
    test('an offline cancel stays queued, then replays', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.cancelAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          cancelNote: any(named: 'cancelNote'),
        ),
      ).thenThrow(AppError.noInternet);

      final cancelled = await helper.cancelAppointment(
        appointmentUid: 'a1',
        cancelledByUid: 'p1',
        cancelNote: 'feeling better',
      );
      expect(cancelled.status, 'Cancelled');
      expect(cancelled.synced, isFalse);

      when(
        () => remote.cancelAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          cancelNote: any(named: 'cancelNote'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});
      await helper.replayPendingAppointmentActions('p1');

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.status, 'Cancelled');
      expect(rows.single.synced, isTrue);
    });

    test(
      'replay attempts every row, then rethrows the first failure',
      () async {
        await helper.cacheAppointments([
          _appt('a1', synced: false, status: 'Cancelled'),
          _appt('a2', synced: false, status: 'Cancelled'),
        ], fromCloud: false);
        var calls = 0;
        when(
          () => remote.cancelAppointment(
            appointmentUid: any(named: 'appointmentUid'),
            cancelNote: any(named: 'cancelNote'),
          ),
        ).thenAnswer((i) async {
          calls++;
          if ((i.namedArguments[#appointmentUid] as String) == 'a1') {
            throw AppError.requestTimeout;
          }
          return <String, dynamic>{};
        });

        await expectLater(
          helper.replayPendingAppointmentActions('p1'),
          throwsA(AppError.requestTimeout),
        );

        expect(calls, 2);
        final rows = await helper.getPatientAppointments('p1');
        expect(rows.where((a) => a.uid == 'a1').single.synced, isFalse);
        expect(rows.where((a) => a.uid == 'a2').single.synced, isTrue);
      },
    );

    test("replay leaves another user's queued rows alone", () async {
      await helper.cacheAppointments([
        _appt('a1', patientUid: 'p2', synced: false, status: 'Cancelled'),
      ], fromCloud: false);

      await helper.replayPendingAppointmentActions('p1');

      verifyNever(
        () => remote.cancelAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          cancelNote: any(named: 'cancelNote'),
        ),
      );
    });
  });

  group('bookAppointment', () {
    final start = DateTime.utc(2026, 11, 10, 10);

    test('calls the callable with a UTC Z start, then syncs the row', () async {
      when(
        () => remote.requestAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          type: any(named: 'type'),
          scheduledStart: any(named: 'scheduledStart'),
          doctorUid: any(named: 'doctorUid'),
          caseUid: any(named: 'caseUid'),
          symptomText: any(named: 'symptomText'),
          inputMode: any(named: 'inputMode'),
          transcriptionUid: any(named: 'transcriptionUid'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});
      when(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('a-new')]);

      final booked = await helper.bookAppointment(
        patientUid: 'p1',
        appointmentUid: 'a-new',
        doctorUid: 'd1',
        start: start,
        symptomText: 'fever',
      );

      expect(booked.uid, 'a-new');
      verify(
        () => remote.requestAppointment(
          appointmentUid: 'a-new',
          type: 'Consultation',
          scheduledStart: '2026-11-10T10:00:00.000Z',
          doctorUid: 'd1',
          symptomText: 'fever',
          // ignore: avoid_redundant_argument_values — contract under test.
          inputMode: 'Typed',
        ),
      ).called(1);
      verify(
        () => remote.fetchPatientDelta(
          patientUid: 'p1',
          cursor: any(named: 'cursor'),
        ),
      ).called(1);
    });

    test('offline sync returns the cached row', () async {
      await helper.cacheAppointments([_appt('a-new')], fromCloud: true);
      when(
        () => remote.requestAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          type: any(named: 'type'),
          scheduledStart: any(named: 'scheduledStart'),
          doctorUid: any(named: 'doctorUid'),
          caseUid: any(named: 'caseUid'),
          symptomText: any(named: 'symptomText'),
          inputMode: any(named: 'inputMode'),
          transcriptionUid: any(named: 'transcriptionUid'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});
      when(
        () => remote.fetchPatientDelta(
          patientUid: any(named: 'patientUid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      final booked = await helper.bookAppointment(
        patientUid: 'p1',
        appointmentUid: 'a-new',
        doctorUid: 'd1',
        start: start,
      );

      expect(booked.uid, 'a-new');
    });

    test('no row after sync throws dataNotFound', () async {
      when(
        () => remote.requestAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          type: any(named: 'type'),
          scheduledStart: any(named: 'scheduledStart'),
          doctorUid: any(named: 'doctorUid'),
          caseUid: any(named: 'caseUid'),
          symptomText: any(named: 'symptomText'),
          inputMode: any(named: 'inputMode'),
          transcriptionUid: any(named: 'transcriptionUid'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});
      when(
        () => remote.fetchPatientDelta(
          patientUid: any(named: 'patientUid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_appt('other')]);

      await expectLater(
        helper.bookAppointment(
          patientUid: 'p1',
          appointmentUid: 'a-new',
          doctorUid: 'd1',
          start: start,
        ),
        throwsA(AppError.dataNotFound),
      );
    });
  });

  group('complete', () {
    test('a completion updates the cached row', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.completeAppointment(
          appointmentUid: 'a1',
          outcome: 'Treated',
        ),
      ).thenAnswer((_) async => <String, dynamic>{});

      final completed = await helper.completeAppointment(
        appointmentUid: 'a1',
        outcome: 'Treated',
      );

      expect(completed.status, 'Completed');
      expect(completed.synced, isTrue);
    });

    test('an offline completion rethrows without queueing', () async {
      await helper.cacheAppointments([_appt('a1')], fromCloud: true);
      when(
        () => remote.completeAppointment(
          appointmentUid: any(named: 'appointmentUid'),
          outcome: any(named: 'outcome'),
        ),
      ).thenThrow(AppError.noInternet);

      await expectLater(
        helper.completeAppointment(appointmentUid: 'a1', outcome: 'Treated'),
        throwsA(AppError.noInternet),
      );

      final rows = await helper.getPatientAppointments('p1');
      expect(rows.single.status, 'Requested');
      expect(rows.single.synced, isTrue);
    });
  });

  group('intake', () {
    test('the doctor caches and reads the intake', () async {
      await helper.cacheIntakes(
        [_intake('a1')],
        fromCloud: true,
        viewerUid: 'd1',
      );

      final intake = await helper.getIntake('a1', 'd1');
      expect(intake?.appointmentUid, 'a1');
      expect(intake?.synced, isTrue);
    });

    test('a patient never caches an intake', () async {
      await helper.cacheIntakes(
        [_intake('a1')],
        fromCloud: true,
        viewerUid: 'p1',
      );

      expect(await helper.getIntake('a1', 'p1'), isNull);
      expect(await helper.getIntake('a1', 'd1'), isNull);
    });

    test("one doctor never reads another's intake", () async {
      await helper.cacheIntakes(
        [_intake('a1')],
        fromCloud: true,
        viewerUid: 'd1',
      );

      expect(await helper.getIntake('a1', 'd2'), isNull);
      expect(await helper.getIntake('a1', ''), isNull);
    });

    test('an intake merge keeps the newer row', () async {
      await helper.cacheIntakes(
        [_intake('a1', stamp: _t3)],
        fromCloud: true,
        viewerUid: 'd1',
      );
      await helper.cacheIntakes(
        [_intake('a1')],
        fromCloud: true,
        viewerUid: 'd1',
      );

      expect((await helper.getIntake('a1', 'd1'))?.lastUpdatedAt, _t3);
    });
  });
}
