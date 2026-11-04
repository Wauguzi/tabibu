import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A directory tile: portrait on a pastel square, name, specialty. The whole
/// card is one tap; the arrow circle is decoration only.
class DoctorGridCard extends StatelessWidget {
  const DoctorGridCard({
    required this.name,
    required this.specialty,
    required this.onTap,
    this.image,
    this.backdrop = .sky,
    super.key,
  });

  final String name;
  final String specialty;
  final VoidCallback onTap;
  final ImageProvider? image;
  final IconTone backdrop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final fill = _toneFill(backdrop, isDark);
    final image = this.image;

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$name, $specialty',
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surfaceContainerHigh
                    : scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadii.tile),
                boxShadow: AppShadows.card(),
              ),
              child: Padding(
                padding: AppStyles.cardPadding,
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: image == null
                              ? Center(
                                  child: Avatar.tile(name: name, radius: 36),
                                )
                              : Image(image: image, fit: .cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      name,
                      style: textTheme.titleMedium,
                      // One line each: every card in the grid keeps its height.
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    Text(
                      specialty,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: .centerRight,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          shape: .circle,
                        ),
                        alignment: Alignment.center,
                        child: AssetIcon(
                          Assets.icons.arrowUpRightIcon,
                          size: 12,
                          scaleUp: false,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
