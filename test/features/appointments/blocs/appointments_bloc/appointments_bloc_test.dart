import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/cache/appointment_cache_helper.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';

class _MockCache extends Mock implements AppointmentCacheHelper {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

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
  late _MockAnalytics analytics;

  AppointmentsBloc build() =>
      AppointmentsBloc(cache: cache, internet: internet, analytics: analytics);

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() {
    cache = _MockCache();
    internet = _MockInternet();
    analytics = _MockAnalytics();
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => analytics.logAppointmentRequested(),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logAppointmentResponded(accepted: any(named: 'accepted')),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logAppointmentCompleted(),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logAppointmentCancelled(),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logAppointmentRescheduled(),
    ).thenAnswer((_) async {});
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
          verifyNever(() => analytics.logAppointmentRequested());
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
        verify: (_) {
          verify(() => analytics.logAppointmentRequested()).called(1);
        },
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
        verify: (_) {
          verifyNever(() => analytics.logAppointmentRequested());
        },
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
          verify(
            () => analytics.logAppointmentResponded(accepted: false),
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
        verify: (_) {
          verify(
            () => analytics.logAppointmentResponded(accepted: true),
          ).called(1);
        },
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
        verify: (_) {
          verify(() => analytics.logAppointmentCompleted()).called(1);
        },
      );
    });

    group('AppointmentCancelRequested', () {
      blocTest<AppointmentsBloc, AppointmentsState>(
        'reason and note join into one server note',
        setUp: () {
          when(
            () => cache.cancelAppointment(
              appointmentUid: 'a1',
              cancelledByUid: 'p1',
              cancelNote: 'I feel better\nSee you next term',
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Cancelled'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
            reason: 'I feel better',
            note: 'See you next term',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentCancelSuccess(
            appointment: _appt('a1', status: 'Cancelled'),
            appointments: [_appt('a1', status: 'Cancelled')],
          ),
        ],
        verify: (_) {
          verify(() => analytics.logAppointmentCancelled()).called(1);
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'a note at the limit goes whole',
        setUp: () {
          final whole = 'a' * cancelNoteMaxLength;
          when(
            () => cache.cancelAppointment(
              appointmentUid: 'a1',
              cancelledByUid: 'p1',
              cancelNote: whole,
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Cancelled'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
            note: 'a' * cancelNoteMaxLength,
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentCancelSuccess(
            appointment: _appt('a1', status: 'Cancelled'),
            appointments: [_appt('a1', status: 'Cancelled')],
          ),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'past the limit the composed note is cut to 300 points',
        setUp: () {
          when(
            () => cache.cancelAppointment(
              appointmentUid: 'a1',
              cancelledByUid: 'p1',
              cancelNote: 'r\n${'n' * (cancelNoteMaxLength - 2)}',
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Cancelled'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
            reason: 'r',
            note: 'n' * cancelNoteMaxLength,
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentCancelSuccess(
            appointment: _appt('a1', status: 'Cancelled'),
            appointments: [_appt('a1', status: 'Cancelled')],
          ),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'a cancel keeps the offline flag',
        setUp: () {
          when(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Cancelled'));
        },
        build: build,
        seed: () =>
            AppointmentsLoadSuccess(appointments: [_appt('a1')], offline: true),
        act: (bloc) => bloc.add(
          const AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(
            appointments: [_appt('a1')],
            offline: true,
          ),
          AppointmentCancelSuccess(
            appointment: _appt('a1', status: 'Cancelled'),
            appointments: [_appt('a1', status: 'Cancelled')],
            offline: true,
          ),
        ],
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'offline fails with no call',
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appt('a1')],
          ),
        ],
        verify: (_) {
          verifyNever(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          );
          verifyNever(() => analytics.logAppointmentCancelled());
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'a queued write reports offline instead of success',
        setUp: () {
          when(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          ).thenAnswer(
            (_) async =>
                _appt('a1', status: 'Cancelled').copyWith(synced: false),
          );
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appt('a1')],
          ),
        ],
        verify: (_) {
          verifyNever(() => analytics.logAppointmentCancelled());
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'a refused cancel keeps the row',
        setUp: () {
          when(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          ).thenThrow(AppError.unknown);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          const AppointmentCancelRequested(
            appointmentUid: 'a1',
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentWriteFailure(
            error: AppError.unknown,
            appointments: [_appt('a1')],
          ),
        ],
      );
    });

    group('AppointmentRescheduleRequested', () {
      final start = DateTime.utc(2026, 11, 12, 9);

      blocTest<AppointmentsBloc, AppointmentsState>(
        'books first, then cancels the old time',
        setUp: () {
          when(
            () => cache.bookAppointment(
              patientUid: 'p1',
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: 'd1',
              start: start,
              // ignore: avoid_redundant_argument_values — the mock matches the exact call.
              type: 'Consultation',
              caseUid: any(named: 'caseUid'),
              symptomText: any(named: 'symptomText'),
            ),
          ).thenAnswer((_) async => _appt('a2'));
          when(
            () => cache.cancelAppointment(
              appointmentUid: 'a1',
              cancelledByUid: 'p1',
              cancelNote: 'Moved to a new time',
            ),
          ).thenAnswer((_) async => _appt('a1', status: 'Cancelled'));
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          AppointmentRescheduleRequested(
            appointmentUid: 'a1',
            patientUid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            cancelledByUid: 'p1',
            reason: 'Moved to a new time',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentRescheduleSuccess(
            appointment: _appt('a2'),
            appointments: [
              _appt('a1', status: 'Cancelled'),
              _appt('a2'),
            ],
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => cache.bookAppointment(
              patientUid: 'p1',
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: 'd1',
              start: start,
              // ignore: avoid_redundant_argument_values — the mock matches the exact call.
              type: 'Consultation',
              caseUid: any(named: 'caseUid'),
              symptomText: any(named: 'symptomText'),
            ),
            () => cache.cancelAppointment(
              appointmentUid: 'a1',
              cancelledByUid: 'p1',
              cancelNote: 'Moved to a new time',
            ),
          ]);
          verify(() => analytics.logAppointmentRescheduled()).called(1);
          verifyNever(() => analytics.logAppointmentRequested());
          verifyNever(() => analytics.logAppointmentCancelled());
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'a failed booking leaves the original alone',
        setUp: () {
          when(
            () => cache.bookAppointment(
              patientUid: any(named: 'patientUid'),
              appointmentUid: any(named: 'appointmentUid'),
              doctorUid: any(named: 'doctorUid'),
              start: any(named: 'start'),
              type: any(named: 'type'),
              caseUid: any(named: 'caseUid'),
              symptomText: any(named: 'symptomText'),
            ),
          ).thenThrow(AppError.unknown);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          AppointmentRescheduleRequested(
            appointmentUid: 'a1',
            patientUid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteInProgress(appointments: [_appt('a1')]),
          AppointmentWriteFailure(
            error: AppError.unknown,
            appointments: [_appt('a1')],
          ),
        ],
        verify: (_) {
          verifyNever(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          );
          verifyNever(() => analytics.logAppointmentRescheduled());
        },
      );

      blocTest<AppointmentsBloc, AppointmentsState>(
        'offline fails with no call',
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
        },
        build: build,
        seed: () => AppointmentsLoadSuccess(appointments: [_appt('a1')]),
        act: (bloc) => bloc.add(
          AppointmentRescheduleRequested(
            appointmentUid: 'a1',
            patientUid: 'p1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: start,
            cancelledByUid: 'p1',
          ),
        ),
        expect: () => [
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appt('a1')],
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
              caseUid: any(named: 'caseUid'),
              symptomText: any(named: 'symptomText'),
            ),
          );
          verifyNever(
            () => cache.cancelAppointment(
              appointmentUid: any(named: 'appointmentUid'),
              cancelledByUid: any(named: 'cancelledByUid'),
              cancelNote: any(named: 'cancelNote'),
            ),
          );
        },
      );
    });
  });
}
