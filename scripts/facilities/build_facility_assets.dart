import 'dart:convert';
import 'dart:io';

import 'facility_sanitizer.dart';

/// `make facilities FACILITIES=<export> COUNTIES=<export>` runs this on plain
/// text copies of the exports.
void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'usage: dart run scripts/facilities/build_facility_assets.dart '
      '<facilities.txt> <counties.txt> [outDir]',
    );
    exit(64);
  }
  final outDir = args.length > 2 ? args[2] : 'assets/data';

  final data = sanitize(
    facilitiesText: File(args[0]).readAsStringSync(),
    countiesText: File(args[1]).readAsStringSync(),
  );

  Directory(outDir).createSync(recursive: true);
  for (final (name, value) in [
    ('facilities_nairobi.json', data.facilities),
    ('sub_counties_nairobi.json', data.subCounties),
    ('counties.json', data.counties),
  ]) {
    // One record per line: small in the bundle, readable in a diff.
    final lines = value.map(jsonEncode).join(',\n');
    File('$outDir/$name').writeAsStringSync('[\n$lines\n]\n');
  }

  data.report.forEach((key, value) => stdout.writeln('$key: $value'));
}
