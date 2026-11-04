import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_viewer.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/who_can_see_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

const _careTeam = [
  ShareViewer(
    uid: 'dr-1',
    displayName: 'Dr. Wanjiru Kamau',
    role: ActorRole.doctor,
    removable: false,
  ),
  ShareViewer(
    uid: 'pa-1',
    displayName: 'Dr. Achieng Odhiambo',
    role: ActorRole.pathologist,
    removable: false,
  ),
];

const _colleague = ShareViewer(
  uid: 'dr-9',
  displayName: 'Dr. Peter Otieno',
  role: ActorRole.doctor,
  removable: true,
);

void main() {
  late FeatureBlocs blocs;
  late MockAuthBloc authBloc;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    registerFallbackValue(const ShareReset());
    registerFallbackValue(const DirectoryRequested());
  });

  setUp(() {
    blocs = FeatureBlocs();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    when(() => blocs.share.add(any())).thenReturn(null);
    when(() => blocs.directory.add(any())).thenReturn(null);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    ShareState state = const ShareLoadSuccess(viewers: _careTeam),
    DirectoryState directory = const DirectoryInitial(),
  }) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    when(() => blocs.share.state).thenReturn(state);
    when(() => blocs.directory.state).thenReturn(directory);
    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ...blocs.providers,
        ],
        child: const WhoCanSeeScreen(caseUid: 'c1'),
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

  group('WhoCanSeeScreen', () {
    testWidgets('asks the bloc for the case on open', (tester) async {
      await pumpScreen(tester);

      verify(
        () => blocs.share.add(
          const ShareRequested(
            uid: 'patient-1',
            role: Role.patient,
            caseUid: 'c1',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows a spinner until the first load lands', (tester) async {
      await pumpScreen(tester, state: const ShareLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets(
      'rule 3: lists the care team and the shared people with their roles',
      (tester) async {
        await pumpScreen(
          tester,
          state: const ShareLoadSuccess(viewers: [..._careTeam, _colleague]),
        );

        expect(find.text(l10n.shareWhoCanSeeTitle), findsOneWidget);
        expect(find.text(l10n.shareCareTeam), findsOneWidget);
        expect(find.text(l10n.shareSharedPeople), findsOneWidget);
        expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
        expect(find.text(l10n.shareReviewedBy), findsOneWidget);
        expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
        expect(find.text('Dr. Peter Otieno'), findsOneWidget);
        expect(find.text(l10n.shareFullAccess), findsNWidgets(2));
        expect(find.text(l10n.shareThisReportOnly), findsOneWidget);
      },
    );

    testWidgets(
      'rule 3: the care team has no way to be removed; only a shared person '
      'does',
      (tester) async {
        await pumpScreen(
          tester,
          state: const ShareLoadSuccess(viewers: [..._careTeam, _colleague]),
        );

        // One Stop sharing, for the one removable person.
        expect(find.text(l10n.shareStopSharing), findsOneWidget);
      },
    );

    testWidgets('rule 3: a care team alone offers no removal at all', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text(l10n.shareStopSharing), findsNothing);
      expect(find.text(l10n.shareSharedPeople), findsNothing);
    });

    testWidgets(
      'rule 2: removing a viewer names them first and dispatches only on '
      'confirm',
      (tester) async {
        await pumpScreen(
          tester,
          state: const ShareLoadSuccess(viewers: [..._careTeam, _colleague]),
        );

        await tester.tap(find.text(l10n.shareStopSharing));
        await settleSheet(tester);

        expect(
          inSheet(l10n.shareRemoveConfirmTitle('Dr. Peter Otieno')),
          findsOneWidget,
        );
        expect(inSheet(l10n.shareRemoveConfirmBody), findsOneWidget);
        verifyNever(
          () => blocs.share.add(any(that: isA<ShareRemoveViewerRequested>())),
        );

        await tester.tap(inSheet(l10n.shareStopSharing));
        await settleSheet(tester);

        verify(
          () => blocs.share.add(
            const ShareRemoveViewerRequested(
              uid: 'patient-1',
              caseUid: 'c1',
              viewerUid: 'dr-9',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets('rule 2: cancelling the remove sheet changes nothing', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        state: const ShareLoadSuccess(viewers: [..._careTeam, _colleague]),
      );

      await tester.tap(find.text(l10n.shareStopSharing));
      await settleSheet(tester);
      await tester.tap(inSheet(l10n.commonCancel));
      await settleSheet(tester);

      verifyNever(
        () => blocs.share.add(any(that: isA<ShareRemoveViewerRequested>())),
      );
    });

    testWidgets(
      'rule 2: stopping a pending share names the recipient, then revokes it',
      (tester) async {
        final doctor = PractitionerModel.empty().copyWith(
          uid: 'dr-2',
          title: 'Dr.',
          firstName: 'Mary',
          lastName: 'Njeri',
        );
        await pumpScreen(
          tester,
          state: const ShareLoadSuccess(
            viewers: _careTeam,
            shares: [
              ShareCodeModel(uid: 's1', caseUid: 'c1', recipientUid: 'dr-2'),
            ],
          ),
          directory: DirectoryLoadSuccess(all: [doctor], visible: [doctor]),
        );

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

        await tester.tap(inSheet(l10n.shareStopSharing));
        await settleSheet(tester);

        verify(
          () => blocs.share.add(
            const ShareRevokeRequested(uid: 'patient-1', shareUid: 's1'),
          ),
        ).called(1);
      },
    );

    testWidgets('shows a failed load as a toast', (tester) async {
      whenListen(
        blocs.share,
        Stream.value(const ShareLoadFailure(error: AppError.noInternet)),
        initialState: const ShareLoadSuccess(viewers: _careTeam),
      );
      await pumpScreen(tester);
      await tester.pump();

      expect(find.text(AppError.noInternet.description(l10n)), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        state: const ShareLoadSuccess(viewers: [..._careTeam, _colleague]),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
