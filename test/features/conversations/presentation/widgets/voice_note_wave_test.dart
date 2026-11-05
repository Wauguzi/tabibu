import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_note_wave.dart';

void main() {
  test('shouldRepaint uses listEquals, not list identity', () {
    final heights = <double>[1, 2, 3];
    final opacities = <double>[0.4, 0.8, 1];
    final a = VoiceNoteWavePainter(
      heights: heights,
      opacities: opacities,
      color: const Color(0xFF000000),
    );
    final b = VoiceNoteWavePainter(
      heights: List<double>.from(heights),
      opacities: List<double>.from(opacities),
      color: const Color(0xFF000000),
    );
    expect(a.shouldRepaint(b), isFalse);

    final c = VoiceNoteWavePainter(
      heights: List<double>.from(heights)..[0] = 9,
      opacities: List<double>.from(opacities),
      color: const Color(0xFF000000),
    );
    expect(a.shouldRepaint(c), isTrue);
  });
}
