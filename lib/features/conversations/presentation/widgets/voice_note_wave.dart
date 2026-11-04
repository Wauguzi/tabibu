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
    super.key,
  });

  final List<int> peaks;
  final Color foreground;
  final double playedFraction;

  /// True while playing, paused mid-clip, or otherwise part-played.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final heights = VoiceWaveGeometry.heightsFromPeaks(peaks);
    final opacities = VoiceWaveGeometry.barOpacities(
      playedFraction,
      active: active,
    );
    return SizedBox(
      width: VoiceWaveGeometry.boxWidth,
      height: VoiceWaveGeometry.boxHeight,
      child: CustomPaint(
        painter: VoiceNoteWavePainter(
          heights: heights,
          opacities: opacities,
          color: foreground,
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
  });

  final List<double> heights;
  final List<double> opacities;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = .fill;
    for (var i = 0; i < VoiceWaveGeometry.barCount; i++) {
      final height = heights[i];
      final x = i * (VoiceWaveGeometry.barWidth + VoiceWaveGeometry.barGap);
      final top = (VoiceWaveGeometry.boxHeight - height) / 2;
      paint.color = color.withValues(alpha: opacities[i]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x, top, x + VoiceWaveGeometry.barWidth, top + height),
          const Radius.circular(VoiceWaveGeometry.barRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VoiceNoteWavePainter oldDelegate) =>
      oldDelegate.color != color ||
      !listEquals(oldDelegate.heights, heights) ||
      !listEquals(oldDelegate.opacities, opacities);
}
