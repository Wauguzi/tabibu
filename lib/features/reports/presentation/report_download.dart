import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/report_text_id.dart';
import 'package:tabibu/features/reports/data/services/report_pdf_builder.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Builds a signed-report PDF for the patient and hands it to the platform
/// share sheet. Uses a temp file deleted after the sheet closes (S-3). Never
/// logs a name, diagnosis or result.
class ReportDownload {
  ReportDownload({
    ReportPdfBuilder? pdfBuilder,
    ReportCacheHelper? reports,
    Future<Directory> Function()? temporaryDirectory,
    Future<ShareResult> Function(ShareParams params)? share,
    Logger? logger,
  }) : _pdf = pdfBuilder ?? getIt<ReportPdfBuilder>(),
       _reports = reports ?? getIt<ReportCacheHelper>(),
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _share = share ?? SharePlus.instance.share,
       _logger = logger ?? Logger();

  final ReportPdfBuilder _pdf;
  final ReportCacheHelper _reports;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<ShareResult> Function(ShareParams params) _share;
  final Logger _logger;

  /// Builds and shares the PDF, or throws [AppError] when the release gate
  /// refuses (`permissionDenied` / `dataNotFound`). Callers show a generic
  /// failure; this method never logs personal content.
  Future<void> sharePatientReport({
    required PathologyReportModel report,
    required CaseModel caseModel,
    required PatientModel patient,
    required String language,
    required AppLocalizations l10n,
    required DateTime now,
  }) async {
    final translation = await _approvedTranslation(
      caseUid: caseModel.uid,
      report: report,
      language: language,
    );
    final input = ReportPdfInput.fromSignedReport(
      report: report,
      viewerRole: ActorRole.patient.value,
      viewerUid: patient.uid,
      patientUid: patient.uid,
      patientDisplayName: patient.fullName,
      dateOfBirth: patient.dateOfBirth,
      sex: patient.sex,
      county: patient.county,
      subCounty: patient.subCounty,
      doctorName: caseModel.doctorName,
      doctorFacilityName: caseModel.doctorFacilityName,
      clinicalNotes: caseModel.clinicalNotes,
      now: now,
      translation: translation,
    );

    File? file;
    try {
      final bytes = await _pdf.build(input, l10n);
      final dir = await _temporaryDirectory();
      final safeName = _fileName(report, caseModel);
      file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      await _share(
        ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]),
      );
    } on AppError {
      // Refusal: nothing personal reaches the log.
      rethrow;
    } on Object {
      if (kDebugMode) _logger.w('Report download failed');
      throw AppError.unknown;
    } finally {
      final written = file;
      if (written != null) {
        try {
          if (written.existsSync()) written.deleteSync();
        } on Object {
          if (kDebugMode) _logger.w('Temp report file not removed');
        }
      }
    }
  }

  Future<ReportTextApprovedModel?> _approvedTranslation({
    required String caseUid,
    required PathologyReportModel report,
    required String language,
  }) async {
    final id = reportTextId(report.uid, .translation, language);
    ReportTextApprovedModel? text;
    try {
      text = await _reports.syncApprovedText(caseUid: caseUid, textUid: id);
    } on AppError {
      try {
        text = await _reports.getApprovedText(caseUid, id);
      } on Object {
        return null;
      }
    } on Object {
      return null;
    }
    if (text == null) return null;
    // A mismatched or empty hash is an unapproved / stale draft — omit it.
    if (text.sourceSha256.isEmpty ||
        text.sourceSha256 != report.contentSha256) {
      return null;
    }
    return text;
  }

  String _fileName(PathologyReportModel report, CaseModel caseModel) {
    final raw = report.testName.isNotEmpty
        ? report.testName
        : (caseModel.tests.isNotEmpty ? caseModel.tests.first.name : 'report');
    final safe = raw.replaceAll(RegExp(r'[^\w.\- ]+'), '_').trim();
    return '${safe.isEmpty ? 'report' : safe}.pdf';
  }
}
