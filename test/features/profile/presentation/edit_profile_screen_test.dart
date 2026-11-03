import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('EditProfileScreen', () {
    setUpAll(
      () => registerFallbackValue(
        const PatientProfileChanged(
          firstName: '',
          middleName: '',
          lastName: '',
          phoneNumber: '',
        ),
      ),
    );

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    PatientSession fullSession() => PatientSession(
      patient: RoleSessions.patient.patient.copyWith(
        middleName: 'Mumbi',
        email: 'amina.wambui@gmail.com',
      ),
      roles: RoleSessions.patient.roles,
    );

    /// The fields by label, for prefill and read-only assertions.
    Map<String, TabibuTextField> fields(WidgetTester tester) => {
      for (final field
          in tester.widgetList<TabibuTextField>(find.byType(TabibuTextField)))
        field.label: field,
    };

    testWidgets('prefills the names and phone', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(fullSession(), '/patient/profile/edit');
      await tester.pumpAndSettle();

      final byLabel = fields(tester);
      expect(byLabel['First name']!.controller!.text, 'Amina');
      expect(byLabel['Middle name']!.controller!.text, 'Mumbi');
      expect(byLabel['Last name']!.controller!.text, 'Wambui');
      expect(byLabel['Phone number']!.controller!.text, '+254712345678');
    });

    testWidgets('birth, email and sex are read-only, with the note', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(fullSession(), '/patient/profile/edit');
      await tester.pumpAndSettle();

      final byLabel = fields(tester);
      expect(byLabel['First name']!.readOnly, isFalse);
      expect(byLabel['Phone number']!.readOnly, isFalse);
      expect(byLabel['Date of birth']!.readOnly, isTrue);
      expect(byLabel['Date of birth']!.controller!.text, '14 Mar 1980');
      expect(byLabel['Email']!.readOnly, isTrue);
      expect(byLabel['Email']!.controller!.text, 'amina.wambui@gmail.com');
      expect(byLabel['Sex']!.readOnly, isTrue);
      expect(byLabel['Sex']!.controller!.text, 'Female');
      expect(
        find.text('To correct these, ask at the clinic.'),
        findsOneWidget,
      );
    });

    testWidgets('a valid save dispatches trimmed and shaped', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/edit',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is TabibuTextField && widget.label == 'First name',
          ),
          matching: find.byType(TextField),
        ),
        '  Amina ',
      );
      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is TabibuTextField && widget.label == 'Phone number',
          ),
          matching: find.byType(TextField),
        ),
        '0712 345 678',
      );
      await tester.tap(find.text('Save changes'));
      // No answer: the button spins, so the tree never settles.
      await tester.pump();

      verify(
        () => bloc.add(
          const PatientProfileChanged(
            firstName: 'Amina',
            middleName: 'Mumbi',
            lastName: 'Wambui',
            phoneNumber: '+254712345678',
          ),
        ),
      ).called(1);
    });

    testWidgets('empty names are refused before sending', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/edit',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is TabibuTextField && widget.label == 'First name',
          ),
          matching: find.byType(TextField),
        ),
        '',
      );
      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is TabibuTextField && widget.label == 'Last name',
          ),
          matching: find.byType(TextField),
        ),
        '   ',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your first name.'), findsOneWidget);
      expect(find.text('Enter your last name.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a bad phone is refused before sending', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/edit',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is TabibuTextField && widget.label == 'Phone number',
          ),
          matching: find.byType(TextField),
        ),
        '123',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a saved edit returns to the details', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/details',
        answers: answers,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is CircleIconButton &&
              widget.icon == Assets.icons.editIcon,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save changes'));
      await tester.pump();
      answers.add(ProfileSaveSuccess(session: fullSession()));
      await tester.pumpAndSettle();

      expect(find.text('About me'), findsOneWidget);
    });

    testWidgets('a failed save says why and stays', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/edit',
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save changes'));
      await tester.pump();
      answers.add(
        ProfileSaveFailure(
          session: fullSession(),
          error: AppError.noInternet,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (
      tester,
    ) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/edit',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Hariri wasifu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
