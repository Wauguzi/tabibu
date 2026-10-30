import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A circular icon button: back, open, send and the one primary action.
/// Round means tappable; content icons live in square tiles instead. White
/// on the page, surface low on white cards, ink for the primary action.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.filled = false,
    this.onCard = false,
    this.diameter = 48,
    super.key,
  }) : assert(diameter >= 48, 'Tap targets are at least 48 dp.');

  final SvgGenImage icon;
  final VoidCallback? onTap;
  final String semanticLabel;
  final bool filled;
  final bool onCard;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final isDark = scheme.brightness == .dark;
    final background = filled
        ? status.ink
        : onCard
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;
    final foreground = filled
        ? (isDark ? AppColors.inkLight : Colors.white)
        : scheme.onSurface;

    final onTap = this.onTap;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          elevation: filled ? 0 : 2,
          shadowColor: AppShadows.raisedColor,
          child: Tappable(
            onTap: onTap,
            child: Center(
              child: AssetIcon(
                icon,
                size: 24,
                color: foreground,
                scaleUp: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
