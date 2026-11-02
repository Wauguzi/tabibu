import 'dart:math';

import 'package:material_ui/material_ui.dart';

// One dash rhythm for every dashed line in the app.
const _dash = 6.0;
const _gap = 4.0;

/// A dashed rounded-rectangle outline, drawn with a [CustomPainter]. The
/// draft frame: AI drafts always wear it, signed work never does, so the
/// distinction survives without colour.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    required this.color,
    required this.radius,
    required this.child,
    this.strokeWidth = 1.5,
    super.key,
  });

  final Color color;
  final double radius;
  final Widget child;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(inset),
          Radius.circular(max(radius - inset, 0)),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, min(distance + _dash, metric.length)),
          paint,
        );
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// A dashed hairline across the available width, in [DashedBorder]'s
/// rhythm: splits a card where a solid divider would read as two cards.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(min(x + _dash, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
