import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every `@HiveType` model must be registered in `hive_helper.dart`.
///
/// `hive_registrar.g.dart` exists and codegen keeps it current, but nothing
/// calls it — registration is a hand-maintained cascade in `HiveHelperImpl`.
/// That makes the generated file a decoy: it updates itself when a model is
/// added, so the obvious place to look says everything is fine while the
/// live list silently rots. A model missing from the cascade compiles, ships,
/// and only fails at the first write with "Cannot write, unknown type".
void main() {
  final libDir = Directory('lib');

  List<File> dartFiles() => libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('every @HiveType model is registered in hive_helper', () {
    final hiveTypes = <String, String>{};
    final typeIds = <String, String>{};

    for (final file in dartFiles()) {
      if (file.path.endsWith('.g.dart')) continue;
      final source = file.readAsStringSync();
      final matches = RegExp(
        r'@HiveType\(\s*typeId:\s*(\d+)\s*\)\s*\n\s*class\s+(\w+)',
      ).allMatches(source);
      for (final match in matches) {
        hiveTypes[match.group(2)!] = file.path;
        typeIds[match.group(2)!] = match.group(1)!;
      }
    }

    expect(
      hiveTypes,
      isNotEmpty,
      reason: 'found no @HiveType models — the scan itself is broken',
    );

    final registrations = File(
      'lib/core/helpers/hive_helper.dart',
    ).readAsStringSync();

    final unregistered = <String>[];
    for (final entry in hiveTypes.entries) {
      if (!registrations.contains('registerAdapter(${entry.key}Adapter())')) {
        unregistered.add(
          '${entry.key} (typeId ${typeIds[entry.key]}) from ${entry.value}',
        );
      }
    }

    expect(
      unregistered,
      isEmpty,
      reason:
          'These models have no registerAdapter call in hive_helper.dart, so '
          'the first write of one throws HiveError "Cannot write, unknown '
          'type". Adding the model to hive_registrar.g.dart is not enough — '
          'nothing calls it.\n  ${unregistered.join('\n  ')}',
    );
  });

  test('no two models share a typeId', () {
    final byId = <String, List<String>>{};

    for (final file in dartFiles()) {
      if (file.path.endsWith('.g.dart')) continue;
      final source = file.readAsStringSync();
      final matches = RegExp(
        r'@HiveType\(\s*typeId:\s*(\d+)\s*\)\s*\n\s*class\s+(\w+)',
      ).allMatches(source);
      for (final match in matches) {
        byId.putIfAbsent(match.group(1)!, () => []).add(match.group(2)!);
      }
    }

    final clashes = byId.entries.where((e) => e.value.length > 1).toList();

    expect(
      clashes.map((e) => 'typeId ${e.key}: ${e.value.join(', ')}').toList(),
      isEmpty,
      reason: 'Two models on one typeId decode into each other silently.',
    );
  });
}
