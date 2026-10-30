// cspell:ignore aaab aaabb aaacc
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/facilities_helper.dart';

class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final raw = _assets[key];
    if (raw == null) throw ArgumentError('No fixture for $key.');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(raw)));
  }
}

Map<String, dynamic> _facility({
  required String id,
  required String name,
  required String ward,
  required String subCounty,
  required String geohash,
  required bool isOperational,
}) => {
  'facilityId': id,
  'mflCode': '13043',
  'name': name,
  'kephLevel': 'Level 3',
  'facilityType': 'Basic Health Centre',
  'owner': 'Ministry of Health',
  'wardId': 44,
  'ward': ward,
  'subCountyId': 35,
  'subCounty': subCounty,
  'countyId': 47,
  'county': 'Nairobi',
  'latitude': -1.3,
  'longitude': 36.7,
  'geohash': geohash,
  'isLocationApproximate': false,
  'isLab': false,
  'operationStatus': isOperational ? 'Operational' : 'Closed',
  'isOperational': isOperational,
};

String get _countiesJson => jsonEncode([
  {'id': 1, 'name': 'Mombasa'},
  {'id': 47, 'name': 'Nairobi'},
]);

String get _subCountiesJson => jsonEncode([
  {
    'id': 35,
    'name': 'Kibra',
    'countyId': 47,
    'latitude': -1.3,
    'longitude': 36.7,
    'geohash': 'kzf0eg70h',
  },
  {
    'id': 36,
    'name': 'Langata',
    'countyId': 47,
    'latitude': -1.33,
    'longitude': 36.78,
    'geohash': 'kzf0mj8cj',
  },
]);

String get _facilitiesJson => jsonEncode([
  _facility(
    id: 'f1',
    name: 'Zebra Clinic',
    ward: 'Ward A',
    subCounty: 'Dagoretti',
    geohash: 'kzf0aaaaa',
    isOperational: true,
  ),
  _facility(
    id: 'f2',
    name: 'Apple Hospital',
    ward: 'Ward B',
    subCounty: 'Kibra',
    geohash: 'kzf0aaabb',
    isOperational: false,
  ),
  _facility(
    id: 'f3',
    name: 'Mango Centre',
    ward: 'Ward A',
    subCounty: 'Kibra',
    geohash: 'abcd12345',
    isOperational: true,
  ),
  _facility(
    id: 'f4',
    name: 'apple annex',
    ward: 'Ward C',
    subCounty: 'Langata',
    geohash: 'kzf0aaacc',
    isOperational: true,
  ),
]);

FacilitiesHelper _helper() => FacilitiesHelper(
  bundle: _FakeAssetBundle({
    'assets/data/counties.json': _countiesJson,
    'assets/data/sub_counties_nairobi.json': _subCountiesJson,
    'assets/data/facilities_nairobi.json': _facilitiesJson,
  }),
);

void main() {
  group('FacilitiesHelper', () {
    test('counties loads once and caches', () async {
      final helper = _helper();
      final counties = await helper.counties();
      expect(counties.map((c) => c.name), ['Mombasa', 'Nairobi']);
      expect(await helper.counties(), same(counties));
    });

    test('nairobiSubCounties loads and caches', () async {
      final helper = _helper();
      final subCounties = await helper.nairobiSubCounties();
      expect(subCounties.map((s) => s.name), ['Kibra', 'Langata']);
      expect(await helper.nairobiSubCounties(), same(subCounties));
    });

    test('facilityById finds by id and misses to null', () async {
      final helper = _helper();
      expect((await helper.facilityById('f2'))?.name, 'Apple Hospital');
      expect(await helper.facilityById('missing'), isNull);
    });

    test(
      'search matches name, ward and sub-county case-insensitively',
      () async {
        final helper = _helper();
        expect(
          (await helper.searchFacilities('MANGO')).map((f) => f.facilityId),
          ['f3'],
        );
        expect(
          (await helper.searchFacilities('ward a')).map((f) => f.facilityId),
          ['f3', 'f1'],
        );
        expect(
          (await helper.searchFacilities('KIBRA')).map((f) => f.facilityId),
          ['f3', 'f2'],
        );
        expect(await helper.searchFacilities('zzz'), isEmpty);
      },
    );

    test(
      'empty query returns everything, operational first then by name',
      () async {
        final helper = _helper();
        expect((await helper.searchFacilities('')).map((f) => f.facilityId), [
          'f4',
          'f3',
          'f1',
          'f2',
        ]);
      },
    );

    test('nearGeohash sorts by shared prefix, then by name', () async {
      final helper = _helper();
      expect(
        (await helper.searchFacilities(
          '',
          nearGeohash: 'kzf0aaab',
        )).map((f) => f.facilityId),
        // f2 shares 8 characters, f4 and f1 share 7, f3 shares none.
        ['f2', 'f4', 'f1', 'f3'],
      );
    });
  });
}
