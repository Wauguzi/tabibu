import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoDatePicker;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
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
import 'package:tabibu/features/auth/presentation/patient_name_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFilePickerService extends Mock implements FilePickerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PatientNameScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;
    late MockFilePickerService filePicker;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
      filePicker = MockFilePickerService();
      getIt.registerSingleton<FilePickerService>(filePicker);
    });

    tearDown(getIt.reset);

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
      ],
      child: const PatientNameScreen(),
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

    Future<void> fillNames(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField).at(0), 'Amina');
      await tester.enterText(find.byType(TextField).at(2), 'Wambui');
      await tester.pumpAndSettle();
    }

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Tell us about you'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Tell us about you'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty first name shows the message under it, once', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.byType(NoticeCard), findsNothing);

      await tester.enterText(find.byType(TextField).at(0), 'Amina');
      await tester.pumpAndSettle();
      expect(find.text('Enter your name'), findsNothing);
    });

    testWidgets('a missing sex shows its message under the cards', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await fillNames(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Choose one'), findsOneWidget);
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('typing a name keeps the sex message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await fillNames(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Aminah');
      await tester.pumpAndSettle();

      expect(find.text('Choose one'), findsOneWidget);
    });

    testWidgets('a missing birth date shows its message under the picker', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await fillNames(tester);
      await tester.ensureVisible(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your date of birth'), findsOneWidget);
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('complete details go to D2', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.patient, dateOfBirth: '1980-03-14'),
        ),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/name',
        routes: [
          GoRoute(path: '/sign-up/patient/name', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/patient/account',
            builder: (_, _) => const Text('D2 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
      await fillNames(tester);
      await tester.ensureVisible(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(captured.draft.firstName, 'Amina');
      expect(captured.draft.lastName, 'Wambui');
      expect(captured.draft.sex, Sex.female);
      expect(captured.draft.dateOfBirth, '1980-03-14');
      expect(find.text('D2 stub'), findsOneWidget);
    });

    testWidgets('an existing account skips to D3', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.patient, dateOfBirth: '1980-03-14'),
        ),
      );
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(session: SignUpIncompleteSession(email: 'a@b.co')),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/name',
        routes: [
          GoRoute(path: '/sign-up/patient/name', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/patient/phone',
            builder: (_, _) => const Text('D3 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
      await fillNames(tester);
      await tester.ensureVisible(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('D3 stub'), findsOneWidget);
    });

    testWidgets('the birth date opens a picker', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Select date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select date'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);
    });

    testWidgets('the field shows the formatted date', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.patient, dateOfBirth: '1980-03-14'),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('14 Mar 1980'), findsOneWidget);
    });

    testWidgets('shows Female before Male', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final femaleX = tester.getTopLeft(find.text('Female')).dx;
      final maleX = tester.getTopLeft(find.text('Male')).dx;
      expect(femaleX, lessThan(maleX));
    });

    testWidgets('the sex cards do not touch', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      // The gap sits between the two cards' labels, spanning their height.
      final female = tester.getRect(find.text('Female'));
      final male = tester.getRect(find.text('Male'));
      final gaps = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == AppSpacing.sm && w.height == null,
      );
      final between =
          [
            for (final gap in tester.widgetList<SizedBox>(gaps))
              tester.getRect(find.byWidget(gap)),
          ].where(
            (rect) =>
                rect.left >= female.right &&
                rect.right <= male.left &&
                rect.top <= female.center.dy &&
                rect.bottom >= female.center.dy,
          );
      expect(between, hasLength(1));
    });

    testWidgets('a selected sex card fills with the brand mint', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      List<Material> selectedCards() => tester
          .widgetList<Material>(find.byType(Material))
          .where(
            (m) =>
                m.borderRadius == BorderRadius.circular(AppRadii.card) &&
                m.color == AppColors.mintLight,
          )
          .toList();

      expect(selectedCards(), isEmpty);

      await tester.ensureVisible(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      expect(selectedCards(), hasLength(1));
    });

    testWidgets('opening the picker commits the date it opens on', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Select date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select date'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expected = DateFormat(
        'd MMM y',
        'en',
      ).format(DateTime(now.year - 25, now.month, now.day));
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('a picked photo replaces Add with Change', (tester) async {
      when(
        () => filePicker.pickPhoto(fromCamera: any(named: 'fromCamera')),
      ).thenAnswer(
        (_) async => UploadFile(
          // A 1x1 PNG; MemoryImage rejects anything undecodable.
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

      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('Continue waits while the photo is read', (tester) async {
      final pending = Completer<UploadFile?>();
      when(
        () => filePicker.pickPhoto(fromCamera: any(named: 'fromCamera')),
      ).thenAnswer((_) => pending.future);

      TabibuButton continueButton() => tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, 'Continue'),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(continueButton().onTap, isNotNull);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from library'));
      // The spinner never settles while the read pends.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(continueButton().onTap, isNull);

      pending.complete(null);
      await tester.pumpAndSettle();
      expect(continueButton().onTap, isNotNull);
    });

    testWidgets('back keeps what was entered in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await fillNames(tester);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      final draft = committedDraft(signUpBloc);
      expect(draft.firstName, 'Amina');
      expect(draft.lastName, 'Wambui');
      expect(draft.dateOfBirth, isEmpty);
    });
  });
}
