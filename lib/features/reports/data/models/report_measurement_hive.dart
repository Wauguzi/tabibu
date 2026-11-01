import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';

part 'report_measurement_hive.g.dart';

/// Cached [ReportMeasurementModel], in the same field order.
@HiveType(typeId: 19)
class ReportMeasurementHive {
  ReportMeasurementHive({
    required this.key,
    required this.unit,
    required this.value,
    required this.precision,
  });

  factory ReportMeasurementHive.fromModel(ReportMeasurementModel model) {
    return ReportMeasurementHive(
      key: model.key,
      unit: model.unit,
      value: model.value,
      precision: model.precision,
    );
  }

  ReportMeasurementModel toModel() {
    return ReportMeasurementModel(
      key: key,
      unit: unit,
      value: value,
      precision: precision,
    );
  }

  @HiveField(0)
  final String key;

  @HiveField(1)
  final String unit;

  @HiveField(2)
  final double value;

  @HiveField(3)
  final int precision;
}
