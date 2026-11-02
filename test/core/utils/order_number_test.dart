import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/order_number.dart';

void main() {
  group('isOrderNumber', () {
    test('takes the server format, in any case', () {
      expect(isOrderNumber('ODR-JK-AW-02112026-001'), isTrue);
      expect(isOrderNumber(' odr-jk-amw-02112026-120 '), isTrue);
    });

    test('rejects the wrong parts', () {
      expect(isOrderNumber('ODR-JK-AW-0211202-001'), isFalse);
      expect(isOrderNumber('ODR-J-AW-02112026-001'), isFalse);
      expect(isOrderNumber('ODR-JK-AWXY-02112026-001'), isFalse);
      expect(isOrderNumber('TB-0231'), isFalse);
    });
  });

  group('looksLikeOrderNumber', () {
    test('an ODR start that is not whole yet', () {
      expect(looksLikeOrderNumber('ODR-JK'), isTrue);
      expect(looksLikeOrderNumber('odr jk aw'), isTrue);
    });

    test('not a whole number, and not a name', () {
      expect(looksLikeOrderNumber('ODR-JK-AW-02112026-001'), isFalse);
      expect(looksLikeOrderNumber('Amina'), isFalse);
    });
  });
}
