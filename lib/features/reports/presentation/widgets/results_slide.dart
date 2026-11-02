import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A lavender results hero slide: chip, title, body, optional illustration
/// and open arrow.
class ResultsSlide extends StatelessWidget {
  const ResultsSlide({
    required this.chipLabel,
    required this.title,
    required this.body,
    this.illustration,
    this.onTap,
    super.key,
  });

  final String chipLabel;
  final String title;
  final String body;
  final Widget? illustration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final illustration = this.illustration;
    final onTap = this.onTap;
    final fill = isDark ? AppColors.lavenderDark : AppColors.lavenderLight;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Align(
                    alignment: .centerLeft,
                    child: StatusChip(label: chipLabel, tone: .info),
                  ),
                ),
                if (onTap != null)
                  ExcludeSemantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        shape: .circle,
                      ),
                      alignment: .center,
                      child: AssetIcon(
                        Assets.icons.arrowUpRightIcon,
                        size: 16,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(fontWeight: .w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (illustration != null) ...[
              const SizedBox(height: AppSpacing.md),
              Align(alignment: .bottomRight, child: illustration),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$chipLabel, $title',
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(child: card),
        ),
      ),
    );
  }
}
