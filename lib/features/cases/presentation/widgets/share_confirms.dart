import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Asks whether to end a pending share, naming who loses access (rule 2).
/// True only when the person confirms.
Future<bool> confirmStopSharing(BuildContext context, {required String name}) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.shareStopConfirmTitle(name),
    subtitle: l10n.shareStopConfirmBody(name),
  );
}

/// Asks whether to remove a viewer from the case. The title names them; the
/// body has no name of its own.
Future<bool> confirmRemoveViewer(BuildContext context, {required String name}) {
  final l10n = context.l10n;
  return _confirm(
    context,
    title: l10n.shareRemoveConfirmTitle(name),
    subtitle: l10n.shareRemoveConfirmBody,
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  final l10n = context.l10n;
  final confirmed = await showSettledSheet<bool>(
    context,
    title: title,
    subtitle: subtitle,
    cancelLabel: l10n.commonCancel,
    builder: (sheet) => TabibuButton.primary(
      label: l10n.shareStopSharing,
      onTap: () => Navigator.of(sheet).pop(true),
    ),
  );
  return confirmed ?? false;
}
