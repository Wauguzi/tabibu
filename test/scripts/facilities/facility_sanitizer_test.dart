import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/services/geohash_service.dart';

import '../../../scripts/facilities/facility_sanitizer.dart';

Map<String, Object?> _row({
  String id = 'f1',
  Object? mflCode = '10001',
  String name = 'Alpha Clinic',
  String latitude = '-1.300000',
  String longitude = '36.800000',
  bool active = true,
  String status = 'Operational',
  int subCountyId = 30,
  String subCounty = 'Westlands',
  int countyId = 47,
  Object? ward = const {'id': 1, 'name': 'Parklands'},
}) => {
  'id': id,
  'mfl_code': mflCode,
  'facility_name': name,
  'keph_level': 'Level 2',
  'facility_type': 'Medical Clinic',
  'facility_type_category': null,
  'owner': 'Ministry of Health',
  'owner_type': null,
  'constituency': null,
  'latitude': latitude,
  'longitude': longitude,
  'is_lab': 0,
  'active': active,
  'phone_number': null,
  'email': null,
  'ward': ward,
  'sub_county': {'id': subCountyId, 'name': subCounty},
  'county': {'id': countyId, 'name': 'Nairobi'},
  'operation_status': status,
};

String _export(List<Map<String, Object?>> rows) =>
    'Facilities in Nairobi:\n\n${jsonEncode({'data': rows})}\n';

final String _counties = jsonEncode([
  for (var id = 47; id >= 1; id--) {'id': id, 'name': 'County $id'},
]);

SanitizedFacilityData _run(List<Map<String, Object?>> rows) =>
    sanitize(facilitiesText: _export(rows), countiesText: _counties);

void main() {
  group('extractJsonValues', () {
    test('reads values pasted one after another between headings', () {
      const text = 'batch 1 {"data": [1]}\n\nbatch 2 {"data": ["a]}"]}';
      expect(extractJsonValues(text), [
        {
          'data': [1],
        },
        {
          'data': ['a]}'],
        },
      ]);
    });

    test('rejects an unterminated value', () {
      expect(() => extractJsonValues('{"data": ['), throwsFormatException);
    });
  });

  group('sanitize', () {
    test('keeps closed facilities, marked not operational', () {
      final data = _run([
        _row(),
        _row(id: 'f2', name: 'Closed', active: false, status: 'Closed'),
      ]);
      final byId = {for (final f in data.facilities) f['facilityId']: f};
      expect(byId['f1']!['isOperational'], isTrue);
      expect(byId['f2']!['isOperational'], isFalse);
      expect(byId['f2']!['operationStatus'], 'Closed');
      expect(data.report['operational'], 1);
      expect(data.report['notOperational'], 1);
    });

    test('active alone does not make a facility operational', () {
      final facility = _run([
        _row(status: 'Non-Operational'),
      ]).facilities.single;
      expect(facility['isOperational'], isFalse);
    });

    test('turns nulls into empty values and trims text', () {
      final facility = _run([
        _row(mflCode: 'None', name: '  Avenue  Health   Care '),
      ]).facilities.single;
      expect(facility['mflCode'], '');
      expect(facility['name'], 'Avenue Health Care');
      expect(facility.values, isNot(contains(null)));
    });

    test('a missing ward becomes an empty ward', () {
      final facility = _run([_row(ward: null)]).facilities.single;
      expect(facility['wardId'], 0);
      expect(facility['ward'], '');
    });

    test('stores a nine-character geohash of the coordinates', () {
      final facility = _run([_row()]).facilities.single;
      expect(facility['geohash'], GeohashService.encode(lat: -1.3, lng: 36.8));
    });

    test('a 0, 0 facility takes its sub-county centre and is flagged', () {
      final data = _run([
        _row(),
        _row(id: 'f2', latitude: '-1.200000', longitude: '36.900000'),
        _row(id: 'f3', latitude: '0.0', longitude: '0.0'),
      ]);
      final centre = data.subCounties.single;
      expect(centre['latitude'], -1.25);
      expect(centre['longitude'], 36.85);
      final approximate = data.facilities.firstWhere(
        (f) => f['facilityId'] == 'f3',
      );
      expect(approximate['isLocationApproximate'], isTrue);
      expect(approximate['geohash'], centre['geohash']);
      expect(data.report['approximateLocation'], 1);
    });

    test('a repeated row from overlapping batches is kept once', () {
      final text = _export([_row()]) + _export([_row(name: 'Renamed')]);
      final data = sanitize(facilitiesText: text, countiesText: _counties);
      expect(data.facilities.single['name'], 'Renamed');
      expect(data.report['rowsRead'], 2);
    });

    test('rejects a facility outside Nairobi', () {
      expect(() => _run([_row(countyId: 22)]), throwsFormatException);
    });

    test('rejects a non-zero coordinate outside Kenya', () {
      expect(
        () => _run([_row(latitude: '51.5', longitude: '-0.12')]),
        throwsFormatException,
      );
    });

    test('rejects a sub-county with no located facility', () {
      expect(
        () => _run([_row(latitude: '0', longitude: '0')]),
        throwsFormatException,
      );
    });

    test('returns the 47 counties in code order', () {
      final counties = _run([_row()]).counties;
      expect(counties.map((c) => c['id']), List.generate(47, (i) => i + 1));
    });

    test('rejects a county list that is not 1 to 47', () {
      expect(
        () => sanitize(
          facilitiesText: _export([_row()]),
          countiesText: jsonEncode([
            {'id': 1, 'name': 'Mombasa'},
          ]),
        ),
        throwsFormatException,
      );
    });
  });
}
