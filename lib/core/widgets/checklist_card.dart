import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A card of check-circle rows under a title, white or ink.
class ChecklistCard extends StatelessWidget {
  const ChecklistCard({
    required this.title,
    required this.items,
    this.leading,
    this.inverse = false,
    super.key,
  });

  final String title;
  final List<String> items;
  final Widget? leading;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    final leading = this.leading;
    final content = inverse
        ? (isDark ? AppColors.inkLight : Colors.white)
        : scheme.onSurface;
    final check = inverse ? content : scheme.primary;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: inverse
            ? status.ink
            : (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: content),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: .start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: .circle,
                      border: Border.all(color: check, width: 2),
                    ),
                    alignment: .center,
                    child: AssetIcon(
                      Assets.icons.tickIcon,
                      size: 12,
                      color: check,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    items[i],
                    style: textTheme.bodyMedium?.copyWith(color: content),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
