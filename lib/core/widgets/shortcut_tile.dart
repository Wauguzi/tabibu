import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A pastel shortcut tile: icon, figure, title and body, with an arrow when
/// it goes somewhere. Without a tap it is a metric tile and shows no arrow.
class ShortcutTile extends StatelessWidget {
  const ShortcutTile({
    required this.icon,
    required this.tone,
    required this.title,
    this.body,
    this.value,
    this.badge,
    this.illustration,
    this.onTap,
    this.tall = false,
    super.key,
  });

  final SvgGenImage icon;
  final IconTone tone;
  final String title;
  final String? body;
  final String? value;
  final Widget? badge;
  final Widget? illustration;
  final VoidCallback? onTap;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    final body = this.body;
    final value = this.value;
    final badge = this.badge;
    final illustration = this.illustration;
    final onTap = this.onTap;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _toneFill(tone, isDark),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      // A tile handed more height keeps its icon on top and its figure and
      // words at the bottom, as the design draws it, so no empty band is left
      // under the text.
      child: Column(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .start,
        children: [
          Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  // Black glyph on white in light, white on black in dark.
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.black
                          : scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: .center,
                    child: AssetIcon(
                      icon,
                      size: 22,
                      color: isDark ? AppColors.white : AppColors.inkLight,
                    ),
                  ),
                  if (onTap != null)
                    ExcludeSemantics(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: isDark
                              ? AppColors.black
                              : scheme.surfaceContainerLowest,
                        ),
                        alignment: .center,
                        child: AssetIcon(
                          Assets.icons.arrowUpRightIcon,
                          size: 14,
                          color: isDark ? AppColors.white : AppColors.inkLight,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (badge != null) ...[
                badge,
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
          if (tall && illustration != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(child: illustration),
              ),
            ),
          Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              if (value != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: .scaleDown,
                    alignment: .centerLeft,
                    child: Text(
                      value,
                      style: AppStyles.numericLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(title, style: textTheme.titleMedium),
              if (body != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(body, style: textTheme.bodySmall),
              ],
            ],
          ),
        ],
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

/// A bento of shortcut tiles: a tall tile left, two stacked tiles right. The
/// row is as tall as its taller side and both sides fill it, so the tall tile
/// never ends short of the pair and leaves a gap that reads as a missing tile.
class ShortcutBento extends StatelessWidget {
  const ShortcutBento({
    required this.tall,
    required this.top,
    required this.bottom,
    super.key,
  });

  final Widget tall;
  final Widget top;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    // The height is the larger natural height of the two sides, so no tight
    // height can clip a tile's wrapped text.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(child: tall),
          const SizedBox(width: AppSpacing.bentoGap),
          Expanded(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Expanded(child: top),
                const SizedBox(height: AppSpacing.bentoGap),
                Expanded(child: bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _toneFill(IconTone tone, bool isDark) => switch ((tone, isDark)) {
  (.sky, false) => AppColors.skyLight,
  (.sky, true) => AppColors.skyDark,
  (.mint, false) => AppColors.mintLight,
  (.mint, true) => AppColors.mintDark,
  (.lavender, false) => AppColors.lavenderLight,
  (.lavender, true) => AppColors.lavenderDark,
  (.butter, false) => AppColors.butterLight,
  (.butter, true) => AppColors.butterDark,
  (.peach, false) => AppColors.peachLight,
  (.peach, true) => AppColors.peachDark,
  (.white, false) => AppColors.surfaceLowestLight,
  (.white, true) => AppColors.surfaceHighDark,
  (.glass, _) => AppColors.white.withValues(alpha: 0.16),
  (.neutral, false) => AppColors.surfaceLowLight,
  (.neutral, true) => AppColors.surfaceLowDark,
  (.danger, false) => AppColors.peachLight,
  (.danger, true) => AppColors.peachDark,
};
