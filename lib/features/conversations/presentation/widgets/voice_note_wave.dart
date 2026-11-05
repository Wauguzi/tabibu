import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_wave_geometry.dart';

/// Draws the designer's 16-bar wave; [playedFraction] drives played opacity.
class VoiceNoteWave extends StatelessWidget {
  const VoiceNoteWave({
    required this.peaks,
    required this.foreground,
    required this.playedFraction,
    this.active = false,
    this.width,
    super.key,
  });

  final List<int> peaks;
  final Color foreground;
  final double playedFraction;

  /// True while playing, paused mid-clip, or otherwise part-played.
  final bool active;

  /// Defaults to the designer's 108 dp; shrinks first in a tight bubble.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final heights = VoiceWaveGeometry.heightsFromPeaks(peaks);
    final opacities = VoiceWaveGeometry.barOpacities(
      playedFraction,
      active: active,
    );
    final w = (width ?? VoiceWaveGeometry.boxWidth).clamp(
      VoiceWaveGeometry.minBoxWidth,
      VoiceWaveGeometry.boxWidth,
    );
    return SizedBox(
      width: w,
      height: VoiceWaveGeometry.boxHeight,
      child: CustomPaint(
        painter: VoiceNoteWavePainter(
          heights: heights,
          opacities: opacities,
          color: foreground,
          boxWidth: w,
        ),
      ),
    );
  }
}

/// Public so tests can assert [shouldRepaint] uses value equality on lists.
class VoiceNoteWavePainter extends CustomPainter {
  VoiceNoteWavePainter({
    required this.heights,
    required this.opacities,
    required this.color,
    this.boxWidth = VoiceWaveGeometry.boxWidth,
  });

  final List<double> heights;
  final List<double> opacities;
  final Color color;
  final double boxWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = .fill;
    final scale = boxWidth / VoiceWaveGeometry.boxWidth;
    final barW = VoiceWaveGeometry.barWidth * scale;
    final gap = VoiceWaveGeometry.barGap * scale;
    final radius = VoiceWaveGeometry.barRadius * scale;
    for (var i = 0; i < VoiceWaveGeometry.barCount; i++) {
      final height = heights[i];
      final x = i * (barW + gap);
      final top = (VoiceWaveGeometry.boxHeight - height) / 2;
      paint.color = color.withValues(alpha: opacities[i]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x, top, x + barW, top + height),
          Radius.circular(radius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VoiceNoteWavePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.boxWidth != boxWidth ||
      !listEquals(oldDelegate.heights, heights) ||
      !listEquals(oldDelegate.opacities, opacities);
}
