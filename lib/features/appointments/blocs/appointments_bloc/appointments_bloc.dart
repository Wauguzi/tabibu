import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/cache/appointment_cache_helper.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:uuid/uuid.dart';

/// The signed-in patient's or doctor's appointments, and the writes on them.
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({
    AppointmentCacheHelper? cache,
    InternetService? internet,
    AnalyticsService? analytics,
  }) : _cache = cache ?? getIt<AppointmentCacheHelper>(),
       _internet = internet ?? getIt<InternetService>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       super(const AppointmentsInitial()) {
    // Cache first, then a silent sync; a second open while loading is
    // pointless.
    on<AppointmentsRequested>(_onRequested, transformer: droppable());
    // Sync first: pull-to-refresh.
    on<AppointmentsRefreshed>(_onRefreshed, transformer: droppable());
    // One booking at a time; a retry reuses the pending uid.
    on<AppointmentBookRequested>(_onBook, transformer: droppable());
    // Writes must not race each other.
    on<AppointmentDecisionRequested>(_onDecision, transformer: sequential());
    on<AppointmentCompleteRequested>(_onComplete, transformer: sequential());
    on<AppointmentCancelRequested>(_onCancel, transformer: sequential());
    on<AppointmentRescheduleRequested>(
      _onReschedule,
      transformer: sequential(),
    );
    on<AppointmentsReset>(_onReset);
  }

  final AppointmentCacheHelper _cache;
  final InternetService _internet;
  final AnalyticsService _analytics;
  final Uuid _uuid = const Uuid();

  /// Last failed booking's uid, reused for the same doctor and start.
  String? _pendingBookUid;
  String? _pendingBookDoctorUid;
  DateTime? _pendingBookStart;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  AppointmentsLoadInProgress _inProgress() => AppointmentsLoadInProgress(
    appointments: state.appointments,
    offline: state.offline,
  );

  AppointmentsLoadFailure _loadFailure(Object e) => AppointmentsLoadFailure(
    error: _toAppError(e),
    appointments: state.appointments,
    offline: state.offline,
  );

  AppointmentWriteFailure _writeFailure(Object e) => AppointmentWriteFailure(
    error: _toAppError(e),
    appointments: state.appointments,
    offline: state.offline,
  );

  AppointmentsLoadSuccess _success(
    List<AppointmentModel> appointments, {
    bool offline = false,
  }) => AppointmentsLoadSuccess(appointments: appointments, offline: offline);

  Future<List<AppointmentModel>> _get(String uid, Role role) => switch (role) {
    .patient => _cache.getPatientAppointments(uid),
    .doctor => _cache.getDoctorAppointments(uid),
    .pathologist => throw AppError.dataNotFound,
  };

  Future<List<AppointmentModel>> _sync(String uid, Role role) => switch (role) {
    .patient => _cache.syncPatientAppointments(uid),
    .doctor => _cache.syncDoctorAppointments(uid),
    .pathologist => throw AppError.dataNotFound,
  };

  String _bookingUid({required String doctorUid, required DateTime start}) {
    if (_pendingBookUid != null &&
        _pendingBookDoctorUid == doctorUid &&
        // Same moment, whichever zone the screen passed it in.
        (_pendingBookStart?.isAtSameMomentAs(start) ?? false)) {
      return _pendingBookUid!;
    }
    final uid = _uuid.v4();
    _pendingBookUid = uid;
    _pendingBookDoctorUid = doctorUid;
    _pendingBookStart = start;
    return uid;
  }

  void _clearPendingBook() {
    _pendingBookUid = null;
    _pendingBookDoctorUid = null;
    _pendingBookStart = null;
  }

  void _onReset(AppointmentsReset event, Emitter<AppointmentsState> emit) {
    _clearPendingBook();
    emit(const AppointmentsInitial());
  }

  Future<void> _onRequested(
    AppointmentsRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(_inProgress());
    try {
      final cached = await _get(event.uid, event.role);
      if (cached.isNotEmpty) {
        emit(_success(cached));
      }
      try {
        final synced = await _sync(event.uid, event.role);
        emit(_success(synced));
      } on Object catch (e) {
        final error = _toAppError(e);
        if (_offline.contains(error)) {
          final appointments = cached.isNotEmpty ? cached : state.appointments;
          if (appointments.isEmpty) {
            emit(_loadFailure(error));
            return;
          }
          emit(_success(appointments, offline: true));
          return;
        }
        emit(_loadFailure(error));
      }
    } on Object catch (e) {
      emit(_loadFailure(e));
    }
  }

  Future<void> _onRefreshed(
    AppointmentsRefreshed event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(_inProgress());
    try {
      final synced = await _sync(event.uid, event.role);
      emit(_success(synced));
    } on Object catch (e) {
      final error = _toAppError(e);
      if (_offline.contains(error) && state.appointments.isNotEmpty) {
        emit(_success(state.appointments, offline: true));
        return;
      }
      emit(_loadFailure(error));
    }
  }

  Future<void> _onBook(
    AppointmentBookRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (!await _internet.check()) {
      emit(_writeFailure(AppError.noInternet));
      return;
    }
    emit(
      AppointmentWriteInProgress(
        appointments: state.appointments,
        offline: state.offline,
      ),
    );
    try {
      final appointmentUid = _bookingUid(
        doctorUid: event.doctorUid,
        start: event.start,
      );
      final appointment = await _cache.bookAppointment(
        patientUid: event.uid,
        appointmentUid: appointmentUid,
        doctorUid: event.doctorUid,
        start: event.start,
        type: event.type,
        symptomText: event.symptomText,
      );
      _clearPendingBook();
      final appointments = await _cache.getPatientAppointments(event.uid);
      unawaited(_analytics.logAppointmentRequested());
      emit(
        AppointmentBookSuccess(
          appointment: appointment,
          appointments: appointments,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onDecision(
    AppointmentDecisionRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(
      AppointmentWriteInProgress(
        appointments: state.appointments,
        offline: state.offline,
      ),
    );
    try {
      final appointment = await _cache.saveAppointmentDecision(
        appointmentUid: event.appointmentUid,
        accept: event.accept,
        declineReason: event.reason?.value ?? '',
        declineNote: event.note,
      );
      final appointments = [
        for (final row in state.appointments)
          if (row.uid == appointment.uid) appointment else row,
      ];
      unawaited(
        _analytics.logAppointmentResponded(accepted: event.accept),
      );
      emit(
        AppointmentDecisionSuccess(
          appointment: appointment,
          appointments: appointments,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onComplete(
    AppointmentCompleteRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(
      AppointmentWriteInProgress(
        appointments: state.appointments,
        offline: state.offline,
      ),
    );
    try {
      final appointment = await _cache.completeAppointment(
        appointmentUid: event.appointmentUid,
        outcome: event.outcome,
      );
      final appointments = [
        for (final row in state.appointments)
          if (row.uid == appointment.uid) appointment else row,
      ];
      unawaited(_analytics.logAppointmentCompleted());
      emit(
        AppointmentCompleteSuccess(
          appointment: appointment,
          appointments: appointments,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  /// A cancel lands or it doesn't: no optimistic row, no queued write.
  Future<void> _onCancel(
    AppointmentCancelRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (!await _internet.check()) {
      emit(_writeFailure(AppError.noInternet));
      return;
    }
    emit(
      AppointmentWriteInProgress(
        appointments: state.appointments,
        offline: state.offline,
      ),
    );
    try {
      final appointment = await _cache.cancelAppointment(
        appointmentUid: event.appointmentUid,
        cancelledByUid: event.cancelledByUid,
        cancelNote: _cancelNote(event.reason, event.note),
      );
      // The network dropped mid-write and the cache queued it: say so.
      if (!appointment.synced) throw AppError.noInternet;
      unawaited(_analytics.logAppointmentCancelled());
      emit(
        AppointmentCancelSuccess(
          appointment: appointment,
          appointments: _replaced(appointment),
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onReschedule(
    AppointmentRescheduleRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (!await _internet.check()) {
      emit(_writeFailure(AppError.noInternet));
      return;
    }
    emit(
      AppointmentWriteInProgress(
        appointments: state.appointments,
        offline: state.offline,
      ),
    );
    try {
      final bookingUid = _bookingUid(
        doctorUid: event.doctorUid,
        start: event.start,
      );
      final booked = await _cache.bookAppointment(
        patientUid: event.patientUid,
        appointmentUid: bookingUid,
        doctorUid: event.doctorUid,
        start: event.start,
        type: event.type,
        caseUid: event.caseUid,
        symptomText: event.symptomText,
      );
      _clearPendingBook();
      // Only a held booking releases the old time.
      final cancelled = await _cache.cancelAppointment(
        appointmentUid: event.appointmentUid,
        cancelledByUid: event.cancelledByUid,
        cancelNote: _cancelNote(event.reason, event.note),
      );
      if (!cancelled.synced) throw AppError.noInternet;
      unawaited(_analytics.logAppointmentRescheduled());
      emit(
        AppointmentRescheduleSuccess(
          appointment: booked,
          appointments: [..._replaced(cancelled), booked],
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  List<AppointmentModel> _replaced(AppointmentModel appointment) => [
    for (final row in state.appointments)
      if (row.uid == appointment.uid) appointment else row,
  ];

  /// The composed note, cut to the server's limit in code points, as
  /// `sanitize` counts them. The sheets cap the typed note so this only ever
  /// bites on a composed move longer than the field allows.
  static String _cancelNote(String reason, String note) {
    final composed = [
      reason.trim(),
      note.trim(),
    ].where((part) => part.isNotEmpty).join('\n');
    if (composed.length <= cancelNoteMaxLength) return composed;
    return String.fromCharCodes(composed.runes.take(cancelNoteMaxLength));
  }
}
