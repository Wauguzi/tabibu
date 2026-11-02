import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/presentation/widgets/sign_out_sheet.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('confirmSignOut', () {
    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => confirmSignOut(context, isPatient: true),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out of Tabibu?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('signs out only once the sheet has slid away', (tester) async {
      final authBloc = MockAuthBloc();
      await tester.pumpApp(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => confirmSignOut(context, isPatient: true),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TabibuButton, 'Sign out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      verifyNever(() => authBloc.add(const SignOutRequested()));

      await tester.pumpAndSettle();
      verify(() => authBloc.add(const SignOutRequested())).called(1);
    });
  });
}
