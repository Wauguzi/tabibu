import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

class _MockReferenceData extends Mock implements ReferenceDataHelper {}

class _MockPractitioners extends Mock implements PractitionerCacheHelper {}

class _MockCases extends Mock implements CaseFirebase {}

class _MockInternet extends Mock implements InternetService {}

final _now = DateTime.utc(2026, 11, 2, 9);

LabTestModel _test(String id) => LabTestModel.fromJson({
  'labTestId': id,
  'testTypeId': 'histology',
  'testTypeName': 'Histopathology and Cytology',
  'name': 'Test $id',
  'isActive': true,
  'testPriceKes': 1000,
  'isPriceEstimate': false,
  'tatCollectionToDelivery': 24,
  'tatDeliveryToResults': 48,
  'totalTurnaroundTime': 72,
});

PractitionerModel _practitioner(
  String uid, {
  bool pathologist = true,
  bool available = true,
  String firstName = 'Achieng',
}) => PractitionerModel.empty().copyWith(
  uid: uid,
  firstName: firstName,
  lastName: 'Odhiambo',
  isPathologist: pathologist,
  isAvailable: available,
);

RiskCheckModel _check(String status, {String advisoryKey = ''}) =>
    RiskCheckModel(status: status, advisoryKey: advisoryKey);

const _started = OrderStarted(
  appointmentUid: 'appt-1',
  patientId: 'pat-1',
  patientName: 'Amina Wambui',
  doctorUid: 'doc-1',
);

void main() {
  late _MockReferenceData referenceData;
  late _MockPractitioners practitioners;
  late _MockCases cases;
  late _MockInternet internet;
  late List<Duration> waits;

  setUp(() {
    referenceData = _MockReferenceData();
    practitioners = _MockPractitioners();
    cases = _MockCases();
    internet = _MockInternet();
    waits = [];
    when(
      () => referenceData.activeLabTests(),
    ).thenAnswer((_) async => [for (var i = 0; i < 12; i++) _test('t$i')]);
    when(() => referenceData.labTestTypes()).thenAnswer((_) async => []);
    when(() => referenceData.insurers()).thenAnswer((_) async => []);
    when(() => practitioners.syncPractitioners()).thenAnswer(
      (_) async => [
        _practitioner('path-b', firstName: 'Peter'),
        _practitioner('path-a'),
        _practitioner('doc-2', pathologist: false),
        _practitioner('path-busy', available: false),
        _practitioner('doc-1'),
      ],
    );
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => cases.createOrder(
        caseUid: any(named: 'caseUid'),
        appointmentUid: any(named: 'appointmentUid'),
        patientId: any(named: 'patientId'),
        labTestIds: any(named: 'labTestIds'),
        priority: any(named: 'priority'),
        sampleCollectedAt: any(named: 'sampleCollectedAt'),
        payment: any(named: 'payment'),
        clinicalNotes: any(named: 'clinicalNotes'),
        sampleNotes: any(named: 'sampleNotes'),
      ),
    ).thenAnswer((_) async => {'status': 'created'});
    when(
      () => cases.requestPathologist(
        caseUid: any(named: 'caseUid'),
        pathologistUid: any(named: 'pathologistUid'),
      ),
    ).thenAnswer((_) async => {'status': 'ok'});
  });

  OrderBloc build() => OrderBloc(
    referenceData: referenceData,
    practitioners: practitioners,
    cases: cases,
    internet: internet,
    delay: (d) async => waits.add(d),
    clock: () => _now,
  );

  /// A started bloc with one test picked, ready to create.
  Future<OrderBloc> ready() async {
    final bloc = build()
      ..add(_started)
      ..add(const OrderTestToggled(labTestId: 't1'));
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<OrderEditing>().having((s) => s.draft.testIds, 'tests', ['t1']),
      ),
    );
    return bloc;
  }

  void verifyNotCreated() => verifyNever(
    () => cases.createOrder(
      caseUid: any(named: 'caseUid'),
      appointmentUid: any(named: 'appointmentUid'),
      patientId: any(named: 'patientId'),
      labTestIds: any(named: 'labTestIds'),
      priority: any(named: 'priority'),
      sampleCollectedAt: any(named: 'sampleCollectedAt'),
      payment: any(named: 'payment'),
      clinicalNotes: any(named: 'clinicalNotes'),
      sampleNotes: any(named: 'sampleNotes'),
    ),
  );

  group('OrderStarted', () {
    test('opens a fresh draft with one case uid and the catalogue', () async {
      final bloc = build()..add(_started);
      final state = await bloc.stream.firstWhere((s) => s is OrderEditing);

      expect(state.draft.caseUid, isNotEmpty);
      expect(state.draft.collectedAt, _now);
      expect(state.tests, hasLength(12));
      // Listed, available pathologists only, never the doctor, by name.
      expect(state.pathologists.map((p) => p.uid), ['path-a', 'path-b']);
      await bloc.close();
    });

    test('the same appointment resumes its draft and case uid', () async {
      final bloc = await ready();
      final first = bloc.state.draft.caseUid;

      bloc.add(_started);
      final again = await bloc.stream.firstWhere((s) => s is OrderEditing);

      expect(again.draft.caseUid, first);
      expect(again.draft.testIds, ['t1']);
      await bloc.close();
    });

    test('another appointment starts afresh', () async {
      final bloc = await ready();
      final first = bloc.state.draft.caseUid;

      bloc.add(
        const OrderStarted(
          appointmentUid: 'appt-2',
          patientId: 'pat-2',
          patientName: 'Mary Njeri',
          doctorUid: 'doc-1',
        ),
      );
      final next = await bloc.stream.firstWhere((s) => s is OrderEditing);

      expect(next.draft.caseUid, isNot(first));
      expect(next.draft.testIds, isEmpty);
      await bloc.close();
    });

    test('keeps only known preselected tests, at most ten', () async {
      final bloc = build()
        ..add(
          OrderStarted(
            appointmentUid: 'appt-1',
            patientId: 'pat-1',
            patientName: 'Amina',
            doctorUid: 'doc-1',
            testIds: ['gone', for (var i = 0; i < 12; i++) 't$i'],
          ),
        );
      final state = await bloc.stream.firstWhere((s) => s is OrderEditing);

      expect(state.draft.testIds, [for (var i = 0; i < 9; i++) 't$i']);
      await bloc.close();
    });

    test('offline reads the cached directory and says so', () async {
      when(
        () => practitioners.syncPractitioners(),
      ).thenThrow(AppError.noInternet);
      when(
        () => practitioners.getPractitioners(),
      ).thenAnswer((_) async => [_practitioner('path-a')]);
      final bloc = build()..add(_started);
      final state = await bloc.stream.firstWhere((s) => s is OrderEditing);

      expect(state.offline, isTrue);
      expect(state.pathologists, hasLength(1));
      await bloc.close();
    });
  });

  group('editing', () {
    test('toggles tests, up to ten', () async {
      final bloc = await ready();
      for (var i = 2; i < 12; i++) {
        bloc.add(OrderTestToggled(labTestId: 't$i'));
      }
      bloc.add(const OrderTestToggled(labTestId: 't1'));
      await pumpEventQueue();

      expect(bloc.state.draft.testIds, [for (var i = 2; i < 11; i++) 't$i']);
      await bloc.close();
    });

    test('details and payment change the draft', () async {
      final bloc = await ready()
        ..add(
          const OrderDetailsChanged(
            priority: Urgency.urgent,
            specimen: 'Left axilla',
            clinicalNotes: 'Assess for metastasis.',
          ),
        )
        ..add(
          const OrderPaymentChanged(
            insured: true,
            insurerId: 'jubilee-health',
            policyNumber: 'POL 123/4',
          ),
        );
      await pumpEventQueue();

      final draft = bloc.state.draft;
      expect(draft.priority, Urgency.urgent);
      expect(draft.specimen, 'Left axilla');
      expect(draft.payment, {
        'method': 'Insurance',
        'insurerId': 'jubilee-health',
        'policyNumber': 'POL 123/4',
      });
      await bloc.close();
    });
  });

  group('OrderCreateRequested', () {
    test('offline fails fast and keeps the draft', () async {
      when(() => internet.check()).thenAnswer((_) async => false);
      final bloc = await ready()
        ..add(const OrderCreateRequested());
      final state = await bloc.stream.firstWhere((s) => s is OrderWriteFailure);

      expect((state as OrderWriteFailure).error, AppError.noInternet);
      expect(state.draft.created, isFalse);
      verifyNotCreated();
      await bloc.close();
    });

    test('an invalid draft never calls the server', () async {
      final bloc = build()..add(_started);
      await bloc.stream.firstWhere((s) => s is OrderEditing);
      bloc.add(const OrderCreateRequested());
      await bloc.stream.firstWhere((s) => s is OrderWriteFailure);

      verifyNotCreated();
      await bloc.close();
    });

    test(
      'creates once with the server values, then watches the risk check',
      () async {
        var calls = 0;
        when(() => cases.fetchRiskCheck(any())).thenAnswer(
          (_) async => ++calls < 3 ? _check('Running') : _check('Ready'),
        );
        final bloc = await ready()
          ..add(const OrderCreateRequested())
          ..add(const OrderCreateRequested());
        final settled = await bloc.stream.firstWhere((s) => s.riskCheckSettled);

        verify(
          () => cases.createOrder(
            caseUid: settled.draft.caseUid,
            appointmentUid: 'appt-1',
            patientId: 'pat-1',
            labTestIds: ['t1'],
            priority: 'Routine',
            sampleCollectedAt: '2026-11-02T09:00:00.000Z',
            payment: {'method': 'Cash'},
          ),
        ).called(1);
        expect(settled.draft.created, isTrue);
        expect(settled.riskCheck?.statusValue, JobStatus.ready);
        expect(waits, everyElement(OrderBloc.pollEvery));
        expect(settled.canSend, isFalse, reason: 'no pathologist yet');
        await bloc.close();
      },
    );

    test('a failed create keeps the case uid for the retry', () async {
      when(
        () => cases.createOrder(
          caseUid: any(named: 'caseUid'),
          appointmentUid: any(named: 'appointmentUid'),
          patientId: any(named: 'patientId'),
          labTestIds: any(named: 'labTestIds'),
          priority: any(named: 'priority'),
          sampleCollectedAt: any(named: 'sampleCollectedAt'),
          payment: any(named: 'payment'),
          clinicalNotes: any(named: 'clinicalNotes'),
          sampleNotes: any(named: 'sampleNotes'),
        ),
      ).thenThrow(AppError.serviceUnavailable);
      final bloc = await ready();
      final uid = bloc.state.draft.caseUid;
      bloc.add(const OrderCreateRequested());
      final failed = await bloc.stream.firstWhere(
        (s) => s is OrderWriteFailure,
      );

      expect(failed.draft.caseUid, uid);
      expect(failed.draft.created, isFalse);
      await bloc.close();
    });

    test('gives up waiting after the poll window, and may send', () async {
      when(
        () => cases.fetchRiskCheck(any()),
      ).thenAnswer((_) async => _check('Running'));
      final bloc = await ready()
        ..add(const OrderCreateRequested());
      final settled = await bloc.stream.firstWhere((s) => s.riskCheckSettled);

      expect(
        waits,
        hasLength(
          OrderBloc.pollFor.inMilliseconds ~/
              OrderBloc.pollEvery.inMilliseconds,
        ),
      );
      expect(settled.riskCheck?.statusValue, JobStatus.running);
      await bloc.close();
    });

    test('a failed read is retried at the next tick', () async {
      var calls = 0;
      when(() => cases.fetchRiskCheck(any())).thenAnswer((_) async {
        if (++calls == 1) throw AppError.serviceUnavailable;
        return _check('Failed');
      });
      final bloc = await ready()
        ..add(const OrderCreateRequested());
      final settled = await bloc.stream.firstWhere((s) => s.riskCheckSettled);

      expect(settled.riskCheck?.statusValue, JobStatus.failed);
      expect(calls, 2);
      await bloc.close();
    });
  });

  group('flags and sending', () {
    Future<OrderBloc> created(RiskCheckModel check) async {
      when(() => cases.fetchRiskCheck(any())).thenAnswer((_) async => check);
      final bloc = await ready()
        ..add(const OrderCreateRequested());
      await bloc.stream.firstWhere((s) => s.riskCheckSettled);
      return bloc;
    }

    test('a flag needs the protocol confirmed before sending', () async {
      final bloc = await created(_check('Ready', advisoryKey: 'VhfProtocol'))
        ..add(const OrderPathologistSelected(pathologistUid: 'path-a'));
      await pumpEventQueue();

      expect(bloc.state.flagged, isTrue);
      expect(bloc.state.canSend, isFalse);

      bloc.add(const OrderProtocolConfirmed(confirmed: true));
      await pumpEventQueue();
      expect(bloc.state.canSend, isTrue);
      await bloc.close();
    });

    test('only a listed pathologist can be chosen', () async {
      final bloc = await created(_check('Ready'))
        ..add(const OrderPathologistSelected(pathologistUid: 'path-busy'));
      await pumpEventQueue();

      expect(bloc.state.draft.pathologistUid, isEmpty);
      await bloc.close();
    });

    test('sends to the pathologist once', () async {
      final bloc = await created(_check('Ready'))
        ..add(const OrderPathologistSelected(pathologistUid: 'path-a'))
        ..add(const OrderSendRequested())
        ..add(const OrderSendRequested());
      final sent = await bloc.stream.firstWhere((s) => s is OrderSendSuccess);

      verify(
        () => cases.requestPathologist(
          caseUid: sent.draft.caseUid,
          pathologistUid: 'path-a',
        ),
      ).called(1);
      await bloc.close();
    });

    test('refuses to send before it may', () async {
      final bloc = await created(_check('Ready'))
        ..add(const OrderSendRequested());
      await bloc.stream.firstWhere((s) => s is OrderWriteFailure);

      verifyNever(
        () => cases.requestPathologist(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
        ),
      );
      await bloc.close();
    });

    test('a created order ignores edits to its tests and details', () async {
      final bloc = await created(_check('Ready'))
        ..add(const OrderTestToggled(labTestId: 't5'))
        ..add(const OrderDetailsChanged(specimen: 'changed'));
      await pumpEventQueue();

      expect(bloc.state.draft.testIds, ['t1']);
      expect(bloc.state.draft.specimen, isEmpty);
      await bloc.close();
    });
  });

  test('a reset stops the risk-check poll', () async {
    when(
      () => cases.fetchRiskCheck(any()),
    ).thenAnswer((_) async => _check('Running'));
    final bloc = await ready()
      ..add(const OrderCreateRequested());
    await bloc.stream.firstWhere((s) => s is OrderRiskCheckUpdated);
    bloc.add(const OrderReset());
    await pumpEventQueue();
    final calls = verify(() => cases.fetchRiskCheck(any())).callCount;
    await pumpEventQueue(times: 50);

    verifyNever(() => cases.fetchRiskCheck(any()));
    expect(bloc.state, isA<OrderInitial>());
    expect(calls, greaterThan(0));
    await bloc.close();
  });

  group('OrderDraft.issues', () {
    const base = OrderDraft(testIds: ['t1']);

    test('a complete draft has none', () {
      expect(base.copyWith(collectedAt: _now).issues(_now), isEmpty);
    });

    test('collection time is required, past and within 7 days', () {
      expect(base.issues(_now), [OrderDraftIssue.collectedAtMissing]);
      expect(
        base
            .copyWith(collectedAt: _now.add(const Duration(minutes: 1)))
            .issues(_now),
        [OrderDraftIssue.collectedAtInFuture],
      );
      expect(
        base
            .copyWith(collectedAt: _now.subtract(const Duration(days: 8)))
            .issues(_now),
        [OrderDraftIssue.collectedAtTooOld],
      );
    });

    test('insurance needs an insurer and a policy number', () {
      final insured = base.copyWith(collectedAt: _now, insured: true);
      expect(insured.issues(_now), [
        OrderDraftIssue.insurerMissing,
        OrderDraftIssue.policyInvalid,
      ]);
      expect(
        insured
            .copyWith(insurerId: 'other', insurerName: 'A', policyNumber: 'P1')
            .issues(_now),
        [OrderDraftIssue.insurerNameInvalid, OrderDraftIssue.policyInvalid],
      );
    });

    test("text limits are the server's", () {
      final long = base.copyWith(
        collectedAt: _now,
        specimen: 'x' * 1001,
        clinicalNotes: 'x' * 2001,
      );
      expect(long.issues(_now), [
        OrderDraftIssue.specimenTooLong,
        OrderDraftIssue.notesTooLong,
      ]);
    });
  });
}
