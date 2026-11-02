import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';

class _MockReports extends Mock implements ReportCacheHelper {}

class _MockRemote extends Mock implements ReportFirebase {}

class _MockCases extends Mock implements CaseCacheHelper {}

class _MockInternet extends Mock implements InternetService {}

const _case = 'c1';
const _me = 'p1';
final _shown = DateTime.utc(2026, 11, 2, 9);

final ReportDraftModel _draft = ReportDraftModel.empty().copyWith(
  uid: _me,
  caseUid: _case,
  pathologistUid: _me,
  prereadRunUid: 'run1',
  status: 'Editing',
  lastUpdatedAt: '2026-11-02T09:00:00.000Z',
);
final PrereadModel _preread = PrereadModel.empty().copyWith(
  uid: 'run1',
  caseUid: _case,
  status: JobStatus.ready.value,
);
final PrereadScoreModel _score = PrereadScoreModel.empty().copyWith(
  uid: 'run1',
);
final PathologyReportModel _signed = PathologyReportModel.empty().copyWith(
  uid: 'r1',
  caseUid: _case,
  signedAt: '2026-11-02T10:00:00.000Z',
);

const _sign = CaseSignRequested(signaturePng: 'iVBORw0KGgo=', attested: true);

void main() {
  late _MockReports reports;
  late _MockRemote remote;
  late _MockCases cases;
  late _MockInternet internet;

  CaseWorkspaceBloc build() => CaseWorkspaceBloc(
    reports: reports,
    remote: remote,
    cases: cases,
    internet: internet,
    now: () => _shown,
  );

  CaseWorkspaceLoadSuccess loaded({
    ReportDraftModel? draft,
    PrereadModel? preread,
    PrereadScoreModel? score,
  }) => CaseWorkspaceLoadSuccess(
    caseUid: _case,
    pathologistUid: _me,
    draft: draft ?? _draft,
    preread: preread ?? _preread,
    score: score,
    prereadShownAt: _shown.toIso8601String(),
  );

  void neverSigned() => verifyNever(
    () => remote.signReport(
      caseUid: any(named: 'caseUid'),
      signaturePng: any(named: 'signaturePng'),
      draftLastUpdatedAt: any(named: 'draftLastUpdatedAt'),
    ),
  );

  setUp(() {
    reports = _MockReports();
    remote = _MockRemote();
    cases = _MockCases();
    internet = _MockInternet();
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => cases.getCases(_me),
    ).thenAnswer((_) async => [CaseModel.empty().copyWith(uid: _case)]);
  });

  group('open', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'loads the draft, the pre-read and a missing score, which is then due',
      setUp: () {
        when(
          () => reports.syncDraft(caseUid: _case, pathologistUid: _me),
        ).thenAnswer((_) async => _draft);
        when(
          () => remote.fetchPreread(caseUid: _case, runUid: 'run1'),
        ).thenAnswer((_) async => _preread);
        when(
          () => reports.syncPrereadScore(
            caseUid: _case,
            runUid: 'run1',
            pathologistUid: _me,
          ),
        ).thenAnswer((_) async => null);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceLoadSuccess>());
        expect(bloc.state.needsScore, isTrue);
        expect(bloc.state.prereadShownAt, _shown.toIso8601String());
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'with no draft online, starts the report then reads it',
      setUp: () {
        var calls = 0;
        when(
          () => reports.syncDraft(caseUid: _case, pathologistUid: _me),
        ).thenAnswer((_) async => calls++ == 0 ? null : _draft);
        when(
          () => remote.startReport(caseUid: _case, kind: 'Initial'),
        ).thenAnswer((_) async => {'status': 'ok'});
        when(
          () => remote.fetchPreread(caseUid: _case, runUid: 'run1'),
        ).thenAnswer((_) async => _preread);
        when(
          () => reports.syncPrereadScore(
            caseUid: _case,
            runUid: 'run1',
            pathologistUid: _me,
          ),
        ).thenAnswer((_) async => _score);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        verify(
          () => remote.startReport(caseUid: _case, kind: 'Initial'),
        ).called(1);
        expect(bloc.state.draft, _draft);
        expect(bloc.state.needsScore, isFalse);
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'offline reads the saved draft, starts nothing and reads no pre-read',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
        when(
          () => reports.getDraft(_case, _me),
        ).thenAnswer((_) async => _draft);
        when(
          () => reports.getPrereadScore(_case, 'run1', _me),
        ).thenAnswer((_) async => null);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        expect(bloc.state.offline, isTrue);
        expect(bloc.state.preread, isNull);
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
        verifyNever(
          () => remote.fetchPreread(
            caseUid: any(named: 'caseUid'),
            runUid: any(named: 'runUid'),
          ),
        );
      },
    );
  });

  group('edit', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'saves on the phone and shows the saved draft',
      setUp: () =>
          when(
            () => reports.saveDraftFields(
              caseUid: _case,
              pathologistUid: _me,
              fields: {'diagnosis': 'Metastatic carcinoma'},
            ),
          ).thenAnswer(
            (_) async => _draft.copyWith(diagnosis: 'Metastatic carcinoma'),
          ),
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'diagnosis': 'Metastatic carcinoma'}),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseDraftSaveSuccess>());
        expect(bloc.state.draft?.diagnosis, 'Metastatic carcinoma');
      },
    );
  });

  group('score', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'an overall outside 1 to 5 is refused without a call',
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(
        const CasePrereadScored(
          overall: 6,
          findingsVerdict: 'Agree',
          impressionVerdict: 'Agree',
          urgencyVerdict: 'Agree',
          measurementsVerdict: 'Accepted',
          segmentationVerdict: 'Good',
        ),
      ),
      verify: (bloc) => expect(bloc.state, isA<CaseWorkspaceWriteFailure>()),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'sends the verdicts with when the pre-read was first shown',
      setUp: () {
        when(
          () => remote.scorePreread(
            caseUid: any(named: 'caseUid'),
            runUid: any(named: 'runUid'),
            overall: any(named: 'overall'),
            findingsVerdict: any(named: 'findingsVerdict'),
            impressionVerdict: any(named: 'impressionVerdict'),
            measurementsVerdict: any(named: 'measurementsVerdict'),
            segmentationVerdict: any(named: 'segmentationVerdict'),
            urgencyVerdict: any(named: 'urgencyVerdict'),
            prereadShownAt: any(named: 'prereadShownAt'),
            comment: any(named: 'comment'),
          ),
        ).thenAnswer((_) async => {'status': 'ok'});
        when(
          () => reports.syncPrereadScore(
            caseUid: _case,
            runUid: 'run1',
            pathologistUid: _me,
          ),
        ).thenAnswer((_) async => _score);
      },
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(
        const CasePrereadScored(
          overall: 4,
          findingsVerdict: 'PartlyAgree',
          impressionVerdict: 'Agree',
          urgencyVerdict: 'Agree',
          measurementsVerdict: 'Corrected',
          segmentationVerdict: 'Acceptable',
          comment: '  One tile was stroma.  ',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseScoreSuccess>());
        expect(bloc.state.needsScore, isFalse);
        verify(
          () => remote.scorePreread(
            caseUid: _case,
            runUid: 'run1',
            overall: 4,
            findingsVerdict: 'PartlyAgree',
            impressionVerdict: 'Agree',
            measurementsVerdict: 'Corrected',
            segmentationVerdict: 'Acceptable',
            urgencyVerdict: 'Agree',
            prereadShownAt: _shown.toIso8601String(),
            comment: 'One tile was stroma.',
          ),
        ).called(1);
      },
    );
  });

  group('sign (H-3, H-16, H-17)', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'without the attestation, nothing is sent',
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(
        const CaseSignRequested(signaturePng: 'iVBORw0KGgo=', attested: false),
      ),
      verify: (_) => neverSigned(),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'without a signature, nothing is sent',
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) =>
          bloc.add(const CaseSignRequested(signaturePng: '', attested: true)),
      verify: (_) => neverSigned(),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a pre-read that is due a score blocks signing',
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(_sign),
      verify: (bloc) {
        expect(bloc.state.needsScore, isTrue);
        neverSigned();
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'offline, nothing is signed or queued',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(_sign),
      expect: () => [
        CaseWorkspaceWriteFailure(
          error: AppError.noInternet,
          caseUid: _case,
          pathologistUid: _me,
          draft: _draft,
          preread: _preread,
          score: _score,
          prereadShownAt: _shown.toIso8601String(),
        ),
      ],
      verify: (_) => neverSigned(),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'an edit that could not be sent first blocks signing',
      setUp: () {
        when(
          () => reports.replayPendingDraftEdits(_me),
        ).thenAnswer((_) async {});
        when(
          () => reports.hasUnsyncedDraftEdits(_case),
        ).thenAnswer((_) async => true);
      },
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(_sign),
      verify: (_) => neverSigned(),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'signs the draft the server holds, then shows the signed report',
      setUp: () {
        when(
          () => reports.replayPendingDraftEdits(_me),
        ).thenAnswer((_) async {});
        when(
          () => reports.hasUnsyncedDraftEdits(_case),
        ).thenAnswer((_) async => false);
        when(
          () => reports.syncDraft(caseUid: _case, pathologistUid: _me),
        ).thenAnswer(
          (_) async =>
              _draft.copyWith(lastUpdatedAt: '2026-11-02T09:30:00.000Z'),
        );
        when(
          () => remote.signReport(
            caseUid: any(named: 'caseUid'),
            signaturePng: any(named: 'signaturePng'),
            draftLastUpdatedAt: any(named: 'draftLastUpdatedAt'),
          ),
        ).thenAnswer((_) async => {'status': 'ok'});
        when(
          () => reports.syncReports(_me, role: Role.pathologist),
        ).thenAnswer((_) async => [_signed]);
      },
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(_sign),
      verify: (bloc) {
        expect(bloc.state, isA<CaseSignSuccess>());
        expect(bloc.state.signed, _signed);
        verify(
          () => remote.signReport(
            caseUid: _case,
            signaturePng: 'iVBORw0KGgo=',
            draftLastUpdatedAt: '2026-11-02T09:30:00.000Z',
          ),
        ).called(1);
      },
    );
  });

  blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
    'drops everything on reset',
    build: build,
    seed: () => loaded(score: _score),
    act: (bloc) => bloc.add(const CaseWorkspaceReset()),
    expect: () => [const CaseWorkspaceInitial()],
  );
}
