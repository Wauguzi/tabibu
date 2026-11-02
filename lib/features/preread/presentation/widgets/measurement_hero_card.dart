import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A labelled segment on the measurement range bar (0–1 along the track).
class RangeBand {
  const RangeBand({
    required this.label,
    required this.start,
    required this.end,
  });

  final String label;
  final double start;
  final double end;
}

/// Measurement hero for the case workspace: teal [PatternCard] normally,
/// lavender wash when [unsure]. The caller supplies every label.
class MeasurementHeroCard extends StatelessWidget {
  const MeasurementHeroCard({
    required this.eyebrow,
    required this.value,
    required this.caption,
    required this.bands,
    required this.position,
    this.chipLabel,
    this.chipTone = StatusTone.aiDraft,
    this.unsure = false,
    super.key,
  });

  final String eyebrow;
  final String value;
  final String caption;
  final List<RangeBand> bands;
  final double position;
  final String? chipLabel;
  final StatusTone chipTone;
  final bool unsure;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final chipLabel = this.chipLabel;
    final onHero = unsure ? scheme.onSurface : Colors.white;
    final onHeroMuted = unsure
        ? scheme.onSurfaceVariant
        : Colors.white.withValues(alpha: 0.85);
    final marker = position.clamp(0.0, 1.0);

    final body = Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Text(
                eyebrow,
                style: textTheme.bodyMedium?.copyWith(
                  color: onHero,
                  fontWeight: .w600,
                ),
              ),
            ),
            if (chipLabel != null) ...[
              const SizedBox(width: AppSpacing.xs),
              StatusChip(label: chipLabel, tone: chipTone),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppStyles.numericLarge.copyWith(color: onHero)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          caption,
          style: textTheme.bodyMedium?.copyWith(color: onHeroMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        _RangeBar(
          bands: bands,
          position: marker,
          labelColor: onHeroMuted,
          trackColor: unsure
              ? scheme.onSurface.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.35),
          fillColor: unsure ? scheme.onSurface : Colors.white,
          markerColor: unsure ? scheme.onSurface : Colors.white,
        ),
      ],
    );

    if (unsure) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.hero),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppGradients.lavenderWashDark
                : AppGradients.lavenderWash,
          ),
          child: Padding(padding: AppStyles.cardPadding, child: body),
        ),
      );
    }

    return PatternCard(child: body);
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.bands,
    required this.position,
    required this.labelColor,
    required this.trackColor,
    required this.fillColor,
    required this.markerColor,
  });

  final List<RangeBand> bands;
  final double position;
  final Color labelColor;
  final Color trackColor;
  final Color fillColor;
  final Color markerColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (bands.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: .stretch,
          children: [
            SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: .none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 6,
                    child: Row(
                      children: [
                        for (var i = 0; i < bands.length; i++) ...[
                          if (i > 0) const SizedBox(width: 2),
                          Expanded(
                            flex: _flex(bands[i]),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: trackColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: i == 0
                                      ? const Radius.circular(AppRadii.pill)
                                      : .zero,
                                  right: i == bands.length - 1
                                      ? const Radius.circular(AppRadii.pill)
                                      : .zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: (width * position).clamp(0.0, width) - 6,
                    top: 2,
                    child: Container(
                      width: 12,
                      height: 16,
                      decoration: BoxDecoration(
                        color: markerColor,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: fillColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                for (var i = 0; i < bands.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: _flex(bands[i]),
                    child: Text(
                      bands[i].label,
                      textAlign: .center,
                      style: textTheme.labelSmall?.copyWith(color: labelColor),
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  int _flex(RangeBand band) {
    final span = (band.end - band.start).abs();
    final scaled = (span * 1000).round();
    return scaled < 1 ? 1 : scaled;
  }
}
