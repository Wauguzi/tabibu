// cspell:ignore Kipindupindu
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/preread/data/models/preread_draft_model.dart';
import 'package:tabibu/features/preread/data/models/preread_finding_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_facts.dart';

void main() {
  group('workspaceAiComments', () {
    test('joins the AI findings, one per line, as the server compares', () {
      const preread = PrereadModel(
        draft: PrereadDraftModel(
          findings: [
            PrereadFindingModel(text: 'First finding.'),
            PrereadFindingModel(text: 'Second finding.'),
          ],
        ),
      );

      expect(workspaceAiComments(preread), 'First finding.\nSecond finding.');
    });

    test('is empty when the draft has no findings', () {
      expect(workspaceAiComments(PrereadModel.empty()), isEmpty);
    });
  });

  group('workspaceSubtitle', () {
    const smear = OrderedTestModel(name: 'Malaria smear');

    test('is empty without a case', () {
      expect(workspaceSubtitle(null), isEmpty);
    });

    test('names the first test and the patient', () {
      const caseModel = CaseModel(
        patientName: 'Amina Wambui',
        patientAgeYears: 46,
        tests: [
          smear,
          OrderedTestModel(name: 'Histology'),
        ],
      );

      expect(workspaceSubtitle(caseModel), 'Malaria smear · Amina W., 46');
    });

    test('drops whichever half is missing', () {
      expect(
        workspaceSubtitle(const CaseModel(tests: [smear])),
        'Malaria smear',
      );
      expect(
        workspaceSubtitle(const CaseModel(patientName: 'Amina Wambui')),
        'Amina W.',
      );
    });
  });

  group('workspaceScaleLabel', () {
    test('is empty when the scale is unknown', () {
      expect(workspaceScaleLabel(0), isEmpty);
      expect(workspaceScaleLabel(-1), isEmpty);
    });

    test('rounds to whole microns from one up, two places below', () {
      expect(workspaceScaleLabel(2.4), '2 µm');
      expect(workspaceScaleLabel(0.25), '0.25 µm');
    });
  });

  group('workspaceDiseaseName', () {
    const disease = NotifiableDiseaseModel(
      nameEn: 'Cholera',
      nameSw: 'Kipindupindu',
    );

    test('reads the Swahili name for sw and English otherwise', () {
      expect(workspaceDiseaseName(disease, 'sw'), 'Kipindupindu');
      expect(workspaceDiseaseName(disease, 'en'), 'Cholera');
    });
  });

  group('workspaceMeasurementRows', () {
    test('keeps whole numbers whole and other values as they are', () {
      expect(workspaceMeasurementRows(const {'count': 12, 'density': 2.5}), [
        ('count', '12'),
        ('density', '2.5'),
      ]);
    });

    test('is empty without measurements', () {
      expect(workspaceMeasurementRows(const {}), isEmpty);
    });
  });
}
