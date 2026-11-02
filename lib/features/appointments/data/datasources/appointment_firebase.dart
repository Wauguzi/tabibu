import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/models/transcription_result_model.dart';

/// Firestore + callables + speech upload for appointments. No caching.
@lazySingleton
class AppointmentFirebase {
  AppointmentFirebase({
    required this._firestore,
    required this._functions,
    required this._storage,
  });

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  static const int maxSpeechBytes = 512 * 1024;

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseFunctionsException() => AppError.fromFunctionsException(e),
    FirebaseException(:final code) => AppError.fromFirebaseCode(code),
    _ => AppError.unknown,
  };

  Future<T> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return await body();
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('$operation failed: $e');
      throw _toAppError(e);
    }
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final result = await _functions.httpsCallable(name).call<dynamic>(data);
    final raw = result.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  /// Patient delta: `patientUid ==`, `lastUpdatedAt >=` (I-15).
  Future<List<AppointmentModel>> fetchPatientDelta({
    required String patientUid,
    String? cursor,
  }) => _guard('Appointment patient delta', () async {
    var query = _appointments.where('patientUid', isEqualTo: patientUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        AppointmentModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Doctor delta: `doctorUid ==`, `lastUpdatedAt >=` (I-16).
  Future<List<AppointmentModel>> fetchDoctorDelta({
    required String doctorUid,
    String? cursor,
  }) => _guard('Appointment doctor delta', () async {
    var query = _appointments.where('doctorUid', isEqualTo: doctorUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        AppointmentModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Uploads symptom audio to `speechAudio/{uid}/{audioUid}.m4a`, then calls
  /// `transcribeSymptoms`. The server deletes the object in `finally`.
  Future<TranscriptionResultModel> transcribeSymptoms({
    required String uid,
    required String audioUid,
    required Uint8List bytes,
    String contentType = 'audio/mp4',
  }) => _guard('Transcribe symptoms', () async {
    if (bytes.length > maxSpeechBytes) throw AppError.fileTooLarge;
    final path = 'speechAudio/$uid/$audioUid.m4a';
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
    final data = await _call('transcribeSymptoms', {'audioUid': audioUid});
    return TranscriptionResultModel.fromJson(data);
  });

  Future<Map<String, dynamic>> requestAppointment({
    required String appointmentUid,
    required String type,
    required String scheduledStart,
    String? doctorUid,
    String? caseUid,
    String symptomText = '',
    String inputMode = 'Typed',
    String? transcriptionUid,
  }) => _guard('Request appointment', () {
    final data = <String, dynamic>{
      'appointmentUid': appointmentUid,
      'type': type,
      'scheduledStart': scheduledStart,
      'symptomText': symptomText,
      'inputMode': inputMode,
      if (doctorUid != null && doctorUid.isNotEmpty) 'doctorUid': doctorUid,
      if (caseUid != null && caseUid.isNotEmpty) 'caseUid': caseUid,
      if (transcriptionUid != null && transcriptionUid.isNotEmpty)
        'transcriptionUid': transcriptionUid,
    };
    return _call('requestAppointment', data);
  });

  Future<Map<String, dynamic>> respondToAppointment({
    required String appointmentUid,
    required String decision,
    String declineReason = '',
    String declineNote = '',
  }) => _guard(
    'Respond to appointment',
    () => _call('respondToAppointment', {
      'appointmentUid': appointmentUid,
      'decision': decision,
      'declineReason': declineReason,
      'declineNote': declineNote,
    }),
  );

  Future<Map<String, dynamic>> cancelAppointment({
    required String appointmentUid,
    String cancelNote = '',
  }) => _guard(
    'Cancel appointment',
    () => _call('cancelAppointment', {
      'appointmentUid': appointmentUid,
      'cancelNote': cancelNote,
    }),
  );

  Future<Map<String, dynamic>> completeAppointment({
    required String appointmentUid,
    required String outcome,
  }) => _guard(
    'Complete appointment',
    () => _call('completeAppointment', {
      'appointmentUid': appointmentUid,
      'outcome': outcome,
    }),
  );
}
