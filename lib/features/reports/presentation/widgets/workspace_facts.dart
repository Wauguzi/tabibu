import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';

/// The AI findings as one comments string (the server's signing compare).
String workspaceAiComments(PrereadModel preread) =>
    preread.draft.findings.map((f) => f.text).join('\n');

/// TopBar subtitle: "{test} · {first} {L}., {age}".
String workspaceSubtitle(CaseModel? caseModel) {
  if (caseModel == null) return '';
  final test = caseModel.tests.isEmpty ? '' : caseModel.tests.first.name;
  final patient = patientOf(caseModel)?.label ?? '';
  if (test.isEmpty) return patient;
  if (patient.isEmpty) return test;
  return '$test · $patient';
}

/// Scale pill from microns per pixel; empty when unknown.
String workspaceScaleLabel(double micronsPerPixel) {
  if (micronsPerPixel <= 0) return '';
  final value = micronsPerPixel >= 1
      ? micronsPerPixel.toStringAsFixed(0)
      : micronsPerPixel.toStringAsFixed(2);
  return '$value µm';
}

/// Localised disease name from the register.
String workspaceDiseaseName(NotifiableDiseaseModel disease, String language) =>
    language == 'sw' ? disease.nameSw : disease.nameEn;

/// Measurement rows from the pre-read map (key → value).
List<(String, String)> workspaceMeasurementRows(Map<String, double> values) => [
  for (final entry in values.entries)
    (
      entry.key,
      entry.value == entry.value.roundToDouble()
          ? entry.value.toStringAsFixed(0)
          : entry.value.toString(),
    ),
];
