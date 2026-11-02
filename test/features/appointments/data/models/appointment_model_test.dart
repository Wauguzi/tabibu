import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';

Map<String, dynamic> appointmentJson() => {
  'uid': 'appt-1',
  'type': 'Consultation',
  'status': 'Requested',
  'patientUid': 'patient-1',
  'patientId': 'pat-rec-1',
  'patientName': 'Patient One',
  'doctorUid': 'doc-1',
  'doctorName': 'Dr Doc',
  'facilityName': 'Clinic One',
  'createdByUid': 'patient-1',
  'scheduledStart': '2026-11-02T08:00:00.000Z',
  'scheduledEnd': '2026-11-02T08:30:00.000Z',
  'symptomText': 'Headache for two days',
  'inputMode': 'Typed',
  'symptomLanguage': 'en',
  'intakeStatus': 'Queued',
  'discussedCaseUid': '',
  'discussedOrderNumber': '',
  'caseUids': <String>[],
  'expiresAt': '2026-11-01T18:00:00.000Z',
  'respondedAt': '',
  'acceptedAt': '',
  'declineReason': '',
  'declineNote': '',
  'cancelledAt': '',
  'cancelledByUid': '',
  'cancelNote': '',
  'completedAt': '',
  'createdAt': '2026-11-01T08:00:00.000Z',
  'lastUpdatedAt': '2026-11-01T08:00:00.000Z',
};

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);

  group('AppointmentModel', () {
    test('fromJson round-trips through toJson', () {
      final json = appointmentJson();
      expect(AppointmentModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AppointmentModel.fromJson({});
      expect(model.type, 'Consultation');
      expect(model.status, 'Requested');
      expect(model.inputMode, 'Typed');
      expect(model.intakeStatus, 'None');
    });

    test('toJson never contains synced', () {
      expect(
        AppointmentModel.fromJson(
          appointmentJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and helpers', () {
      final model = AppointmentModel.fromJson(appointmentJson());
      expect(model.typeValue, AppointmentType.consultation);
      expect(model.statusValue, AppointmentStatus.requested);
      expect(model.isRequested, isTrue);
      expect(model.isExpiredAt(now), isFalse);
      expect(
        model.copyWith(expiresAt: '2026-11-01T11:00:00.000Z').isExpiredAt(now),
        isTrue,
      );
    });
  });

  group('AppointmentHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = AppointmentModel.fromJson(
        appointmentJson(),
      ).copyWith(synced: false);
      expect(AppointmentHive.fromModel(model).toModel(), model);
    });
  });
}
