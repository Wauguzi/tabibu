import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_tests_step.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

void main() {
  group('OrderTestsStep', () {
    testWidgets('94: a tap outside the test search dismisses it', (
      tester,
    ) async {
      final order = _MockOrderBloc();
      when(() => order.state).thenReturn(
        OrderEditing(
          tests: [
            LabTestModel.empty().copyWith(
              labTestId: 't1',
              name: 'Full blood count',
              testTypeId: 'haem',
              testTypeName: 'Haematology',
              isActive: true,
              testPriceKes: 1200,
            ),
          ],
        ),
      );
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpApp(
        BlocProvider<OrderBloc>.value(
          value: order,
          child: OrderTestsStep(state: order.state, onNext: () {}),
        ),
      );
      await tester.pump();
      final search = find.byType(TextField);
      await tester.tap(search);
      await tester.pump();
      final node = tester.widget<TextField>(search).focusNode!;
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.text(l10n.orderTestsTitle));
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });
  });
}
