import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_model.dart';

part 'intake_draft_hive.g.dart';

/// Cached [IntakeDraftModel], in the same field order.
@HiveType(typeId: 26)
class IntakeDraftHive {
  IntakeDraftHive({
    required this.chiefComplaint,
    required this.symptoms,
    required this.duration,
    required this.redFlags,
    required this.summary,
    required this.isTranslation,
  });

  factory IntakeDraftHive.fromModel(IntakeDraftModel model) {
    return IntakeDraftHive(
      chiefComplaint: model.chiefComplaint,
      symptoms: model.symptoms,
      duration: model.duration,
      redFlags: model.redFlags,
      summary: model.summary,
      isTranslation: model.isTranslation,
    );
  }

  IntakeDraftModel toModel() {
    return IntakeDraftModel(
      chiefComplaint: chiefComplaint,
      symptoms: symptoms,
      duration: duration,
      redFlags: redFlags,
      summary: summary,
      isTranslation: isTranslation,
    );
  }

  @HiveField(0)
  final String chiefComplaint;
  @HiveField(1)
  final List<String> symptoms;
  @HiveField(2)
  final String duration;
  @HiveField(3)
  final List<String> redFlags;
  @HiveField(4)
  final String summary;
  @HiveField(5)
  final bool isTranslation;
}
