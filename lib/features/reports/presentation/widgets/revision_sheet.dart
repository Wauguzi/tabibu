import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Asks for the amendment reason (required, ≤ 500) before starting a
/// revision draft. Returns the trimmed reason, or null if dismissed.
abstract final class AmendSheet {
  static Future<String?> show(BuildContext context) =>
      TabibuBottomSheet.show<String>(
        context,
        title: context.l10n.signedCaseAmendTitle,
        builder: (_) => const _RevisionForm(kind: .amend),
      );
}

/// Asks for the addendum text (required, ≤ 2,000) before starting a
/// revision draft. Returns the trimmed text, or null if dismissed.
abstract final class AddendumSheet {
  static Future<String?> show(BuildContext context) =>
      TabibuBottomSheet.show<String>(
        context,
        title: context.l10n.signedCaseAddendumTitle,
        builder: (_) => const _RevisionForm(kind: .addendum),
      );
}

enum _RevisionKind { amend, addendum }

class _RevisionForm extends StatefulWidget {
  const _RevisionForm({required this.kind});

  final _RevisionKind kind;

  @override
  State<_RevisionForm> createState() => _RevisionFormState();
}

class _RevisionFormState extends State<_RevisionForm> {
  final _text = TextEditingController();
  var _showRequired = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final value = _text.text.trim();
    if (value.isEmpty) {
      setState(() => _showRequired = true);
      return;
    }
    Navigator.of(context).pop<String>(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amend = widget.kind == .amend;
    final max = amend
        ? CaseWorkspaceBloc.maxAmendmentReason
        : CaseWorkspaceBloc.maxAddendumText;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(amend ? l10n.signedCaseAmendBody : l10n.signedCaseAddendumBody),
        const SizedBox(height: AppSpacing.md),
        TabibuTextField(
          label: amend
              ? l10n.signedCaseAmendReasonLabel
              : l10n.signedCaseAddendumTextLabel,
          controller: _text,
          maxLines: amend ? 4 : 8,
          maxLength: max,
          required: true,
          onChanged: (_) {
            if (_showRequired) setState(() => _showRequired = false);
          },
        ),
        if (_showRequired) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            amend
                ? l10n.signedCaseAmendReasonRequired
                : l10n.signedCaseAddendumTextRequired,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        TabibuButton.primary(
          label: amend
              ? l10n.signedCaseAmendContinue
              : l10n.signedCaseAddendumContinue,
          onTap: _send,
        ),
      ],
    );
  }
}
