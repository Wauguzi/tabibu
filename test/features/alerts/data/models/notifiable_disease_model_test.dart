import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_lab_test_model.dart';

Map<String, dynamic> diseaseJson() => {
  'diseaseId': 'malaria',
  'nameEn': 'Malaria',
  'nameSw': 'Malaria',
  'ihrStatus': 'EventAssessed',
  'reportingCategory': 'Weekly',
  'kenyaGroup': 'Elimination',
  'categorySourceId': 'S1',
  'categoryVerified': false,
  'caseDefinitionEn': 'Fever with parasites.',
  'caseDefinitionSw': 'Fever with parasites.',
  'labTests': [
    {
      'labTestId': 'blood_smear',
      'name': 'Blood smear',
      'strength': 'Confirms',
      'mappingVerified': true,
    },
    {
      'labTestId': 'rdt',
      'name': 'Rapid test',
      'strength': 'Presumptive',
      'mappingVerified': true,
    },
  ],
  'publicAlertEligible': true,
  'allowManualAlert': false,
  'preReadHint': 'MalariaParasites',
  'sourceIds': <String>['S1', 'S4'],
};

void main() {
  group('NotifiableLabTestModel', () {
    test('fromJson round-trips and defaults', () {
      final json = {
        'labTestId': 't1',
        'name': 'NAAT',
        'strength': 'Confirms',
        'mappingVerified': false,
      };
      expect(NotifiableLabTestModel.fromJson(json).toJson(), json);
      final empty = NotifiableLabTestModel.fromJson({});
      expect(empty.strength, 'Uncertain');
      expect(empty.strengthValue, TestStrength.uncertain);
    });
  });

  group('NotifiableDiseaseModel', () {
    test('fromJson round-trips through toJson', () {
      final json = diseaseJson();
      expect(NotifiableDiseaseModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = NotifiableDiseaseModel.fromJson({});
      expect(model.ihrStatus, 'None');
      expect(model.reportingCategory, 'NotListed');
      expect(model.kenyaGroup, 'NotListed');
      expect(model.labTests, isEmpty);
      expect(model.publicAlertEligible, isFalse);
    });

    test('typed getters and hasConfirmingTest', () {
      final model = NotifiableDiseaseModel.fromJson(diseaseJson());
      expect(model.ihrStatusValue, IhrStatus.eventAssessed);
      expect(model.reportingCategoryValue, ReportingCategory.weekly);
      expect(model.kenyaGroupValue, KenyaGroup.elimination);
      expect(model.hasConfirmingTest, isTrue);
      expect(NotifiableDiseaseModel.fromJson({}).hasConfirmingTest, isFalse);
    });
  });
}
