import 'dart:convert';

import 'package:tabibu/core/services/geohash_service.dart';

/// Turns Ministry of Health facility and county exports into the assets in
/// architecture §6.2 (CRQ-0015). Pure, so it is tested without files.

const nairobiCountyId = 47;

// Generous bounds around Kenya: a non-zero coordinate outside them is a data
// error, not a facility.
const ({double min, double max}) _kenyaLat = (min: -4.9, max: 5.1);
const ({double min, double max}) _kenyaLng = (min: 33.8, max: 42.0);

class SanitizedFacilityData {
  const SanitizedFacilityData({
    required this.facilities,
    required this.subCounties,
    required this.counties,
    required this.report,
  });

  final List<Map<String, Object>> facilities;
  final List<Map<String, Object>> subCounties;
  final List<Map<String, Object>> counties;
  final Map<String, int> report;
}

/// Every top-level JSON value in [text]. The exports are API responses pasted
/// one after another, with headings between them.
List<Object?> extractJsonValues(String text) {
  final values = <Object?>[];
  var i = 0;
  while (i < text.length) {
    final c = text[i];
    if (c != '{' && c != '[') {
      i++;
      continue;
    }
    final end = _matchingClose(text, i);
    if (end == -1) {
      throw FormatException('Unterminated JSON value', text, i);
    }
    values.add(jsonDecode(text.substring(i, end + 1)));
    i = end + 1;
  }
  return values;
}

int _matchingClose(String text, int start) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < text.length; i++) {
    final c = text[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (c == r'\') {
        escaped = true;
      } else if (c == '"') {
        inString = false;
      }
      continue;
    }
    switch (c) {
      case '"':
        inString = true;
      case '{' || '[':
        depth++;
      case '}' || ']':
        depth--;
        if (depth == 0) return i;
    }
  }
  return -1;
}

SanitizedFacilityData sanitize({
  required String facilitiesText,
  required String countiesText,
}) {
  final rows = <String, Map<String, dynamic>>{};
  var rawRows = 0;
  for (final value in extractJsonValues(facilitiesText)) {
    if (value is! Map || value['data'] is! List) continue;
    for (final row in value['data'] as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = _text(map['id']);
      if (id.isEmpty) throw FormatException('A facility has no id: $map');
      if ((map['county'] as Map?)?['id'] != nairobiCountyId) {
        throw FormatException('Facility $id is not in Nairobi');
      }
      rawRows++;
      // Overlapping batches repeat rows; the later copy wins.
      rows[id] = map;
    }
  }

  final located = <String, ({double lat, double lng})>{};
  for (final MapEntry(key: id, value: row) in rows.entries) {
    final lat = double.tryParse(_text(row['latitude'])) ?? 0;
    final lng = double.tryParse(_text(row['longitude'])) ?? 0;
    if (lat == 0 && lng == 0) continue;
    if (lat < _kenyaLat.min ||
        lat > _kenyaLat.max ||
        lng < _kenyaLng.min ||
        lng > _kenyaLng.max) {
      throw FormatException('Facility $id lies outside Kenya: $lat, $lng');
    }
    located[id] = (lat: lat, lng: lng);
  }

  final subCounties = _subCounties(rows, located);
  final centres = {for (final s in subCounties) s['id']! as int: s};

  final facilities = <Map<String, Object>>[];
  var approximate = 0;
  var missingMflCode = 0;
  var operational = 0;
  for (final MapEntry(key: id, value: row) in rows.entries) {
    final isOperational = _isOperational(row);
    if (isOperational) operational++;
    final subCounty = Map<String, dynamic>.from(row['sub_county'] as Map);
    final ward = Map<String, dynamic>.from((row['ward'] as Map?) ?? const {});
    final point = located[id];
    final centre = centres[subCounty['id']]!;
    final lat = point?.lat ?? centre['latitude']! as double;
    final lng = point?.lng ?? centre['longitude']! as double;
    if (point == null) approximate++;
    final mflCode = _mflCode(row['mfl_code']);
    if (mflCode.isEmpty) missingMflCode++;

    facilities.add({
      'facilityId': id,
      'mflCode': mflCode,
      'name': _text(row['facility_name']),
      'kephLevel': _text(row['keph_level']),
      'facilityType': _text(row['facility_type']),
      'owner': _text(row['owner']),
      'wardId': (ward['id'] as int?) ?? 0,
      'ward': _text(ward['name']),
      'subCountyId': subCounty['id'] as int,
      'subCounty': _text(subCounty['name']),
      'countyId': nairobiCountyId,
      'county': 'Nairobi',
      'latitude': lat,
      'longitude': lng,
      'geohash': GeohashService.encode(lat: lat, lng: lng),
      'isLocationApproximate': point == null,
      'isLab': row['is_lab'] == 1 || row['is_lab'] == true,
      'operationStatus': _text(row['operation_status']),
      'isOperational': isOperational,
    });
  }
  facilities.sort(_byName);

  return SanitizedFacilityData(
    facilities: facilities,
    subCounties: subCounties,
    counties: _counties(countiesText),
    report: {
      'rowsRead': rawRows,
      'uniqueFacilities': rows.length,
      'operational': operational,
      'notOperational': facilities.length - operational,
      'approximateLocation': approximate,
      'missingMflCode': missingMflCode,
      'subCounties': subCounties.length,
    },
  );
}

List<Map<String, Object>> _subCounties(
  Map<String, Map<String, dynamic>> rows,
  Map<String, ({double lat, double lng})> located,
) {
  final names = <int, String>{};
  final points = <int, List<({double lat, double lng})>>{};
  for (final MapEntry(key: id, value: row) in rows.entries) {
    final subCounty = row['sub_county'] as Map;
    final subCountyId = subCounty['id'] as int;
    names[subCountyId] = _text(subCounty['name']);
    final point = located[id];
    if (point != null) (points[subCountyId] ??= []).add(point);
  }

  final result = <Map<String, Object>>[];
  for (final MapEntry(key: id, value: name) in names.entries) {
    final within = points[id];
    if (within == null || within.isEmpty) {
      throw FormatException('Sub-county $name has no located facility');
    }
    final lat = _round6(
      within.map((p) => p.lat).reduce((a, b) => a + b) / within.length,
    );
    final lng = _round6(
      within.map((p) => p.lng).reduce((a, b) => a + b) / within.length,
    );
    result.add({
      'id': id,
      'name': name,
      'countyId': nairobiCountyId,
      'latitude': lat,
      'longitude': lng,
      'geohash': GeohashService.encode(lat: lat, lng: lng),
    });
  }
  return result..sort(_byName);
}

List<Map<String, Object>> _counties(String text) {
  final list = extractJsonValues(text).whereType<List<dynamic>>().firstOrNull;
  if (list == null) throw const FormatException('No county list found');
  final counties = [
    for (final c in list)
      {'id': (c as Map)['id'] as int, 'name': _text(c['name'])},
  ]..sort((a, b) => (a['id']! as int).compareTo(b['id']! as int));
  final ids = counties.map((c) => c['id']).toList();
  if (ids.length != 47 || ids.toSet().length != 47 || ids.last != 47) {
    throw FormatException('Expected counties 1 to 47, got $ids');
  }
  return counties;
}

bool _isOperational(Map<String, dynamic> row) =>
    row['active'] == true && _text(row['operation_status']) == 'Operational';

String _mflCode(Object? value) {
  final code = _text(value);
  return code.toLowerCase() == 'none' || code.toLowerCase() == 'null'
      ? ''
      : code;
}

/// `null` becomes `''`; runs of whitespace collapse to one space.
String _text(Object? value) =>
    value == null ? '' : '$value'.trim().replaceAll(RegExp(r'\s+'), ' ');

double _round6(double value) => double.parse(value.toStringAsFixed(6));

int _byName(Map<String, Object> a, Map<String, Object> b) {
  final byName = (a['name']! as String).toLowerCase().compareTo(
    (b['name']! as String).toLowerCase(),
  );
  return byName != 0
      ? byName
      : '${a['facilityId'] ?? a['id']}'.compareTo(
          '${b['facilityId'] ?? b['id']}',
        );
}
