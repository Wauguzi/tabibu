import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ProfileLanguageScreen', () {
    setUpAll(
      () => registerFallbackValue(
        const LanguageChangeRequested(language: AppLanguage.sw),
      ),
    );

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    bool selected(WidgetTester tester, String title) => tester
        .widgetList<OptionCard>(find.byType(OptionCard))
        .firstWhere((card) => card.title == title)
        .selected;

    testWidgets('a patient reads the body and picks a language', (
      tester,
    ) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/language',
      );
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(
        find.text(
          'Choose the language for the app, your results and health notices.',
        ),
        findsOneWidget,
      );
      expect(selected(tester, 'English'), isTrue);
      expect(selected(tester, 'Kiswahili'), isFalse);

      await tester.tap(find.text('Kiswahili'));
      await tester.pumpAndSettle();
      expect(selected(tester, 'Kiswahili'), isTrue);

      await tester.tap(find.text('Save'));
      // No answer: the button spins, so the tree never settles.
      await tester.pump();

      verify(
        () => bloc.add(const LanguageChangeRequested(language: AppLanguage.sw)),
      ).called(1);
    });

    testWidgets('a doctor reads the note under the options', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor/profile/language',
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Summaries you share are translated for each patient, whatever '
          'you choose here.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Choose the language for the app, your results and health notices.',
        ),
        findsNothing,
      );
    });

    testWidgets('a pathologist reads their own note', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist/profile/language',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Reports are always written in English for clinicians.'),
        findsOneWidget,
      );
    });

    testWidgets('a saved choice returns to the tab', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        answers: answers,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kiswahili'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(
        LanguageChangeSuccess(
          session: RoleSessions.patient,
          language: AppLanguage.sw,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('a failed save says why and stays', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/language',
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kiswahili'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(
        LanguageChangeFailure(
          session: RoleSessions.patient,
          error: AppError.noInternet,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // The screen unsaves: Save sends again.
      await tester.tap(find.text('Save'));
      await tester.pump();
      verify(
        () => bloc.add(const LanguageChangeRequested(language: AppLanguage.sw)),
      ).called(2);
    });

    testWidgets('ignores a failure that answers no save', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/language',
        states: [
          LanguageChangeFailure(
            session: RoleSessions.patient,
            error: AppError.noInternet,
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsNothing);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/language',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Lugha'), findsOneWidget);
      expect(find.text('Kiswahili'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
