import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// What the doctor chose on the decline sheet.
typedef DeclineChoice = ({DeclineReason reason, String note});

/// The server's note limit on a decline.
const declineNoteMaxLength = 200;

/// The decline sheet: one required reason and an optional note. The server's
/// four reasons only; `slotTaken` is the system's own, never a doctor's choice.
abstract final class DeclineBookingSheet {
  static Future<DeclineChoice?> show(
    BuildContext context, {
    required String name,
  }) => TabibuBottomSheet.show<DeclineChoice>(
    context,
    title: context.l10n.bookingRequestsDeclineTitle(name),
    builder: (_) => _DeclineForm(name: name),
  );
}

class _DeclineForm extends StatefulWidget {
  const _DeclineForm({required this.name});

  final String name;

  @override
  State<_DeclineForm> createState() => _DeclineFormState();
}

class _DeclineFormState extends State<_DeclineForm> {
  final _note = TextEditingController();
  DeclineReason? _reason;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _send() {
    final reason = _reason;
    if (reason == null) return;
    Navigator.of(
      context,
    ).pop<DeclineChoice>((reason: reason, note: _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasons = <(DeclineReason, String)>[
      (.slotUnavailable, l10n.declineReasonSlotUnavailable),
      (.outsidePractice, l10n.declineReasonOutsidePractice),
      (.referredElsewhere, l10n.declineReasonReferredElsewhere),
      (.other, l10n.declineReasonOther),
    ];
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final (reason, label) in reasons) ...[
          OptionCard(
            title: label,
            selected: _reason == reason,
            onSheet: true,
            onTap: () => setState(() => _reason = reason),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        TabibuTextField(
          label: l10n.bookingRequestsDeclineNoteLabel,
          hint: l10n.bookingRequestsDeclineNoteHint(widget.name),
          controller: _note,
          maxLines: 3,
          maxLength: declineNoteMaxLength,
          keyboardType: .multiline,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.bookingRequestsDeclineSend,
          onTap: _reason == null ? null : _send,
        ),
      ],
    );
  }
}
