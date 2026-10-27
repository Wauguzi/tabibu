import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/app_version.dart';

void main() {
  test('compares numerically, so a padded patch sorts correctly', () {
    expect(compareVersions('1.0.10', '1.0.09'), isPositive);
    expect(compareVersions('1.0.02', '1.0.2'), 0);
    expect(compareVersions('1.1.0', '1.0.99'), isPositive);
    expect(compareVersions('0.9.9', '1.0.0'), isNegative);
  });

  test('ignores the build number and stray quotes', () {
    expect(compareVersions('1.0.02+1002', '1.0.02'), 0);
    expect(compareVersions('1.0.02', '"1.0.03"'), isNegative);
  });

  test('a missing or unreadable part counts as 0', () {
    expect(compareVersions('1', '1.0.0'), 0);
    expect(compareVersions('1.x.1', '1.0.1'), 0);
    expect(compareVersions('', '0.0.0'), 0);
  });
}
