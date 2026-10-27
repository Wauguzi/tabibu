import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';

void main() {
  group('CountyModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{'id': 47, 'name': 'Nairobi'};
      final model = CountyModel.fromJson(json);
      expect(model.id, 47);
      expect(model.name, 'Nairobi');
      expect(model.toJson(), json);
    });
  });
}
