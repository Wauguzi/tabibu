import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/practitioner_details_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFilePickerService extends Mock implements FilePickerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GoogleSignInRequested());
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PractitionerDetailsScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;
    late MockFilePickerService filePicker;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.doctor)));
      filePicker = MockFilePickerService();
      getIt.registerSingleton<FilePickerService>(filePicker);
    });

    tearDown(getIt.reset);

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
      ],
      child: const PractitionerDetailsScreen(),
    );

    Future<void> pumpUnderStub(WidgetTester tester, Widget step) async {
      final router = GoRouter(
        initialLocation: '/previous/step',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (_, _) => const Text('Previous step'),
            routes: [GoRoute(path: 'step', builder: (_, _) => step)],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
    }

    SignUpDraft committedDraft(MockSignUpBloc bloc) {
      final captured = verify(() => bloc.add(captureAny())).captured;
      return (captured.last as SignUpDraftUpdated).draft;
    }

    Finder errorNotice() => find.byWidgetPredicate(
      (w) => w is NoticeCard && w.variant == NoticeVariant.error,
    );

    Future<void> pickTitle(WidgetTester tester) async {
      await tester.tap(find.text('Choose your title'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr.').last);
      await tester.pumpAndSettle();
    }

    Future<void> fillNames(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField).at(0), 'Wanjiru');
      await tester.enterText(find.byType(TextField).at(1), 'Kamau');
    }

    Future<void> fillPassword(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField).at(4), 'Strong1!');
    }

    Future<void> fillAll(WidgetTester tester) async {
      await tester.tap(find.text('Choose your title'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr.').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Wanjiru');
      await tester.enterText(find.byType(TextField).at(1), 'Kamau');
      await tester.enterText(
        find.byType(TextField).at(2),
        'w.kamau@akuh.example',
      );
      await tester.enterText(find.byType(TextField).at(3), '+254722118450');
      await tester.enterText(find.byType(TextField).at(4), 'Strong1!');
      await tester.pumpAndSettle();
    }

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Your details'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Your details'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty title shows its message under the picker', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await fillPassword(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // The hint and the error share the text; the notice stays away.
      expect(find.text('Choose your title'), findsNWidgets(2));
      expect(errorNotice(), findsNothing);
    });

    testWidgets('no name or photo shows no question mark', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('?'), findsNothing);
    });

    testWidgets('the phone formats with +254 as typed', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(3), '722118450');
      await tester.pumpAndSettle();

      expect(find.text('+254 722 118 450'), findsOneWidget);
    });

    testWidgets('an empty name shows its message under the first field', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await pickTitle(tester);
      await fillPassword(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(errorNotice(), findsNothing);
    });

    testWidgets('a bad email shows its message under the email field', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await pickTitle(tester);
      await fillNames(tester);
      await tester.enterText(find.byType(TextField).at(2), 'not-an-email');
      await fillPassword(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like an email address"),
        findsOneWidget,
      );
      expect(errorNotice(), findsNothing);
    });

    testWidgets('a bad phone shows its message under the phone field', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await pickTitle(tester);
      await fillNames(tester);
      await tester.enterText(
        find.byType(TextField).at(2),
        'w.kamau@akuh.example',
      );
      await tester.enterText(find.byType(TextField).at(3), '123');
      await fillPassword(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a Kenyan mobile number, like 712 345 678'),
        findsOneWidget,
      );
      expect(errorNotice(), findsNothing);
    });

    testWidgets('no photo shows its message under the photo row', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await pickTitle(tester);
      await fillNames(tester);
      await tester.enterText(
        find.byType(TextField).at(2),
        'w.kamau@akuh.example',
      );
      await tester.enterText(find.byType(TextField).at(3), '722118450');
      await fillPassword(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Add a photo of yourself'), findsOneWidget);
      expect(errorNotice(), findsNothing);
    });

    testWidgets('complete details create the account', (tester) async {
      when(
        () => filePicker.pickPhoto(fromCamera: any(named: 'fromCamera')),
      ).thenAnswer(
        (_) async => UploadFile(
          bytes: base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
            // cspell:disable-next-line
            '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
          ),
          contentType: 'image/jpeg',
          name: 'photo.jpg',
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from library'));
      await tester.pumpAndSettle();
      await fillAll(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final updated =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(updated.draft.title, PractitionerTitle.dr);
      expect(updated.draft.firstName, 'Wanjiru');
      expect(updated.draft.phoneNumber, '+254722118450');
      expect(updated.draft.picture, isNotNull);
      verify(
        () => authBloc.add(
          const CreateAccountRequested(
            email: 'w.kamau@akuh.example',
            password: 'Strong1!',
          ),
        ),
      ).called(1);
    });

    testWidgets('once the account exists, E1 is read-only and moves on', (
      tester,
    ) async {
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(
          session: SignUpIncompleteSession(
            email: 'w.kamau@akuh.example',
            emailVerified: true,
          ),
        ),
      );
      when(() => signUpBloc.state).thenReturn(
        SignUpState(
          draft: SignUpDraft(
            role: Role.doctor,
            picture: UploadFile(
              bytes: base64Decode(
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
                // cspell:disable-next-line
                '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
              ),
              contentType: 'image/jpeg',
              name: 'photo.jpg',
            ),
          ),
        ),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/details',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/details',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/practitioner/licence',
            builder: (_, _) => const Text('E2 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      // The account's email shows and cannot change; no password is asked.
      final email = find.widgetWithText(TextField, 'w.kamau@akuh.example');
      expect(email, findsOneWidget);
      expect(tester.widget<TextField>(email).readOnly, isTrue);
      expect(find.byType(PasswordField), findsNothing);
      expect(
        find.text(
          'Your account is set up with this email. Continue to the next step.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Choose your title'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr.').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Wanjiru');
      await tester.enterText(find.byType(TextField).at(1), 'Kamau');
      await tester.enterText(find.byType(TextField).at(3), '722118450');
      await tester.pumpAndSettle();

      // The photo comes from the draft on this path.
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verifyNever(() => authBloc.add(any()));
      expect(find.text('E2 stub'), findsOneWidget);
    });

    testWidgets('emailAlreadyInUse shows under the email field', (
      tester,
    ) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountFailure(
            session: SignedOutSession(),
            error: AppError.emailAlreadyInUse,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('An account already uses this email. Sign in instead.'),
        findsOneWidget,
      );
      expect(errorNotice(), findsNothing);
    });

    testWidgets('a weak password refusal shows under the password field', (
      tester,
    ) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountFailure(
            session: SignedOutSession(),
            error: AppError.weakPassword,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Use at least 8 characters, a number and a symbol'),
        findsOneWidget,
      );
      expect(errorNotice(), findsNothing);
    });

    testWidgets("the pathologist's photo line names the attaching doctors", (
      tester,
    ) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Doctors see this when they attach you.'),
        findsOneWidget,
      );
      expect(find.text('Patients see this on your profile.'), findsNothing);
    });

    testWidgets('success goes to E2', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountSuccess(
            session: SignUpIncompleteSession(
              email: 'w.kamau@akuh.example',
              emailVerified: true,
            ),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/details',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/details',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/practitioner/licence',
            builder: (_, _) => const Text('E2 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('E2 stub'), findsOneWidget);
    });

    testWidgets('an unconfirmed address goes to verification', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountSuccess(
            session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/details',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/details',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/account/verify-email',
            builder: (_, _) => const Text('verify stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('verify stub'), findsOneWidget);
    });

    testWidgets('back keeps what was entered in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await tester.enterText(find.byType(TextField).at(0), 'Wanjiru');
      await tester.enterText(find.byType(TextField).at(1), 'Kamau');
      await tester.enterText(
        find.byType(TextField).at(2),
        'w.kamau@akuh.example',
      );
      await tester.enterText(find.byType(TextField).at(3), '0722118450');
      await tester.enterText(find.byType(TextField).at(4), 'Strong1!');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      final draft = committedDraft(signUpBloc);
      expect(draft.firstName, 'Wanjiru');
      expect(draft.lastName, 'Kamau');
      expect(draft.email, 'w.kamau@akuh.example');
      expect(draft.phoneNumber, '+254722118450');
    });

    testWidgets('a fresh E1 shows the email from the draft', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.doctor, email: 'w.kamau@akuh.example'),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('w.kamau@akuh.example'), findsOneWidget);
    });
  });
}
