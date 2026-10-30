import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/tappable.dart';

/// A filter chip: ink when selected, white when not. Toggles on tap.
class TabibuFilterChip extends StatelessWidget {
  const TabibuFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    final onTap = this.onTap;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        enabled: onTap != null,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: Material(
            color: selected ? status.ink : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            elevation: selected ? 0 : 2,
            shadowColor: AppShadows.cardColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      color: selected
                          ? (isDark ? AppColors.inkLight : Colors.white)
                          : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
