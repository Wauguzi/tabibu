import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// One field in "Compare with AI draft": AI on the draft surface, the
/// pathologist on the edited surface (decision H-5).
class DiffCard extends StatelessWidget {
  const DiffCard({
    required this.field,
    required this.aiLabel,
    required this.aiText,
    required this.yoursLabel,
    required this.yoursText,
    this.note,
    super.key,
  });

  final String field;
  final String aiLabel;
  final String aiText;
  final String yoursLabel;
  final String yoursText;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final note = this.note;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(field, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _DiffBlock(
              label: aiLabel,
              text: aiText,
              icon: Assets.icons.inProgressIcon,
              iconColor: status.aiDraft,
              labelColor: status.aiDraft,
              fill: status.aiDraftContainer,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DiffBlock(
              label: yoursLabel,
              text: yoursText,
              icon: Assets.icons.editIcon,
              iconColor: status.editedBorder,
              labelColor: scheme.onSurface,
              fill: status.editedSurface,
              borderColor: status.editedBorder,
            ),
            if (note != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                note,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiffBlock extends StatelessWidget {
  const _DiffBlock({
    required this.label,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.labelColor,
    required this.fill,
    this.borderColor,
  });

  final String label;
  final String text;
  final SvgGenImage icon;
  final Color iconColor;
  final Color labelColor;
  final Color fill;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = this.borderColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: borderColor == null ? null : Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                AssetIcon(icon, size: 18, color: iconColor, scaleUp: false),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(color: labelColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(text, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
