// cspell:ignore aspi Glycocylated Carboxyhemoglobin Carbonmonoxide Carboxyhaemoglobin
// cspell:ignore fluorescenceleishmaniasis microscopyleishmaniasis Lipoarabino mannan
// cspell:ignore lipoarabinomannan TIBC Bence NAATs
// ignore_for_file: lines_longer_than_80_chars

import '../facilities/facility_sanitizer.dart' show extractJsonValues;
import 'lab_test_prices.dart';

/// Turns the Ministry of Health's test-type export into the two catalogue
/// assets in architecture §6.2 (CRQ-0033). Pure, so it is tested without
/// files.

class SanitizedLabTestData {
  const SanitizedLabTestData({
    required this.testTypes,
    required this.labTests,
    required this.report,
  });

  final List<Map<String, Object>> testTypes;
  final List<Map<String, Object>> labTests;
  final Map<String, int> report;
}

/// Rows the export carries from data entry, not from the Ministry's list.
const Set<String> placeholderNames = {'test', 'Test run', 'Migraine'};

/// Rows that repeat another row's test under a second name.
const Map<String, String> duplicateNames = {
  'Covid 19 Rapid Test': 'SARS-CoV-2 antigen test',
};

/// Names the hyphenation rules cannot mend: a lost bracket, a spelling, or a
/// break that joined two words rather than one.
const Map<String, String> nameCorrections = {
  'Blood grouping (ABO and Rh D, other blood types':
      'Blood grouping (ABO and Rh D, other blood types)',
  'Transferring, iron ferritin and TIBC':
      'Transferrin, iron, ferritin and TIBC',
  'Bence jones proteins urine test': 'Bence Jones proteins urine test',
  'Glycocylated haemoglobin (HbA1C) test': 'Glycated haemoglobin (HbA1c) test',
  'Phosphorous': 'Phosphorus',
  'Carboxyhemoglobin/Carbonmonoxide': 'Carboxyhaemoglobin (carbon monoxide)',
  'Direct fluorescenceleishmaniasis':
      'Direct fluorescence test for leishmaniasis',
  'Smear microscopyleishmaniasis': 'Smear microscopy for leishmaniasis',
  'Stool concentration for ova/cyst (%)': 'Stool concentration for ova/cyst',
  'TB Lipoarabino-mannan (LAM)': 'TB lipoarabinomannan (LAM)',
  'Hepatitis B surface antigen (HBsA-g)-ELISA':
      'Hepatitis B surface antigen (HBsAg) ELISA',
  'Hepatitis B surface antigen (HBsA-g)-RDT':
      'Hepatitis B surface antigen (HBsAg) RDT',
  'NAATs for EBOLA': 'NAATs for Ebola',
};

SanitizedLabTestData sanitize(
  String exportText, {
  Map<String, int> prices = labTestPricesKes,
  Set<String> placeholders = placeholderNames,
  Map<String, String> duplicates = duplicateNames,
  Map<String, String> corrections = nameCorrections,
}) {
  final export = extractJsonValues(exportText)
      .whereType<Map<dynamic, dynamic>>()
      .firstWhere(
        (v) => v['data'] is List,
        orElse: () => throw const FormatException('No test-type list found'),
      );

  final testTypes = <Map<String, Object>>[];
  final labTests = <Map<String, Object>>[];
  final seenIds = <String>{};
  final seenNames = <String, String>{};
  final usedCorrections = <String>{};
  final droppedPlaceholders = <String>{};
  final droppedDuplicates = <String>{};
  var rowsRead = 0;
  var emptyTypes = 0;

  for (final rawType in export['data'] as List) {
    final type = Map<String, dynamic>.from(rawType as Map);
    final typeId = _text(type['id']);
    final typeName = _text(type['name']);
    if (typeId.isEmpty || typeName.isEmpty) {
      throw FormatException('A test type has no id or name: $type');
    }

    final kept = <Map<String, Object>>[];
    for (final rawTest in (type['lab_tests'] as List?) ?? const []) {
      rowsRead++;
      final test = Map<String, dynamic>.from(rawTest as Map);
      final id = _text(test['id']);
      if (id.isEmpty) throw FormatException('A lab test has no id: $test');
      if (!seenIds.add(id)) throw FormatException('Lab test $id is repeated');
      if (_text(test['category_id']) != typeId) {
        throw FormatException('Lab test $id is filed under another type');
      }

      final rawName = _text(test['name']);
      if (placeholders.contains(rawName)) {
        droppedPlaceholders.add(rawName);
        continue;
      }
      if (duplicates.containsKey(rawName)) {
        droppedDuplicates.add(rawName);
        continue;
      }
      // Every kept row's description repeats its name, so it is not shipped;
      // one that says more must be looked at, not dropped.
      if (_text(test['description']) != rawName) {
        throw FormatException('Lab test "$rawName" has its own description');
      }

      final mended = mendName(rawName);
      final name = corrections[mended] ?? mended;
      if (name != mended) usedCorrections.add(mended);
      final key = name.toLowerCase();
      final clash = seenNames[key];
      if (clash != null) {
        throw FormatException('"$name" appears in both $clash and $typeName');
      }
      seenNames[key] = typeName;

      final price = prices['$typeName/$name'];
      if (price == null || price <= 0) {
        throw FormatException('No price for "$typeName/$name"');
      }

      final tat = _turnaround(test, rawName);

      kept.add({
        'labTestId': id,
        'testTypeId': typeId,
        'testTypeName': typeName,
        'name': name,
        'isActive': test['is_active'] == true,
        'testPriceKes': price,
        'isPriceEstimate': true,
        'tatCollectionToDelivery': tat.collectionToDelivery,
        'tatDeliveryToResults': tat.deliveryToResults,
        'totalTurnaroundTime': tat.total,
      });
    }

    if (kept.isEmpty) {
      emptyTypes++;
      continue;
    }
    kept.sort(
      (a, b) => (a['name']! as String).toLowerCase().compareTo(
        (b['name']! as String).toLowerCase(),
      ),
    );
    testTypes.add({
      'testTypeId': typeId,
      'name': typeName,
      'testCount': kept.length,
    });
    labTests.addAll(kept);
  }

  // A list entry that matches nothing is stale: the export changed under it.
  void requireAllUsed(String what, Iterable<String> listed, Set<String> used) {
    final stale = listed.where((n) => !used.contains(n)).toList();
    if (stale.isNotEmpty) throw FormatException('Unused $what: $stale');
  }

  requireAllUsed('placeholders', placeholders, droppedPlaceholders);
  requireAllUsed('duplicates', duplicates.keys, droppedDuplicates);
  requireAllUsed('name corrections', corrections.keys, usedCorrections);
  requireAllUsed('prices', prices.keys, {
    for (final t in labTests) '${t['testTypeName']}/${t['name']}',
  });

  return SanitizedLabTestData(
    testTypes: testTypes,
    labTests: labTests,
    report: {
      'rowsRead': rowsRead,
      'testTypes': testTypes.length,
      'emptyTestTypesDropped': emptyTypes,
      'labTests': labTests.length,
      'placeholdersDropped': droppedPlaceholders.length,
      'duplicatesDropped': droppedDuplicates.length,
      'namesCorrected': usedCorrections.length,
    },
  );
}

/// The export's two stages and their total, in its own unit. A missing or
/// negative stage, or a total that is not their sum, stops the run rather
/// than ship a time nobody can check.
({int collectionToDelivery, int deliveryToResults, int total}) _turnaround(
  Map<String, dynamic> test,
  String name,
) {
  final collection = test['tat_collection_to_delivery'];
  final results = test['tat_delivery_to_results'];
  final total = test['total_turn_around_time'];
  if (collection is! int ||
      results is! int ||
      total is! int ||
      collection < 0 ||
      results < 0 ||
      total != collection + results) {
    throw FormatException('Lab test "$name" has an unusable turnaround time');
  }
  return (
    collectionToDelivery: collection,
    deliveryToResults: results,
    total: total,
  );
}

/// Mends the line breaks the export kept from a typeset source: "aspi- rate"
/// is one word, "Beta- 2" keeps its hyphen, "IgM/ IgG" closes up.
String mendName(String name) => _text(name)
    .replaceAllMapped(RegExp('([a-z])- ([a-z])'), (m) => '${m[1]}${m[2]}')
    .replaceAllMapped(RegExp(r'(\S)- (\S)'), (m) => '${m[1]}-${m[2]}')
    .replaceAllMapped(RegExp(r'(\S)/ (\S)'), (m) => '${m[1]}/${m[2]}');

/// `null` becomes `''`; runs of whitespace collapse to one space.
String _text(Object? value) =>
    value == null ? '' : '$value'.trim().replaceAll(RegExp(r'\s+'), ' ');
