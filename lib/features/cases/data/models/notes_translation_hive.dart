import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_model.dart';

part 'notes_translation_hive.g.dart';

/// Cached [NotesTranslationModel], in the same field order.
@HiveType(typeId: 11)
class NotesTranslationHive {
  NotesTranslationHive({
    required this.uid,
    required this.caseUid,
    required this.status,
    required this.sourceLanguage,
    required this.language,
    required this.sourceSha256,
    required this.text,
    required this.models,
    required this.failureReason,
    required this.requestedAt,
    required this.readyAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory NotesTranslationHive.fromModel(NotesTranslationModel model) {
    return NotesTranslationHive(
      uid: model.uid,
      caseUid: model.caseUid,
      status: model.status,
      sourceLanguage: model.sourceLanguage,
      language: model.language,
      sourceSha256: model.sourceSha256,
      text: model.text,
      models: model.models,
      failureReason: model.failureReason,
      requestedAt: model.requestedAt,
      readyAt: model.readyAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  NotesTranslationModel toModel() {
    return NotesTranslationModel(
      uid: uid,
      caseUid: caseUid,
      status: status,
      sourceLanguage: sourceLanguage,
      language: language,
      sourceSha256: sourceSha256,
      text: text,
      models: models,
      failureReason: failureReason,
      requestedAt: requestedAt,
      readyAt: readyAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String caseUid;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String sourceLanguage;

  @HiveField(4)
  final String language;

  @HiveField(5)
  final String sourceSha256;

  @HiveField(6)
  final String text;

  @HiveField(7)
  final Map<String, String> models;

  @HiveField(8)
  final String failureReason;

  @HiveField(9)
  final String requestedAt;

  @HiveField(10)
  final String readyAt;

  @HiveField(11)
  final String lastUpdatedAt;

  @HiveField(12)
  final bool synced;
}
