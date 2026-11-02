import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_model.dart';

Map<String, dynamic> notesTranslationJson() => {
  'uid': 'current',
  'caseUid': 'uid-case-1',
  'status': 'Ready',
  'sourceLanguage': 'sw',
  'language': 'en',
  'sourceSha256': 'test-sha',
  'text': 'Translated test notes',
  'models': {'translate': 'test-model-1'},
  'failureReason': '',
  'requestedAt': '2030-05-01T10:00:00.000Z',
  'readyAt': '2030-05-01T10:01:00.000Z',
  'lastUpdatedAt': '2030-05-01T10:01:00.000Z',
};

void main() {
  group('NotesTranslationModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = notesTranslationJson();
      final model = NotesTranslationModel.fromJson(json);
      expect(model.status, 'Ready');
      expect(model.text, 'Translated test notes');
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = NotesTranslationModel.fromJson({});
      expect(model, NotesTranslationModel.empty());
      expect(model.uid, 'current');
      expect(model.status, 'Queued');
    });

    test('toJson never contains synced', () {
      final model = NotesTranslationModel.fromJson(notesTranslationJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = NotesTranslationModel.fromJson(notesTranslationJson());
      expect(model.statusValue, JobStatus.ready);
      expect(model.failureReasonValue, FailureReason.none);
      expect(
        NotesTranslationModel.fromJson({'status': 'Bogus'}).statusValue,
        JobStatus.queued,
      );
      expect(
        NotesTranslationModel.fromJson({
          'failureReason': 'Bogus',
        }).failureReasonValue,
        FailureReason.serviceError,
      );
    });
  });

  group('NotesTranslationHive', () {
    test('fromModel maps every field', () {
      final hive = NotesTranslationHive.fromModel(
        NotesTranslationModel.fromJson(notesTranslationJson()),
      );
      expect(hive.uid, 'current');
      expect(hive.caseUid, 'uid-case-1');
      expect(hive.status, 'Ready');
      expect(hive.sourceLanguage, 'sw');
      expect(hive.language, 'en');
      expect(hive.sourceSha256, 'test-sha');
      expect(hive.text, 'Translated test notes');
      expect(hive.models, {'translate': 'test-model-1'});
      expect(hive.failureReason, '');
      expect(hive.requestedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.readyAt, '2030-05-01T10:01:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-01T10:01:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = NotesTranslationModel.fromJson(notesTranslationJson());
      expect(NotesTranslationHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = NotesTranslationModel.fromJson(
        notesTranslationJson(),
      ).copyWith(synced: false);
      expect(NotesTranslationHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
