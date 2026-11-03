import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A shortcut tile's picture: a sheet with its lines and a small [badge] at
/// its corner (a sparkle by default). Decorative, so screen readers skip it.
class SheetIllustration extends StatelessWidget {
  const SheetIllustration({this.badge, super.key});

  final SvgGenImage? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == .dark;
    final line = (isDark ? AppColors.lavenderLight : AppColors.lavenderDark)
        .withValues(alpha: 0.5);
    return ExcludeSemantics(
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 72,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: line, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .stretch,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: i == 2 ? 0.6 : 1,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 4,
              child: AssetIcon(
                badge ?? Assets.icons.sparkleIcon,
                size: 16,
                color: line,
                scaleUp: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
