import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
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
      expect(pdf.subject.ageYears, 36);
      expect(pdf.subject.ageMonths, 9);
      expect(pdf.blocks, isNotEmpty);
      expect(pdf.measurements, [
        const PdfMeasurement(key: 'size', value: '3 mm'),
      ]);
    });

    test('blocks carry wire keys, not display text', () {
      final pdf = build();
      expect(pdf.blocks[0].sectionKey, 'Diagnosis');
      expect(pdf.blocks[0].lines.single.label, 'Final');
      expect(pdf.blocks[1].sectionKey, 'Comments');
      expect(pdf.blocks[2].sectionKey, 'ClinicalNotes');
      expect(pdf.blocks[3].sectionKey, 'Macroscopic');
      expect(pdf.blocks[3].lines.single.label, 'specimen');
    });

    test('orders sections and lines by response order', () {
      final pdf = build(
        reportOverride: report.copyWith(
          responses: const [
            ReportResponseModel(
              section: 'Microscopic',
              question: 'margins',
              answer: 'M',
              order: 3,
            ),
            ReportResponseModel(
              section: 'Macroscopic',
              question: 'specimenSize',
              answer: 'S',
              order: 1,
            ),
            ReportResponseModel(
              section: 'Macroscopic',
              question: 'specimenDescription',
              answer: 'D',
            ),
          ],
        ),
      );
      expect(pdf.blocks[3].sectionKey, 'Macroscopic');
      expect(pdf.blocks[3].lines.map((l) => l.label), [
        'specimenDescription',
        'specimenSize',
      ]);
      expect(pdf.blocks[4].sectionKey, 'Microscopic');
    });

    test('keeps template section order when question order restarts', () {
      final pdf = build(
        reportOverride: report.copyWith(
          responses: const [
            ReportResponseModel(
              section: 'Ancillary',
              question: 'immunohistochemistry',
              answer: 'I',
              order: 1,
            ),
            ReportResponseModel(
              section: 'Microscopic',
              question: 'microscopicDescription',
              answer: 'M',
              order: 1,
            ),
            ReportResponseModel(
              section: 'Unlisted',
              question: 'extra',
              answer: 'E',
              order: 1,
            ),
            ReportResponseModel(
              section: 'Macroscopic',
              question: 'specimenDescription',
              answer: 'D',
              order: 1,
            ),
          ],
        ),
      );
      expect(pdf.blocks.skip(3).map((b) => b.sectionKey), [
        'Macroscopic',
        'Microscopic',
        'Ancillary',
        'Unlisted',
      ]);
    });

    test('carries the translation approver and language', () {
      final pdf = build(
        translation: const ReportTextApprovedModel(
          sourceSha256: 'contenthash',
          approvedText: {'diagnosis': 'Translated.'},
          approverName: 'Path One',
          language: 'sw',
        ),
      );
      expect(pdf.translation, {'diagnosis': 'Translated.'});
      expect(pdf.translationApproverName, 'Path One');
      expect(pdf.translationLanguage, 'sw');
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

    test('reads a lowercase or unknown role as the patient', () {
      expect(
        () => build(viewerRole: 'patient', viewerUid: 'patient-1'),
        throwsA(AppError.permissionDenied),
      );
      expect(
        () => build(viewerRole: 'nurse', viewerUid: 'stranger'),
        throwsA(AppError.permissionDenied),
      );
      final pdf = build(
        viewerRole: 'patient',
        viewerUid: 'patient-1',
        released: true,
      );
      expect(pdf.viewerRole, 'patient');
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

  group('PdfSubject.ageFromDateOfBirth', () {
    test('computes years and months', () {
      expect(
        PdfSubject.ageFromDateOfBirth(
          '1990-01-15T00:00:00.000Z',
          DateTime.utc(2026, 11),
        ),
        (years: 36, months: 9),
      );
    });

    test('counts a birthday not yet reached this year', () {
      expect(
        PdfSubject.ageFromDateOfBirth(
          '1990-12-15T00:00:00.000Z',
          DateTime.utc(2026, 11, 1, 12),
        ),
        (years: 35, months: 10),
      );
    });

    test('reads an unknown date as -1', () {
      expect(PdfSubject.ageFromDateOfBirth('', now), (years: -1, months: -1));
      expect(PdfSubject.ageFromDateOfBirth('not-a-date', now), (
        years: -1,
        months: -1,
      ));
    });

    test('reads a future date as -1', () {
      expect(
        PdfSubject.ageFromDateOfBirth(
          '2027-01-15T00:00:00.000Z',
          DateTime.utc(2026, 11, 1, 12),
        ),
        (years: -1, months: -1),
      );
    });
  });
}
