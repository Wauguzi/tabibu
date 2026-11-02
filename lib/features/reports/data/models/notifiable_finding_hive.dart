import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';

part 'notifiable_finding_hive.g.dart';

/// Cached [NotifiableFindingModel], in the same field order.
@HiveType(typeId: 52)
class NotifiableFindingHive {
  NotifiableFindingHive({
    required this.diseaseId,
    required this.alertRequested,
  });

  factory NotifiableFindingHive.fromModel(NotifiableFindingModel model) {
    return NotifiableFindingHive(
      diseaseId: model.diseaseId,
      alertRequested: model.alertRequested,
    );
  }

  NotifiableFindingModel toModel() {
    return NotifiableFindingModel(
      diseaseId: diseaseId,
      alertRequested: alertRequested,
    );
  }

  @HiveField(0)
  final String diseaseId;

  @HiveField(1)
  final bool alertRequested;
}
