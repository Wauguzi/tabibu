import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';

void main() {
  group('SubCountyModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{
        'id': 35,
        'name': 'Kibra',
        'countyId': 47,
        'latitude': -1.30047,
        'longitude': 36.73162,
        'geohash': 'kzf0eg70h',
      };
      final model = SubCountyModel.fromJson(json);
      expect(model.id, 35);
      expect(model.name, 'Kibra');
      expect(model.toJson(), json);
    });
  });
}
