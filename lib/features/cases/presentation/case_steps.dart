import 'package:tabibu/l10n/l10n.dart';

/// The labels of the doctor's five case steps, in order, for a
/// `CaseStepper` with `current: case.doctorStep`.
List<String> doctorCaseStepLabels(AppLocalizations l10n) => [
  l10n.caseStepSeen,
  l10n.caseStepOrdered,
  l10n.caseStepPathologist,
  l10n.caseStepSigned,
  l10n.caseStepDiscussed,
];

/// The stepper's reading for screen readers: where the case is, in words.
String doctorCaseStepSemantics(AppLocalizations l10n, int current) {
  final labels = doctorCaseStepLabels(l10n);
  final step = current.clamp(0, labels.length - 1);
  return l10n.caseStepProgress(step + 1, labels.length, labels[step]);
}
