import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_hive.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';

Map<String, dynamic> measurementJson() => {
  'key': 'focus_mm',
  'unit': 'mm',
  'value': 2.5,
  'precision': 1,
};

void main() {
  group('ReportMeasurementModel', () {
    test('fromJson round-trips through toJson', () {
      final json = measurementJson();
      expect(ReportMeasurementModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportMeasurementModel.fromJson({});
      expect(model.key, '');
      expect(model.value, 0);
      expect(model.precision, 0);
    });

    test('formatted includes unit', () {
      expect(
        ReportMeasurementModel.fromJson(measurementJson()).formatted,
        '2.5 mm',
      );
      expect(const ReportMeasurementModel(value: 1).formatted, '1');
    });
  });

  group('ReportMeasurementHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = ReportMeasurementModel.fromJson(measurementJson());
      expect(ReportMeasurementHive.fromModel(model).toModel(), model);
    });
  });
}
