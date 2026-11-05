import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide LockState;
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/app/view/app.dart' show tabibuLocalizationsDelegates;
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/routing/app_router.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/presentation/unlock_overlay.dart';
import 'package:tabibu/features/lock/presentation/widgets/pin_pad.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/feature_blocs.dart';
import '../../../helpers/role_sessions.dart';

void main() {
  late MockAuthBloc auth;
  late MockLockBloc lock;

  setUp(() {
    auth = MockAuthBloc();
    lock = MockLockBloc();
    when(() => auth.state).thenReturn(const AuthInitial());
    whenListen(
      lock,
      const Stream<LockState>.empty(),
      initialState: const LockLoadSuccess(enabled: true, locked: true),
    );
  });

  /// Same shape as [App]: overlay in `MaterialApp.router` builder, above
  /// the navigator that owns [TabibuRouter.navigatorKey].
  Future<void> pumpOverlay(WidgetTester tester) async {
    final router = GoRouter(
      navigatorKey: TabibuRouter.navigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: auth),
          BlocProvider<LockBloc>.value(value: lock),
        ],
        child: MaterialApp.router(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: tabibuLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => UnlockOverlay(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('94: the PIN overlay uses the pad, not a soft-keyboard field', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpOverlay(tester);

    expect(find.byType(PinPad), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);

    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('Forgot PIN opens the sheet from the router navigator', (
    tester,
  ) async {
    // Phone-tall surface so the Forgot link is on-screen (default 800×600
    // overflows the overlay column).
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpOverlay(tester);
    final forgot = find.text('Forgot PIN?');
    expect(forgot, findsOneWidget);
    await tester.ensureVisible(forgot);
    await tester.tap(forgot);
    await tester.pumpAndSettle();
    expect(find.text('Forgot your PIN?'), findsOneWidget);
    expect(find.text('Sign in again'), findsWidgets);
  });

  testWidgets('locked load failure offers retry and sign-out', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    whenListen(
      lock,
      const Stream<LockState>.empty(),
      initialState: const LockLoadFailure(
        error: AppError.unknown,
        locked: true,
      ),
    );
    await pumpOverlay(tester);
    expect(find.text('Could not check app lock'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Sign in again'), findsOneWidget);
  });
}
