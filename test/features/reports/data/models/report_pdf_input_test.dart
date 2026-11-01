import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';

import 'pathology_report_model_test.dart' show reportJson;

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);
  final report = PathologyReportModel.fromJson(reportJson());

  ReportPdfInput build({
    PathologyReportModel? reportOverride,
    String viewerRole = 'Doctor',
    String viewerUid = 'doc-1',
    bool isDraft = false,
    bool released = false,
    ReportTextApprovedModel? translation,
  }) {
    final r = (reportOverride ?? report).copyWith(
      releasedToPatient: released,
      releasedAt: released ? '2026-11-01T12:00:00.000Z' : '',
    );
    return ReportPdfInput.fromSignedReport(
      report: r,
      locale: 'en',
      viewerRole: viewerRole,
      viewerUid: viewerUid,
      patientUid: 'patient-1',
      patientDisplayName: 'Patient One',
      dateOfBirth: '1990-01-15T00:00:00.000Z',
      sex: 'Female',
      county: 'Nairobi',
      subCounty: 'Kibra',
      doctorName: 'Dr Doc',
      doctorFacilityName: 'Clinic One',
      clinicalNotes: 'Notes',
      disclaimer: 'Disclaimer',
      generatedAtLabel: '2026-11-01 15:00',
      now: now,
      isDraft: isDraft,
      translation: translation,
    );
  }

  group('ReportPdfInput.fromSignedReport', () {
    test('builds input for a report reader', () {
      final pdf = build();
      expect(pdf.header.orderNumber, 'ODR-1');
      expect(pdf.subject.displayName, 'Patient One');
      expect(pdf.subject.ageLabel, isNotEmpty);
      expect(pdf.blocks, isNotEmpty);
      expect(pdf.measurements, ['3 mm']);
    });

    test('refuses a draft', () {
      expect(() => build(isDraft: true), throwsA(AppError.dataNotFound));
    });

    test('refuses a superseded version', () {
      expect(
        () => build(reportOverride: report.copyWith(status: 'Superseded')),
        throwsA(AppError.dataNotFound),
      );
    });

    test('refuses a patient when unreleased', () {
      expect(
        () => build(viewerRole: 'Patient', viewerUid: 'patient-1'),
        throwsA(AppError.permissionDenied),
      );
    });

    test('allows a released patient', () {
      final pdf = build(
        viewerRole: 'Patient',
        viewerUid: 'patient-1',
        released: true,
      );
      expect(pdf.viewerRole, 'Patient');
    });

    test('refuses a non-reader non-patient', () {
      expect(
        () => build(viewerUid: 'stranger'),
        throwsA(AppError.permissionDenied),
      );
    });

    test('refuses a translation with mismatched sourceSha256', () {
      expect(
        () => build(
          translation: const ReportTextApprovedModel(
            sourceSha256: 'other',
            approvedText: {'body': 'x'},
          ),
        ),
        throwsA(AppError.permissionDenied),
      );
    });

    test('refuses a translation with no sourceSha256', () {
      expect(
        () => build(
          translation: const ReportTextApprovedModel(
            approvedText: {'body': 'x'},
          ),
        ),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('PdfSubject.ageLabelFromDateOfBirth', () {
    test('computes years and months', () {
      expect(
        PdfSubject.ageLabelFromDateOfBirth(
          '1990-01-15T00:00:00.000Z',
          DateTime.utc(2026, 11),
        ),
        '36 years 9 months',
      );
      expect(PdfSubject.ageLabelFromDateOfBirth('', now), '');
    });
  });
}
