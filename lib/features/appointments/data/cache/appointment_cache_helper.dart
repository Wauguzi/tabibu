import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/appointments/data/datasources/appointment_firebase.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_model.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/models/transcription_result_model.dart';

/// Cached appointments and intake summaries: the layer the blocs call.
@lazySingleton
class AppointmentCacheHelper {
  AppointmentCacheHelper({required this._db, required this._remote});

  final DBHelper _db;
  final AppointmentFirebase _remote;
  final Logger _logger = Logger();

  /// Failures that mean "the cloud cannot be reached", for which the cache
  /// stands in.
  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Replay mapping (§3.8): these drop the local change and refetch by id.
  /// `failed-precondition` collapses into [AppError.unknown], which also
  /// covers transient faults (`aborted`, `internal`), so it stays queued: a
  /// stuck-but-visible row beats a silently dropped decision.
  static const Set<AppError> _dropAndRefetch = {
    .permissionDenied,
    .dataNotFound,
  };

  /// Whether [incoming] may replace [cached] (sync rule, §6).
  bool _accepts({
    required bool fromCloud,
    required ({bool synced, String lastUpdatedAt})? cached,
    required String incoming,
  }) =>
      !fromCloud ||
      cached == null ||
      cloudRowWins(
        cachedSynced: cached.synced,
        cachedLastUpdatedAt: cached.lastUpdatedAt,
        incomingLastUpdatedAt: incoming,
      );

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<AppointmentModel>> syncPatientAppointments(
    String patientUid, {
    String? since,
  }) async {
    if (patientUid.isEmpty) return const [];
    try {
      final remote = await _remote.fetchPatientDelta(
        patientUid: patientUid,
        cursor: since ?? await patientAppointmentsCursor(patientUid),
      );
      await cacheAppointments(remote, fromCloud: true);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getPatientAppointments(patientUid);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getPatientAppointments(patientUid);
  }

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<AppointmentModel>> syncDoctorAppointments(
    String doctorUid, {
    String? since,
  }) async {
    if (doctorUid.isEmpty) return const [];
    try {
      final remote = await _remote.fetchDoctorDelta(
        doctorUid: doctorUid,
        cursor: since ?? await doctorAppointmentsCursor(doctorUid),
      );
      await cacheAppointments(remote, fromCloud: true);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getDoctorAppointments(doctorUid);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getDoctorAppointments(doctorUid);
  }

  /// The patient's cached appointments.
  Future<List<AppointmentModel>> getPatientAppointments(
    String patientUid,
  ) async {
    if (patientUid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<AppointmentHive>(
        HiveHelperImpl.appointmentsBox,
      ))
        if (row.patientUid == patientUid) row.toModel(),
    ];
  }

  /// The doctor's cached appointments.
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorUid) async {
    if (doctorUid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<AppointmentHive>(
        HiveHelperImpl.appointmentsBox,
      ))
        if (row.doctorUid == doctorUid) row.toModel(),
    ];
  }

  /// Delta cursor for the patient's list, or null to pull everything.
  Future<String?> patientAppointmentsCursor(String patientUid) async =>
      syncCursorFrom(
        (await getPatientAppointments(patientUid)).map((a) => a.lastUpdatedAt),
      );

  /// Delta cursor for the doctor's list, or null to pull everything.
  Future<String?> doctorAppointmentsCursor(String doctorUid) async =>
      syncCursorFrom(
        (await getDoctorAppointments(doctorUid)).map((a) => a.lastUpdatedAt),
      );

  /// Caches appointment rows under the merge guard.
  Future<void> cacheAppointments(
    List<AppointmentModel> appointments, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<AppointmentHive>(
        HiveHelperImpl.appointmentsBox,
      ))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<AppointmentHive>(HiveHelperImpl.appointmentsBox, {
      for (final a in appointments)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[a.uid],
          incoming: a.lastUpdatedAt,
        ))
          a.uid: AppointmentHive.fromModel(
            fromCloud ? a.copyWith(synced: true) : a,
          ),
    });
  }

  /// Caches intake summaries for the appointment's doctor only; rows for any
  /// other viewer are skipped, never stored.
  Future<void> cacheIntakes(
    List<AppointmentIntakeModel> intakes, {
    required bool fromCloud,
    required String viewerUid,
  }) async {
    if (viewerUid.isEmpty) return;
    final cached = {
      for (final row in await _db.getAll<AppointmentIntakeHive>(
        HiveHelperImpl.appointmentIntakesBox,
      ))
        row.appointmentUid: (
          synced: row.synced,
          lastUpdatedAt: row.lastUpdatedAt,
        ),
    };
    await _db
        .putAll<AppointmentIntakeHive>(HiveHelperImpl.appointmentIntakesBox, {
          for (final i in intakes)
            // Doctor-only, fail closed: a row whose doctor is unknown or
            // someone else is not this viewer's to keep.
            if (i.doctorUid == viewerUid &&
                _accepts(
                  fromCloud: fromCloud,
                  cached: cached[i.appointmentUid],
                  incoming: i.lastUpdatedAt,
                ))
              i.appointmentUid: AppointmentIntakeHive.fromModel(
                fromCloud ? i.copyWith(synced: true) : i,
              ),
        });
  }

  /// The cached intake summary, only for the appointment's doctor.
  Future<AppointmentIntakeModel?> getIntake(
    String appointmentUid,
    String viewerUid,
  ) async {
    if (appointmentUid.isEmpty || viewerUid.isEmpty) return null;
    final row = await _db.get<AppointmentIntakeHive>(
      HiveHelperImpl.appointmentIntakesBox,
      appointmentUid,
    );
    if (row == null || row.doctorUid != viewerUid) return null;
    return row.toModel();
  }

  /// Online only: uploads symptom audio and returns the transcript. The
  /// server deletes the object; nothing is cached locally.
  Future<TranscriptionResultModel> transcribeSymptoms({
    required String uid,
    required String audioUid,
    required Uint8List bytes,
    String contentType = 'audio/wav',
  }) => _remote.transcribeSymptoms(
    uid: uid,
    audioUid: audioUid,
    bytes: bytes,
    contentType: contentType,
  );

  /// Online only: requests the slot, then syncs and returns the new row.
  Future<AppointmentModel> bookAppointment({
    required String patientUid,
    required String appointmentUid,
    required String doctorUid,
    required DateTime start,
    String type = 'Consultation',
    String caseUid = '',
    String symptomText = '',
    String inputMode = 'Typed',
    String transcriptionUid = '',
  }) async {
    await _remote.requestAppointment(
      appointmentUid: appointmentUid,
      type: type,
      scheduledStart: start.toUtc().toIso8601String(),
      doctorUid: doctorUid,
      caseUid: caseUid,
      symptomText: symptomText,
      inputMode: inputMode,
      transcriptionUid: transcriptionUid.isEmpty ? null : transcriptionUid,
    );
    List<AppointmentModel> rows;
    try {
      rows = await syncPatientAppointments(patientUid);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      rows = const [];
    }
    final match =
        rows.firstWhereOrNull((a) => a.uid == appointmentUid) ??
        (await getPatientAppointments(
          patientUid,
        )).firstWhereOrNull((a) => a.uid == appointmentUid);
    if (match != null) return match;
    throw AppError.dataNotFound;
  }

  /// Saves the doctor's decision locally, then sends it; offline it stays
  /// queued and the optimistic row is returned.
  Future<AppointmentModel> saveAppointmentDecision({
    required String appointmentUid,
    required bool accept,
    String declineReason = '',
    String declineNote = '',
  }) async {
    final row = await _db.get<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
    );
    if (row == null) throw AppError.dataNotFound;
    final now = syncTimestamp();
    final decided = row.toModel().copyWith(
      status: accept
          ? AppointmentStatus.accepted.value
          : AppointmentStatus.declined.value,
      respondedAt: now,
      acceptedAt: accept ? now : row.acceptedAt,
      declineReason: declineReason,
      declineNote: declineNote,
      lastUpdatedAt: now,
      synced: false,
    );
    await cacheAppointments([decided], fromCloud: false);
    try {
      await _remote.respondToAppointment(
        appointmentUid: appointmentUid,
        decision: accept ? 'Accept' : 'Decline',
        declineReason: declineReason,
        declineNote: declineNote,
      );
    } on AppError catch (e) {
      if (_offline.contains(e)) return decided;
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(decided);
      rethrow;
    }
    return await _markSynced(appointmentUid);
  }

  /// Cancels locally, then sends it; offline it stays queued and the
  /// optimistic row is returned.
  Future<AppointmentModel> cancelAppointment({
    required String appointmentUid,
    required String cancelledByUid,
    String cancelNote = '',
  }) async {
    final row = await _db.get<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
    );
    if (row == null) throw AppError.dataNotFound;
    final now = syncTimestamp();
    final cancelled = row.toModel().copyWith(
      status: AppointmentStatus.cancelled.value,
      cancelledAt: now,
      cancelledByUid: cancelledByUid,
      cancelNote: cancelNote,
      lastUpdatedAt: now,
      synced: false,
    );
    await cacheAppointments([cancelled], fromCloud: false);
    try {
      await _remote.cancelAppointment(
        appointmentUid: appointmentUid,
        cancelNote: cancelNote,
      );
    } on AppError catch (e) {
      if (_offline.contains(e)) return cancelled;
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(cancelled);
      rethrow;
    }
    return await _markSynced(appointmentUid);
  }

  /// Completes online only: the outcome is not cached, so there is nothing
  /// faithful to replay later. The cached row updates on success.
  Future<AppointmentModel> completeAppointment({
    required String appointmentUid,
    required String outcome,
  }) async {
    await _remote.completeAppointment(
      appointmentUid: appointmentUid,
      outcome: outcome,
    );
    final row = await _db.get<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
    );
    if (row == null) throw AppError.dataNotFound;
    final completed = row.toModel().copyWith(
      status: AppointmentStatus.completed.value,
      completedAt: syncTimestamp(),
      lastUpdatedAt: syncTimestamp(),
      synced: true,
    );
    await _db.put<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
      AppointmentHive.fromModel(completed),
    );
    return completed;
  }

  /// Replays every queued decision or cancellation in scope; attempts all of
  /// them, then rethrows the first failure, if any.
  Future<void> replayPendingAppointmentActions(String uid) async {
    if (uid.isEmpty) return;
    AppError? firstFailure;
    for (final row in await _db.getAll<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
    )) {
      if (row.synced || (row.patientUid != uid && row.doctorUid != uid)) {
        continue;
      }
      try {
        await _replay(row.toModel());
      } on AppError catch (e) {
        firstFailure ??= e;
      }
    }
    if (firstFailure != null) throw firstFailure;
  }

  Future<void> _replay(AppointmentModel row) async {
    switch (row.statusValue) {
      case AppointmentStatus.accepted:
        await _replayDecision(row, accept: true);
      case AppointmentStatus.declined:
        await _replayDecision(row, accept: false);
      case AppointmentStatus.cancelled:
        await _replayCancel(row);
      case _:
        // No other status is ever queued; leave it alone.
        if (kDebugMode) _logger.w('Not replaying ${row.uid}: ${row.status}.');
    }
  }

  Future<void> _replayDecision(
    AppointmentModel row, {
    required bool accept,
  }) async {
    try {
      await _remote.respondToAppointment(
        appointmentUid: row.uid,
        decision: accept ? 'Accept' : 'Decline',
        declineReason: row.declineReason,
        declineNote: row.declineNote,
      );
    } on AppError catch (e) {
      // Transient (and unknown) errors stay queued for the next flush.
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(row);
      rethrow;
    }
    await _markSynced(row.uid);
  }

  Future<void> _replayCancel(AppointmentModel row) async {
    try {
      await _remote.cancelAppointment(
        appointmentUid: row.uid,
        cancelNote: row.cancelNote,
      );
    } on AppError catch (e) {
      // Transient (and unknown) errors stay queued for the next flush.
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(row);
      rethrow;
    }
    await _markSynced(row.uid);
  }

  /// Drops the queued change for the server truth: the refetch runs first, so
  /// a transient refetch failure leaves the queued row in place.
  Future<void> _dropAndRefetchById(AppointmentModel row) async {
    List<AppointmentModel> fresh;
    try {
      fresh = row.patientUid.isNotEmpty
          ? await _remote.fetchPatientDelta(patientUid: row.patientUid)
          : await _remote.fetchDoctorDelta(doctorUid: row.doctorUid);
    } on AppError catch (e) {
      // A denied refetch evicts the row; anything else stays queued.
      if (e == AppError.permissionDenied) {
        await _evict(row.uid, 'refetch denied');
      }
      return;
    }
    final match = fresh.where((a) => a.uid == row.uid).firstOrNull;
    if (match == null) {
      await _evict(row.uid, 'gone server-side');
      return;
    }
    // Direct: the merge guard would keep the queued row this replaces.
    await _db.put<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      row.uid,
      AppointmentHive.fromModel(match.copyWith(synced: true)),
    );
  }

  Future<AppointmentModel> _markSynced(String appointmentUid) async {
    final row = await _db.get<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
    );
    // Deleted under us (a concurrent sign-out wipes the boxes): the server
    // already has the decision, so there is nothing left to do.
    if (row == null) throw AppError.dataNotFound;
    final synced = row.toModel().copyWith(synced: true);
    await _db.put<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
      AppointmentHive.fromModel(synced),
    );
    return synced;
  }

  Future<void> _evict(String appointmentUid, String reason) async {
    if (kDebugMode) _logger.i('Evicting appointment $appointmentUid: $reason.');
    await _db.delete<AppointmentHive>(
      HiveHelperImpl.appointmentsBox,
      appointmentUid,
    );
  }
}
