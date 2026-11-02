import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_model.dart';

part 'alert_receipt_hive.g.dart';

/// Cached [AlertReceiptModel], in the same field order.
@HiveType(typeId: 51)
class AlertReceiptHive {
  AlertReceiptHive({
    required this.alertUid,
    required this.readAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory AlertReceiptHive.fromModel(AlertReceiptModel model) {
    return AlertReceiptHive(
      alertUid: model.alertUid,
      readAt: model.readAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  AlertReceiptModel toModel() {
    return AlertReceiptModel(
      alertUid: alertUid,
      readAt: readAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String alertUid;
  @HiveField(1)
  final String readAt;
  @HiveField(2)
  final String lastUpdatedAt;
  @HiveField(3)
  final bool synced;
}
