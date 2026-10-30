import 'dart:math';

import 'package:material_ui/material_ui.dart';

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
    const dashWidth = 6.0;
    const gapWidth = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            min(distance + dashWidth, metric.length),
          ),
          paint,
        );
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
