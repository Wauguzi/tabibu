import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';

Map<String, dynamic> guidanceJson() => {
  'diseaseId': 'cholera',
  'reviewedOn': '2026-01-01',
  'bullets': [
    {
      'bulletId': 'ors',
      'audience': 'Patient',
      'textEn': 'Start ORS at the first sign of diarrhoea.',
      'textSw': 'Start ORS at the first sign of diarrhoea.',
      'swIsOfficial': false,
      'sourceId': 'S16',
    },
  ],
  'sources': [
    {
      'sourceId': 'S16',
      'title': 'Cholera advice',
      'publisher': 'MoH',
      'url': 'https://example.com/s16',
      'publishedOn': '2025-04-08',
      'accessedOn': '2026-01-01',
    },
  ],
};

void main() {
  group('PublicHealthGuidanceModel', () {
    test('fromJson round-trips through toJson', () {
      final json = guidanceJson();
      expect(PublicHealthGuidanceModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = PublicHealthGuidanceModel.fromJson({});
      expect(model.diseaseId, '');
      expect(model.bullets, isEmpty);
      expect(model.sources, isEmpty);
    });
  });
}
