import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/presentation/share_report_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

PractitionerModel _doctor({
  String uid = 'dr-1',
  String first = 'Wanjiru',
  String last = 'Kamau',
  bool pathologist = false,
  bool available = true,
}) => PractitionerModel.empty().copyWith(
  uid: uid,
  title: 'Dr.',
  firstName: first,
  lastName: last,
  isPathologist: pathologist,
  isAvailable: available,
  specialties: [if (pathologist) 'Histopathology' else 'General surgery'],
  facilityName: 'Aga Khan University Hospital',
);

void main() {
  late FeatureBlocs blocs;
  late MockAuthBloc authBloc;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    registerFallbackValue(const DirectoryRequested());
    registerFallbackValue(const ShareReset());
  });

  setUp(() {
    blocs = FeatureBlocs();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    when(() => blocs.directory.add(any())).thenReturn(null);
    when(() => blocs.share.add(any())).thenReturn(null);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<PractitionerModel> visible = const [],
    DirectoryState? directory,
    List<ShareState>? shareStates,
  }) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    when(() => blocs.directory.state).thenReturn(
      directory ?? DirectoryLoadSuccess(all: visible, visible: visible),
    );
    if (shareStates != null) {
      whenListen(
        blocs.share,
        Stream.fromIterable(shareStates),
        initialState: const ShareInitial(),
      );
    }
    final router = GoRouter(
      initialLocation: '/patient/result/c1/share',
      routes: [
        GoRoute(
          path: '/patient/result/:caseUid/share',
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              ...blocs.providers,
            ],
            child: ShareReportScreen(caseUid: state.pathParameters['caseUid']!),
          ),
        ),
        GoRoute(
          path: '/patient/result/:caseUid/share/done',
          builder: (_, state) =>
              Text('stub done ${state.pathParameters['caseUid']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(router);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> releaseRouter(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  group('ShareReportScreen', () {
    testWidgets('searches the directory and lists each practitioner', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        visible: [
          _doctor(),
          _doctor(
            uid: 'pa-1',
            first: 'Achieng',
            last: 'Odhiambo',
            pathologist: true,
          ),
        ],
      );

      verify(() => blocs.directory.add(const DirectoryRequested())).called(1);
      expect(find.text(l10n.resultDetailShare), findsOneWidget);
      expect(find.text(l10n.shareWhoShouldSee), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
      // Specialty and facility together, as the subtitle key spells them.
      expect(
        find.text(
          l10n.shareRecipientSubtitle(
            'Aga Khan University Hospital',
            'General surgery',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'lists pathologists and unavailable doctors; hides the sender',
      (tester) async {
        await pumpScreen(
          tester,
          visible: [
            _doctor(),
            _doctor(
              uid: 'pa-1',
              first: 'Achieng',
              last: 'Odhiambo',
              pathologist: true,
            ),
            _doctor(
              uid: 'dr-busy',
              first: 'Busy',
              last: 'Doc',
              available: false,
            ),
            _doctor(uid: 'patient-1', first: 'Self', last: 'Sender'),
          ],
        );

        expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
        expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
        expect(find.text('Dr. Busy Doc'), findsOneWidget);
        expect(find.text('Dr. Self Sender'), findsNothing);
      },
    );

    testWidgets('directory query state narrows the share list', (tester) async {
      final kamau = _doctor();
      final other = _doctor(uid: 'dr-2', first: 'Other', last: 'Otieno');
      await pumpScreen(
        tester,
        directory: DirectoryLoadSuccess(
          all: [kamau, other],
          visible: [kamau],
          query: 'kam',
        ),
      );

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Dr. Other Otieno'), findsNothing);
    });

    testWidgets('typing in the search field filters through the directory', (
      tester,
    ) async {
      await pumpScreen(tester, visible: [_doctor()]);

      await tester.enterText(find.byType(TextField), 'kam');
      await tester.pump();

      verify(
        () => blocs.directory.add(const DirectoryQueryChanged(query: 'kam')),
      ).called(1);
    });

    testWidgets(
      'sharing waits for a pick: no create until a person is chosen',
      (tester) async {
        await pumpScreen(tester, visible: [_doctor()]);

        await tester.tap(find.text(l10n.resultDetailShare));
        await tester.pump();

        verifyNever(
          () => blocs.share.add(any(that: isA<ShareCreateRequested>())),
        );
      },
    );

    testWidgets(
      'rule 6: the primary creates a Join share for the pick with no gate in '
      'between (Face ID / PIN waits on bundle 53)',
      (tester) async {
        await pumpScreen(
          tester,
          visible: [
            _doctor(),
            _doctor(uid: 'dr-2', last: 'Otieno'),
          ],
        );

        await tester.tap(find.text('Dr. Wanjiru Otieno'));
        await tester.pump();
        await tester.tap(find.text(l10n.resultDetailShare));
        await tester.pump();

        verify(
          () => blocs.share.add(
            const ShareCreateRequested(
              uid: 'patient-1',
              role: Role.patient,
              caseUid: 'c1',
              recipientUid: 'dr-2',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets('a created share replaces the screen with the done screen', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        visible: [_doctor()],
        shareStates: [const ShareWriteInProgress(), const ShareCreateSuccess()],
      );
      await tester.pumpAndSettle();

      expect(find.text('stub done c1'), findsOneWidget);
      await releaseRouter(tester);
    });

    testWidgets('rule 5: an offline failure shows its message and stays here', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        visible: [_doctor()],
        shareStates: [const ShareWriteFailure(error: AppError.noInternet)],
      );
      await tester.pump();

      expect(find.text(AppError.noInternet.description(l10n)), findsOneWidget);
      expect(find.text(l10n.resultDetailShare), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('shows the empty state when nothing matches', (tester) async {
      await pumpScreen(
        tester,
        directory: const DirectoryLoadSuccess(query: 'zzz'),
      );

      expect(find.text(l10n.findDoctorNoResultsTitle('zzz')), findsOneWidget);
    });

    testWidgets('shows a spinner while the directory loads', (tester) async {
      await pumpScreen(tester, directory: const DirectoryLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(tester, visible: [_doctor()]);

      expect(tester.takeException(), isNull);
    });
  });
}
