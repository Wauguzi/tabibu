import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/presentation/case_history_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _sw = lookupAppLocalizations(const Locale('sw'));

// Noon in Nairobi on 29 Oct 2026.
final _noon = DateTime.utc(2026, 10, 29, 9);

CaseLogEntryModel _entry({
  String actionType = '',
  String toStage = 'OrderCreated',
  String createdAt = '2026-10-29T08:30:00Z',
  String createdByUid = 'doc-1',
  String actorRole = 'Doctor',
}) => CaseLogEntryModel(
  actionType: actionType,
  toStage: toStage,
  createdAt: createdAt,
  createdByUid: createdByUid,
  actorRole: actorRole,
);

CaseModel _case() => const CaseModel().copyWith(
  uid: 'case-1',
  tests: const [
    OrderedTestModel(name: 'Histology'),
    OrderedTestModel(name: 'Cytology'),
  ],
);

PractitionerModel _ali() => PractitionerModel.empty().copyWith(
  uid: 'doc-9',
  firstName: 'Ali',
  lastName: 'Hassan',
);

void main() {
  group('CaseHistoryScreen', () {
    late FeatureBlocs blocs;

    setUp(() => blocs = FeatureBlocs());

    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    Future<void> pumpHistory(
      WidgetTester tester, {
      List<CaseLogEntryModel> entries = const [],
      CaseModel? caseModel,
      List<PractitionerModel> directory = const [],
      Role role = .doctor,
      Locale? locale,
      ThemeMode themeMode = ThemeMode.light,
      double textScale = 1,
    }) async {
      tallView(tester);
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(cases: [?caseModel], logs: {'case-1': entries}),
      );
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: directory));
      final auth = MockAuthBloc();
      when(
        () => auth.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      await tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: auth),
              ...blocs.providers,
            ],
            child: CaseHistoryScreen(caseUid: 'case-1', role: role, now: _noon),
          ),
        ),
        locale: locale,
        themeMode: themeMode,
      );
      await tester.pump();
    }

    testWidgets('groups entries under day headers, newest first', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        caseModel: _case(),
        directory: [_ali()],
        entries: [
          _entry(toStage: 'SampleReceived', createdAt: '2026-10-29T07:30:00Z'),
          _entry(actionType: 'Share', createdByUid: 'doc-9'),
          _entry(createdAt: '2026-10-28T15:00:00Z'),
          _entry(toStage: 'ReportSigned', createdAt: '2026-10-24T10:00:00Z'),
        ],
      );

      expect(find.text(_en.accessLogTitle), findsOneWidget);
      expect(find.text(_en.accessLogBody), findsOneWidget);
      expect(find.text(_en.accessLogToday), findsOneWidget);
      expect(find.text(_en.accessLogYesterday), findsOneWidget);
      expect(find.text('24 Oct 2026'), findsOneWidget);
      // Newest first within the day.
      final today = find.text(_en.accessLogToday);
      expect(
        tester.getTopLeft(find.text(_en.accessLogReceived)).dy,
        greaterThan(tester.getTopLeft(today).dy),
      );
      expect(find.text('11:30 AM'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
    });

    testWidgets('every action and stage with a line reads in words', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        caseModel: _case(),
        directory: [_ali()],
        entries: [
          _entry(),
          _entry(toStage: 'SampleReceived'),
          _entry(toStage: 'ReportSigned'),
          _entry(toStage: 'Cancelled'),
          _entry(actionType: 'Share', createdByUid: 'doc-9'),
          _entry(actionType: 'Reject'),
          _entry(actionType: 'Expire'),
          _entry(actionType: 'Reassign'),
          _entry(actionType: 'Cancel'),
          _entry(actionType: 'Revise'),
          _entry(actionType: 'Receive'),
          _entry(actionType: 'AddSlides'),
        ],
      );

      expect(
        find.text(_en.accessLogOrdered('Histology, Cytology')),
        findsOneWidget,
      );
      // Received twice: the stage and the action.
      expect(find.text(_en.accessLogReceived), findsNWidgets(2));
      expect(find.text(_en.accessLogSigned), findsOneWidget);
      // Cancelled twice: the stage and the action.
      expect(find.text(_en.accessLogCancelled), findsNWidgets(2));
      expect(find.text(_en.accessLogShared('Ali Hassan')), findsOneWidget);
      expect(find.text(_en.accessLogRejected), findsOneWidget);
      expect(find.text(_en.accessLogExpired), findsOneWidget);
      expect(find.text(_en.accessLogReassigned), findsOneWidget);
      expect(find.text(_en.accessLogRevised), findsOneWidget);
      expect(find.text(_en.accessLogSlidesAdded), findsOneWidget);
    });

    testWidgets('a share nobody knows reads as the role', (tester) async {
      await pumpHistory(
        tester,
        caseModel: _case(),
        entries: [
          _entry(actionType: 'Share', createdByUid: 'ghost'),
          _entry(
            actionType: 'Share',
            createdByUid: 'ghost-2',
            actorRole: 'Pathologist',
          ),
        ],
      );

      expect(find.text(_en.accessLogShared(_en.roleDoctor)), findsOneWidget);
      expect(
        find.text(_en.accessLogShared(_en.rolePathologist)),
        findsOneWidget,
      );
    });

    testWidgets('viewer removals, open-less stages and bad dates stay out', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        caseModel: _case(),
        entries: [
          _entry(actionType: 'RemoveViewer'),
          _entry(toStage: 'PathologistRequested'),
          _entry(toStage: 'PrereadReady'),
          _entry(toStage: 'DiscussionBooked'),
          _entry(toStage: 'Completed'),
          _entry(createdAt: 'not-a-date'),
          _entry(toStage: 'SampleReceived'),
        ],
      );

      expect(find.text(_en.accessLogReceived), findsOneWidget);
      expect(find.textContaining('no longer see'), findsNothing);
      expect(find.text(_en.accessLogEmpty), findsNothing);
    });

    testWidgets('an order without its case leaves the ordered line out', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        entries: [
          _entry(),
          _entry(toStage: 'SampleReceived'),
        ],
      );

      expect(find.textContaining('Ordered'), findsNothing);
      expect(find.text(_en.accessLogReceived), findsOneWidget);
    });

    testWidgets('an empty log says so', (tester) async {
      await pumpHistory(tester);
      expect(find.text(_en.accessLogEmpty), findsOneWidget);
    });

    testWidgets('loading and failure', (tester) async {
      Future<void> pumpState(CasesState state) async {
        tallView(tester);
        when(() => blocs.cases.state).thenReturn(state);
        final auth = MockAuthBloc();
        when(
          () => auth.state,
        ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
        await tester.pumpApp(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: auth),
              ...blocs.providers,
            ],
            child: CaseHistoryScreen(
              key: ValueKey(state.runtimeType),
              caseUid: 'case-1',
              role: .doctor,
            ),
          ),
        );
        await tester.pump();
      }

      await pumpState(const CasesLoadInProgress());
      expect(find.byType(LoadingView), findsOneWidget);

      await pumpState(const CasesLoadFailure(error: AppError.unknown));
      expect(find.text(_en.errorUnknown), findsOneWidget);
    });

    testWidgets('opens the log for its case and role', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/result/case-1/history',
        blocs: blocs,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => blocs.cases.add(
          const CaseLogRequested(caseUid: 'case-1', role: .patient),
        ),
      ).called(1);
      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      await pumpHistory(
        tester,
        caseModel: _case(),
        entries: [
          _entry(actionType: 'Share', createdByUid: 'doc-9'),
          _entry(createdAt: '2026-10-28T15:00:00Z'),
        ],
        locale: const Locale('sw'),
        themeMode: ThemeMode.dark,
        textScale: 1.3,
      );

      expect(find.text(_sw.accessLogTitle), findsOneWidget);
      expect(find.text(_sw.accessLogToday), findsOneWidget);
      expect(find.text(_sw.accessLogYesterday), findsOneWidget);
    });
  });
}
