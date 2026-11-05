import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_wave_geometry.dart';

void main() {
  group('playedBarCount', () {
    test('matches fraction at 0, 25, 50 and 100 percent', () {
      expect(VoiceWaveGeometry.playedBarCount(0), 0);
      expect(VoiceWaveGeometry.playedBarCount(0.25), 4);
      expect(VoiceWaveGeometry.playedBarCount(0.5), 8);
      expect(VoiceWaveGeometry.playedBarCount(1), 16);
    });
  });

  group('barOpacities', () {
    test('idle keeps every bar at 0.8', () {
      final opacities = VoiceWaveGeometry.barOpacities(0.5, active: false);
      expect(opacities, everyElement(VoiceWaveGeometry.idleOpacity));
    });

    test('active uses 1.0 played and 0.4 unplayed', () {
      final opacities = VoiceWaveGeometry.barOpacities(0.5, active: true);
      expect(opacities.take(8), everyElement(VoiceWaveGeometry.playedOpacity));
      expect(
        opacities.skip(8),
        everyElement(VoiceWaveGeometry.activeUnplayedOpacity),
      );
    });

    test('partial bar blends at 1/32 of the clip', () {
      // 16 bars → each is 1/16; halfway through the first bar is 1/32.
      final opacities = VoiceWaveGeometry.barOpacities(1 / 32, active: true);
      expect(opacities.first, closeTo(0.7, 0.001));
      expect(
        opacities.skip(1),
        everyElement(VoiceWaveGeometry.activeUnplayedOpacity),
      );
    });

    test('whole bars match at 0, 50 and 100 percent', () {
      expect(
        VoiceWaveGeometry.barOpacities(0, active: true),
        everyElement(VoiceWaveGeometry.activeUnplayedOpacity),
      );
      final mid = VoiceWaveGeometry.barOpacities(0.5, active: true);
      expect(mid.take(8), everyElement(VoiceWaveGeometry.playedOpacity));
      expect(
        mid.skip(8),
        everyElement(VoiceWaveGeometry.activeUnplayedOpacity),
      );
      expect(
        VoiceWaveGeometry.barOpacities(1, active: true),
        everyElement(VoiceWaveGeometry.playedOpacity),
      );
    });
  });

  group('heightsFromPeaks', () {
    test('empty peaks use the design heights', () {
      expect(
        VoiceWaveGeometry.heightsFromPeaks(const []),
        VoiceWaveGeometry.designHeights,
      );
    });

    test('64 peaks resample to 16 heights between 6 and 24', () {
      final peaks = List<int>.generate(64, (i) => (i * 3) % 101);
      final heights = VoiceWaveGeometry.heightsFromPeaks(peaks);
      expect(heights, hasLength(16));
      for (final h in heights) {
        expect(h, inInclusiveRange(6, 24));
      }
    });

    test('all-zero peaks sit at the minimum height, not an empty box', () {
      final heights = VoiceWaveGeometry.heightsFromPeaks(
        List<int>.filled(16, 0),
      );
      expect(heights.every((h) => h == VoiceWaveGeometry.minBarHeight), isTrue);
    });
  });
}
