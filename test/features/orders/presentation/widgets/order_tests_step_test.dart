import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_tests_step.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

OrderEditing _catalogue() => OrderEditing(
  testTypes: [
    for (final (id, name) in const [
      ('haem', 'Haematology'),
      ('chem', 'Clinical chemistry'),
      ('micro', 'Microbiology'),
      ('histo', 'Histopathology'),
      ('cyto', 'Cytopathology'),
      ('immuno', 'Immunology and serology'),
    ])
      LabTestTypeModel.empty().copyWith(testTypeId: id, name: name),
  ],
  tests: [
    for (final (id, typeId, typeName) in const [
      ('t1', 'haem', 'Haematology'),
      ('t2', 'chem', 'Clinical chemistry'),
      ('t3', 'micro', 'Microbiology'),
      ('t4', 'histo', 'Histopathology'),
      ('t5', 'cyto', 'Cytopathology'),
      ('t6', 'immuno', 'Immunology and serology'),
    ])
      LabTestModel.empty().copyWith(
        labTestId: id,
        name: 'Test $id',
        testTypeId: typeId,
        testTypeName: typeName,
        isActive: true,
        testPriceKes: 1200,
      ),
  ],
);

Finder _chipStrip() => find.byWidgetPredicate(
  (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
);

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

    for (final locale in [const Locale('en'), const Locale('sw')]) {
      testWidgets('99: type chips stay one row and scroll at 2.0x '
          '(${locale.languageCode})', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 2000);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final order = _MockOrderBloc();
        when(() => order.state).thenReturn(_catalogue());
        await tester.pumpApp(
          BlocProvider<OrderBloc>.value(
            value: order,
            child: OrderTestsStep(state: order.state, onNext: () {}),
          ),
          locale: locale,
        );
        await tester.pump();

        final strip = _chipStrip();
        expect(strip, findsOneWidget);
        final stripHeight = tester.getSize(strip).height;
        // One chip row (not wrapped): tall text at 2.0x still stays under
        // two chip heights.
        expect(stripHeight, lessThan(120));

        final scrollable = find.descendant(
          of: strip,
          matching: find.byType(Scrollable),
        );
        final before = tester
            .state<ScrollableState>(scrollable)
            .position
            .pixels;
        await tester.drag(strip, const Offset(-200, 0));
        await tester.pumpAndSettle();
        expect(
          tester.state<ScrollableState>(scrollable).position.pixels,
          greaterThan(before),
        );
      });
    }
  });
}
