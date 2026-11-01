import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_response_hive.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';

Map<String, dynamic> responseJson() => {
  'section': 'Macroscopic',
  'question': 'specimen',
  'answer': 'Skin ellipse',
  'order': 1,
};

void main() {
  group('ReportResponseModel', () {
    test('fromJson round-trips through toJson', () {
      final json = responseJson();
      expect(ReportResponseModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportResponseModel.fromJson({});
      expect(model.section, '');
      expect(model.answer, '');
      expect(model.order, 0);
    });

    test('typed getter', () {
      expect(
        ReportResponseModel.fromJson(responseJson()).sectionValue,
        ReportSection.macroscopic,
      );
    });
  });

  group('ReportResponseHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = ReportResponseModel.fromJson(responseJson());
      final hive = ReportResponseHive.fromModel(model);
      expect(hive.section, model.section);
      expect(hive.question, model.question);
      expect(hive.answer, model.answer);
      expect(hive.order, model.order);
      expect(hive.toModel(), model);
    });
  });
}
