import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/signed_case_view.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

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

PathologyReportModel _report({String pathologistUid = 'path-1'}) =>
    PathologyReportModel(
      uid: 'rep-1',
      caseUid: 'case-1',
      orderNumber: 'ODR-AO-AW-02112026-001',
      pathologistUid: pathologistUid,
      diagnosis: 'Metastatic carcinoma in 1 of 1 sentinel lymph node.',
      comments:
          'Sentinel lymph node with metastatic breast carcinoma. '
          'Largest focus 2.1 mm.',
      signedAt: '2026-10-27T07:42:00Z',
      measurements: const [
        ReportMeasurementModel(
          key: 'Largest focus',
          unit: 'mm',
          value: 2.1,
          precision: 1,
        ),
      ],
    );

CaseModel _case() => const CaseModel(
  uid: 'case-1',
  orderNumber: 'ODR-AO-AW-02112026-001',
  doctorName: 'Dr. Wanjiru Kamau',
  patientName: 'Amina Wambui',
);

void main() {
  group('SignedCaseView', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpView(
      WidgetTester tester, {
      PathologyReportModel? report,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: SingleChildScrollView(
            child: SignedCaseView(
              report: report ?? _report(),
              caseModel: _case(),
            ),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
    });

    testWidgets('shows the chips, banner and report verbatim', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpView(tester);

      expect(find.text(l10n.caseStepSigned), findsOneWidget);
      expect(
        find.text(l10n.signedCaseSentChip('Dr. Wanjiru Kamau')),
        findsOneWidget,
      );
      expect(find.text(l10n.signedCaseSignedByYou), findsOneWidget);
      expect(
        find.text(
          l10n.signedCaseSentLine('27 Oct, 10:42 AM', 'Dr. Wanjiru Kamau'),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.reportPdfSignedReport), findsOneWidget);
      expect(find.text('Diagnosis · Final'), findsOneWidget);
      expect(
        find.text('Metastatic carcinoma in 1 of 1 sentinel lymph node.'),
        findsOneWidget,
      );
      expect(find.text('Comments'), findsOneWidget);
      expect(
        find.text(
          'Sentinel lymph node with metastatic breast carcinoma. '
          'Largest focus 2.1 mm.',
        ),
        findsOneWidget,
      );
      expect(find.text('Largest focus'), findsOneWidget);
      expect(find.text('2.1 mm'), findsOneWidget);
      expect(find.text(l10n.signedCaseDraftKept), findsOneWidget);
    });

    testWidgets('has no AI panel, frame, sparkle or heatmap', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpView(tester);

      expect(find.byType(AiDraftFrame), findsNothing);
      expect(find.text(l10n.workspaceAiDraft), findsNothing);
      expect(find.text(l10n.workspaceHeatmap), findsNothing);
      expect(find.text(l10n.scoreTitle), findsNothing);
    });

    testWidgets('the signer follows the compare link', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      Widget withBlocs(Widget child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ...blocs.providers,
        ],
        child: child,
      );
      final routes = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => withBlocs(
              SingleChildScrollView(
                child: SignedCaseView(report: _report(), caseModel: _case()),
              ),
            ),
          ),
          GoRoute(
            path: '/pathologist/case/:caseUid/compare',
            builder: (_, state) =>
                Text('stub compare ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      await tester.pumpRouterApp(routes);
      await tester.pump();

      expect(find.text(l10n.signedCaseCompare), findsOneWidget);
      await tester.tap(find.text(l10n.signedCaseCompare));
      await tester.pumpAndSettle();
      expect(find.text('stub compare case-1'), findsOneWidget);
    });

    testWidgets('another signer sees no compare link', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpView(tester, report: _report(pathologistUid: 'path-9'));

      expect(find.text(l10n.signedCaseSignedByYou), findsOneWidget);
      expect(find.text(l10n.signedCaseCompare), findsNothing);
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpView(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text(l10n.signedCaseSignedByYou), findsOneWidget);
      expect(find.text(l10n.reportPdfSignedReport), findsOneWidget);
      expect(find.text(l10n.signedCaseDraftKept), findsOneWidget);
      expect(find.text(l10n.signedCaseCompare), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
