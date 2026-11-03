import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// One language's AI explanation, waiting for the doctor: the draft's
/// segments verbatim inside [AiDraftFrame], then Approve as is (primary) and
/// Edit (secondary). Reject sits behind the `•••` button beside Edit. While
/// [busy] every control is off.
class ExplanationDraftCard extends StatelessWidget {
  const ExplanationDraftCard({
    required this.title,
    required this.segments,
    required this.busy,
    required this.onApprove,
    required this.onEdit,
    required this.onMore,
    super.key,
  });

  final String title;
  final List<String> segments;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        AiDraftFrame(
          label: l10n.alertReviewAiDraftNotSent,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(title, style: textTheme.titleMedium),
              for (final segment in segments) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(segment, style: textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TabibuButton.primary(
          label: l10n.alertReviewApproveAsIs,
          onTap: busy ? null : onApprove,
        ),
        const SizedBox(height: AppSpacing.xs),
        // Outside the frame: its semantics merge everything inside it.
        Row(
          children: [
            Expanded(
              child: TabibuButton.secondary(
                label: l10n.reviewEdit,
                onTap: busy ? null : onEdit,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            MoreButton(
              semanticLabel: l10n.notificationsMoreLabel,
              onTap: busy ? null : onMore,
            ),
          ],
        ),
      ],
    );
  }
}
