import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';

List<Map<String, dynamic>> _readAsset(String name) =>
    (jsonDecode(File('assets/data/$name').readAsStringSync()) as List<dynamic>)
        .cast<Map<String, dynamic>>();

void main() {
  late List<NotifiableDiseaseModel> diseases;
  late List<PublicHealthGuidanceModel> guidance;

  setUpAll(() {
    diseases = [
      for (final row in _readAsset('notifiable_diseases.json'))
        NotifiableDiseaseModel.fromJson(row),
    ];
    guidance = [
      for (final row in _readAsset('public_health_guidance.json'))
        PublicHealthGuidanceModel.fromJson(row),
    ];
  });

  test('the bundle holds 38 diseases with 20 guidance entries', () {
    expect(diseases, hasLength(38));
    expect(diseases.map((d) => d.diseaseId).toSet(), hasLength(38));
    expect(guidance, hasLength(20));
  });

  test('only eligible diseases have guidance', () {
    final byId = {for (final d in diseases) d.diseaseId: d};
    for (final entry in guidance) {
      final disease = byId[entry.diseaseId];
      expect(disease, isNotNull, reason: entry.diseaseId);
      expect(disease!.publicAlertEligible, isTrue, reason: entry.diseaseId);
    }
  });

  test("every bullet's source resolves within its entry", () {
    for (final entry in guidance) {
      final sources = {for (final s in entry.sources) s.sourceId};
      for (final bullet in entry.bullets) {
        expect(
          sources,
          contains(bullet.sourceId),
          reason: '${entry.diseaseId} ${bullet.bulletId}',
        );
      }
      for (final source in entry.sources) {
        expect(source.url, startsWith('https://'));
      }
    }
  });

  test('every mapped test exists in the lab catalogue', () {
    final catalogue = {
      for (final row in _readAsset('lab_tests.json'))
        row['labTestId'] as String,
    };
    for (final disease in diseases) {
      for (final test in disease.labTests) {
        expect(
          catalogue,
          contains(test.labTestId),
          reason: '${disease.diseaseId} ${test.name}',
        );
      }
    }
  });
}
