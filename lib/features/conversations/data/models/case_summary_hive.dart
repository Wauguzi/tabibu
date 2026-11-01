import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_model.dart';

part 'case_summary_hive.g.dart';

/// Cached [CaseSummaryModel], in the same field order.
@HiveType(typeId: 34)
class CaseSummaryHive {
  CaseSummaryHive({
    required this.caseRef,
    required this.ageBand,
    required this.sex,
    required this.testTypeNames,
    required this.testNames,
    required this.reportStatus,
    required this.signedDiagnosisExcerpt,
    required this.signedAt,
    required this.signedByName,
    required this.reportLanguage,
    required this.builtAt,
  });

  factory CaseSummaryHive.fromModel(CaseSummaryModel model) {
    return CaseSummaryHive(
      caseRef: model.caseRef,
      ageBand: model.ageBand,
      sex: model.sex,
      testTypeNames: model.testTypeNames,
      testNames: model.testNames,
      reportStatus: model.reportStatus,
      signedDiagnosisExcerpt: model.signedDiagnosisExcerpt,
      signedAt: model.signedAt,
      signedByName: model.signedByName,
      reportLanguage: model.reportLanguage,
      builtAt: model.builtAt,
    );
  }

  CaseSummaryModel toModel() {
    return CaseSummaryModel(
      caseRef: caseRef,
      ageBand: ageBand,
      sex: sex,
      testTypeNames: testTypeNames,
      testNames: testNames,
      reportStatus: reportStatus,
      signedDiagnosisExcerpt: signedDiagnosisExcerpt,
      signedAt: signedAt,
      signedByName: signedByName,
      reportLanguage: reportLanguage,
      builtAt: builtAt,
    );
  }

  @HiveField(0)
  final String caseRef;

  @HiveField(1)
  final String ageBand;

  @HiveField(2)
  final String sex;

  @HiveField(3)
  final List<String> testTypeNames;

  @HiveField(4)
  final List<String> testNames;

  @HiveField(5)
  final String reportStatus;

  @HiveField(6)
  final String signedDiagnosisExcerpt;

  @HiveField(7)
  final String signedAt;

  @HiveField(8)
  final String signedByName;

  @HiveField(9)
  final String reportLanguage;

  @HiveField(10)
  final String builtAt;
}
