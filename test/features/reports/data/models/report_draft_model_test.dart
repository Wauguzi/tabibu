import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';

Map<String, dynamic> draftJson() => {
  'uid': 'draft-1',
  'caseUid': 'case-1',
  'pathologistUid': 'path-1',
  'kind': 'Initial',
  'status': 'Editing',
  'baseReportUid': '',
  'targetReportUid': '',
  'prereadRunUid': 'run-1',
  'templateKey': 'General',
  'title': 'Draft',
  'diagnosisType': 'Final',
  'diagnosis': '',
  'comments': '',
  'responses': <Object>[],
  'labelOverrides': {'a': 'b'},
  'labelOverrideCount': 1,
  'isCritical': false,
  'addendumText': '',
  'amendmentReason': '',
  'diagnosisStartedAt': '',
  'startedFromPreread': true,
  'startedAt': '2026-11-01T08:00:00.000Z',
  'signedReportUid': '',
  'notifiableFindings': <Object>[],
  'hintShownDiseaseIds': ['malaria'],
  'confirmatoryRequests': <String>[],
  'createdByUid': 'path-1',
  'language': 'en',
  'lastUpdatedAt': '2026-11-01T08:00:00.000Z',
};

void main() {
  group('ReportDraftModel', () {
    test('fromJson round-trips through toJson', () {
      final json = draftJson();
      expect(ReportDraftModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportDraftModel.fromJson({});
      expect(model.kind, 'Initial');
      expect(model.status, 'Editing');
      expect(model.templateKey, 'General');
      expect(model.labelOverrides, isEmpty);
      expect(model.synced, isTrue);
    });

    test('toJson never contains synced', () {
      expect(
        ReportDraftModel.fromJson(draftJson()).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and labelOverrideCountMatches', () {
      final model = ReportDraftModel.fromJson(draftJson());
      expect(model.kindValue, DraftKind.initial);
      expect(model.statusValue, DraftStatus.editing);
      expect(model.labelOverrideCountMatches, isTrue);
      expect(
        model.copyWith(labelOverrideCount: 2).labelOverrideCountMatches,
        isFalse,
      );
    });
  });

  group('ReportDraftHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = ReportDraftModel.fromJson(
        draftJson(),
      ).copyWith(synced: false);
      expect(ReportDraftHive.fromModel(model).toModel(), model);
    });
  });
}
