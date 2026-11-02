import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/cache/appointment_cache_helper.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';

class _MockCache extends Mock implements AppointmentCacheHelper {}

class _MockInternet extends Mock implements InternetService {}

AppointmentModel _appt(
  String uid, {
  String status = 'Requested',
  String doctorUid = 'd1',
}) => AppointmentModel.empty().copyWith(
  uid: uid,
  patientUid: 'p1',
  doctorUid: doctorUid,
  status: status,
);

void main() {
  late _MockCache cache;
  late _MockInternet internet;

  AppointmentsBloc build() =>
      AppointmentsBloc(cache: cache, internet: internet);

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() {
    cache = _MockCache();
    internet = _MockInternet();
    when(() => internet.check()).thenAnswer((_) async => true);
  });

  group('AppointmentsBloc', () {
    test('starts empty', () {
      expect(build().state, const AppointmentsInitial());
    });

    blocTest<AppointmentsBloc, AppointmentsState>(
      'drops its data on reset',
      build: build,
      seed: () => const AppointmentsLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const AppointmentsReset()),
      expect: () => [const AppointmentsInitial()],
    );

    group('AppointmentsRequested', () {
      blocTest<AppointmentsBloc, AppointmentsState>(
        'patient: cache then sync',
        setUp: () {
          when(
            () => cache.getPatientAppointments('p1'),
          ).thenAnswer((_) async => [_appt('a1')]);
          when(
            () => cache.syncPatientAppointments('p1'),
          ).thenAnswer((_) async => [_appt('a1'), _appt('a2')]);
        },
        build: build,
        act: (bloc) => bloc.add(
          const AppointmentsRequested(uid: 'p1', role: Role.patient),
        ),
        expect: () => [
          const AppointmentsLoadInProgress(),
          AppointmentsLoadSuccess(appointments: [_appt('a1')]),
          AppointmentsLoadSuccess(appointments: [_appt('a1'), _appt('a2')]),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'doctor: cache then sync',
        setUp: () {
          when(
            () => cache.getDoctorAppointments('d1'),
          ).thenAnswer((_) async => [_appt('a1')]);
          when(
            () => cache.syncDoctorAppointments('d1'),
          ).thenAnswer((_) async => [_appt('a1'), _appt('a2')]);
        },
        build: build,
        act: (bloc) =>
            bloc.add(const AppointmentsRequested(uid: 'd1', role: Role.doctor)),
        expect: () => [
          const AppointmentsLoadInProgress(),
          AppointmentsLoadSuccess(appointments: [_appt('a1')]),
          AppointmentsLoadSuccess(appointments: [_appt('a1'), _appt('a2')]),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'unsupported role fails',
        build: build,
        act: (bloc) => bloc.add(
          const AppointmentsRequested(uid: 'x1', role: Role.pathologist),
        ),
        expect: () => [
          const AppointmentsLoadInProgress(),
          const AppointmentsLoadFailure(error: AppError.dataNotFound),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'offline with a cache keeps the rows',
        setUp: () {
          when(
            () => cache.getPatientAppointments('p1'),
          ).thenAnswer((_) async => [_appt('a1')]);
          when(
            () => cache.syncPatientAppointments('p1'),
          ).thenThrow(AppError.noInternet);
        },
        build: build,
        act: (bloc) => bloc.add(
          const AppointmentsRequested(uid: 'p1', role: Role.patient),
        ),
        expect: () => [
          const AppointmentsLoadInProgress(),
          AppointmentsLoadSuccess(appointments: [_appt('a1')]),
          AppointmentsLoadSuccess(appointments: [_appt('a1')], offline: true),
        ],
      );
    });

    group('AppointmentsRefreshed', () {
      blocTest<AppointmentsBloc, AppointmentsState>(
        'patient syncs first',
        setUp: () {
          when(
            () => cache.syncPatientAppointments('p1'),
          ).thenAnswer((_) async => [_appt('a1')]);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a0')]),
        act: (bloc) => bloc.add(
          const AppointmentsRefreshed(uid: 'p1', role: Role.patient),
        ),
        expect: () => [
          AppointmentsLoadInProgress(appointments: [_appt('a0')]),
          AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'doctor syncs first',
        setUp: () {
          when(
            () => cache.syncDoctorAppointments('d1'),
          ).thenAnswer((_) async => [_appt('a1')]);
        },
        build: build,
        act: (bloc) =>
            bloc.add(const AppointmentsRefreshed(uid: 'd1', role: Role.doctor)),
        expect: () => [
          const AppointmentsLoadInProgress(),
          AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        ],
      );
    });

    group('AppointmentBookRequested', () {
      final start = DateTime.utc(2026, 11, 10, 10);
      final later = DateTime.utc(2026, 11, 10, 11);

      blocTest<AppointmentsBloc, AppointmentsState>(
        'offline fails with no call',
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a0')]),
        act: (bloc) => bloc.add(
          AppointmentBookRequested(
            uid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            symptomText: 'fever',
          ),
        ),
        expect: () => [
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appt('a0')],
          ),
        ],
        verify: (_) {
          verifyNever(
            () => cache.bookAppointment(
              patientUid: any(named: 'patientUid'),
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: any(named: 'doctorUid'),
              start: any(named: 'start'),
              type: any(named: 'type'),
              symptomText: any(named: 'symptomText'),
            ),
          );
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'success refreshes the list',
        setUp: () {
          when(
            () => cache.bookAppointment(
              patientUid: any(named: 'patientUid'),
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: any(named: 'doctorUid'),
              start: any(named: 'start'),
              type: any(named: 'type'),
              symptomText: any(named: 'symptomText'),
            ),
          ).thenAnswer((_) async => _appt('a-new'));
          when(
            () => cache.getPatientAppointments('p1'),
          ).thenAnswer((_) async => [_appt('a0'), _appt('a-new')]);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a0')]),
        act: (bloc) => bloc.add(
          AppointmentBookRequested(
            uid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            symptomText: 'fever',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a0')]),
          AppointmentBookSuccess(
            appointment: _appt('a-new'),
            appointments: [_appt('a0'), _appt('a-new')],
          ),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'failure keeps the list',
        setUp: () {
          when(
            () => cache.bookAppointment(
              patientUid: any(named: 'patientUid'),
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: any(named: 'doctorUid'),
              start: any(named: 'start'),
              type: any(named: 'type'),
              symptomText: any(named: 'symptomText'),
            ),
          ).thenThrow(AppError.requestTimeout);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a0')]),
        act: (bloc) => bloc.add(
          AppointmentBookRequested(
            uid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            symptomText: '',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a0')]),
          AppointmentWriteFailure(
            error: AppError.requestTimeout,
            appointments: [_appt('a0')],
          ),
        ],
      );

      test(
        'a retry after a failure reuses the same uid; a new start gets another',
        () async {
          final uids = <String>[];
          when(
            () => cache.bookAppointment(
              patientUid: any(named: 'patientUid'),
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: any(named: 'doctorUid'),
              start: any(named: 'start'),
              type: any(named: 'type'),
              symptomText: any(named: 'symptomText'),
            ),
          ).thenAnswer((invocation) async {
            uids.add(invocation.namedArguments[#appointmentUid]! as String);
            throw AppError.requestTimeout;
          });

          final bloc = build()
            ..add(
              AppointmentBookRequested(
                uid: 'p1',
                doctorUid: 'd1',
                type: 'Consultation',
                start: start,
                symptomText: '',
              ),
            );
          await expectLater(
            bloc.stream,
            emitsThrough(
              isA<AppointmentWriteFailure>().having(
                (s) => s.error,
                'error',
                AppError.requestTimeout,
              ),
            ),
          );

          bloc.add(
            AppointmentBookRequested(
              uid: 'p1',
              doctorUid: 'd1',
              type: 'Consultation',
              // The same moment in another zone is the same booking.
              start: start.toLocal(),
              symptomText: '',
            ),
          );
          await expectLater(
            bloc.stream,
            emitsThrough(
              isA<AppointmentWriteFailure>().having(
                (s) => s.error,
                'error',
                AppError.requestTimeout,
              ),
            ),
          );

          bloc.add(
            AppointmentBookRequested(
              uid: 'p1',
              doctorUid: 'd1',
              type: 'Consultation',
              start: later,
              symptomText: '',
            ),
          );
          await expectLater(
            bloc.stream,
            emitsThrough(
              isA<AppointmentWriteFailure>().having(
                (s) => s.error,
                'error',
                AppError.requestTimeout,
              ),
            ),
          );

          expect(uids, hasLength(3));
          expect(uids[0], uids[1]);
          expect(uids[2], isNot(uids[0]));
          await bloc.close();
        },
      );
    });

    group('AppointmentDecisionRequested', () {
      blocTest<AppointmentsBloc, AppointmentsState>(
        'decline sends the reason wire value',
        setUp: () {
          when(
            () => cache.saveAppointmentDecision(
              appointmentUid: 'a1',
              accept: false,
              declineReason: 'SlotUnavailable',
              declineNote: 'busy',
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Declined'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentDecisionRequested(
            appointmentUid: 'a1',
            accept: false,
            reason: DeclineReason.slotUnavailable,
            note: 'busy',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentDecisionSuccess(
            appointment: _appt('a1', status: 'Declined'),
            appointments: [_appt('a1', status: 'Declined')],
          ),
        ],
        verify: (_) {
          verify(
            () => cache.saveAppointmentDecision(
              appointmentUid: 'a1',
              accept: false,
              declineReason: 'SlotUnavailable',
              declineNote: 'busy',
            ),
          ).called(1);
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'accept replaces the row',
        setUp: () {
          when(
            () => cache.saveAppointmentDecision(
              appointmentUid: 'a1',
              accept: true,
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Accepted'));
        },
        build: build,
        seed: () =>
            AppointmentsLoadSuccess(appointments: [_appt('a1'), _appt('a2')]),
        act: (bloc) => bloc.add(
          const AppointmentDecisionRequested(
            appointmentUid: 'a1',
            accept: true,
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1'), _appt('a2')]),
          AppointmentDecisionSuccess(
            appointment: _appt('a1', status: 'Accepted'),
            appointments: [
              _appt('a1', status: 'Accepted'),
              _appt('a2'),
            ],
          ),
        ],
      );
    });

    group('AppointmentCompleteRequested', () {
      blocTest<AppointmentsBloc, AppointmentsState>(
        'complete replaces the row',
        setUp: () {
          when(
            () => cache.completeAppointment(
              appointmentUid: 'a1',
              outcome: 'Treated',
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Completed'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentCompleteRequested(
            appointmentUid: 'a1',
            outcome: 'Treated',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentCompleteSuccess(
            appointment: _appt('a1', status: 'Completed'),
            appointments: [_appt('a1', status: 'Completed')],
          ),
        ],
      );
    });
  });
}
