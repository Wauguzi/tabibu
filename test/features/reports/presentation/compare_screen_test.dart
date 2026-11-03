import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_draft_model.dart';
import 'package:tabibu/features/preread/data/models/preread_finding_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/compare_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/diff_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

PractitionerSession _session() => PractitionerSession(
  doctor: RoleSessions.pathologist.doctor.copyWith(uid: 'path-1'),
  roles: RoleSessions.pathologist.roles,
);

PathologyReportModel _signed({String pathologistUid = 'path-1'}) =>
    PathologyReportModel(
      uid: 'rep-1',
      caseUid: 'case-1',
      orderNumber: 'ODR-AO-AW-02112026-001',
      pathologistUid: pathologistUid,
      diagnosis: 'Metastatic carcinoma in 1 of 1 sentinel lymph node.',
      comments: 'Sentinel lymph node with metastatic breast carcinoma.',
      signedAt: '2026-10-27T07:42:00Z',
    );

PrereadModel _preread() => const PrereadModel(
  draft: PrereadDraftModel(
    impression: 'Atypical cells, see comment.',
    findings: [
      PrereadFindingModel(text: 'One node with suspicious cells.'),
      PrereadFindingModel(text: 'Largest focus 2.6 mm.'),
    ],
  ),
);

CaseModel _case() => const CaseModel(
  uid: 'case-1',
  orderNumber: 'ODR-AO-AW-02112026-001',
  doctorName: 'Dr. Wanjiru Kamau',
  patientName: 'Amina Wambui',
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CaseWorkspaceOpened(caseUid: '', pathologistUid: ''),
    );
  });

  group('CompareScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpScreen(
      WidgetTester tester, {
      required CaseWorkspaceState state,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(() => blocs.caseWorkspace.state).thenReturn(state);
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const CompareScreen(caseUid: 'case-1'),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => blocs.caseWorkspace.add(any())).thenReturn(null);
    });

    testWidgets('opens the case when the state is elsewhere', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, state: const CaseWorkspaceInitial());

      verify(
        () => blocs.caseWorkspace.add(
          const CaseWorkspaceOpened(
            caseUid: 'case-1',
            pathologistUid: 'path-1',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows each AI text only on the AI side', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        state: CaseWorkspaceLoadSuccess(
          caseUid: 'case-1',
          caseModel: _case(),
          signed: _signed(),
          preread: _preread(),
        ),
      );

      expect(find.text(l10n.compareTitle), findsOneWidget);
      expect(
        find.text(l10n.compareSubtitle('ODR-AO-AW-02112026-001')),
        findsOneWidget,
      );
      expect(find.byType(DiffCard), findsNWidgets(2));
      expect(find.text(l10n.reportSectionDiagnosis), findsOneWidget);
      expect(find.text(l10n.reportQuestionFindings), findsOneWidget);
      // AI texts appear once each: never on the signed side.
      expect(find.text('Atypical cells, see comment.'), findsOneWidget);
      expect(
        find.text('One node with suspicious cells.\nLargest focus 2.6 mm.'),
        findsOneWidget,
      );
      expect(
        find.text('Metastatic carcinoma in 1 of 1 sentinel lymph node.'),
        findsOneWidget,
      );
      expect(
        find.text('Sentinel lymph node with metastatic breast carcinoma.'),
        findsOneWidget,
      );
      expect(find.text(l10n.workspaceAiDraft), findsNWidgets(2));
      expect(find.text(l10n.compareYourReport), findsNWidgets(2));
    });

    testWidgets('no pre-read shows the no-draft message and no diff', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        state: CaseWorkspaceLoadSuccess(
          caseUid: 'case-1',
          caseModel: _case(),
          signed: _signed(),
        ),
      );

      expect(find.text(l10n.deskNoAiDraft), findsOneWidget);
      expect(find.byType(DiffCard), findsNothing);
      expect(
        find.text(l10n.compareSubtitle('ODR-AO-AW-02112026-001')),
        findsNothing,
      );
    });

    testWidgets("another signer's case shows nothing but the message", (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        state: CaseWorkspaceLoadSuccess(
          caseUid: 'case-1',
          caseModel: _case(),
          signed: _signed(pathologistUid: 'path-9'),
          preread: _preread(),
        ),
      );

      expect(find.text(l10n.compareTitle), findsOneWidget);
      expect(find.text(l10n.deskNoAiDraft), findsOneWidget);
      expect(find.byType(DiffCard), findsNothing);
      // No subtitle, no AI text, no signed text.
      expect(
        find.text(l10n.compareSubtitle('ODR-AO-AW-02112026-001')),
        findsNothing,
      );
      expect(find.text('Atypical cells, see comment.'), findsNothing);
      expect(
        find.text('Metastatic carcinoma in 1 of 1 sentinel lymph node.'),
        findsNothing,
      );
    });

    testWidgets('equal texts show on both sides with no marker', (
      tester,
    ) async {
      _useTallSurface(tester);
      final same = _signed().copyWith(
        diagnosis: 'Atypical cells, see comment.',
        comments: 'One node with suspicious cells.\nLargest focus 2.6 mm.',
      );
      await pumpScreen(
        tester,
        state: CaseWorkspaceLoadSuccess(
          caseUid: 'case-1',
          caseModel: _case(),
          signed: same,
          preread: _preread(),
        ),
      );

      // Bundle 35 made no "No change" key: the identical texts speak.
      expect(find.text('Atypical cells, see comment.'), findsNWidgets(2));
      expect(
        find.text('One node with suspicious cells.\nLargest focus 2.6 mm.'),
        findsNWidgets(2),
      );
      expect(find.byType(DiffCard), findsNWidgets(2));
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        state: CaseWorkspaceLoadSuccess(
          caseUid: 'case-1',
          caseModel: _case(),
          signed: _signed(),
          preread: _preread(),
        ),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text(l10n.compareTitle), findsOneWidget);
      expect(
        find.text(l10n.compareSubtitle('ODR-AO-AW-02112026-001')),
        findsOneWidget,
      );
      expect(find.byType(DiffCard), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
