import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';

Map<String, dynamic> bulletJson() => {
  'bulletId': 'b1',
  'audience': 'Clinician',
  'textEn': 'Report immediately.',
  'textSw': 'Report at once.',
  'swIsOfficial': false,
  'sourceId': 'S1',
};

void main() {
  group('GuidanceBulletModel', () {
    test('fromJson round-trips through toJson', () {
      final json = bulletJson();
      expect(GuidanceBulletModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = GuidanceBulletModel.fromJson({});
      expect(model.audience, 'Patient');
      expect(model.swIsOfficial, isFalse);
      expect(model.textSw, '');
    });

    test('typed getters', () {
      expect(
        GuidanceBulletModel.fromJson(bulletJson()).audienceValue,
        GuidanceAudience.clinician,
      );
      expect(
        const GuidanceBulletModel().audienceValue,
        GuidanceAudience.patient,
      );
    });
  });

  group('GuidanceBulletHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = GuidanceBulletModel.fromJson(bulletJson());
      expect(GuidanceBulletHive.fromModel(model).toModel(), model);
    });
  });
}
