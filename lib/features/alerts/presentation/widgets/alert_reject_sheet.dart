import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The server accepts a reason up to 500 characters; the chosen label takes
/// part of it, so the note stops well short.
const alertRejectNoteMaxLength = 300;

/// Opens the reject sheet and returns the reason to send, or null when the
/// approver closes it. The reason is the chosen row's label, followed by the
/// note when there is one.
Future<String?> showAlertRejectSheet(BuildContext context) {
  final l10n = context.l10n;
  return showSettledSheet<String>(
    context,
    title: l10n.alertReviewRejectTitle,
    subtitle: l10n.alertReviewRejectBody,
    cancelLabel: l10n.commonCancel,
    builder: (sheet) =>
        AlertRejectForm(onReject: (reason) => Navigator.of(sheet).pop(reason)),
  );
}

/// One required reason, an optional note, and the confirming button.
class AlertRejectForm extends StatefulWidget {
  const AlertRejectForm({required this.onReject, super.key});

  final ValueChanged<String> onReject;

  @override
  State<AlertRejectForm> createState() => _AlertRejectFormState();
}

class _AlertRejectFormState extends State<AlertRejectForm> {
  final _note = TextEditingController();
  int? _chosen;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _confirm(String label) {
    final note = _note.text.trim();
    widget.onReject(note.isEmpty ? label : '$label: $note');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasons = <(String, String?)>[
      (l10n.alertReviewReasonNotEnough, null),
      (l10n.alertReviewReasonOneHousehold, null),
      (l10n.alertReviewReasonWrongArea, null),
      (l10n.alertReviewReasonOther, l10n.alertReviewReasonOtherSub),
    ];
    final chosen = _chosen;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final (index, (label, sub)) in reasons.indexed) ...[
          OptionCard(
            title: label,
            supporting: sub,
            selected: chosen == index,
            onSheet: true,
            onTap: () => setState(() => _chosen = index),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        TabibuTextField(
          label: l10n.alertReviewNoteLabel,
          hint: l10n.alertReviewNoteHint,
          controller: _note,
          maxLines: 3,
          maxLength: alertRejectNoteMaxLength,
          keyboardType: .multiline,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.alertReviewRejectAlert,
          onTap: chosen == null ? null : () => _confirm(reasons[chosen].$1),
        ),
      ],
    );
  }
}
