import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The mark every AI-derived item on the desk wears (H-18): the `aiDraft`
/// container, the sparkle and the `aiDraft` text, inside the dashed draft
/// border. The AI colour is never the signed one, and colour is never the
/// only carrier: the label is read aloud.
class AiMark extends StatelessWidget {
  const AiMark({required this.label, this.semanticLabel, super.key});

  final String label;

  /// What a screen reader says when it needs to say more than [label], e.g.
  /// that a band belongs to an AI draft.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: DashedBorder(
        color: status.draftBorder,
        radius: AppRadii.pill,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: status.aiDraftContainer,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              AssetIcon(
                Assets.icons.sparkleIcon,
                size: 14,
                color: status.aiDraft,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: status.aiDraft,
                    fontWeight: .w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
