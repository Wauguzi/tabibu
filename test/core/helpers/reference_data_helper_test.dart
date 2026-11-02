import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/features/orders/data/advisory_protocol.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Serves the real asset files while counting loads per key.
class _CountingBundle extends AssetBundle {
  _CountingBundle(this._assets);

  final Map<String, String> _assets;
  final loads = <String, int>{};

  @override
  Future<ByteData> load(String key) async {
    loads[key] = (loads[key] ?? 0) + 1;
    final raw = _assets[key];
    if (raw == null) throw ArgumentError('No asset for $key.');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(raw)));
  }
}

/// Every template question key to its label getter, so a key without a
/// generated label fails to compile and an empty one fails the test.
String _label(String questionKey, AppLocalizations l10n) =>
    switch (questionKey) {
      'specimenDescription' => l10n.reportQuestionSpecimenDescription,
      'specimenSize' => l10n.reportQuestionSpecimenSize,
      'representativeSections' => l10n.reportQuestionRepresentativeSections,
      'microscopicDescription' => l10n.reportQuestionMicroscopicDescription,
      'tumourGrade' => l10n.reportQuestionTumourGrade,
      'margins' => l10n.reportQuestionMargins,
      'lymphNodes' => l10n.reportQuestionLymphNodes,
      'immunohistochemistry' => l10n.reportQuestionImmunohistochemistry,
      'parasiteSpecies' => l10n.reportQuestionParasiteSpecies,
      'parasiteDensity' => l10n.reportQuestionParasiteDensity,
      'parasiteStages' => l10n.reportQuestionParasiteStages,
      'rapidTestResult' => l10n.reportQuestionRapidTestResult,
      'findings' => l10n.reportQuestionFindings,
      'methodNotes' => l10n.reportQuestionMethodNotes,
      _ => throw ArgumentError('No label for $questionKey.'),
    };

void main() {
  late _CountingBundle bundle;
  late ReferenceDataHelper helper;
  late AppLocalizations en;
  late AppLocalizations sw;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    sw = await AppLocalizations.delegate.load(const Locale('sw'));
  });

  setUp(() {
    bundle = _CountingBundle({
      for (final name in [
        'lab_tests.json',
        'lab_test_types.json',
        'insurers.json',
        'report_templates.json',
        'public_health_guidance.json',
      ])
        'assets/data/$name': File('assets/data/$name').readAsStringSync(),
    });
    helper = ReferenceDataHelper(bundle: bundle);
  });

  test('the catalogue counts', () async {
    expect(await helper.labTests(), hasLength(247));
    expect(await helper.labTestTypes(), hasLength(11));
    expect(await helper.reportTemplates(), hasLength(3));

    final insurers = await helper.insurers();
    expect(insurers, hasLength(14));
    expect(insurers.first.insurerId, 'sha');
    expect(insurers.first.type, 'publicScheme');
    expect(insurers.last.insurerId, 'other');
    expect(insurers.skip(1).take(12).map((i) => i.type).toSet(), {'insurer'});
  });

  test('the guidance register carries the VHF protocol row (F-13)', () async {
    final guidance = await helper.publicHealthGuidance();
    expect(guidance, hasLength(20));
    final vhf = guidance.firstWhere(
      (g) => g.diseaseId == AdvisoryProtocol.vhf.guidanceDiseaseId,
    );
    expect(vhf.bullets.where((b) => b.audienceValue == .clinician), isNotEmpty);
    expect(identical(guidance, await helper.publicHealthGuidance()), isTrue);
  });

  test('every test type maps to exactly one template', () async {
    final types = await helper.labTestTypes();
    final templates = await helper.reportTemplates();
    final mapped = [for (final template in templates) ...template.testTypeIds];

    expect(mapped, hasLength(types.length));
    expect(mapped.toSet(), hasLength(types.length));
    expect(mapped.toSet(), types.map((t) => t.testTypeId).toSet());
  });

  test('templateForTestType falls back to General', () async {
    final types = await helper.labTestTypes();
    final histopathologyTypeId = types
        .where((t) => t.name == 'Histopathology and Cytology')
        .single
        .testTypeId;

    expect(
      (await helper.templateForTestType(histopathologyTypeId)).templateKey,
      'Cancer',
    );
    expect(
      (await helper.templateForTestType('unknown-id')).templateKey,
      'General',
    );
  });

  test('labTestsByType and activeLabTests read the catalogue', () async {
    final types = await helper.labTestTypes();
    final typeId = types.first.testTypeId;

    final byType = await helper.labTestsByType(typeId);
    expect(byType, isNotEmpty);
    expect(byType.every((t) => t.testTypeId == typeId), isTrue);
    expect(await helper.labTestsByType('unknown-id'), isEmpty);

    final active = await helper.activeLabTests();
    expect(active, isNotEmpty);
    expect(active.every((t) => t.isActive), isTrue);
    expect(active.length, lessThanOrEqualTo((await helper.labTests()).length));
  });

  test('each asset loads once', () async {
    await helper.labTests();
    await helper.labTests();
    await helper.labTestTypes();
    await helper.labTestTypes();
    await helper.insurers();
    await helper.insurers();
    await helper.reportTemplates();
    await helper.reportTemplates();

    expect(bundle.loads['assets/data/lab_tests.json'], 1);
    expect(bundle.loads['assets/data/lab_test_types.json'], 1);
    expect(bundle.loads['assets/data/insurers.json'], 1);
    expect(bundle.loads['assets/data/report_templates.json'], 1);
  });

  test('every questionKey resolves to a label in en and sw', () async {
    var count = 0;
    for (final template in await helper.reportTemplates()) {
      for (final section in template.sections) {
        for (final question in section.questions) {
          expect(
            _label(question.questionKey, en),
            isNotEmpty,
            reason: '${question.questionKey} en',
          );
          expect(
            _label(question.questionKey, sw),
            isNotEmpty,
            reason: '${question.questionKey} sw',
          );
          count++;
        }
      }
    }
    expect(count, 14);
  });
}
