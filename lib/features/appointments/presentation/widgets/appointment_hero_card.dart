import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// The teal next-appointment / now hero. Lives inside a [PatternCard];
/// [progress] is the caller's segmented bar (doctor home).
class AppointmentHeroCard extends StatelessWidget {
  const AppointmentHeroCard({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
    this.subtitle,
    this.figure,
    this.leading,
    this.progress,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget primary;
  final Widget? secondary;
  final String? subtitle;

  /// The large figure under the title, e.g. the appointment's time.
  final String? figure;
  final Widget? leading;
  final Widget? progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final leading = this.leading;
    final secondary = this.secondary;
    final subtitle = this.subtitle;
    final figure = this.figure;
    final progress = this.progress;

    return PatternCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      eyebrow,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: .w600,
                      ),
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(width: AppSpacing.sm),
                progress,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: .start,
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (figure != null)
                      Text(
                        figure,
                        style: AppStyles.numericLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: .ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: primary),
              if (secondary != null) ...[
                const SizedBox(width: AppSpacing.xs),
                secondary,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
