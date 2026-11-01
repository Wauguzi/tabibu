import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_provenance_model.dart';

Map<String, dynamic> provenanceJson() => {
  'uid': 'prov-1',
  'caseUid': 'case-1',
  'reportUid': 'report-1',
  'pathologistUid': 'path-1',
  'prereadRunUid': 'run-1',
  'diffBase': 'AiDraft',
  'aiDraft': {'diagnosis': 'AI text'},
  'aiModels': {'spark': '1.3'},
  'aiMeasurements': <Object>[],
  'finalMeasurements': <Object>[],
  'labelOverrideCount': 0,
  'diff': [
    {
      'field': 'diagnosis',
      'change': 'Edited',
      'baseValue': 'AI text',
      'finalValue': 'Final text',
      'similarity': 0.5,
    },
  ],
  'editRate': 0.5,
  'acceptedUnchanged': false,
  'hintShownDiseaseIds': <String>[],
  'createdAt': '2026-11-01T10:00:00.000Z',
  'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
};

void main() {
  group('ReportProvenanceModel', () {
    test('fromJson round-trips through toJson', () {
      final json = provenanceJson();
      expect(ReportProvenanceModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportProvenanceModel.fromJson({});
      expect(model.diffBase, 'None');
      expect(model.aiDraft, isEmpty);
      expect(model.diff, isEmpty);
    });

    test('typed getters and computesAcceptedUnchanged', () {
      final model = ReportProvenanceModel.fromJson(provenanceJson());
      expect(model.diffBaseValue, DiffBase.aiDraft);
      expect(model.computesAcceptedUnchanged, isFalse);
      expect(model.copyWith(editRate: 0).computesAcceptedUnchanged, isTrue);
      expect(model.diff.first.changeValue, FieldChange.edited);
    });
  });
}
