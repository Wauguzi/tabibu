import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/services/report_pdf_builder.dart';
import 'package:tabibu/features/reports/presentation/report_download.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../data/models/pathology_report_model_test.dart' show reportJson;

class _MockPdf extends Mock implements ReportPdfBuilder {}

class _MockReports extends Mock implements ReportCacheHelper {}

class _MemoryLog extends LogOutput {
  final lines = <String>[];

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 11, 3, 12);
  final l10n = lookupAppLocalizations(const Locale('en'));
  final patient = PatientModel.empty().copyWith(
    uid: 'patient-1',
    firstName: 'Amina',
    lastName: 'Wanjiku',
    dateOfBirth: '1990-01-15T00:00:00.000Z',
    sex: 'Female',
    county: 'Nairobi',
    subCounty: 'Kibra',
  );
  const caseModel = CaseModel(
    uid: 'case-1',
    doctorName: 'Dr Doc',
    doctorFacilityName: 'Clinic One',
    clinicalNotes: 'Notes',
  );

  late _MockPdf pdf;
  late _MockReports reports;
  late _MemoryLog logOutput;
  late Directory tempDir;
  late List<ShareParams> shared;
  late ReportDownload download;

  PathologyReportModel signed({bool released = true}) =>
      PathologyReportModel.fromJson(reportJson()).copyWith(
        releasedToPatient: released,
        releasedAt: released ? '2026-11-01T12:00:00.000Z' : '',
      );

  setUpAll(() {
    registerFallbackValue(const ReportPdfInput());
    registerFallbackValue(l10n);
  });

  setUp(() async {
    pdf = _MockPdf();
    reports = _MockReports();
    logOutput = _MemoryLog();
    tempDir = await Directory.systemTemp.createTemp('report_download_');
    shared = <ShareParams>[];
    when(
      () => pdf.build(any(), any()),
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
    when(
      () => reports.syncApprovedText(
        caseUid: any(named: 'caseUid'),
        textUid: any(named: 'textUid'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => reports.getApprovedText(any(), any()),
    ).thenAnswer((_) async => null);
    download = ReportDownload(
      pdfBuilder: pdf,
      reports: reports,
      temporaryDirectory: () async => tempDir,
      share: (params) async {
        shared.add(params);
        return const ShareResult('', ShareResultStatus.success);
      },
      logger: Logger(
        level: Level.warning,
        output: logOutput,
        printer: SimplePrinter(colors: false),
      ),
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('ReportDownload', () {
    test('refuses an unreleased report and never shares', () async {
      await expectLater(
        () => download.sharePatientReport(
          report: signed(released: false),
          caseModel: caseModel,
          patient: patient,
          language: 'en',
          l10n: l10n,
          now: now,
        ),
        throwsA(AppError.permissionDenied),
      );
      expect(shared, isEmpty);
      verifyNever(() => pdf.build(any(), any()));
    });

    test('refuses a draft (non-signed) report and never shares', () async {
      await expectLater(
        () => download.sharePatientReport(
          report: signed().copyWith(status: 'Draft'),
          caseModel: caseModel,
          patient: patient,
          language: 'en',
          l10n: l10n,
          now: now,
        ),
        throwsA(AppError.dataNotFound),
      );
      expect(shared, isEmpty);
      verifyNever(() => pdf.build(any(), any()));
    });

    test('omits a translation whose source hash does not match', () async {
      when(
        () => reports.syncApprovedText(
          caseUid: any(named: 'caseUid'),
          textUid: any(named: 'textUid'),
        ),
      ).thenAnswer(
        (_) async => const ReportTextApprovedModel(
          sourceSha256: 'stale-hash',
          approvedText: {'diagnosis': 'Should not appear'},
          language: 'en',
        ),
      );

      await download.sharePatientReport(
        report: signed(),
        caseModel: caseModel,
        patient: patient,
        language: 'en',
        l10n: l10n,
        now: now,
      );

      final input =
          verify(() => pdf.build(captureAny(), any())).captured.single
              as ReportPdfInput;
      expect(input.translation, isEmpty);
      expect(shared, hasLength(1));
    });

    test('shares a released report and deletes the temp file', () async {
      await download.sharePatientReport(
        report: signed(),
        caseModel: caseModel,
        patient: patient,
        language: 'en',
        l10n: l10n,
        now: now,
      );

      expect(shared, hasLength(1));
      expect(shared.single.files, isNotNull);
      expect(shared.single.files, isNotEmpty);
      final path = shared.single.files!.single.path;
      expect(File(path).existsSync(), isFalse);
      expect(tempDir.listSync(), isEmpty);
    });

    test(
      'refusal and failure log lines never carry a name or result',
      () async {
        final name = patient.fullName;
        const diagnosis = 'Benign';
        const comments = 'Clear margins.';

        await expectLater(
          () => download.sharePatientReport(
            report: signed(released: false),
            caseModel: caseModel,
            patient: patient,
            language: 'en',
            l10n: l10n,
            now: now,
          ),
          throwsA(AppError.permissionDenied),
        );

        when(() => pdf.build(any(), any())).thenThrow(Exception('disk'));
        await expectLater(
          () => download.sharePatientReport(
            report: signed(),
            caseModel: caseModel,
            patient: patient,
            language: 'en',
            l10n: l10n,
            now: now,
          ),
          throwsA(AppError.unknown),
        );

        final joined = logOutput.lines.join('\n');
        expect(joined.contains(name), isFalse);
        expect(joined.contains(diagnosis), isFalse);
        expect(joined.contains(comments), isFalse);
        expect(joined.contains('Amina'), isFalse);
        expect(joined.contains('Wanjiku'), isFalse);
      },
    );
  });
}
