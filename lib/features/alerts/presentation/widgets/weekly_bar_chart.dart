import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// Eight-week (or N-week) case counts with a dashed baseline. One semantics
/// node; colours and copy come from the caller.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.counts,
    required this.baseline,
    required this.labels,
    required this.baselineLabel,
    required this.semanticSummary,
    this.height = 180,
    super.key,
  }) : assert(labels.length >= 2, 'Need first and last axis labels.');

  final List<int> counts;
  final double baseline;
  final List<String> labels;
  final String baselineLabel;
  final String semanticSummary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: semanticSummary,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: WeeklyBarChartPainter(
            counts: counts,
            baseline: baseline,
            firstLabel: labels.first,
            lastLabel: labels.last,
            baselineLabel: baselineLabel,
            aboveColor: status.alertNotice,
            belowColor: scheme.outlineVariant,
            labelStyle: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            baselineLabelStyle: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: .w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out and paints the weekly bars. Exposed for tests that assert
/// colours and bar rects without a golden.
class WeeklyBarChartPainter extends CustomPainter {
  WeeklyBarChartPainter({
    required this.counts,
    required this.baseline,
    required this.firstLabel,
    required this.lastLabel,
    required this.baselineLabel,
    required this.aboveColor,
    required this.belowColor,
    this.labelStyle,
    this.baselineLabelStyle,
  });

  final List<int> counts;
  final double baseline;
  final String firstLabel;
  final String lastLabel;
  final String baselineLabel;
  final Color aboveColor;
  final Color belowColor;
  final TextStyle? labelStyle;
  final TextStyle? baselineLabelStyle;

  static const double _labelBand = 28;
  static const double _topPad = 8;
  static const double _barGapFraction = 0.35;

  /// Peak of the y-scale (counts / baseline, plus 20 %). Never zero.
  double get yMax {
    var peak = baseline;
    for (final c in counts) {
      if (c > peak) peak = c.toDouble();
    }
    if (peak <= 0) return 1;
    return peak * 1.2;
  }

  /// Chart area above the axis labels.
  Rect plotRect(Size size) {
    return Rect.fromLTRB(
      0,
      _topPad,
      size.width,
      math.max(_topPad, size.height - _labelBand),
    );
  }

  /// Bar rectangles left-to-right for [size].
  List<Rect> barRects(Size size) {
    if (counts.isEmpty) return const [];
    final plot = plotRect(size);
    final n = counts.length;
    final slot = plot.width / n;
    final gap = slot * _barGapFraction;
    final barWidth = slot - gap;
    final maxH = plot.height;

    final scale = yMax;
    final out = <Rect>[];
    for (var i = 0; i < n; i++) {
      final h = maxH * (counts[i] / scale);
      final left = plot.left + i * slot + gap / 2;
      out.add(
        Rect.fromLTRB(left, plot.bottom - h, left + barWidth, plot.bottom),
      );
    }
    return out;
  }

  double baselineY(Size size) {
    final plot = plotRect(size);
    return plot.bottom - plot.height * (baseline / yMax);
  }

  Color colorFor(int index) {
    final count = index < counts.length ? counts[index] : 0;
    final base = count > baseline ? aboveColor : belowColor;
    if (counts.isNotEmpty && index == counts.length - 1) {
      return Color.alphaBlend(Colors.black.withValues(alpha: 0.2), base);
    }
    return base;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = plotRect(size);
    final rects = barRects(size);
    const radius = Radius.circular(AppSpacing.xxs);

    for (var i = 0; i < rects.length; i++) {
      final rect = rects[i];
      if (rect.height <= 0) continue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = colorFor(i),
      );
    }

    final y = baselineY(size).clamp(plot.top, plot.bottom);
    final dashPaint = Paint()
      ..color = belowColor
      ..strokeWidth = 1.5
      ..style = .stroke;
    const dash = 5.0;
    const gap = 4.0;
    var x = plot.left;
    while (x < plot.right) {
      final end = math.min(x + dash, plot.right);
      canvas.drawLine(Offset(x, y), Offset(end, y), dashPaint);
      x += dash + gap;
    }

    final baselineTp = TextPainter(
      text: TextSpan(text: baselineLabel, style: baselineLabelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: size.width * 0.4);
    baselineTp.paint(
      canvas,
      Offset(plot.right - baselineTp.width, y - baselineTp.height - 2),
    );

    if (rects.isEmpty) return;

    final firstTp = TextPainter(
      text: TextSpan(text: firstLabel, style: labelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: size.width * 0.45);
    firstTp.paint(
      canvas,
      Offset(rects.first.left, size.height - firstTp.height),
    );

    final lastTp = TextPainter(
      text: TextSpan(text: lastLabel, style: labelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: size.width * 0.45);
    lastTp.paint(
      canvas,
      Offset(rects.last.right - lastTp.width, size.height - lastTp.height),
    );
  }

  @override
  bool shouldRepaint(WeeklyBarChartPainter oldDelegate) =>
      oldDelegate.counts != counts ||
      oldDelegate.baseline != baseline ||
      oldDelegate.firstLabel != firstLabel ||
      oldDelegate.lastLabel != lastLabel ||
      oldDelegate.baselineLabel != baselineLabel ||
      oldDelegate.aboveColor != aboveColor ||
      oldDelegate.belowColor != belowColor ||
      oldDelegate.labelStyle != labelStyle ||
      oldDelegate.baselineLabelStyle != baselineLabelStyle;
}
