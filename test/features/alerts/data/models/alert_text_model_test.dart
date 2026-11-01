import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';

void main() {
  group('AlertTextModel', () {
    test('fromJson round-trips through toJson', () {
      final json = {'headline': 'Alert', 'body': 'Body text'};
      expect(AlertTextModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertTextModel.fromJson({});
      expect(model.headline, '');
      expect(model.body, '');
    });
  });

  group('AlertTextHive', () {
    test('fromModel maps every field and round-trips', () {
      const model = AlertTextModel(headline: 'H', body: 'B');
      expect(AlertTextHive.fromModel(model).toModel(), model);
    });
  });
}
