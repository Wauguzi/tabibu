import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// One day in a [DayStrip]: weekday, day number, and whether it can be booked.
class DayOption {
  const DayOption({
    required this.weekday,
    required this.day,
    required this.available,
    this.semanticLabel,
  });

  final String weekday;
  final String day;
  final bool available;
  final String? semanticLabel;
}

/// A horizontal strip of day pills. Selected is ink; unavailable is dimmed
/// and disabled.
class DayStrip extends StatelessWidget {
  const DayStrip({
    required this.days,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<DayOption> days;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: .horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selected;
          return _DayPill(
            day: day,
            selected: isSelected,
            onTap: day.available ? () => onSelected(index) : null,
          );
        },
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DayOption day;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final available = day.available;
    final onTap = this.onTap;
    final label = day.semanticLabel ?? '${day.weekday} ${day.day}';

    final foreground = !available
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? (isDark ? AppColors.inkLight : AppColors.white)
        : scheme.onSurface;

    final pill = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 64, minHeight: 88),
      child: Material(
        color: !available
            ? (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest)
            : selected
            ? status.ink
            : (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(AppRadii.card),
        elevation: selected || !available ? 0 : 2,
        shadowColor: AppShadows.cardColor,
        child: Opacity(
          opacity: available ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  day.weekday,
                  style: textTheme.bodySmall?.copyWith(color: foreground),
                ),
                Text(
                  day.day,
                  style: textTheme.titleLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        enabled: onTap != null,
        label: label,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(child: pill),
        ),
      ),
    );
  }
}
