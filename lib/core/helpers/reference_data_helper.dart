import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';
import 'package:tabibu/features/orders/data/models/insurer_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_model.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The bundled lab catalogue, insurers and report templates (§1.3). Each
/// asset loads once through the bundle and is cached in memory; the data
/// never changes at runtime.
@lazySingleton
class ReferenceDataHelper {
  ReferenceDataHelper({@ignoreParam AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<LabTestTypeModel>? _labTestTypes;
  List<LabTestModel>? _labTests;
  List<InsurerModel>? _insurers;
  List<ReportTemplateModel>? _reportTemplates;
  List<PublicHealthGuidanceModel>? _guidance;

  /// The 11 lab test types, in catalogue order.
  Future<List<LabTestTypeModel>> labTestTypes() async {
    final cached = _labTestTypes;
    if (cached != null) return cached;
    final loaded = await _load(
      Assets.data.labTestTypes,
      LabTestTypeModel.fromJson,
    );
    return _labTestTypes = loaded;
  }

  /// Every lab test, active or not.
  Future<List<LabTestModel>> labTests() async {
    final cached = _labTests;
    if (cached != null) return cached;
    final loaded = await _load(Assets.data.labTests, LabTestModel.fromJson);
    return _labTests = loaded;
  }

  /// The orderable tests.
  Future<List<LabTestModel>> activeLabTests() async =>
      (await labTests()).where((t) => t.isActive).toList();

  /// The tests of one type, in catalogue order.
  Future<List<LabTestModel>> labTestsByType(String testTypeId) async =>
      (await labTests()).where((t) => t.testTypeId == testTypeId).toList();

  /// SHA first, the insurers, then `other`.
  Future<List<InsurerModel>> insurers() async {
    final cached = _insurers;
    if (cached != null) return cached;
    final loaded = await _load(Assets.data.insurers, InsurerModel.fromJson);
    return _insurers = loaded;
  }

  /// The report templates.
  Future<List<ReportTemplateModel>> reportTemplates() async {
    final cached = _reportTemplates;
    if (cached != null) return cached;
    final loaded = await _load(
      Assets.data.reportTemplates,
      ReportTemplateModel.fromJson,
    );
    return _reportTemplates = loaded;
  }

  /// The public-health guidance register, one row per notifiable disease.
  Future<List<PublicHealthGuidanceModel>> publicHealthGuidance() async {
    final cached = _guidance;
    if (cached != null) return cached;
    final loaded = await _load(
      Assets.data.publicHealthGuidance,
      PublicHealthGuidanceModel.fromJson,
    );
    return _guidance = loaded;
  }

  /// The template covering [testTypeId], or `General` when none does.
  Future<ReportTemplateModel> templateForTestType(String testTypeId) async {
    final templates = await reportTemplates();
    for (final template in templates) {
      if (template.testTypeIds.contains(testTypeId)) return template;
    }
    for (final template in templates) {
      if (template.templateKey == ReportTemplate.general.value) return template;
    }
    return ReportTemplateModel.empty();
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
}
