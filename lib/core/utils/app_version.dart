/// Compares `major.minor.patch` versions numerically, so `1.0.10` is after
/// `1.0.09`. A build suffix (`+1002`) is ignored; missing or unreadable
/// parts count as 0.
int compareVersions(String a, String b) {
  List<int> parts(String v) {
    final core = v.trim().replaceAll('"', '').split('+').first.split('.');
    return [
      for (var i = 0; i < 3; i++)
        int.tryParse(core.elementAtOrNull(i) ?? '') ?? 0,
    ];
  }

  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}
