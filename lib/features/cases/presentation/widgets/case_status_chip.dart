import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The doctor-facing status of a case, one mapping for rows and detail.
class CaseStatusChip extends StatelessWidget {
  const CaseStatusChip({required this.caseModel, super.key});

  final CaseModel caseModel;

  /// The chip's words and tone, shared with row announcements.
  static (String, StatusTone) partsOf(CaseModel c, AppLocalizations l10n) {
    if (c.needsDoctor) return (l10n.doctorCasesDiscuss, .attention);
    if (c.isDone) return (l10n.doctorCasesClosed, .closed);
    // Refused or lapsed: still step 1, but it needs the doctor.
    if (c.currentStageValue == .pathologistRejected) {
      return (l10n.doctorCasesOrdered, .attention);
    }
    if (c.currentStageValue == .reportInProgress) {
      return (l10n.doctorCaseReportInProgress, .info);
    }
    if (c.doctorStep <= 1) return (l10n.doctorCasesOrdered, .neutral);
    if (c.doctorStep == 2) return (l10n.doctorCasesWithPathologist, .info);
    return (l10n.doctorCasesSigned, .signed);
  }

  @override
  Widget build(BuildContext context) {
    final (label, tone) = partsOf(caseModel, context.l10n);
    return StatusChip(label: label, tone: tone);
  }
}
