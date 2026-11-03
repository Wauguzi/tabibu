import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_identity_card.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('PractitionerProfileScreen', () {
    setUpAll(
      () => registerFallbackValue(
        const PractitionerProfileChanged(
          specialties: [],
          bio: '',
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

    // Bottom sheets never settle.
    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    PractitionerSession surgeon() => PractitionerSession(
      doctor: RoleSessions.doctor().doctor.copyWith(
        phoneNumber: '+254712345678',
        email: 'w.kamau@akuh.org',
        bio: 'Breast surgeon with 12 years at Aga Khan.',
      ),
      roles: RoleSessions.doctor().roles,
    );

    Future<void> enterIn(WidgetTester tester, String label, String value) =>
        tester.enterText(
          find.descendant(
            of: find.byWidgetPredicate(
              (widget) => widget is TabibuTextField && widget.label == label,
            ),
            matching: find.byType(TextField),
          ),
          value,
        );

    testWidgets('a doctor reads their details', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile/details');
      await tester.pumpAndSettle();

      expect(find.text('Profile details'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PractitionerIdentityCard),
          matching: find.text('Dr. Wanjiru Kamau'),
        ),
        findsOneWidget,
      );
      // The hero says verified and nothing more; the number is in the licence
      // card below.
      expect(find.text('KMPDC verified'), findsOneWidget);
      expect(find.text('KMPDC verified · A 12345'), findsNothing);
      expect(find.text('Change photo'), findsOneWidget);
      expect(find.text('Shown to patients'), findsOneWidget);
      expect(find.text('General surgery'), findsOneWidget);
      expect(find.text('Only for Tabibu'), findsOneWidget);
      expect(find.text('KMPDC licence A 12345'), findsOneWidget);
      expect(
        find.text("Licence details come from KMPDC and can't be changed here."),
        findsOneWidget,
      );
    });

    testWidgets('names and email are read-only', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile/details');
      await tester.pumpAndSettle();

      final byLabel = {
        for (final field in tester.widgetList<TabibuTextField>(
          find.byType(TabibuTextField),
        ))
          field.label: field,
      };
      expect(byLabel['Full name']!.readOnly, isTrue);
      expect(byLabel['Full name']!.controller!.text, 'Dr. Wanjiru Kamau');
      expect(byLabel['Email']!.readOnly, isTrue);
      expect(byLabel['About you']!.readOnly, isFalse);
      expect(byLabel['Phone']!.readOnly, isFalse);
    });

    testWidgets('a pathologist reads areas and their section', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/details',
      );
      await tester.pumpAndSettle();

      expect(find.text('Shown to doctors'), findsOneWidget);
      expect(find.text('Histopathology · Cytology'), findsOneWidget);
      expect(find.text('KMPDC licence B 67890'), findsOneWidget);
    });

    testWidgets("the frame's Languages row stays out without a field", (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile/details');
      await tester.pumpAndSettle();

      expect(find.text('Languages'), findsNothing);
    });

    testWidgets('the specialty sheet adds to the list', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile/details');
      await tester.pumpAndSettle();

      await tester.tap(find.text('General surgery'));
      await settleSheet(tester);
      expect(find.text('Choose your specialty'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(SearchField),
          matching: find.byType(TextField),
        ),
        'Dermatology',
      );
      await tester.pump();
      await tester.tap(find.text('Dermatology').last);
      await tester.pump();
      await tester.tap(find.text('Done · 2 selected'));
      await settleSheet(tester);

      expect(find.text('General surgery · Dermatology'), findsOneWidget);
    });

    testWidgets('emptying the list keeps the old one', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile/details');
      await tester.pumpAndSettle();

      await tester.tap(find.text('General surgery'));
      await settleSheet(tester);
      await tester.enterText(
        find.descendant(
          of: find.byType(SearchField),
          matching: find.byType(TextField),
        ),
        'General surgery',
      );
      await tester.pump();
      await tester.tap(find.text('General surgery').last);
      await tester.pump();
      await tester.tap(find.text('Done · 0 selected'));
      await settleSheet(tester);

      expect(find.text('General surgery'), findsOneWidget);
    });

    testWidgets('a long bio is refused before sending', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        surgeon(),
        '/doctor/profile/details',
      );
      await tester.pumpAndSettle();

      await enterIn(tester, 'About you', 'A' * 1001);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Keep it under 1,000 characters.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a bad phone is refused before sending', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        surgeon(),
        '/doctor/profile/details',
      );
      await tester.pumpAndSettle();

      await enterIn(tester, 'Phone', 'not-a-phone');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a valid save dispatches shaped', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        surgeon(),
        '/doctor/profile/details',
      );
      await tester.pumpAndSettle();

      await enterIn(tester, 'Phone', '0712 345 678');
      await tester.tap(find.text('Save'));
      // No answer: the button spins, so the tree never settles.
      await tester.pump();

      final sent =
          verify(() => bloc.add(captureAny())).captured.single
              as PractitionerProfileChanged;
      expect(sent.specialties, ['General surgery']);
      expect(sent.bio, 'Breast surgeon with 12 years at Aga Khan.');
      expect(sent.phoneNumber, '+254712345678');
      expect(sent.picture, isNull);
    });

    testWidgets('a saved edit returns to the tab', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(surgeon(), '/doctor/profile', answers: answers);
      await tester.pumpAndSettle();

      // The tab's only circle is the card pencil.
      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(ProfileSaveSuccess(session: surgeon()));
      await tester.pumpAndSettle();

      expect(find.text('My profile'), findsOneWidget);
    });

    testWidgets('a failed save says why and stays', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        surgeon(),
        '/doctor/profile/details',
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(
        ProfileSaveFailure(session: surgeon(), error: AppError.noInternet),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      expect(find.text('Profile details'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/details',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Maelezo ya wasifu'), findsOneWidget);
      expect(find.text('Huonekana na madaktari'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
