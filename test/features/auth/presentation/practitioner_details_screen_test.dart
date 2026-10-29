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

    testWidgets('an empty title shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(4), 'Strong1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Select a valid title.'), findsOneWidget);
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

    testWidgets('a signed-in account skips creation', (tester) async {
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(
          session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
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
      await fillAll(tester);

      // The photo comes from the draft on this path.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verifyNever(() => authBloc.add(any()));
      expect(find.text('E2 stub'), findsOneWidget);
    });

    testWidgets('a failure shows its message', (tester) async {
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
        find.text(
          'An account already exists with this email. Sign in instead.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('success goes to E2', (tester) async {
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
            path: '/sign-up/practitioner/licence',
            builder: (_, _) => const Text('E2 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('E2 stub'), findsOneWidget);
    });
  });
}
