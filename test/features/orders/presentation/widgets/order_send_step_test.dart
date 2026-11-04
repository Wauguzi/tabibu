import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_send_step.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('OrderSendStep', () {
    testWidgets('94: a tap outside the pathologist search dismisses it', (
      tester,
    ) async {
      final blocs = FeatureBlocs();
      final authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<SlideUploadBloc>.value(value: blocs.slideUpload),
            BlocProvider<CasesBloc>.value(value: blocs.cases),
            BlocProvider<OrderBloc>.value(value: blocs.order),
          ],
          child: const OrderSendStep(state: OrderEditing()),
        ),
      );
      await tester.pump();
      final search = find.byType(TextField);
      await tester.tap(search);
      await tester.pump();
      final node = tester.widget<TextField>(search).focusNode!;
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      // The empty-state line sits in the same list, outside the field.
      await tester.tap(find.text(l10n.orderNoPathologists));
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });
  });
}
