import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/patient_phone_screen.dart';

import '../../../helpers/helpers.dart';

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PatientPhoneScreen', () {
    late MockSignUpBloc signUpBloc;

    setUp(() {
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
    });

    Widget screen() => BlocProvider<SignUpBloc>.value(
      value: signUpBloc,
      child: const PatientPhoneScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Your phone number'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Your phone number'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a bad number shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('The phone number is not valid. Check it and try again.'),
        findsNWidgets(2),
      );
    });

    testWidgets('a good number goes to D4', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up/patient/phone',
        routes: [
          GoRoute(path: '/sign-up/patient/phone', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/patient/area',
            builder: (_, _) => const Text('D4 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '712 345 678');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(captured.draft.phoneNumber, '+254712345678');
      expect(find.text('D4 stub'), findsOneWidget);
    });
  });
}
