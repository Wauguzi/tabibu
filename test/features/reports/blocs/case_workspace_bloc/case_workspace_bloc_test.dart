import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_draft_model.dart';
import 'package:tabibu/features/preread/data/models/preread_finding_model.dart';
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

class _MockCaseRemote extends Mock implements CaseFirebase {}

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
  draft: const PrereadDraftModel(
    impression: 'Plasmodium falciparum trophozoites',
    findings: [
      PrereadFindingModel(text: 'Ring forms in RBCs'),
      PrereadFindingModel(text: 'No gametocytes seen'),
    ],
  ),
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
  setUpAll(() {
    registerFallbackValue(Role.pathologist);
    registerFallbackValue(<String, dynamic>{});
  });

  late _MockReports reports;
  late _MockRemote remote;
  late _MockCases cases;
  late _MockInternet internet;
  late _MockCaseRemote caseRemote;

  CaseWorkspaceBloc build() => CaseWorkspaceBloc(
    reports: reports,
    remote: remote,
    cases: cases,
    caseRemote: caseRemote,
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
    caseRemote = _MockCaseRemote();
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => cases.getCases(_me),
    ).thenAnswer((_) async => [CaseModel.empty().copyWith(uid: _case)]);
  });

  group('a case the pathologist is asked to take', () {
    final asked = CaseModel.empty().copyWith(
      uid: _case,
      currentStage: 'PathologistRequested',
      requestedPathologistUid: _me,
    );
    const open = CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me);

    void noReads() {
      verifyNever(
        () => remote.startReport(
          caseUid: any(named: 'caseUid'),
          kind: any(named: 'kind'),
        ),
      );
      verifyNever(
        () => reports.syncDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
        ),
      );
    }

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'opens on the request alone: no report is started, no draft read',
      setUp: () =>
          when(() => cases.getCases(_me)).thenAnswer((_) async => [asked]),
      build: build,
      act: (bloc) => bloc.add(open),
      expect: () => [
        isA<CaseWorkspaceLoadInProgress>(),
        isA<CaseWorkspaceLoadSuccess>().having(
          (s) => s.caseModel?.requestedPathologistUid,
          'requested',
          _me,
        ),
      ],
      verify: (_) => noReads(),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a case missing from the phone is fetched before deciding',
      setUp: () {
        when(() => cases.getCases(_me)).thenAnswer((_) async => []);
        when(() => cases.syncCases(_me)).thenAnswer((_) async => [asked]);
      },
      build: build,
      act: (bloc) => bloc.add(open),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceLoadSuccess>());
        expect(bloc.state.caseModel?.uid, _case);
        noReads();
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      "asked of someone else, it is not this pathologist's request",
      setUp: () {
        when(() => cases.getCases(_me)).thenAnswer(
          (_) async => [asked.copyWith(requestedPathologistUid: 'other')],
        );
        when(
          () => reports.syncDraft(caseUid: _case, pathologistUid: _me),
        ).thenAnswer((_) async => null);
        when(
          () => remote.startReport(caseUid: _case, kind: 'Initial'),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      act: (bloc) => bloc.add(open),
      verify: (_) => verify(
        () => remote.startReport(caseUid: _case, kind: 'Initial'),
      ).called(1),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'accepting sends it, refreshes the cases, then opens the workspace',
      setUp: () {
        when(() => cases.getCases(_me)).thenAnswer((_) async => [asked]);
        when(() => cases.syncCases(_me)).thenAnswer((_) async => [asked]);
        when(
          () => caseRemote.acceptCase(caseUid: _case),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: asked,
      ),
      act: (bloc) => bloc.add(const CaseRequestAccepted()),
      verify: (_) {
        verify(() => caseRemote.acceptCase(caseUid: _case)).called(1);
        verify(() => cases.syncCases(_me)).called(greaterThanOrEqualTo(1));
      },
      expect: () => [
        isA<CaseWorkspaceWriteInProgress>(),
        isA<CaseWorkspaceLoadInProgress>(),
        isA<CaseWorkspaceLoadSuccess>(),
      ],
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a refused accept fails and opens nothing',
      setUp: () => when(
        () => caseRemote.acceptCase(caseUid: _case),
      ).thenThrow(AppError.permissionDenied),
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: asked,
      ),
      act: (bloc) => bloc.add(const CaseRequestAccepted()),
      expect: () => [
        isA<CaseWorkspaceWriteInProgress>(),
        isA<CaseWorkspaceWriteFailure>().having(
          (s) => s.error,
          'error',
          AppError.permissionDenied,
        ),
      ],
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'declining sends the trimmed reason and finishes',
      setUp: () {
        when(() => cases.syncCases(_me)).thenAnswer((_) async => [asked]);
        when(
          () => caseRemote.rejectCase(caseUid: _case, reason: 'On leave'),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: asked,
      ),
      act: (bloc) =>
          bloc.add(const CaseRequestDeclined(reason: '  On leave  ')),
      expect: () => [
        isA<CaseWorkspaceWriteInProgress>(),
        isA<CaseRequestDeclineSuccess>(),
      ],
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'an empty or over-long reason is refused before anything is sent',
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: asked,
      ),
      act: (bloc) => bloc
        ..add(const CaseRequestDeclined(reason: '   '))
        ..add(CaseRequestDeclined(reason: 'x' * 501)),
      // Both are the same refusal, so the state changes once.
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) => verifyNever(
        () => caseRemote.rejectCase(
          caseUid: any(named: 'caseUid'),
          reason: any(named: 'reason'),
        ),
      ),
    );
  });

  group('an accepted case with no sample recorded', () {
    final accepted = CaseModel.empty().copyWith(
      uid: _case,
      currentStage: 'PrereadReady',
      pathologistUid: _me,
    );
    const open = CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me);

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'opens on the case alone: no report is started',
      setUp: () =>
          when(() => cases.getCases(_me)).thenAnswer((_) async => [accepted]),
      build: build,
      act: (bloc) => bloc.add(open),
      expect: () => [
        isA<CaseWorkspaceLoadInProgress>(),
        isA<CaseWorkspaceLoadSuccess>().having(
          (s) => s.caseModel?.awaitsSample,
          'awaits the sample',
          isTrue,
        ),
      ],
      verify: (_) => verifyNever(
        () => remote.startReport(
          caseUid: any(named: 'caseUid'),
          kind: any(named: 'kind'),
        ),
      ),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'once the accession is recorded the workspace opens as it always does',
      setUp: () {
        when(() => cases.getCases(_me)).thenAnswer((_) async => [accepted]);
        when(() => cases.syncCases(_me)).thenAnswer((_) async => [accepted]);
        when(
          () => caseRemote.recordSampleReceived(
            caseUid: _case,
            labAccessionNo: 'LAB-AO-03112026-005',
          ),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: accepted,
      ),
      act: (bloc) => bloc.add(
        const CaseSampleReceived(labAccessionNo: ' LAB-AO-03112026-005 '),
      ),
      verify: (_) => verify(
        () => caseRemote.recordSampleReceived(
          caseUid: _case,
          labAccessionNo: 'LAB-AO-03112026-005',
        ),
      ).called(1),
      expect: () => [
        isA<CaseWorkspaceWriteInProgress>(),
        isA<CaseWorkspaceLoadInProgress>(),
        isA<CaseWorkspaceLoadSuccess>(),
      ],
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'an accession the lab could not use is refused before anything is sent',
      build: build,
      seed: () => CaseWorkspaceLoadSuccess(
        caseUid: _case,
        pathologistUid: _me,
        caseModel: accepted,
      ),
      act: (bloc) => bloc
        ..add(const CaseSampleReceived(labAccessionNo: ''))
        ..add(const CaseSampleReceived(labAccessionNo: 'has space')),
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) => verifyNever(
        () => caseRemote.recordSampleReceived(
          caseUid: any(named: 'caseUid'),
          labAccessionNo: any(named: 'labAccessionNo'),
        ),
      ),
    );
  });

  group('a pre-read nobody has scored yet', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a refused score read is no score: the workspace opens with the report '
      'locked',
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
        ).thenThrow(AppError.permissionDenied);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceLoadSuccess>());
        expect(bloc.state.score, isNull);
        expect(bloc.state.needsScore, isTrue);
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'any other score failure still fails the load',
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
        ).thenThrow(AppError.unknown);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) => expect(bloc.state, isA<CaseWorkspaceLoadFailure>()),
    );
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

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a signed case loads the report and never starts one',
      setUp: () {
        when(() => cases.getCases(_me)).thenAnswer(
          (_) async => [
            CaseModel.empty().copyWith(
              uid: _case,
              currentReportUid: 'r1',
              prereadRunUid: 'run1',
            ),
          ],
        );
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
        ).thenAnswer((_) async => _score);
        when(
          () => reports.syncReports(_me, role: Role.pathologist),
        ).thenAnswer((_) async => [_signed]);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        expect(bloc.state.signed, _signed);
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'offline, a signed case reads the cached report',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
        when(() => cases.getCases(_me)).thenAnswer(
          (_) async => [
            CaseModel.empty().copyWith(
              uid: _case,
              currentReportUid: 'r1',
              prereadRunUid: 'run1',
            ),
          ],
        );
        when(
          () => reports.getDraft(_case, _me),
        ).thenAnswer((_) async => _draft);
        when(
          () => reports.getPrereadScore(_case, 'run1', _me),
        ).thenAnswer((_) async => _score);
        when(
          () => reports.getReports(_me, role: Role.pathologist),
        ).thenAnswer((_) async => [_signed]);
      },
      build: build,
      act: (bloc) => bloc.add(
        const CaseWorkspaceOpened(caseUid: _case, pathologistUid: _me),
      ),
      verify: (bloc) {
        expect(bloc.state.offline, isTrue);
        expect(bloc.state.signed, _signed);
        verifyNever(() => reports.syncReports(any(), role: any(named: 'role')));
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
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
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => _draft.copyWith(
              diagnosis: 'Metastatic carcinoma',
              diagnosisStartedAt: _shown.toIso8601String(),
            ),
          ),
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'diagnosis': 'Metastatic carcinoma'}),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseDraftSaveSuccess>());
        expect(bloc.state.draft?.diagnosis, 'Metastatic carcinoma');
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'refuses a diagnosis while a score is still due (H-20)',
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'diagnosis': 'Metastatic carcinoma'}),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceWriteFailure>());
        expect(
          (bloc.state as CaseWorkspaceWriteFailure).error,
          AppError.invalidDecision,
        );
        verifyNever(
          () => reports.saveDraftFields(
            caseUid: any(named: 'caseUid'),
            pathologistUid: any(named: 'pathologistUid'),
            fields: any(named: 'fields'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'adds diagnosisStartedAt on the first non-empty diagnosis',
      setUp: () =>
          when(
            () => reports.saveDraftFields(
              caseUid: _case,
              pathologistUid: _me,
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => _draft.copyWith(
              diagnosis: 'First diagnosis',
              diagnosisStartedAt: _shown.toIso8601String(),
            ),
          ),
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'diagnosis': 'First diagnosis'}),
      ),
      verify: (_) {
        final fields =
            verify(
                  () => reports.saveDraftFields(
                    caseUid: _case,
                    pathologistUid: _me,
                    fields: captureAny(named: 'fields'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(fields['diagnosisStartedAt'], _shown.toIso8601String());
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'does not re-stamp diagnosisStartedAt on later diagnosis edits',
      setUp: () =>
          when(
            () => reports.saveDraftFields(
              caseUid: _case,
              pathologistUid: _me,
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => _draft.copyWith(
              diagnosis: 'Second diagnosis',
              diagnosisStartedAt: '2026-11-02T08:00:00.000Z',
            ),
          ),
      build: build,
      seed: () => loaded(
        score: _score,
        draft: _draft.copyWith(
          diagnosis: 'First diagnosis',
          diagnosisStartedAt: '2026-11-02T08:00:00.000Z',
        ),
      ),
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'diagnosis': 'Second diagnosis'}),
      ),
      verify: (_) {
        final fields =
            verify(
                  () => reports.saveDraftFields(
                    caseUid: _case,
                    pathologistUid: _me,
                    fields: captureAny(named: 'fields'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(fields.containsKey('diagnosisStartedAt'), isFalse);
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'comments may be edited before scoring',
      setUp: () => when(
        () => reports.saveDraftFields(
          caseUid: _case,
          pathologistUid: _me,
          fields: {'comments': 'Looking at tile 3'},
        ),
      ).thenAnswer((_) async => _draft.copyWith(comments: 'Looking at tile 3')),
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(
        const CaseDraftEdited(fields: {'comments': 'Looking at tile 3'}),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseDraftSaveSuccess>());
        expect(bloc.state.needsScore, isTrue);
        expect(bloc.state.draft?.comments, 'Looking at tile 3');
      },
    );
  });

  group('start from pre-read (H-20)', () {
    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'sends impression, findings, startedFromPreread and diagnosisStartedAt',
      setUp: () =>
          when(
            () => reports.saveDraftFields(
              caseUid: _case,
              pathologistUid: _me,
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => _draft.copyWith(
              diagnosis: _preread.draft.impression,
              comments: 'Ring forms in RBCs\nNo gametocytes seen',
              startedFromPreread: true,
              diagnosisStartedAt: _shown.toIso8601String(),
            ),
          ),
      build: build,
      seed: () => loaded(score: _score),
      act: (bloc) => bloc.add(const CaseDraftStartedFromPreread()),
      verify: (_) {
        final fields =
            verify(
                  () => reports.saveDraftFields(
                    caseUid: _case,
                    pathologistUid: _me,
                    fields: captureAny(named: 'fields'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(fields['diagnosis'], _preread.draft.impression);
        expect(fields['comments'], 'Ring forms in RBCs\nNo gametocytes seen');
        expect(fields['startedFromPreread'], isTrue);
        expect(fields['diagnosisStartedAt'], _shown.toIso8601String());
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'is a no-op when the pre-read is not ready',
      build: build,
      seed: () => loaded(
        score: _score,
        preread: _preread.copyWith(status: JobStatus.queued.value),
      ),
      act: (bloc) => bloc.add(const CaseDraftStartedFromPreread()),
      expect: () => <CaseWorkspaceState>[],
      verify: (_) => verifyNever(
        () => reports.saveDraftFields(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'is a no-op when the draft already started from the pre-read',
      build: build,
      seed: () => loaded(
        score: _score,
        draft: _draft.copyWith(startedFromPreread: true),
      ),
      act: (bloc) => bloc.add(const CaseDraftStartedFromPreread()),
      expect: () => <CaseWorkspaceState>[],
      verify: (_) => verifyNever(
        () => reports.saveDraftFields(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ),
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'is a no-op when the diagnosis is already set',
      build: build,
      seed: () => loaded(
        score: _score,
        draft: _draft.copyWith(diagnosis: 'Already written'),
      ),
      act: (bloc) => bloc.add(const CaseDraftStartedFromPreread()),
      expect: () => <CaseWorkspaceState>[],
      verify: (_) => verifyNever(
        () => reports.saveDraftFields(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ),
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

  group('revision (amendment / addendum)', () {
    final signedCase = CaseModel.empty().copyWith(
      uid: _case,
      pathologistUid: _me,
      currentStage: 'ReportSigned',
      currentReportUid: 'r1',
    );
    final signedReport = _signed.copyWith(pathologistUid: _me, version: 1);
    final amendmentDraft = _draft.copyWith(
      kind: 'Amendment',
      status: 'Editing',
      prereadRunUid: '',
      diagnosis: 'Metastatic carcinoma',
      amendmentReason: 'Typo in site',
      baseReportUid: 'r1',
      targetReportUid: 'r1',
    );

    CaseWorkspaceLoadSuccess signedSeed({
      CaseModel? caseModel,
      PathologyReportModel? signed,
      ReportDraftModel? draft,
    }) => CaseWorkspaceLoadSuccess(
      caseUid: _case,
      pathologistUid: _me,
      caseModel: caseModel ?? signedCase,
      draft: draft,
      signed: signed ?? signedReport,
      prereadShownAt: _shown.toIso8601String(),
    );

    void stubRevisionOpen(ReportDraftModel draft) {
      when(() => cases.getCases(_me)).thenAnswer((_) async => [signedCase]);
      when(
        () => reports.syncDraft(caseUid: _case, pathologistUid: _me),
      ).thenAnswer((_) async => draft);
      when(
        () => reports.syncReports(_me, role: Role.pathologist),
      ).thenAnswer((_) async => [signedReport]);
    }

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'amendment: starts the draft, saves the reason, reopens the workspace',
      setUp: () {
        when(
          () => remote.startReport(caseUid: _case, kind: 'Amendment'),
        ).thenAnswer((_) async => {'status': 'started'});
        when(
          () => reports.saveDraftFields(
            caseUid: _case,
            pathologistUid: _me,
            fields: {'amendmentReason': 'Typo in site'},
          ),
        ).thenAnswer((_) async => amendmentDraft);
        stubRevisionOpen(amendmentDraft);
      },
      build: build,
      seed: signedSeed,
      act: (bloc) => bloc.add(
        const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceLoadSuccess>());
        expect(bloc.state.draft?.kind, 'Amendment');
        expect(bloc.state.draft?.amendmentReason, 'Typo in site');
        expect(bloc.state.signed, signedReport);
        verify(
          () => remote.startReport(caseUid: _case, kind: 'Amendment'),
        ).called(1);
        verify(
          () => reports.saveDraftFields(
            caseUid: _case,
            pathologistUid: _me,
            fields: {'amendmentReason': 'Typo in site'},
          ),
        ).called(1);
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'addendum: starts the draft and saves the text',
      setUp: () {
        final addendumDraft = amendmentDraft.copyWith(
          kind: 'Addendum',
          amendmentReason: '',
          addendumText: 'Additional IHC pending.',
        );
        when(
          () => remote.startReport(caseUid: _case, kind: 'Addendum'),
        ).thenAnswer((_) async => {'status': 'started'});
        when(
          () => reports.saveDraftFields(
            caseUid: _case,
            pathologistUid: _me,
            fields: {'addendumText': 'Additional IHC pending.'},
          ),
        ).thenAnswer((_) async => addendumDraft);
        stubRevisionOpen(addendumDraft);
      },
      build: build,
      seed: signedSeed,
      act: (bloc) => bloc.add(
        const CaseRevisionStarted(
          kind: 'Addendum',
          text: 'Additional IHC pending.',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.draft?.kind, 'Addendum');
        expect(bloc.state.draft?.addendumText, 'Additional IHC pending.');
        verify(
          () => remote.startReport(caseUid: _case, kind: 'Addendum'),
        ).called(1);
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'empty reason is refused and never starts a report',
      build: build,
      seed: signedSeed,
      act: (bloc) =>
          bloc.add(const CaseRevisionStarted(kind: 'Amendment', text: '  ')),
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) {
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'reason over 500 characters is refused',
      build: build,
      seed: signedSeed,
      act: (bloc) =>
          bloc.add(CaseRevisionStarted(kind: 'Amendment', text: 'x' * 501)),
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) {
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'only the signer may revise',
      build: build,
      seed: () =>
          signedSeed(signed: signedReport.copyWith(pathologistUid: 'other')),
      act: (bloc) => bloc.add(
        const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
      ),
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) {
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a stage outside REVISION_STAGES is refused',
      build: build,
      seed: () => signedSeed(
        caseModel: signedCase.copyWith(currentStage: 'ReportInProgress'),
      ),
      act: (bloc) => bloc.add(
        const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
      ),
      expect: () => [isA<CaseWorkspaceWriteFailure>()],
      verify: (_) {
        verifyNever(
          () => remote.startReport(
            caseUid: any(named: 'caseUid'),
            kind: any(named: 'kind'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a failed startReport leaves the signed report untouched',
      setUp: () {
        when(
          () => remote.startReport(caseUid: _case, kind: 'Amendment'),
        ).thenThrow(AppError.serviceUnavailable);
      },
      build: build,
      seed: signedSeed,
      act: (bloc) => bloc.add(
        const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
      ),
      verify: (bloc) {
        expect(bloc.state, isA<CaseWorkspaceWriteFailure>());
        expect(bloc.state.signed, signedReport);
        expect(bloc.state.draft, isNull);
        verifyNever(
          () => reports.saveDraftFields(
            caseUid: any(named: 'caseUid'),
            pathologistUid: any(named: 'pathologistUid'),
            fields: any(named: 'fields'),
          ),
        );
      },
    );

    blocTest<CaseWorkspaceBloc, CaseWorkspaceState>(
      'a double tap starts one draft, not two',
      setUp: () {
        when(
          () => remote.startReport(caseUid: _case, kind: 'Amendment'),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return {'status': 'started'};
        });
        when(
          () => reports.saveDraftFields(
            caseUid: _case,
            pathologistUid: _me,
            fields: {'amendmentReason': 'Typo in site'},
          ),
        ).thenAnswer((_) async => amendmentDraft);
        stubRevisionOpen(amendmentDraft);
      },
      build: build,
      seed: signedSeed,
      act: (bloc) async {
        bloc
          ..add(
            const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
          )
          ..add(
            const CaseRevisionStarted(kind: 'Amendment', text: 'Typo in site'),
          );
      },
      verify: (_) {
        verify(
          () => remote.startReport(caseUid: _case, kind: 'Amendment'),
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
