import 'dart:convert';
import 'dart:io';

import 'lab_test_sanitizer.dart';

/// `make lab-tests TESTS=<export>` runs this on a plain text copy of the
/// export.
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'usage: dart run scripts/lab_tests/build_lab_test_assets.dart '
      '<test_types.txt> [outDir]',
    );
    exit(64);
  }
  final outDir = args.length > 1 ? args[1] : 'assets/data';

  final data = sanitize(File(args[0]).readAsStringSync());

  Directory(outDir).createSync(recursive: true);
  for (final (name, value) in [
    ('lab_test_types.json', data.testTypes),
    ('lab_tests.json', data.labTests),
  ]) {
    // One record per line: small in the bundle, readable in a diff.
    final lines = value.map(jsonEncode).join(',\n');
    File('$outDir/$name').writeAsStringSync('[\n$lines\n]\n');
  }

  data.report.forEach((key, value) => stdout.writeln('$key: $value'));
}
