import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_facts.dart';

void main() {
  group('suggestedAccession', () {
    // 3 Nov 2026, 12:00 Nairobi.
    final noon = DateTime.utc(2026, 11, 3, 9);
    final shape = RegExp(r'^[A-Za-z0-9/-]{1,30}$');

    test('reads like the order number: initials, date, sequence', () {
      final accession = suggestedAccession(
        orderNumber: 'ODR-AO-AO-03112026-005',
        firstName: 'Wanjiru',
        lastName: 'Kamau',
        now: noon,
      );

      expect(accession, 'LAB-WK-03112026-005');
      expect(shape.hasMatch(accession), isTrue);
    });

    test('uses Nairobi time for the date near midnight', () {
      final late = DateTime.utc(2026, 11, 3, 22);

      expect(
        suggestedAccession(
          orderNumber: 'ODR-AO-AO-03112026-005',
          firstName: 'Wanjiru',
          lastName: 'Kamau',
          now: late,
        ),
        'LAB-WK-04112026-005',
      );
    });

    test('without names or an order sequence it still fits the lab shape', () {
      final accession = suggestedAccession(
        orderNumber: '',
        firstName: '',
        lastName: '  ',
        now: noon,
      );

      expect(accession, 'LAB-03112026-001');
      expect(shape.hasMatch(accession), isTrue);
    });
  });
}
