import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/share_done_screen.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_code_boxes.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

final _share = ShareCodeModel(
  uid: 's1',
  caseUid: 'c1',
  recipientUid: 'dr-2',
  createdAt: '2026-11-03T08:00:00Z',
  expiresAt: DateTime.now()
      .toUtc()
      .add(const Duration(days: 7))
      .toIso8601String(),
);

final PractitionerModel _doctor = PractitionerModel.empty().copyWith(
  uid: 'dr-2',
  title: 'Dr.',
  firstName: 'Mary',
  lastName: 'Njeri',
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
    when(
      () => blocs.directory.state,
    ).thenReturn(DirectoryLoadSuccess(all: [_doctor], visible: [_doctor]));
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required ShareState state,
    List<ShareState>? then,
  }) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    if (then == null) {
      when(() => blocs.share.state).thenReturn(state);
    } else {
      whenListen(blocs.share, Stream.fromIterable(then), initialState: state);
    }
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (_, _) => const Text('stub start'),
          routes: [
            GoRoute(
              path: 'done',
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  ...blocs.providers,
                ],
                child: const ShareDoneScreen(caseUid: 'c1'),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(router);
    await tester.pump();
    unawaited(router.push('/start/done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return router;
  }

  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Finder inSheet(String text) => find.descendant(
    of: find.byType(TabibuBottomSheet),
    matching: find.text(text),
  );

  group('ShareDoneScreen', () {
    testWidgets(
      'T-18: with no code from the server it names the person and shows no '
      'digit tiles',
      (tester) async {
        await pumpScreen(tester, state: ShareCreateSuccess(shares: [_share]));

        expect(
          find.text(l10n.shareSharedWith('Dr. Mary Njeri')),
          findsOneWidget,
        );
        expect(find.text(l10n.shareSharedBody), findsOneWidget);
        expect(find.text(l10n.shareOpenedReceipt), findsOneWidget);
        expect(find.byType(ShareCodeDigits), findsNothing);
        expect(
          find.text(l10n.shareCodeWorksOnce('Dr. Mary Njeri')),
          findsNothing,
        );
      },
    );

    testWidgets('T-18: a revealed code shows as four tiles, once', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        state: ShareCreateSuccess(
          shares: [_share],
          revealedCode: '4821',
          revealedShareUid: 's1',
        ),
      );

      expect(find.byType(ShareCodeDigits), findsOneWidget);
      for (final digit in '4821'.split('')) {
        expect(find.text(digit), findsOneWidget);
      }
      expect(
        find.text(l10n.shareCodeWorksOnce('Dr. Mary Njeri')),
        findsOneWidget,
      );
    });

    testWidgets('a code revealed for another share is never drawn here', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        state: ShareCreateSuccess(
          shares: [_share],
          revealedCode: '4821',
          revealedShareUid: 'someone-else',
        ),
      );

      expect(find.byType(ShareCodeDigits), findsNothing);
    });

    testWidgets('Done pops back to where the share began', (tester) async {
      await pumpScreen(tester, state: ShareCreateSuccess(shares: [_share]));

      await tester.tap(find.text(l10n.chipDone));
      await tester.pumpAndSettle();

      expect(find.text('stub start'), findsOneWidget);
    });

    testWidgets(
      'T-18: leaving the screen dismisses the revealed code in the bloc',
      (tester) async {
        await pumpScreen(
          tester,
          state: ShareCreateSuccess(
            shares: [_share],
            revealedCode: '4821',
            revealedShareUid: 's1',
          ),
        );
        verifyNever(() => blocs.share.add(const ShareCodeDismissed()));

        await tester.tap(find.text(l10n.chipDone));
        await tester.pumpAndSettle();

        verify(() => blocs.share.add(const ShareCodeDismissed())).called(1);
      },
    );

    testWidgets(
      'rule 2: Stop sharing names the person, and revokes only on confirm',
      (tester) async {
        await pumpScreen(tester, state: ShareCreateSuccess(shares: [_share]));

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
            const ShareRevokeRequested(uid: 'patient-1', shareUid: 's1'),
          ),
        ).called(1);
      },
    );

    testWidgets('a revoked share closes the screen', (tester) async {
      await pumpScreen(
        tester,
        state: ShareCreateSuccess(shares: [_share]),
        then: const [ShareRevokeSuccess()],
      );
      await tester.pumpAndSettle();

      expect(find.text('stub start'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        state: ShareCreateSuccess(
          shares: [_share],
          revealedCode: '4821',
          revealedShareUid: 's1',
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
