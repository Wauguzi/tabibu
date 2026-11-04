import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';

/// A white card of value/label columns split by hairline dividers.
class StatsCard extends StatelessWidget {
  const StatsCard({required this.stats, super.key});

  final List<(String value, String label)> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0)
                  VerticalDivider(
                    width: AppSpacing.md,
                    thickness: 1,
                    color: scheme.outlineVariant,
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        stats[i].$1,
                        style: textTheme.titleMedium,
                        textAlign: .center,
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                      Text(
                        stats[i].$2,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        textAlign: .center,
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
