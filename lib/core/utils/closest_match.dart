import 'dart:math';

import 'package:tabibu/core/utils/text_fold.dart';

/// The label nearest a query that matched nothing, compared on the whole
/// label and on each of its words, folded for case and accents; null when
/// nothing is near enough to suggest. Ties go to the first label in sorted
/// order, so the suggestion is stable.
String? closestMatch(String query, Iterable<String> labels) {
  final needle = foldForSearch(query.trim());
  if (needle.length < 3) return null;
  final allowance = (needle.length / 3).ceil().clamp(2, 4);
  String? best;
  var bestDistance = allowance + 1;
  final sorted = {...labels}.where((l) => l.trim().isNotEmpty).toList()..sort();
  for (final label in sorted) {
    final folded = foldForSearch(label);
    final distance = [folded, ...folded.split(RegExp(r'[\s·-]+'))]
        .where((w) => w.isNotEmpty)
        .map((w) => editDistance(needle, w))
        .reduce(min);
    if (distance > 0 && distance < bestDistance) {
      best = label;
      bestDistance = distance;
    }
  }
  return bestDistance <= allowance ? best : null;
}

/// Levenshtein distance between [a] and [b].
int editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final current = [i, ...List.filled(b.length, 0)];
    for (var j = 1; j <= b.length; j++) {
      current[j] = min(
        min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + (a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1),
      );
    }
    previous = current;
  }
  return previous[b.length];
}
