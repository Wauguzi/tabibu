import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/enter_share_code_screen.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

const _share = ShareCodeModel(
  uid: 's1',
  caseUid: 'c1',
  createdByUid: 'patient-9',
  createdByRole: 'Patient',
  recipientUid: 'doc-1',
  expiresAt: '2026-11-16T08:00:00Z',
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
    when(() => blocs.share.add(any())).thenReturn(null);
    when(() => blocs.directory.add(any())).thenReturn(null);
    when(() => blocs.directory.state).thenReturn(const DirectoryLoadSuccess());
    when(() => blocs.cases.state).thenReturn(
      const CasesLoadSuccess(
        cases: [CaseModel(uid: 'c1', orderNumber: 'TB-1042')],
      ),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Role role = .doctor,
    ShareState state = const ShareLoadSuccess(shares: [_share]),
    List<ShareState>? then,
  }) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final base = switch (role) {
      .pathologist => RoleSessions.pathologist,
      _ => RoleSessions.doctor(),
    };
    final session = PractitionerSession(
      doctor: base.doctor.copyWith(uid: 'doc-1'),
      roles: base.roles,
    );
    when(() => authBloc.state).thenReturn(SignInSuccess(session: session));
    if (then == null) {
      when(() => blocs.share.state).thenReturn(state);
    } else {
      whenListen(blocs.share, Stream.fromIterable(then), initialState: state);
    }
    final router = GoRouter(
      initialLocation: '/${role.name}/share/s1',
      routes: [
        GoRoute(
          path: '/${role.name}/share/:shareUid',
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              ...blocs.providers,
            ],
            child: EnterShareCodeScreen(
              role: role,
              shareUid: state.pathParameters['shareUid']!,
            ),
          ),
        ),
        GoRoute(
          path: '/doctor/case/:caseUid',
          builder: (_, state) =>
              Text('stub doctor case ${state.pathParameters['caseUid']}'),
        ),
        GoRoute(
          path: '/pathologist/case/:caseUid',
          builder: (_, state) =>
              Text('stub workspace ${state.pathParameters['caseUid']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(router);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  group('EnterShareCodeScreen', () {
    testWidgets(
      'on open it loads the recipient shares so a redeem knows the case',
      (tester) async {
        await pumpScreen(tester);

        verify(
          () => blocs.share.add(
            const ShareRequested(
              uid: 'doc-1',
              role: Role.doctor,
              caseUid: '',
              asCreator: false,
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'rule 4/T-18: the field is empty on open, whatever a notification '
      'carries',
      (tester) async {
        // The screen takes the share id only; nothing in its inputs, route or
        // state is a code, so there is nothing it could prefill from.
        await pumpScreen(
          tester,
          state: const ShareLoadSuccess(
            shares: [_share],
            revealedCode: '4821',
            revealedShareUid: 's1',
          ),
        );

        expect(fieldText(tester), isEmpty);
        expect(find.text('4821'), findsNothing);
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).autofillHints,
          anyOf(isNull, isEmpty),
        );
      },
    );

    testWidgets('names the sharer and the case, and when access ends', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(
        find.text(l10n.shareEnterCodeBody('TB-1042', 'Patient')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.shareEnterCodeNote('16 Nov', 'Patient')),
        findsOneWidget,
      );
      expect(find.text(l10n.shareOpenReport), findsOneWidget);
    });

    testWidgets('the field takes only four digits', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), '48a2 1999');
      await tester.pump();

      expect(fieldText(tester), '4821');
    });

    testWidgets(
      'an incomplete code is refused on the screen without a request',
      (tester) async {
        await pumpScreen(tester);

        await tester.enterText(find.byType(TextField), '48');
        await tester.tap(find.text(l10n.shareOpenReport));
        await tester.pump();

        expect(find.text(l10n.shareCodeInvalid), findsOneWidget);
        verifyNever(
          () => blocs.share.add(any(that: isA<ShareRedeemRequested>())),
        );
      },
    );

    testWidgets('four digits redeem the share, with the code from the field', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), '4821');
      await tester.tap(find.text(l10n.shareOpenReport));
      await tester.pump();

      verify(
        () => blocs.share.add(
          const ShareRedeemRequested(
            uid: 'doc-1',
            shareUid: 's1',
            code: '4821',
          ),
        ),
      ).called(1);
    });

    final failures = <(AppError, String Function(AppLocalizations))>[
      (AppError.wrongShareCode, (l) => l.shareCodeWrong),
      (AppError.shareExpired, (l) => l.shareCodeExpired),
      (AppError.shareClosed, (l) => l.shareCodeUsed),
      (AppError.shareLocked, (l) => l.shareCodeLocked),
    ];
    for (final (error, message) in failures) {
      testWidgets('rule 4: ${error.name} shows its own message', (
        tester,
      ) async {
        await pumpScreen(tester, then: [ShareWriteFailure(error: error)]);
        await tester.pump();

        expect(find.text(message(l10n)), findsOneWidget);
        expect(error.description(l10n), message(l10n));
      });
    }

    testWidgets('rule 4: the four failures read differently', (tester) async {
      final texts = {for (final (_, message) in failures) message(l10n)};
      expect(texts, hasLength(4));
    });

    testWidgets('typing again clears the failure message', (tester) async {
      await pumpScreen(
        tester,
        then: const [ShareWriteFailure(error: AppError.wrongShareCode)],
      );
      await tester.pump();
      expect(find.text(l10n.shareCodeWrong), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();

      expect(find.text(l10n.shareCodeWrong), findsNothing);
    });

    testWidgets('rule 4: a doctor who redeems lands on the case', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        then: const [ShareRedeemSuccess(redeemedCaseUid: 'c1')],
      );
      await tester.pumpAndSettle();

      expect(find.text('stub doctor case c1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('rule 4: a pathologist who redeems lands on the workspace', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        role: .pathologist,
        then: const [ShareRedeemSuccess(redeemedCaseUid: 'c9')],
      );
      await tester.pumpAndSettle();

      expect(find.text('stub workspace c9'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
