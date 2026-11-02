import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// The white pill on the teal hero, ink text in both themes. No
/// [TabibuButton] variant stays white in dark mode, so the hero owns this one.
class HeroPillButton extends StatelessWidget {
  const HeroPillButton({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onTap = this.onTap;
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          elevation: 2,
          shadowColor: AppShadows.raisedColor,
          child: Tappable(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xlg,
                vertical: AppSpacing.sm,
              ),
              child: Center(
                child: Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inkLight,
                  ),
                  textAlign: .center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
