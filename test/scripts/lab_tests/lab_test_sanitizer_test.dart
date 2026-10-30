// cspell:ignore aspi phos phate microglob ulin microglobulin NAATs
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../../scripts/lab_tests/lab_test_prices.dart';
import '../../../scripts/lab_tests/lab_test_sanitizer.dart';

Map<String, Object?> _test({
  required String id,
  required String typeId,
  required String name,
  String? description,
}) => {
  'id': id,
  'category_id': typeId,
  'name': name,
  'is_active': true,
  'external_sys_id': null,
  'tat_collection_to_delivery': 100,
  'tat_delivery_to_results': 50,
  'description': description ?? name,
  'total_turn_around_time': 150,
};

String _export(List<Map<String, Object?>> types) =>
    'Test types:\n\n${jsonEncode({'data': types})}\n';

final Map<String, Object?> _parasitology = {
  'id': 't1',
  'name': 'Parasitology',
  'lab_tests': [
    _test(id: 'a', typeId: 't1', name: 'NAATs for malaria'),
    _test(id: 'b', typeId: 't1', name: 'Malaria rapid tests'),
  ],
};

const Map<String, int> _prices = {
  'Parasitology/NAATs for malaria': 6000,
  'Parasitology/Malaria rapid tests': 900,
};

// Every list entry must match a row, so the small fixtures switch them off.
SanitizedLabTestData _run(
  List<Map<String, Object?>> types, {
  Map<String, int> prices = _prices,
}) => sanitize(
  _export(types),
  prices: prices,
  placeholders: const {},
  duplicates: const {},
  corrections: const {},
);

void main() {
  group('mendName', () {
    test('joins a word broken across lines', () {
      expect(
        mendName('Bone marrow aspi- rate (BMA)'),
        'Bone marrow aspirate (BMA)',
      );
      expect(
        mendName('SARS-CoV-2 ge-\nnome sequencing'),
        'SARS-CoV-2 genome sequencing',
      );
    });

    test('keeps a real hyphen and closes up a slash', () {
      expect(mendName('Beta- 2 microglob- ulin'), 'Beta-2 microglobulin');
      expect(mendName('Glucose-6- phos- phate'), 'Glucose-6-phosphate');
      expect(mendName('IgM/ IgG ELISA'), 'IgM/IgG ELISA');
    });
  });

  group('sanitize', () {
    test('carries the type on each test and orders them by name', () {
      final data = _run([_parasitology]);

      expect(data.testTypes, [
        {'testTypeId': 't1', 'name': 'Parasitology', 'testCount': 2},
      ]);
      expect(data.labTests.map((t) => t['name']), [
        'Malaria rapid tests',
        'NAATs for malaria',
      ]);
      expect(data.labTests.first, {
        'labTestId': 'b',
        'testTypeId': 't1',
        'testTypeName': 'Parasitology',
        'name': 'Malaria rapid tests',
        'isActive': true,
        'testPriceKes': 900,
        'isPriceEstimate': true,
        'tatCollectionToDelivery': 100,
        'tatDeliveryToResults': 50,
        'totalTurnaroundTime': 150,
      });
    });

    test('drops a type with no tests', () {
      final data = _run([
        _parasitology,
        {'id': 't2', 'name': 'Category 10', 'lab_tests': <Object>[]},
      ]);

      expect(data.testTypes.map((t) => t['name']), ['Parasitology']);
      expect(data.report['emptyTestTypesDropped'], 1);
    });

    test('drops listed placeholders and duplicates, and mends names', () {
      final data = sanitize(
        _export([
          {
            'id': 't1',
            'name': 'Virology',
            'lab_tests': [
              _test(id: 'a', typeId: 't1', name: 'test', description: 'x'),
              _test(id: 'b', typeId: 't1', name: 'Covid rapid'),
              _test(id: 'c', typeId: 't1', name: 'NAATs for EBOLA'),
            ],
          },
        ]),
        prices: const {'Virology/NAATs for Ebola': 15000},
        placeholders: const {'test'},
        duplicates: const {'Covid rapid': 'SARS-CoV-2 antigen test'},
        corrections: const {'NAATs for EBOLA': 'NAATs for Ebola'},
      );

      expect(data.labTests.single['name'], 'NAATs for Ebola');
      expect(data.report['placeholdersDropped'], 1);
      expect(data.report['duplicatesDropped'], 1);
    });

    test('stops on a test with no price', () {
      expect(
        () => _run(
          [_parasitology],
          prices: const {'Parasitology/NAATs for malaria': 6000},
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('stops on a price, correction or drop that matches nothing', () {
      expect(
        () =>
            _run([_parasitology], prices: {..._prices, 'Parasitology/Gone': 1}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => sanitize(
          _export([_parasitology]),
          prices: _prices,
          placeholders: const {},
          duplicates: const {},
          corrections: const {'Renamed upstream': 'x'},
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('stops on a turnaround time that is missing or does not add up', () {
      for (final broken in [
        {'tat_delivery_to_results': null},
        {'tat_collection_to_delivery': -1, 'total_turn_around_time': 49},
        {'total_turn_around_time': 151},
      ]) {
        final types = [
          {
            'id': 't1',
            'name': 'Parasitology',
            'lab_tests': [
              {
                ..._test(id: 'a', typeId: 't1', name: 'NAATs for malaria'),
                ...broken,
              },
              _test(id: 'b', typeId: 't1', name: 'Malaria rapid tests'),
            ],
          },
        ];
        expect(() => _run(types), throwsA(isA<FormatException>()));
      }
    });

    test('stops on a description that says more than the name', () {
      final types = [
        {
          'id': 't1',
          'name': 'Parasitology',
          'lab_tests': [
            _test(
              id: 'a',
              typeId: 't1',
              name: 'NAATs for malaria',
              description: 'More',
            ),
            _test(id: 'b', typeId: 't1', name: 'Malaria rapid tests'),
          ],
        },
      ];
      expect(() => _run(types), throwsA(isA<FormatException>()));
    });

    test('stops on a repeated id, a misfiled test, or a repeated name', () {
      Map<String, Object?> type(List<Map<String, Object?>> tests) => {
        'id': 't1',
        'name': 'Parasitology',
        'lab_tests': tests,
      };
      expect(
        () => _run([
          type([
            _test(id: 'a', typeId: 't1', name: 'NAATs for malaria'),
            _test(id: 'a', typeId: 't1', name: 'Malaria rapid tests'),
          ]),
        ]),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => _run([
          type([
            _test(id: 'a', typeId: 't9', name: 'NAATs for malaria'),
            _test(id: 'b', typeId: 't1', name: 'Malaria rapid tests'),
          ]),
        ]),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => _run([
          type([
            _test(id: 'a', typeId: 't1', name: 'NAATs for malaria'),
            _test(id: 'b', typeId: 't1', name: 'NAATs for  Malaria'),
          ]),
        ]),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('every benchmark price is a whole, positive number of shillings', () {
    expect(labTestPricesKes.values.where((p) => p <= 0), isEmpty);
    expect(labTestPricesKes.keys.where((k) => !k.contains('/')), isEmpty);
  });
}
