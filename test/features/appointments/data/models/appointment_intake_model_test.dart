import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_model.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_hive.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_model.dart';
import 'package:tabibu/features/appointments/data/models/transcription_result_model.dart';

Map<String, dynamic> intakeJson() => {
  'uid': 'summary',
  'appointmentUid': 'appt-1',
  'doctorUid': 'doc-1',
  'status': 'Ready',
  'inputText': 'Headache for two days',
  'inputMode': 'Typed',
  'inputLanguage': 'en',
  'transcriptLanguage': '',
  'transcriptAcceptedUnchanged': false,
  'transcriptEditDistance': 0.0,
  'drafts': {
    'en': {
      'chiefComplaint': 'Headache',
      'symptoms': ['pain'],
      'duration': '2 days',
      'redFlags': <String>[],
      'summary': 'Two-day headache.',
      'isTranslation': false,
    },
    'sw': {
      'chiefComplaint': 'Headache',
      'symptoms': ['pain'],
      'duration': '2 days',
      'redFlags': <String>[],
      'summary': 'Two-day headache.',
      'isTranslation': true,
    },
  },
  'modelVersion': '1',
  'promptVersion': '1',
  'failureReason': '',
  'requestedAt': '2026-11-01T08:00:00.000Z',
  'readyAt': '2026-11-01T08:01:00.000Z',
  'lastUpdatedAt': '2026-11-01T08:01:00.000Z',
};

void main() {
  group('AppointmentIntakeModel', () {
    test('fromJson round-trips through toJson', () {
      final json = intakeJson();
      expect(AppointmentIntakeModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AppointmentIntakeModel.fromJson({});
      expect(model.uid, 'summary');
      expect(model.status, 'Queued');
      expect(model.inputMode, 'Typed');
      expect(model.drafts, isEmpty);
    });

    test('empty holds en and sw drafts', () {
      final model = AppointmentIntakeModel.empty();
      expect(model.drafts.keys, containsAll(['en', 'sw']));
    });

    test('toJson never contains synced', () {
      expect(
        AppointmentIntakeModel.fromJson(
          intakeJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and isReady', () {
      final model = AppointmentIntakeModel.fromJson(intakeJson());
      expect(model.statusValue, IntakeStatus.ready);
      expect(model.inputModeValue, InputMode.typed);
      expect(model.isReady, isTrue);
    });
  });

  group('AppointmentIntakeHive', () {
    test('fromModel maps nested drafts and round-trips unsynced', () {
      final model = AppointmentIntakeModel.fromJson(
        intakeJson(),
      ).copyWith(synced: false);
      final hive = AppointmentIntakeHive.fromModel(model);
      expect(hive.drafts.keys, containsAll(['en', 'sw']));
      expect(hive.toModel(), model);
    });
  });

  group('IntakeDraftHive', () {
    test('fromModel round-trips', () {
      const model = IntakeDraftModel(
        chiefComplaint: 'Pain',
        symptoms: ['ache'],
        summary: 'Summary',
      );
      expect(IntakeDraftHive.fromModel(model).toModel(), model);
    });
  });

  group('TranscriptionResultModel', () {
    test('fromJson round-trips and defaults', () {
      final json = {
        'transcriptionUid': 'tr-1',
        'transcript': 'hello',
        'detectedLanguage': 'en',
        'models': {'voice': 'v1'},
      };
      expect(TranscriptionResultModel.fromJson(json).toJson(), json);
      expect(TranscriptionResultModel.fromJson({}).transcript, '');
    });
  });
}
