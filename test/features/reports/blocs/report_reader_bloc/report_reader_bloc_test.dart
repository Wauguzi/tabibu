import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';

class _MockReports extends Mock implements ReportCacheHelper {}

class _MockRemote extends Mock implements ReportFirebase {}

class _MockInternet extends Mock implements InternetService {}

const _case = 'c1';

PathologyReportModel _report({bool released = false}) =>
    PathologyReportModel.empty().copyWith(
      uid: 'v1',
      caseUid: _case,
      version: 1,
      status: ReportStatus.signed.value,
      releasedToPatient: released,
    );

final ReportTextModel _draft = ReportTextModel.empty().copyWith(
  uid: 'v1_Explanation_en',
  status: 'Ready',
  machineText: const {'found': 'Cancer cells in one node.'},
);
final ReportTextApprovedModel _approved = ReportTextApprovedModel.empty()
    .copyWith(uid: 'v1_Explanation_en');

void main() {
  late _MockReports reports;
  late _MockRemote remote;
  late _MockInternet internet;

  ReportReaderBloc build() => ReportReaderBloc(
    reports: reports,
    remote: remote,
    internet: internet,
    // No real waiting between polls.
    delay: (_) async {},
  );

  void neverDecided() => verifyNever(
    () => remote.approveReportText(
      caseUid: any(named: 'caseUid'),
      textUid: any(named: 'textUid'),
      decision: any(named: 'decision'),
      approvedText: any(named: 'approvedText'),
    ),
  );

  setUp(() {
    reports = _MockReports();
    remote = _MockRemote();
    internet = _MockInternet();
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => reports.syncApprovedText(
        caseUid: any(named: 'caseUid'),
        textUid: any(named: 'textUid'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => remote.fetchReportText(
        caseUid: any(named: 'caseUid'),
        textUid: any(named: 'textUid'),
      ),
    ).thenAnswer((_) async => null);
  });

  group('open', () {
    blocTest<ReportReaderBloc, ReportReaderState>(
      'an unreleased report reads no explanation at all',
      setUp: () => when(
        () => reports.syncReports('u1', role: Role.patient),
      ).thenAnswer((_) async => [_report()]),
      build: build,
      act: (bloc) => bloc.add(
        const ReportReaderOpened(uid: 'u1', role: Role.patient, caseUid: _case),
      ),
      verify: (bloc) {
        expect(bloc.state.report, _report());
        verifyNever(
          () => reports.syncApprovedText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        );
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a patient reads approved explanations only, never a draft (H-9)',
      setUp: () {
        when(
          () => reports.syncReports('u1', role: Role.patient),
        ).thenAnswer((_) async => [_report(released: true)]);
        when(
          () => reports.syncApprovedText(
            caseUid: _case,
            textUid: 'v1_Explanation_en',
          ),
        ).thenAnswer((_) async => _approved);
      },
      build: build,
      act: (bloc) => bloc.add(
        const ReportReaderOpened(uid: 'u1', role: Role.patient, caseUid: _case),
      ),
      verify: (bloc) {
        expect(bloc.state.approved, {'en': _approved});
        expect(bloc.state.explanations, isEmpty);
        verifyNever(
          () => remote.fetchReportText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        );
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a doctor reads the drafts awaiting approval, by language',
      setUp: () {
        when(
          () => reports.syncReports('d1', role: Role.doctor),
        ).thenAnswer((_) async => [_report(released: true)]);
        when(
          () => remote.fetchReportText(
            caseUid: _case,
            textUid: 'v1_Explanation_en',
          ),
        ).thenAnswer((_) async => _draft);
      },
      build: build,
      act: (bloc) => bloc.add(
        const ReportReaderOpened(uid: 'd1', role: Role.doctor, caseUid: _case),
      ),
      verify: (bloc) => expect(bloc.state.explanations, {'en': _draft}),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a draft still queued has nothing to read, so it is left out',
      setUp: () {
        when(
          () => reports.syncReports('d1', role: Role.doctor),
        ).thenAnswer((_) async => [_report(released: true)]);
        when(
          () => remote.fetchReportText(
            caseUid: _case,
            textUid: 'v1_Explanation_en',
          ),
        ).thenAnswer((_) async => _draft.copyWith(status: 'Queued'));
      },
      build: build,
      act: (bloc) => bloc.add(
        const ReportReaderOpened(uid: 'd1', role: Role.doctor, caseUid: _case),
      ),
      verify: (bloc) => expect(bloc.state.explanations, isEmpty),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'offline, approved texts come from the phone and no draft is read',
      setUp: () {
        when(
          () => reports.syncReports('d1', role: Role.doctor),
        ).thenThrow(AppError.noInternet);
        when(
          () => reports.getReports('d1', role: Role.doctor),
        ).thenAnswer((_) async => [_report(released: true)]);
        when(
          () => reports.getApprovedText(_case, 'v1_Explanation_en'),
        ).thenAnswer((_) async => _approved);
        when(
          () => reports.getApprovedText(_case, 'v1_Explanation_sw'),
        ).thenAnswer((_) async => null);
      },
      build: build,
      act: (bloc) => bloc.add(
        const ReportReaderOpened(uid: 'd1', role: Role.doctor, caseUid: _case),
      ),
      verify: (bloc) {
        expect(bloc.state.offline, isTrue);
        expect(bloc.state.approved, {'en': _approved});
        verifyNever(
          () => remote.fetchReportText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        );
      },
    );
  });

  group('mark discussed', () {
    ReportReaderLoadSuccess loaded(Role role) => ReportReaderLoadSuccess(
      uid: 'd1',
      role: role,
      caseUid: _case,
      report: _report(),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'releases the report',
      setUp: () => when(
        () => remote.markDiscussed(caseUid: _case, reportUid: 'v1'),
      ).thenAnswer((_) async => {'status': 'ok'}),
      build: build,
      seed: () => loaded(Role.doctor),
      act: (bloc) => bloc.add(const ReportDiscussedRequested()),
      verify: (bloc) {
        expect(bloc.state, isA<ReportDiscussedSuccess>());
        expect(bloc.state.report?.releasedToPatient, isTrue);
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'the drafts appear by themselves once the worker has written them',
      setUp: () {
        when(
          () => remote.markDiscussed(caseUid: _case, reportUid: 'v1'),
        ).thenAnswer((_) async => {'status': 'ok'});
        var reads = 0;
        when(
          () => remote.fetchReportText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        ).thenAnswer((invocation) async {
          reads++;
          final id = invocation.namedArguments[#textUid] as String;
          // The first round of reads finds both still queued, the second ready.
          if (reads <= 2) {
            return ReportTextModel.empty().copyWith(uid: id, status: 'Queued');
          }
          return ReportTextModel.empty().copyWith(
            uid: id,
            status: 'Ready',
            machineText: {'found': 'Text for $id'},
          );
        });
      },
      build: build,
      seed: () => loaded(Role.doctor),
      act: (bloc) => bloc.add(const ReportDiscussedRequested()),
      verify: (bloc) {
        expect(bloc.state, isA<ReportReaderLoadSuccess>());
        expect(bloc.state.explanations.keys, unorderedEquals(['en', 'sw']));
        expect(bloc.state.report?.releasedToPatient, isTrue);
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a draft that failed is never shown, and the looking stops',
      setUp: () {
        when(
          () => remote.markDiscussed(caseUid: _case, reportUid: 'v1'),
        ).thenAnswer((_) async => {'status': 'ok'});
        when(
          () => remote.fetchReportText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        ).thenAnswer(
          (invocation) async => ReportTextModel.empty().copyWith(
            uid: invocation.namedArguments[#textUid] as String,
            status: 'Failed',
            failureReason: 'NumberCheck',
          ),
        );
      },
      build: build,
      seed: () => loaded(Role.doctor),
      act: (bloc) => bloc.add(const ReportDiscussedRequested()),
      verify: (bloc) {
        expect(bloc.state, isA<ReportDiscussedSuccess>());
        expect(bloc.state.explanations, isEmpty);
        // Two languages, read once each: a failure ends the wait.
        verify(
          () => remote.fetchReportText(
            caseUid: any(named: 'caseUid'),
            textUid: any(named: 'textUid'),
          ),
        ).called(2);
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'offline, nothing is released or queued',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: () => loaded(Role.doctor),
      act: (bloc) => bloc.add(const ReportDiscussedRequested()),
      verify: (_) => verifyNever(
        () => remote.markDiscussed(
          caseUid: any(named: 'caseUid'),
          reportUid: any(named: 'reportUid'),
        ),
      ),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a second tap offline shows the failure again',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: () => loaded(Role.doctor),
      act: (bloc) async {
        bloc.add(const ReportDiscussedRequested());
        await pumpEventQueue();
        bloc.add(const ReportDiscussedRequested());
      },
      verify: (bloc) => expect(bloc.state, isA<ReportReaderWriteFailure>()),
      expect: () => [
        isA<ReportReaderWriteInProgress>(),
        isA<ReportReaderWriteFailure>(),
        isA<ReportReaderWriteInProgress>(),
        isA<ReportReaderWriteFailure>(),
      ],
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a patient cannot release',
      build: build,
      seed: () => loaded(Role.patient),
      act: (bloc) => bloc.add(const ReportDiscussedRequested()),
      verify: (bloc) {
        expect(bloc.state, isA<ReportReaderWriteFailure>());
        verifyNever(
          () => remote.markDiscussed(
            caseUid: any(named: 'caseUid'),
            reportUid: any(named: 'reportUid'),
          ),
        );
      },
    );
  });

  group('explanation decision (H-8)', () {
    ReportReaderLoadSuccess withDraft() => ReportReaderLoadSuccess(
      uid: 'd1',
      role: Role.doctor,
      caseUid: _case,
      report: _report(released: true),
      explanations: {'en': _draft},
    );

    void stubApprove() => when(
      () => remote.approveReportText(
        caseUid: any(named: 'caseUid'),
        textUid: any(named: 'textUid'),
        decision: any(named: 'decision'),
        approvedText: any(named: 'approvedText'),
      ),
    ).thenAnswer((_) async => {'status': 'ok'});

    blocTest<ReportReaderBloc, ReportReaderState>(
      'approve as is',
      setUp: stubApprove,
      build: build,
      seed: withDraft,
      act: (bloc) =>
          bloc.add(const ExplanationDecisionRequested(language: 'en')),
      verify: (bloc) {
        verify(
          () => remote.approveReportText(
            caseUid: _case,
            textUid: 'v1_Explanation_en',
            decision: 'Approve',
          ),
        ).called(1);
        expect(bloc.state.explanations, isEmpty);
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'an edit identical to the draft is an approval as is',
      setUp: stubApprove,
      build: build,
      seed: withDraft,
      act: (bloc) => bloc.add(
        const ExplanationDecisionRequested(
          language: 'en',
          editedText: {'found': 'Cancer cells in one node.'},
        ),
      ),
      verify: (_) => verify(
        () => remote.approveReportText(
          caseUid: _case,
          textUid: 'v1_Explanation_en',
          decision: 'Approve',
        ),
      ).called(1),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'a real edit is approved with the edited text',
      setUp: stubApprove,
      build: build,
      seed: withDraft,
      act: (bloc) => bloc.add(
        const ExplanationDecisionRequested(
          language: 'en',
          editedText: {'found': 'Cancer cells were found in one lymph node.'},
        ),
      ),
      verify: (_) => verify(
        () => remote.approveReportText(
          caseUid: _case,
          textUid: 'v1_Explanation_en',
          decision: 'ApproveEdited',
          approvedText: {'found': 'Cancer cells were found in one lymph node.'},
        ),
      ).called(1),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'reject',
      setUp: stubApprove,
      build: build,
      seed: withDraft,
      act: (bloc) => bloc.add(
        const ExplanationDecisionRequested(language: 'en', reject: true),
      ),
      verify: (bloc) {
        verify(
          () => remote.approveReportText(
            caseUid: _case,
            textUid: 'v1_Explanation_en',
            decision: 'Reject',
          ),
        ).called(1);
        expect(bloc.state.approved, isEmpty);
      },
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'no draft in that language, no decision',
      build: build,
      seed: withDraft,
      act: (bloc) =>
          bloc.add(const ExplanationDecisionRequested(language: 'sw')),
      verify: (_) => neverDecided(),
    );

    blocTest<ReportReaderBloc, ReportReaderState>(
      'offline, nothing is decided or queued',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: withDraft,
      act: (bloc) =>
          bloc.add(const ExplanationDecisionRequested(language: 'en')),
      verify: (_) => neverDecided(),
    );
  });

  blocTest<ReportReaderBloc, ReportReaderState>(
    'drops everything on reset',
    build: build,
    seed: () => ReportReaderLoadSuccess(caseUid: _case, report: _report()),
    act: (bloc) => bloc.add(const ReportReaderReset()),
    expect: () => [const ReportReaderInitial()],
  );
}
