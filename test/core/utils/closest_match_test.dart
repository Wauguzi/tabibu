// cspell:ignore Amna Wambu kiprno MÁRI
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/closest_match.dart';

void main() {
  group('closestMatch', () {
    const names = ['Amina Wambui', 'Mary Njeri', 'Peter Kiprono'];

    test('suggests a near name, by the whole label or a word', () {
      expect(closestMatch('Amna Wambu', names), 'Amina Wambui');
      expect(closestMatch('kiprno', names), 'Peter Kiprono');
    });

    test('folds case and accents', () {
      expect(closestMatch('MÁRI', names), 'Mary Njeri');
    });

    test('nothing near, an exact match or a short query: none', () {
      expect(closestMatch('Ochieng', names), isNull);
      expect(closestMatch('amina', names), isNull);
      expect(closestMatch('am', names), isNull);
    });

    test('a near order number', () {
      expect(
        closestMatch('ODR-JK-AW-02112026-01', ['ODR-JK-AW-02112026-001']),
        'ODR-JK-AW-02112026-001',
      );
    });
  });

  test('editDistance', () {
    expect(editDistance('kitten', 'sitting'), 3);
    expect(editDistance('', 'abc'), 3);
    expect(editDistance('same', 'same'), 0);
  });
}
