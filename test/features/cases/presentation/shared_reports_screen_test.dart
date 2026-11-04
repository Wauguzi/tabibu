import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/shared_reports_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

const _case = CaseModel(
  uid: 'c1',
  orderNumber: 'TB-1042',
  tests: [OrderedTestModel(name: 'Skin biopsy')],
);

final PractitionerModel _doctor = PractitionerModel.empty().copyWith(
  uid: 'dr-2',
  title: 'Dr.',
  firstName: 'Mary',
  lastName: 'Njeri',
);

const _pending = ShareCodeModel(
  uid: 's-open',
  caseUid: 'c1',
  recipientUid: 'dr-2',
  createdAt: '2026-11-02T08:00:00Z',
  expiresAt: '2026-11-16T08:00:00Z',
);

const _opened = ShareCodeModel(
  uid: 's-done',
  caseUid: 'c1',
  recipientUid: 'dr-2',
  status: 'Redeemed',
  createdAt: '2026-10-20T08:00:00Z',
  redeemedAt: '2026-10-21T09:00:00Z',
  expiresAt: '2026-11-03T08:00:00Z',
);

void main() {
  late FeatureBlocs blocs;
  late MockAuthBloc authBloc;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    registerFallbackValue(const ShareReset());
    registerFallbackValue(const DirectoryRequested());
    registerFallbackValue(const CasesRequested(uid: '', role: .patient));
  });

  setUp(() {
    blocs = FeatureBlocs();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    when(() => blocs.share.add(any())).thenReturn(null);
    when(() => blocs.cases.add(any())).thenReturn(null);
    when(() => blocs.directory.add(any())).thenReturn(null);
    when(
      () => blocs.cases.state,
    ).thenReturn(const CasesLoadSuccess(cases: [_case]));
    when(
      () => blocs.directory.state,
    ).thenReturn(DirectoryLoadSuccess(all: [_doctor], visible: [_doctor]));
  });

  Future<void> pumpScreen(WidgetTester tester, ShareState state) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    when(() => blocs.share.state).thenReturn(state);
    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ...blocs.providers,
        ],
        child: const SharedReportsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Finder inSheet(String text) => find.descendant(
    of: find.byType(TabibuBottomSheet),
    matching: find.text(text),
  );

  group('SharedReportsScreen', () {
    testWidgets('loads every share the patient made, not one case', (
      tester,
    ) async {
      await pumpScreen(tester, const ShareLoadSuccess());

      verify(
        () => blocs.share.add(
          const ShareRequested(
            uid: 'patient-1',
            role: Role.patient,
            caseUid: '',
          ),
        ),
      ).called(1);
    });

    testWidgets('splits pending shares from ended ones', (tester) async {
      await pumpScreen(
        tester,
        const ShareLoadSuccess(shares: [_pending, _opened]),
      );

      expect(find.text(l10n.shareListTitle), findsOneWidget);
      expect(find.text(l10n.shareListActive), findsOneWidget);
      expect(find.text(l10n.shareListEnded), findsOneWidget);
      expect(
        find.text(l10n.shareListReport('TB-1042', 'Skin biopsy')),
        findsNWidgets(2),
      );
      expect(
        find.text(l10n.shareListShared('2 Nov', 'Dr. Mary Njeri')),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.shareListOpened('21 Oct')),
        findsOneWidget,
      );
      // Only the pending row can be stopped.
      expect(find.text(l10n.shareStopSharing), findsOneWidget);
    });

    testWidgets(
      'T-18: no row shows a code, even when the bloc still holds one',
      (tester) async {
        await pumpScreen(
          tester,
          const ShareLoadSuccess(
            shares: [_pending],
            revealedCode: '4821',
            revealedShareUid: 's-open',
          ),
        );

        expect(find.textContaining('4821'), findsNothing);
        expect(find.textContaining('Code'), findsNothing);
      },
    );

    testWidgets('shows the empty sentence with no shares', (tester) async {
      await pumpScreen(tester, const ShareLoadSuccess());

      expect(find.text(l10n.shareListEmpty), findsOneWidget);
    });

    testWidgets('shows a spinner while the first load runs', (tester) async {
      await pumpScreen(tester, const ShareLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets(
      'rule 2: Stop sharing names who loses access, and revokes only on '
      'confirm',
      (tester) async {
        await pumpScreen(tester, const ShareLoadSuccess(shares: [_pending]));

        await tester.tap(find.text(l10n.shareStopSharing));
        await settleSheet(tester);

        expect(
          inSheet(l10n.shareStopConfirmTitle('Dr. Mary Njeri')),
          findsOneWidget,
        );
        expect(
          inSheet(l10n.shareStopConfirmBody('Dr. Mary Njeri')),
          findsOneWidget,
        );
        verifyNever(
          () => blocs.share.add(any(that: isA<ShareRevokeRequested>())),
        );

        await tester.tap(inSheet(l10n.shareStopSharing));
        await settleSheet(tester);

        verify(
          () => blocs.share.add(
            const ShareRevokeRequested(uid: 'patient-1', shareUid: 's-open'),
          ),
        ).called(1);
      },
    );

    testWidgets('rule 2: cancelling leaves the share alone', (tester) async {
      await pumpScreen(tester, const ShareLoadSuccess(shares: [_pending]));

      await tester.tap(find.text(l10n.shareStopSharing));
      await settleSheet(tester);
      await tester.tap(inSheet(l10n.commonCancel));
      await settleSheet(tester);

      verifyNever(
        () => blocs.share.add(any(that: isA<ShareRevokeRequested>())),
      );
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        const ShareLoadSuccess(shares: [_pending, _opened]),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
