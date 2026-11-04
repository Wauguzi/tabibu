import 'package:intl/intl.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
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

/// A lab accession number made the way the order number is: `LAB-{AO}-
/// {DDMMYYYY}-{seq}`, the pathologist's initials, today in Nairobi, and the
/// order's own sequence. It fits the lab's shape (letters, numbers, `/`, `-`,
/// 30 at most) and is only a suggestion: the person can type the lab's own.
String suggestedAccession({
  required String orderNumber,
  required String firstName,
  required String lastName,
  DateTime? now,
}) {
  String initial(String name) => name.trim().isEmpty
      ? ''
      : String.fromCharCode(name.trim().runes.first).toUpperCase();
  final initials = '${initial(firstName)}${initial(lastName)}';
  final sequence =
      RegExp(r'(\d{3})$').firstMatch(orderNumber)?.group(1) ?? '001';
  final date = DateFormat('ddMMyyyy').format(nairobiNow(now));
  return ['LAB', if (initials.isNotEmpty) initials, date, sequence].join('-');
}
