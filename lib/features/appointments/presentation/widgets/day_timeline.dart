import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Visual state of one [TimelineEntry] on the doctor's day rail.
enum TimelineEntryState { done, now, upcoming, free }

/// One slot on a [DayTimeline].
class TimelineEntry {
  const TimelineEntry({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.state,
    this.nowLabel,
    this.avatar,
    this.onTap,
  });

  final String time;
  final String title;
  final String subtitle;
  final TimelineEntryState state;
  final String? nowLabel;
  final Widget? avatar;
  final VoidCallback? onTap;
}

/// The doctor's day rail: time labels, a vertical rule with a teal "now"
/// marker, and cards for done / now / upcoming / free.
class DayTimeline extends StatelessWidget {
  const DayTimeline({required this.entries, super.key});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(entry: entries[i], isLast: i == entries.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isNow = entry.state == .now;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                entry.time,
                style: textTheme.bodySmall?.copyWith(
                  color: isNow ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: isNow ? .w600 : null,
                ),
                textAlign: .end,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 16,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: isNow ? 10 : 8,
                  height: isNow ? 10 : 8,
                  decoration: BoxDecoration(
                    color: isNow ? scheme.primary : scheme.outlineVariant,
                    shape: .circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: scheme.outlineVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              child: _EntryCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return switch (entry.state) {
      .done => _DoneCard(entry: entry),
      .now => _NowCard(entry: entry),
      .upcoming => _UpcomingCard(entry: entry),
      .free => _FreeCard(entry: entry),
    };
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    entry.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    entry.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ExcludeSemantics(child: StatusMark.done(label: entry.title)),
          ],
        ),
      ),
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    // Ink flips to near-white in dark mode, so its text flips to ink.
    final onInk = scheme.brightness == .dark
        ? AppColors.inkLight
        : AppColors.white;
    final avatar = entry.avatar;
    final nowLabel = entry.nowLabel;
    final onTap = entry.onTap;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: status.ink,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            if (avatar != null) ...[
              avatar,
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    entry.title,
                    style: textTheme.titleMedium?.copyWith(color: onInk),
                  ),
                  Text(
                    entry.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: onInk.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (nowLabel != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    nowLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: .w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '${entry.title}, ${entry.subtitle}',
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onTap = entry.onTap;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(entry.title, style: textTheme.titleMedium),
                  Text(
                    entry.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: AssetIcon(
                Assets.icons.forwardIcon,
                size: 22,
                scaleUp: false,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '${entry.title}, ${entry.subtitle}',
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}

class _FreeCard extends StatelessWidget {
  const _FreeCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Free gaps are never tappable, even if a callback was passed.
    return DashedBorder(
      color: scheme.outlineVariant,
      radius: AppRadii.card,
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(entry.title, style: textTheme.titleMedium),
            Text(
              entry.subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
