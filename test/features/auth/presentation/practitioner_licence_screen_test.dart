import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/practitioner_licence_screen.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../helpers/helpers.dart';

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFilePickerService extends Mock implements FilePickerService {}

UploadFile _licence(String name) => UploadFile(
  bytes: Uint8List.fromList(List.filled(2048, 0)),
  contentType: 'application/pdf',
  name: name,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PractitionerLicenceScreen', () {
    late MockSignUpBloc signUpBloc;
    late MockFilePickerService filePicker;

    setUp(() {
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.doctor)));
      filePicker = MockFilePickerService();
      getIt.registerSingleton<FilePickerService>(filePicker);
    });

    tearDown(getIt.reset);

    Widget screen() => BlocProvider<SignUpBloc>.value(
      value: signUpBloc,
      child: const PractitionerLicenceScreen(),
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

    Future<void> fillDoctor(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField), 'A 12345');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Choose up to five'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose up to five'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'surgery');
      await tester.pumpAndSettle();
      await tester.tap(find.text('General surgery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done · 1 selected'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Verify your licence'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Verify your licence'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty number shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('The KMPDC number is not valid. Check it and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('no specialty shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'A 12345');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Choose one to five specialties from the list.'),
        findsOneWidget,
      );
    });

    testWidgets('no document shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await fillDoctor(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('The license is not valid. Check it and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('a picked file tiles and continues to E3', (tester) async {
      when(
        () => filePicker.pickLicence(),
      ).thenAnswer((_) async => _licence('licence.pdf'));

      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/licence',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/licence',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/practitioner/facility',
            builder: (_, _) => const Text('E3 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
      await fillDoctor(tester);

      await tester.ensureVisible(find.text('Add another document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add another document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload a file'));
      await tester.pumpAndSettle();

      expect(find.text('licence.pdf'), findsOneWidget);
      expect(find.text('2.0 KB · PDF'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final updated =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(updated.draft.kmpdcNumber, 'A 12345');
      expect(updated.draft.specialties, [Specialty.generalSurgery]);
      expect(updated.draft.licenses.map((f) => f.name), ['licence.pdf']);
      expect(find.text('E3 stub'), findsOneWidget);
    });

    testWidgets('Continue and Add wait while a licence is read', (
      tester,
    ) async {
      final pending = Completer<UploadFile?>();
      when(() => filePicker.pickLicence()).thenAnswer((_) => pending.future);

      TabibuButton continueButton() => tester.widget<TabibuButton>(
        find.widgetWithText(TabibuButton, 'Continue'),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(continueButton().onTap, isNotNull);

      await tester.ensureVisible(find.text('Add another document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add another document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload a file'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(continueButton().onTap, isNull);
      expect(find.text('Add another document'), findsNothing);

      pending.complete(_licence('licence.pdf'));
      await tester.pumpAndSettle();

      expect(continueButton().onTap, isNotNull);
      expect(find.text('licence.pdf'), findsOneWidget);
    });

    testWidgets('two files hide the add button', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        SignUpState(
          draft: SignUpDraft(
            role: Role.doctor,
            licenses: [_licence('a.pdf'), _licence('b.pdf')],
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Add another document'), findsNothing);
    });

    testWidgets('deleting a file removes its row', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        SignUpState(
          draft: SignUpDraft(
            role: Role.doctor,
            licenses: [_licence('a.pdf'), _licence('b.pdf')],
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final remove = find
          .byWidgetPredicate(
            (w) =>
                w is AssetIcon && w.asset.path == Assets.icons.deleteIcon.path,
          )
          .first;
      await tester.ensureVisible(remove);
      await tester.pumpAndSettle();
      await tester.tap(remove);
      await tester.pumpAndSettle();

      expect(find.text('a.pdf'), findsNothing);
      expect(find.text('b.pdf'), findsOneWidget);
      expect(find.text('Add another document'), findsOneWidget);
    });

    testWidgets('a pathologist picks areas as chips', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(find.text('Your licence and the work you read'), findsOneWidget);

      await tester.tap(find.text('Choose your areas'));
      await tester.pumpAndSettle();
      expect(find.text('Tissue, including lymph nodes'), findsOneWidget);
      await tester.tap(find.text('Histopathology'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done · 1 selected'));
      await tester.pumpAndSettle();

      expect(find.text('Histopathology'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AssetIcon && w.asset.path == Assets.icons.cancelIcon.path,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Histopathology'), findsNothing);
    });

    testWidgets('the area remove button meets the tap target floor', (
      tester,
    ) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose your areas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Histopathology'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done · 1 selected'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Histopathology'));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('the sheet allows all five areas', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose your areas'));
      await tester.pumpAndSettle();
      for (final area in [
        'Histopathology',
        'Cytology',
        'Haematology',
        'Microbiology',
        'Immunohistochemistry',
      ]) {
        await tester.ensureVisible(find.text(area));
        await tester.pumpAndSettle();
        await tester.tap(find.text(area));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Done · 5 selected'));
      await tester.pumpAndSettle();

      for (final area in [
        'Histopathology',
        'Cytology',
        'Haematology',
        'Microbiology',
        'Immunohistochemistry',
      ]) {
        expect(find.text(area), findsOneWidget);
      }
    });

    testWidgets('areas and the add button fill with theme roles', (
      tester,
    ) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final addButtons = tester
          .widgetList<Material>(find.byType(Material))
          .where(
            (m) =>
                m.borderRadius == BorderRadius.circular(AppRadii.card) &&
                m.color == AppColors.mintLight,
          );
      expect(addButtons, hasLength(1));

      await tester.tap(find.text('Choose your areas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Histopathology'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done · 1 selected'));
      await tester.pumpAndSettle();

      final chips = tester.widgetList<Container>(find.byType(Container)).where((
        c,
      ) {
        final decoration = c.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == BorderRadius.circular(AppRadii.pill) &&
            decoration.color == AppColors.lavenderLight;
      });
      expect(chips, hasLength(1));
    });

    testWidgets("the document sheet shows the pathologist's subtitle", (
      tester,
    ) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add another document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add another document'));
      await tester.pumpAndSettle();

      expect(
        find.text('Licence, practising certificate or ID. Up to two.'),
        findsOneWidget,
      );
      expect(
        find.text('Practising licence or specialist certificate. Up to two.'),
        findsNothing,
      );
    });

    testWidgets('back keeps the KMPDC number in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await tester.enterText(find.byType(TextField), 'A 12345');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      expect(committedDraft(signUpBloc).kmpdcNumber, 'A 12345');
    });
  });
}
