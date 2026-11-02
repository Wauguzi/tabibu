import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/text_fold.dart';

void main() {
  group('foldForSearch', () {
    test('trims and lowercases', () {
      expect(foldForSearch('  Otieno '), 'otieno');
    });

    test('folds Latin accents to ASCII', () {
      expect(foldForSearch('José'), 'jose');
      expect(foldForSearch('García'), 'garcia');
      expect(foldForSearch('Ångström'), 'angstrom');
    });

    test('drops combining marks from an NFD source', () {
      // o + combining acute
      expect(foldForSearch('Jose\u0301'), 'jose');
    });

    test('keeps digits and punctuation used in order numbers', () {
      expect(foldForSearch('TB-0231'), 'tb-0231');
      expect(foldForSearch(' 0231 '), '0231');
    });
  });
}
