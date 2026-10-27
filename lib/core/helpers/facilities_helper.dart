import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';

/// The bundled Nairobi reference data (§6.2). Each asset loads once through
/// the bundle and is cached in memory; the data never changes at runtime.
@lazySingleton
class FacilitiesHelper {
  FacilitiesHelper({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<CountyModel>? _counties;
  List<SubCountyModel>? _subCounties;
  List<FacilityModel>? _facilities;

  Future<List<CountyModel>> counties() async {
    final cached = _counties;
    if (cached != null) return cached;
    final loaded = await _load(
      'assets/data/counties.json',
      CountyModel.fromJson,
    );
    return _counties = loaded;
  }

  Future<List<SubCountyModel>> nairobiSubCounties() async {
    final cached = _subCounties;
    if (cached != null) return cached;
    final loaded = await _load(
      'assets/data/sub_counties_nairobi.json',
      SubCountyModel.fromJson,
    );
    return _subCounties = loaded;
  }

  Future<FacilityModel?> facilityById(String id) async {
    final facilities = await _allFacilities();
    return facilities.firstWhereOrNull((f) => f.facilityId == id);
  }

  /// Matches [query] against name, ward or sub-county, case-insensitively.
  /// An empty query returns everything. With [nearGeohash], nearer
  /// facilities (longer shared prefix) sort first; otherwise operational
  /// facilities sort first. Ties break by name.
  Future<List<FacilityModel>> searchFacilities(
    String query, {
    String nearGeohash = '',
  }) async {
    final facilities = await _allFacilities();
    final q = query.trim().toLowerCase();
    final matches =
        facilities.where((facility) {
          if (q.isEmpty) return true;
          return facility.name.toLowerCase().contains(q) ||
              facility.ward.toLowerCase().contains(q) ||
              facility.subCounty.toLowerCase().contains(q);
        }).toList()..sort((a, b) {
          if (nearGeohash.isNotEmpty) {
            final byPrefix = _sharedPrefix(
              b.geohash,
              nearGeohash,
            ).compareTo(_sharedPrefix(a.geohash, nearGeohash));
            if (byPrefix != 0) return byPrefix;
          } else if (a.isOperational != b.isOperational) {
            return a.isOperational ? -1 : 1;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    return matches;
  }

  Future<List<FacilityModel>> _allFacilities() async {
    final cached = _facilities;
    if (cached != null) return cached;
    final loaded = await _load(
      'assets/data/facilities_nairobi.json',
      FacilityModel.fromJson,
    );
    return _facilities = loaded;
  }

  Future<List<T>> _load<T>(
    String asset,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await _bundle.loadString(asset);
    final rows = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return rows.map(fromJson).toList();
  }

  int _sharedPrefix(String a, String b) {
    var length = 0;
    while (length < a.length &&
        length < b.length &&
        a.codeUnitAt(length) == b.codeUnitAt(length)) {
      length++;
    }
    return length;
  }
}
