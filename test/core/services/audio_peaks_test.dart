import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/services/audio_peaks.dart';

void main() {
  group('downsamplePeaks', () {
    test('empty in, empty out', () {
      expect(downsamplePeaks(const []), isEmpty);
    });

    test('caps at 64 and stays in 0..100', () {
      final samples = List<double>.generate(200, (i) => (i % 10) / 10);
      final peaks = downsamplePeaks(samples);
      expect(peaks.length, 64);
      expect(peaks.every((p) => p >= 0 && p <= 100), isTrue);
    });

    test('even spread keeps order of energy', () {
      final samples = [
        ...List<double>.filled(10, 0.1),
        ...List<double>.filled(10, 0.9),
      ];
      final peaks = downsamplePeaks(samples, maxPeaks: 2);
      expect(peaks.length, 2);
      expect(peaks.first, lessThan(peaks.last));
    });

    test('short lists keep every sample', () {
      expect(downsamplePeaks(const [0, 0.5, 1]), [0, 50, 100]);
    });
  });
}
