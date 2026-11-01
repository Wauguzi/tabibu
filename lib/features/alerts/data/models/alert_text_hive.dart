import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';

part 'alert_text_hive.g.dart';

/// Cached [AlertTextModel], in the same field order.
@HiveType(typeId: 47)
class AlertTextHive {
  AlertTextHive({required this.headline, required this.body});

  factory AlertTextHive.fromModel(AlertTextModel model) {
    return AlertTextHive(headline: model.headline, body: model.body);
  }

  AlertTextModel toModel() {
    return AlertTextModel(headline: headline, body: body);
  }

  @HiveField(0)
  final String headline;

  @HiveField(1)
  final String body;
}
