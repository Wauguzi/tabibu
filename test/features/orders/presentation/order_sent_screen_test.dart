import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/presentation/order_sent_screen.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('OrderSentScreen', () {
    final en = lookupAppLocalizations(const Locale('en'));
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    final pathologist = PractitionerModel.empty().copyWith(
      uid: 'path-a',
      title: 'Dr.',
      firstName: 'Achieng',
      lastName: 'Odhiambo',
      isPathologist: true,
      isAvailable: true,
    );

    OrderSendSuccess sent({RiskCheckModel? riskCheck}) => OrderSendSuccess(
      draft: const OrderDraft(
        appointmentUid: 'appt-1',
        caseUid: 'case-1',
        testIds: ['t1'],
        specimen: 'Left axilla',
        created: true,
        pathologistUid: 'path-a',
      ),
      tests: [
        LabTestModel.fromJson({
          'labTestId': 't1',
          'testTypeId': 'histology',
          'testTypeName': 'Histopathology and Cytology',
          'name': 'Histology · sentinel lymph node',
          'isActive': true,
          'testPriceKes': 2500,
          'isPriceEstimate': false,
          'tatCollectionToDelivery': 24,
          'tatDeliveryToResults': 48,
          'totalTurnaroundTime': 72,
        }),
      ],
      pathologists: [pathologist],
      riskCheck: riskCheck,
      riskCheckSettled: true,
    );

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      final base = RoleSessions.doctor();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: base));
    });

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const OrderSentScreen(caseUid: 'case-1'),
        ),
      );
      await tester.pump();
    }

    testWidgets('names the pathologist and summarises the order', (
      tester,
    ) async {
      when(
        () => blocs.order.state,
      ).thenReturn(sent(riskCheck: const RiskCheckModel(status: 'Ready')));
      await pump(tester);

      expect(find.text(en.orderSentHero('Dr. Odhiambo')), findsOneWidget);
      expect(find.text('Histology · sentinel lymph node'), findsOneWidget);
      expect(find.text('Left axilla'), findsOneWidget);
      expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
      expect(find.text(en.orderRiskClear), findsOneWidget);
      expect(
        tester.widget<CaseStepper>(find.byType(CaseStepper)).current,
        2,
        reason: 'with the pathologist until the case arrives',
      );
      verify(
        () => blocs.cases.add(
          CasesRefreshed(uid: RoleSessions.doctor().doctor.uid, role: .doctor),
        ),
      ).called(1);
    });

    testWidgets('a flag reads as protocol advised; an unfinished check says '
        'so', (tester) async {
      when(() => blocs.order.state).thenReturn(
        sent(
          riskCheck: const RiskCheckModel(
            status: 'Ready',
            advisoryKey: 'VhfProtocol',
          ),
        ),
      );
      await pump(tester);
      expect(find.text(en.orderSummaryProtocol), findsOneWidget);

      when(
        () => blocs.order.state,
      ).thenReturn(sent(riskCheck: const RiskCheckModel(status: 'Running')));
      await tester.pumpApp(
        MultiBlocProvider(
          key: UniqueKey(),
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const OrderSentScreen(caseUid: 'case-1'),
        ),
      );
      await tester.pump();
      expect(find.text(en.orderSummaryRiskPending), findsOneWidget);
    });

    testWidgets('shows the case number once the case has synced', (
      tester,
    ) async {
      when(() => blocs.order.state).thenReturn(sent());
      when(() => blocs.cases.state).thenReturn(
        const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'case-1',
              orderNumber: 'ODR-JK-AW-02112026-001',
              currentStage: 'PathologistRequested',
            ),
          ],
        ),
      );
      await pump(tester);

      expect(find.text('ODR-JK-AW-02112026-001'), findsOneWidget);
      expect(find.byType(BottomActionBar), findsOneWidget);
    });
  });
}
