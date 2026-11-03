import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Asks whether to decline an invite. Confirm only: no reason to give, and
/// the server takes the answer alone. True only when the person confirms.
Future<bool> confirmDeclineInvite(
  BuildContext context, {
  required String inviter,
  required String caseNumber,
  required String test,
}) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.mdtDeclineTitle(inviter),
    subtitle: l10n.mdtDeclineBody(caseNumber, inviter, test),
    action: l10n.mdtDeclineInvite,
  );
}

/// Asks whether to leave a consult, saying what leaving costs.
Future<bool> confirmLeaveConsult(BuildContext context) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.mdtLeaveTitle,
    subtitle: l10n.mdtLeaveBody,
    action: l10n.mdtLeaveAction,
  );
}

/// Asks whether to remove a member, saying what they lose.
Future<bool> confirmRemoveMember(BuildContext context, {required String name}) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.mdtRemoveTitle(name),
    subtitle: l10n.mdtRemoveBody(name),
    action: l10n.mdtRemoveAction,
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String action,
}) async {
  final l10n = context.l10n;
  final confirmed = await showSettledSheet<bool>(
    context,
    title: title,
    subtitle: subtitle,
    cancelLabel: l10n.commonCancel,
    builder: (sheet) => TabibuButton.primary(
      label: action,
      onTap: () => Navigator.of(sheet).pop(true),
    ),
  );
  return confirmed ?? false;
}
