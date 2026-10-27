import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';

void main() {
  group('FacilityModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{
        'facilityId': 'facility-1',
        'mflCode': '13043',
        'name': 'Example Health Centre',
        'kephLevel': 'Level 3',
        'facilityType': 'Basic Health Centre',
        'owner': 'Ministry of Health',
        'wardId': 44,
        'ward': 'Woodley',
        'subCountyId': 35,
        'subCounty': 'Kibra',
        'countyId': 47,
        'county': 'Nairobi',
        'latitude': -1.30047,
        'longitude': 36.73162,
        'geohash': 'kzf0eg70h',
        'isLocationApproximate': false,
        'isLab': true,
        'operationStatus': 'Operational',
        'isOperational': true,
      };
      final model = FacilityModel.fromJson(json);
      expect(model.facilityId, 'facility-1');
      expect(model.wardId, 44);
      expect(model.latitude, -1.30047);
      expect(model.isLab, isTrue);
      expect(model.toJson(), json);
    });
  });
}
