import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/facilities/data/facility_group.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('facilityGroupOf', () {
    test('covers every facilityType in the asset', () async {
      const expected = {
        'Primary care hospitals',
        'Secondary care hospitals',
        'Specialized & Tertiary Referral hospitals',
        'Comprehensive Teaching & Tertiary Referral Hospital',
        'HOSPITALS',
        'Hospital',
        'Nursing Homes',
        'Nursing and Maternity Home',
        'Basic Health Centre',
        'Comprehensive Health Centre',
        'HEALTH CENTRE',
        'Medical Center',
        'Medical Clinic',
        'VCT',
        'Dental Clinic',
        'Ophthalmology',
        'Dialysis Center',
        'Radiology Clinic',
        'Rehab. Center - Drug and Substance abuse',
        'Dispensary',
        'Laboratory',
        'Pharmacy',
        'Farewell Home',
      };

      final raw = await rootBundle.loadString(
        'assets/data/facilities_nairobi.json',
      );
      final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final types = {for (final row in rows) row['facilityType'] as String};
      expect(types, expected);
    });

    test('maps one type per row', () {
      expect(facilityGroupOf('Primary care hospitals'), FacilityGroup.hospital);
      expect(facilityGroupOf('Nursing Homes'), FacilityGroup.hospital);
      expect(
        facilityGroupOf('Basic Health Centre'),
        FacilityGroup.healthCentre,
      );
      expect(facilityGroupOf('Medical Center'), FacilityGroup.healthCentre);
      expect(facilityGroupOf('Medical Clinic'), FacilityGroup.clinic);
      expect(
        facilityGroupOf('Rehab. Center - Drug and Substance abuse'),
        FacilityGroup.clinic,
      );
      expect(facilityGroupOf('Dispensary'), FacilityGroup.dispensary);
      expect(facilityGroupOf('Laboratory'), FacilityGroup.laboratory);
    });

    test('returns null for unlisted and unknown types', () {
      expect(facilityGroupOf('Pharmacy'), isNull);
      expect(facilityGroupOf('Farewell Home'), isNull);
      expect(facilityGroupOf('Nightclub'), isNull);
      expect(facilityGroupOf(''), isNull);
    });
  });
}
