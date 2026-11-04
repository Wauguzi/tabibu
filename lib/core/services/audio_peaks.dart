/// Downsamples amplitude samples (0..1) to at most [maxPeaks] integers 0..100,
/// evenly spaced across the recording.
List<int> downsamplePeaks(List<double> samples, {int maxPeaks = 64}) {
  if (samples.isEmpty || maxPeaks <= 0) return const [];
  final capped = maxPeaks.clamp(1, 64);
  if (samples.length <= capped) {
    return [for (final s in samples) _toHundred(s)];
  }
  final out = <int>[];
  for (var i = 0; i < capped; i++) {
    final start = (i * samples.length / capped).floor();
    final end = ((i + 1) * samples.length / capped).ceil().clamp(
      start + 1,
      samples.length,
    );
    var sum = 0.0;
    for (var j = start; j < end; j++) {
      sum += samples[j];
    }
    out.add(_toHundred(sum / (end - start)));
  }
  return out;
}

int _toHundred(double sample) {
  final n = (sample.clamp(0.0, 1.0) * 100).round();
  return n.clamp(0, 100);
}
