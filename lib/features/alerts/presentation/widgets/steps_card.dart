import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';

/// Numbered guidance steps on one white card. Shared by the MoH protocol
/// screen and any guidance surface that numbers its steps.
class StepsCard extends StatelessWidget {
  const StepsCard({required this.steps, super.key});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: .start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: .center,
                  decoration: BoxDecoration(shape: .circle, color: status.ink),
                  child: Text(
                    '${i + 1}',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.surfaceContainerLowest,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(steps[i], style: textTheme.bodyLarge)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
