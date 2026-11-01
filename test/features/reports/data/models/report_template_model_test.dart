import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_template_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_question_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_section_model.dart';

Map<String, dynamic> templateJson() => {
  'templateKey': 'Cancer',
  'testTypeIds': <String>['histopathology'],
  'sections': [
    {
      'sectionKey': 'Macroscopic',
      'order': 0,
      'questions': [
        {'questionKey': 'specimen', 'order': 0, 'required': true},
      ],
    },
  ],
};

void main() {
  group('ReportTemplateQuestionModel', () {
    test('fromJson round-trips and defaults', () {
      final json = {'questionKey': 'specimen', 'order': 1, 'required': true};
      expect(ReportTemplateQuestionModel.fromJson(json).toJson(), json);
      final empty = ReportTemplateQuestionModel.fromJson({});
      expect(empty.questionKey, '');
      expect(empty.required, isFalse);
    });
  });

  group('ReportTemplateSectionModel', () {
    test('fromJson round-trips and typed getter', () {
      final json = {
        'sectionKey': 'Microscopic',
        'order': 1,
        'questions': <Object>[],
      };
      expect(ReportTemplateSectionModel.fromJson(json).toJson(), json);
      expect(
        ReportTemplateSectionModel.fromJson(json).sectionKeyValue,
        ReportSection.microscopic,
      );
      expect(
        ReportTemplateSectionModel.fromJson({}).sectionKeyValue,
        ReportSection.comments,
      );
    });
  });

  group('ReportTemplateModel', () {
    test('fromJson round-trips through toJson', () {
      final json = templateJson();
      expect(ReportTemplateModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportTemplateModel.fromJson({});
      expect(model.templateKey, '');
      expect(model.testTypeIds, isEmpty);
      expect(model.sections, isEmpty);
    });
  });
}
