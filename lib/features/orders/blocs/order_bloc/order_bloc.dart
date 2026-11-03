import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/insurer_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:uuid/uuid.dart';

/// The order wizard (F-12): tests, details, create, the AI risk check, the
/// pathologist, send. The case is created once, under a uid made when the
/// wizard opens; the risk check is advice the doctor reads (H-11), and a
/// flag must be confirmed before the sample is sent on.
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    ReferenceDataHelper? referenceData,
    PractitionerCacheHelper? practitioners,
    CaseFirebase? cases,
    InternetService? internet,
    Future<void> Function(Duration)? delay,
    DateTime Function()? clock,
  }) : _referenceData = referenceData ?? getIt<ReferenceDataHelper>(),
       _practitioners = practitioners ?? getIt<PractitionerCacheHelper>(),
       _cases = cases ?? getIt<CaseFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       _delay = delay ?? Future<void>.delayed,
       _clock = clock ?? DateTime.now,
       super(const OrderInitial()) {
    on<OrderStarted>(_onStarted, transformer: restartable());
    on<OrderTestToggled>(_onTestToggled);
    on<OrderDetailsChanged>(_onDetailsChanged);
    on<OrderPaymentChanged>(_onPaymentChanged);
    // One create or send at a time: a double tap must not repeat a write.
    on<OrderCreateRequested>(_onCreate, transformer: droppable());
    on<OrderPathologistSelected>(_onPathologistSelected);
    on<OrderProtocolConfirmed>(_onProtocolConfirmed);
    on<OrderSendRequested>(_onSend, transformer: droppable());
    on<OrderReset>((_, emit) {
      _watch++;
      emit(const OrderInitial());
    });
  }

  final ReferenceDataHelper _referenceData;
  final PractitionerCacheHelper _practitioners;
  final CaseFirebase _cases;
  final InternetService _internet;
  final Future<void> Function(Duration) _delay;
  final DateTime Function() _clock;
  final Uuid _uuid = const Uuid();

  static const pollEvery = Duration(seconds: 3);
  static const pollFor = Duration(seconds: 90);
  static const _offline = <AppError>{
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Bumped by a reset or a new watch, so a poll left over from an earlier
  /// case stops instead of writing into this one.
  int _watch = 0;

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _onStarted(OrderStarted event, Emitter<OrderState> emit) async {
    final reopen = event.caseUid.isNotEmpty;
    final resume =
        state.draft.appointmentUid == event.appointmentUid &&
        (!reopen || state.draft.caseUid == event.caseUid) &&
        state is! OrderSendSuccess &&
        state is! OrderInitial;
    final draft = resume
        ? state.draft
        : OrderDraft(
            appointmentUid: event.appointmentUid,
            patientId: event.patientId,
            patientName: event.patientName,
            doctorUid: event.doctorUid,
            caseUid: reopen ? event.caseUid : _uuid.v4(),
            testIds: event.testIds.take(OrderDraft.maxTests).toList(),
            collectedAt: _clock(),
            created: reopen,
          );
    if (!resume) _watch++;
    emit(
      OrderLoadInProgress(
        draft: draft,
        tests: state.tests,
        testTypes: state.testTypes,
        insurers: state.insurers,
        pathologists: state.pathologists,
        riskCheck: resume ? state.riskCheck : null,
        riskCheckSettled: resume && state.riskCheckSettled,
        offline: state.offline,
      ),
    );
    try {
      final tests = await _referenceData.activeLabTests();
      final types = await _referenceData.labTestTypes();
      final insurers = await _referenceData.insurers();
      var offline = false;
      List<PractitionerModel> directory;
      try {
        directory = await _practitioners.syncPractitioners();
      } on AppError catch (e) {
        if (!_offline.contains(e)) rethrow;
        offline = true;
        directory = await _practitioners.getPractitioners();
      }
      final known = {for (final t in tests) t.labTestId};
      // Edits made while the lists loaded belong to this draft: keep them.
      final current = state.draft.caseUid == draft.caseUid
          ? state.draft
          : draft;
      emit(
        OrderEditing(
          draft: current.copyWith(
            testIds: current.testIds.where(known.contains).toList(),
          ),
          tests: tests,
          testTypes: types,
          insurers: insurers,
          pathologists: _pathologists(
            directory,
            event.doctorUid,
            event.declinedPathologistUids,
          ),
          riskCheck: state.riskCheck,
          riskCheckSettled: state.riskCheckSettled,
          offline: offline,
        ),
      );
    } on Object catch (e) {
      emit(_failure(e, load: true));
      return;
    }
    if (reopen && !state.riskCheckSettled) await _watchRiskCheck(emit);
  }

  /// Who the doctor may ask: listed pathologists taking cases, never the
  /// doctor and never one who already refused this case, as the server
  /// checks before a request.
  List<PractitionerModel> _pathologists(
    List<PractitionerModel> directory,
    String doctorUid,
    List<String> declined,
  ) => [
    for (final p in directory)
      if (p.isPathologist &&
          p.isAvailable &&
          p.uid != doctorUid &&
          !declined.contains(p.uid))
        p,
  ]..sort((a, b) => a.fullName.compareTo(b.fullName));

  void _onTestToggled(OrderTestToggled event, Emitter<OrderState> emit) {
    if (state.draft.created) return;
    final ids = [...state.draft.testIds];
    if (!ids.remove(event.labTestId)) {
      if (ids.length >= OrderDraft.maxTests) return;
      ids.add(event.labTestId);
    }
    emit(_editing(state.draft.copyWith(testIds: ids)));
  }

  void _onDetailsChanged(OrderDetailsChanged event, Emitter<OrderState> emit) {
    if (state.draft.created) return;
    emit(
      _editing(
        state.draft.copyWith(
          priority: event.priority,
          collectedAt: event.collectedAt,
          specimen: event.specimen,
          clinicalNotes: event.clinicalNotes,
        ),
      ),
    );
  }

  void _onPaymentChanged(OrderPaymentChanged event, Emitter<OrderState> emit) {
    if (state.draft.created) return;
    emit(
      _editing(
        state.draft.copyWith(
          insured: event.insured,
          insurerId: event.insurerId,
          insurerName: event.insurerName,
          policyNumber: event.policyNumber,
        ),
      ),
    );
  }

  Future<void> _onCreate(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    final draft = state.draft;
    if (draft.caseUid.isEmpty || draft.issues(_clock()).isNotEmpty) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (!draft.created) {
      if (!await _internet.check()) {
        emit(_failure(AppError.noInternet));
        return;
      }
      emit(_copy(OrderWriteInProgress.new));
      try {
        // Idempotent by caseUid: a retry after a lost reply answers "exists".
        await _cases.createOrder(
          caseUid: draft.caseUid,
          appointmentUid: draft.appointmentUid,
          patientId: draft.patientId,
          labTestIds: draft.testIds,
          priority: draft.priority.value,
          sampleCollectedAt: draft.collectedAt!.toUtc().toIso8601String(),
          payment: draft.payment,
          clinicalNotes: draft.clinicalNotes.trim(),
          sampleNotes: draft.specimen.trim(),
        );
      } on Object catch (e) {
        emit(_failure(e));
        return;
      }
      emit(_copy(OrderCreateSuccess.new, draft: draft.copyWith(created: true)));
    }
    await _watchRiskCheck(emit);
  }

  /// Polls the case's risk check until it is Ready or Failed, or [pollFor]
  /// has passed. A failed read is retried at the next tick; the doctor can
  /// send once the wait is over either way (F-12).
  Future<void> _watchRiskCheck(Emitter<OrderState> emit) async {
    final watch = ++_watch;
    final caseUid = state.draft.caseUid;
    final ticks = pollFor.inMilliseconds ~/ pollEvery.inMilliseconds;
    for (var tick = 0; tick <= ticks; tick++) {
      if (tick > 0) await _delay(pollEvery);
      if (emit.isDone || watch != _watch || state.draft.caseUid != caseUid) {
        return;
      }
      RiskCheckModel? check;
      try {
        check = await _cases.fetchRiskCheck(caseUid);
      } on Object {
        check = null;
      }
      if (emit.isDone || watch != _watch) return;
      final settled =
          check?.statusValue == JobStatus.ready ||
          check?.statusValue == JobStatus.failed;
      if (check != null || tick == ticks) {
        emit(
          _copy(
            OrderRiskCheckUpdated.new,
            riskCheck: check ?? state.riskCheck,
            riskCheckSettled: settled || tick == ticks,
          ),
        );
      }
      if (settled) return;
    }
  }

  void _onPathologistSelected(
    OrderPathologistSelected event,
    Emitter<OrderState> emit,
  ) {
    if (!state.pathologists.any((p) => p.uid == event.pathologistUid)) return;
    emit(_editing(state.draft.copyWith(pathologistUid: event.pathologistUid)));
  }

  void _onProtocolConfirmed(
    OrderProtocolConfirmed event,
    Emitter<OrderState> emit,
  ) {
    emit(_editing(state.draft.copyWith(protocolConfirmed: event.confirmed)));
  }

  Future<void> _onSend(
    OrderSendRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (!state.canSend) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    emit(_copy(OrderWriteInProgress.new));
    try {
      await _cases.requestPathologist(
        caseUid: state.draft.caseUid,
        pathologistUid: state.draft.pathologistUid,
      );
      _watch++;
      emit(_copy(OrderSendSuccess.new));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  OrderState _editing(OrderDraft draft) =>
      _copy(OrderEditing.new, draft: draft);

  OrderState _copy(
    OrderState Function({
      OrderDraft draft,
      List<LabTestModel> tests,
      List<LabTestTypeModel> testTypes,
      List<InsurerModel> insurers,
      List<PractitionerModel> pathologists,
      RiskCheckModel? riskCheck,
      bool riskCheckSettled,
      bool offline,
    })
    build, {
    OrderDraft? draft,
    RiskCheckModel? riskCheck,
    bool? riskCheckSettled,
  }) => build(
    draft: draft ?? state.draft,
    tests: state.tests,
    testTypes: state.testTypes,
    insurers: state.insurers,
    pathologists: state.pathologists,
    riskCheck: riskCheck ?? state.riskCheck,
    riskCheckSettled: riskCheckSettled ?? state.riskCheckSettled,
    offline: state.offline,
  );

  OrderState _failure(Object e, {bool load = false}) {
    final error = _toAppError(e);
    return load
        ? OrderLoadFailure(
            error: error,
            draft: state.draft,
            tests: state.tests,
            testTypes: state.testTypes,
            insurers: state.insurers,
            pathologists: state.pathologists,
            riskCheck: state.riskCheck,
            riskCheckSettled: state.riskCheckSettled,
            offline: state.offline,
          )
        : OrderWriteFailure(
            error: error,
            draft: state.draft,
            tests: state.tests,
            testTypes: state.testTypes,
            insurers: state.insurers,
            pathologists: state.pathologists,
            riskCheck: state.riskCheck,
            riskCheckSettled: state.riskCheckSettled,
            offline: state.offline,
          );
  }
}
