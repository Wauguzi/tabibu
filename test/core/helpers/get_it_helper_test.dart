import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Unit tests build each class by hand, so a constructor parameter nothing
  // registers only fails on a device, when the screen first asks for it.
  test('every dependency the generated config resolves is registered', () {
    final config = File(
      'lib/core/helpers/get_it_helper.config.dart',
    ).readAsStringSync();
    final registered = {
      for (final match in RegExp(r'gh\.\w+<([\w.]+)>\(').allMatches(config))
        match.group(1),
    };
    final resolved = {
      for (final match in RegExp(r'gh<([\w.]+)>\(\)').allMatches(config))
        match.group(1),
    };

    expect(registered, isNotEmpty);
    expect(resolved.difference(registered), isEmpty);
  });
}
