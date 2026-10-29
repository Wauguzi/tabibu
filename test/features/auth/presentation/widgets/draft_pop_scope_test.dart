import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DraftPopScope', () {
    late SignUpBloc bloc;

    setUp(() => bloc = SignUpBloc());
    tearDown(() => bloc.close());

    Future<void> pumpAndGoBack(
      WidgetTester tester, {
      bool canPop = true,
    }) async {
      final router = GoRouter(
        initialLocation: '/previous/step',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (_, _) => const Text('Previous step'),
            routes: [
              GoRoute(
                path: 'step',
                builder: (_, _) => BlocProvider.value(
                  value: bloc,
                  child: DraftPopScope(
                    canPop: canPop,
                    fill: (draft) => draft.copyWith(firstName: 'Amina'),
                    child: const Text('Step'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('system back commits the step to the draft', (tester) async {
      bloc.add(const SignUpRoleChosen(role: .patient, language: .en));

      await pumpAndGoBack(tester);

      expect(find.text('Previous step'), findsOneWidget);
      expect(bloc.state.draft.firstName, 'Amina');
      expect(bloc.state.draft.role, Role.patient);
    });

    testWidgets('a cleared draft stays cleared', (tester) async {
      await pumpAndGoBack(tester);

      expect(bloc.state.draft.firstName, isEmpty);
    });

    testWidgets('a blocked back neither leaves nor commits', (tester) async {
      bloc.add(const SignUpRoleChosen(role: .patient, language: .en));

      await pumpAndGoBack(tester, canPop: false);

      expect(find.text('Step'), findsOneWidget);
      expect(bloc.state.draft.firstName, isEmpty);
    });
  });
}
