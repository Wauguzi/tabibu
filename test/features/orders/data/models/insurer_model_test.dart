import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/orders/data/models/insurer_model.dart';

void main() {
  group('InsurerModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{
        'insurerId': 'sha',
        'name': 'Social Health Authority',
        'type': 'publicScheme',
      };
      final model = InsurerModel.fromJson(json);
      expect(model.insurerId, 'sha');
      expect(model.name, 'Social Health Authority');
      expect(model.type, 'publicScheme');
      expect(model.toJson(), json);
    });

    test('empty holds the empty values', () {
      const empty = InsurerModel(insurerId: '', name: '', type: '');
      expect(InsurerModel.empty(), empty);
    });
  });
}
