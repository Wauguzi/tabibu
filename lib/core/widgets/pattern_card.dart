import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/logo_cells.dart';

/// A bold teal hero card carrying the scatter pattern: the logo's three
/// cells at low opacity over the teal hero gradient. At most one per screen.
class PatternCard extends StatelessWidget {
  const PatternCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.hero),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppGradients.tealHeroDark
                    : AppGradients.tealHero,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _PatternPainter(isDark: isDark)),
          ),
          Padding(padding: AppStyles.cardPadding, child: child),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.isDark});

  final bool isDark;

  static final List<Path> _cells = [
    LogoCells.joinedPair(),
    LogoCells.drop(),
    LogoCells.dot(),
  ];

  // Fixed scatter: fraction offsets, width, rotation. Hand-placed so the
  // pattern is identical on every run.
  static const _scatter = [
    (0.10, 0.06, 64.0, -0.3),
    (0.84, 0.04, 48.0, 0.5),
    (0.68, 0.20, 80.0, 0.2),
    (0.30, 0.30, 44.0, -0.6),
    (0.90, 0.38, 64.0, 0.9),
    (0.06, 0.50, 56.0, 0.4),
    (0.48, 0.54, 88.0, -0.2),
    (0.74, 0.68, 52.0, 0.7),
    (0.18, 0.78, 70.0, -0.9),
    (0.54, 0.88, 48.0, 0.3),
    (0.88, 0.90, 60.0, -0.4),
    (0.34, 0.10, 36.0, 1.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.12);
    for (var i = 0; i < _scatter.length; i++) {
      final (fx, fy, width, rotation) = _scatter[i];
      canvas
        ..save()
        ..translate(fx * size.width, fy * size.height)
        ..rotate(rotation)
        ..scale(width / 530)
        ..translate(-265, -256);
      for (final cell in _cells) {
        canvas.drawPath(cell, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
