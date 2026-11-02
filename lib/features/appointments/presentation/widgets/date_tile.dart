import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A pastel square with the day number and a caller-localised month label.
class DateTile extends StatelessWidget {
  const DateTile({
    required this.date,
    required this.monthLabel,
    this.tone = .sky,
    super.key,
  });

  final DateTime date;
  final String monthLabel;
  final IconTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final fill = _toneFill(tone, isDark);
    final day = date.day.toString().padLeft(2, '0');

    return Semantics(
      label: '$day $monthLabel',
      excludeSemantics: true,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              day,
              style: textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: .w700,
              ),
            ),
            Text(
              monthLabel,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
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
  (.glass, _) => Colors.white.withValues(alpha: 0.16),
  (.neutral, false) => AppColors.surfaceLowLight,
  (.neutral, true) => AppColors.surfaceLowDark,
  (.danger, false) => AppColors.peachLight,
  (.danger, true) => AppColors.peachDark,
};
