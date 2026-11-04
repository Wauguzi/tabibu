/// Designer's wave geometry for chat voice notes (one place to edit).
///
/// Box 108×24; 16 bars, each 3 wide with a 4 gap (x = 0, 7, … 105); fully
/// rounded (radius 1.5). Heights below are the design frame when a clip has
/// no peaks yet.
abstract final class VoiceWaveGeometry {
  static const double boxWidth = 108;
  static const double boxHeight = 24;
  static const int barCount = 16;
  static const double barWidth = 3;
  static const double barGap = 4;
  static const double barRadius = 1.5;
  static const double minBarHeight = 6;
  static const double maxBarHeight = 24;

  /// Idle / never played / after reset.
  static const double idleOpacity = 0.8;

  /// Unplayed bars while the clip is playing, paused or part-played.
  static const double activeUnplayedOpacity = 0.4;

  /// Played bars while the clip is active.
  static const double playedOpacity = 1;

  /// Design frame heights, left to right.
  static const List<double> designHeights = [
    8,
    14,
    20,
    10,
    18,
    24,
    12,
    16,
    22,
    10,
    14,
    8,
    18,
    12,
    6,
    14,
  ];

  /// Resample up-to-64 peaks (0..100) to 16 bar heights in
  /// [minBarHeight, maxBarHeight]. Empty peaks use [designHeights].
  static List<double> heightsFromPeaks(List<int> peaks) {
    if (peaks.isEmpty) return List<double>.from(designHeights);
    final out = <double>[];
    for (var i = 0; i < barCount; i++) {
      final start = (i * peaks.length / barCount).floor();
      final end = ((i + 1) * peaks.length / barCount).ceil().clamp(
        start + 1,
        peaks.length,
      );
      var sum = 0;
      for (var j = start; j < end; j++) {
        sum += peaks[j].clamp(0, 100);
      }
      final mean = sum / (end - start);
      final height =
          minBarHeight + (mean / 100) * (maxBarHeight - minBarHeight);
      out.add(height.clamp(minBarHeight, maxBarHeight));
    }
    return out;
  }

  /// How many of the 16 bars are fully behind [fraction] (centres left of it).
  static int playedBarCount(double fraction) {
    if (fraction <= 0) return 0;
    if (fraction >= 1) return barCount;
    var count = 0;
    for (var i = 0; i < barCount; i++) {
      final centre = (i + 0.5) / barCount;
      if (centre < fraction) count += 1;
    }
    return count;
  }

  /// Per-bar opacities for [fraction] of position/duration.
  ///
  /// When [active] is false (idle / reset), every bar is [idleOpacity].
  /// When active, finished bars are [playedOpacity], upcoming bars are
  /// [activeUnplayedOpacity], and the bar under the playhead blends between
  /// them by how far through that bar the position is.
  static List<double> barOpacities(double fraction, {required bool active}) {
    if (!active) {
      return List<double>.filled(barCount, idleOpacity);
    }
    final f = fraction.clamp(0.0, 1.0);
    final out = <double>[];
    for (var i = 0; i < barCount; i++) {
      final start = i / barCount;
      final end = (i + 1) / barCount;
      if (f <= start) {
        out.add(activeUnplayedOpacity);
      } else if (f >= end) {
        out.add(playedOpacity);
      } else {
        final through = (f - start) / (end - start);
        out.add(
          activeUnplayedOpacity +
              (playedOpacity - activeUnplayedOpacity) * through,
        );
      }
    }
    return out;
  }
}
