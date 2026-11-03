import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_form.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('normalizeKenyanPhone', () {
    test('keeps a shaped number', () {
      expect(normalizeKenyanPhone('+254712345678'), '+254712345678');
      expect(normalizeKenyanPhone('+254112345678'), '+254112345678');
    });

    test('shapes local spellings', () {
      expect(normalizeKenyanPhone('0712 345 678'), '+254712345678');
      expect(normalizeKenyanPhone('254712345678'), '+254712345678');
      expect(normalizeKenyanPhone('712345678'), '+254712345678');
      expect(normalizeKenyanPhone('+254 712 345 678'), '+254712345678');
      expect(normalizeKenyanPhone('(0712) 345-678'), '+254712345678');
    });

    test('refuses what the rules would refuse', () {
      expect(normalizeKenyanPhone(''), isNull);
      expect(normalizeKenyanPhone('123'), isNull);
      expect(normalizeKenyanPhone('071234567'), isNull);
      expect(normalizeKenyanPhone('+254072345678'), isNull);
      expect(normalizeKenyanPhone('+25471234567'), isNull);
      expect(normalizeKenyanPhone('+2547123456789'), isNull);
      expect(normalizeKenyanPhone('0712abc678'), isNull);
    });
  });

  group('workingDaysSummary', () {
    setUpAll(() => initializeDateFormatting('sw'));

    test('empty stays empty', () {
      expect(workingDaysSummary('en', {}), '');
    });

    test('one day names it', () {
      expect(workingDaysSummary('en', {6}), 'Sat');
    });

    test('a run becomes a span', () {
      expect(workingDaysSummary('en', {1, 2, 3, 4, 5}), 'Mon–Fri');
    });

    test('a split week lists', () {
      expect(workingDaysSummary('en', {1, 3, 5}), 'Mon, Wed, Fri');
    });

    test('a Saturday run spans', () {
      expect(workingDaysSummary('en', {6, 7}), 'Sat–Sun');
    });

    test('order does not matter', () {
      expect(workingDaysSummary('en', {5, 1, 4, 2, 3}), 'Mon–Fri');
    });

    test('reads in Kiswahili', () {
      expect(workingDaysSummary('sw', {1, 2, 3, 4, 5}), 'Jumatatu–Ijumaa');
    });
  });

  group('hoursRangeText', () {
    testWidgets('joins the range with an en dash', (tester) async {
      var text = '';
      await tester.pumpApp(
        Builder(
          builder: (context) {
            text = hoursRangeText(context, 480, 1020);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(text, '8:00 AM–5:00 PM');
    });
  });
}
