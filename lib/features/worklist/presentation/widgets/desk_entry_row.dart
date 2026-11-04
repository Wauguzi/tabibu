import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_rank_badge.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// One case on the desk, as the desk, the list and the search all show it:
/// its rank, the case number, the test and patient, the time waiting, and
/// what is worth knowing at a glance.
///
/// The case number is always 22 characters and its last digits tell cases
/// apart, so it takes one line and shrinks to fit rather than wrapping at a
/// hyphen or ending in an ellipsis. The shared list row would wrap it.
///
/// Urgency and a long wait are not AI and wear `attention`. Anything the AI
/// produced wears [AiMark], and only for a ready pre-read (H-18): a failed one
/// says "No AI draft" in neutral, and one still queued or running says nothing.
class DeskEntryRow extends StatelessWidget {
  const DeskEntryRow({
    required this.entry,
    required this.rank,
    required this.now,
    this.patient,
    this.onTap,
    super.key,
  });

  final WorklistEntryModel entry;

  /// 1-based place among every open case.
  final int rank;
  final DateTime now;
  final DeskPatient? patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final waited = waitedOf(entry, now);
    final shown = aiBandOf(entry);

    final urgency = switch (entry.urgencyValue) {
      .urgent => l10n.deskUrgent,
      .priority => l10n.deskPriority,
      .routine =>
        waited != null && waited > deskLongWait
            ? l10n.deskWaitingOver(waited.inHours)
            : null,
    };
    final ai = switch (entry.prereadStatusValue) {
      .ready =>
        shown == null
            ? AiMark(label: l10n.deskAiDraftReady)
            : AiMark(
                label: bandLabel(l10n, shown),
                semanticLabel:
                    '${l10n.deskAiDraftReady} · ${bandLabel(l10n, shown)}',
              ),
      .failed => StatusChip(label: l10n.deskNoAiDraft, tone: .neutral),
      .queued || .running || null => null,
    };

    final detail = [
      entry.testName,
      patient?.label ?? '',
    ].where((part) => part.isNotEmpty).join(' · ');
    final onTap = this.onTap;
    final card = Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: scheme.brightness == .dark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Align(
              alignment: .topCenter,
              child: DeskRankBadge(rank: rank),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  FittedBox(
                    fit: .scaleDown,
                    alignment: .centerLeft,
                    child: Text(
                      entry.orderNumber,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  if (urgency != null || ai != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        if (urgency != null)
                          StatusChip(label: urgency, tone: .attention),
                        ?ai,
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .end,
              children: [
                if (waited == null)
                  const SizedBox.shrink()
                else
                  Text(
                    elapsedLabel(l10n, waited),
                    style: textTheme.labelSmall,
                    maxLines: 1,
                  ),
                if (onTap != null)
                  ExcludeSemantics(
                    child: AssetIcon(
                      Assets.icons.forwardIcon,
                      size: 22,
                      scaleUp: false,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}
