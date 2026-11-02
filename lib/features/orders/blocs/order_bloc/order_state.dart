import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/data/models/insurer_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// The order wizard (F-12). [riskCheck] is the server's AI risk check for
/// the created case, advice only (H-11); [riskCheckSettled] is true once it
/// is Ready or Failed, or the wait has run out, so sending may go ahead.
/// Every state carries the last good data.
sealed class OrderState extends Equatable {
  const OrderState({
    this.draft = const OrderDraft(),
    this.tests = const <LabTestModel>[],
    this.testTypes = const <LabTestTypeModel>[],
    this.insurers = const <InsurerModel>[],
    this.pathologists = const <PractitionerModel>[],
    this.riskCheck,
    this.riskCheckSettled = false,
    this.offline = false,
  });

  final OrderDraft draft;
  final List<LabTestModel> tests;
  final List<LabTestTypeModel> testTypes;
  final List<InsurerModel> insurers;
  final List<PractitionerModel> pathologists;
  final RiskCheckModel? riskCheck;
  final bool riskCheckSettled;
  final bool offline;

  /// The risk check flagged the order: the protocol must be confirmed.
  bool get flagged =>
      riskCheck?.statusValue == JobStatus.ready &&
      (riskCheck?.advisoryKey ?? '').isNotEmpty;

  /// Everything the send step needs (F-12).
  bool get canSend =>
      draft.created &&
      riskCheckSettled &&
      draft.pathologistUid.isNotEmpty &&
      (!flagged || draft.protocolConfirmed);

  @override
  List<Object?> get props => [
    draft,
    tests,
    testTypes,
    insurers,
    pathologists,
    riskCheck,
    riskCheckSettled,
    offline,
  ];
}

final class OrderInitial extends OrderState {
  const OrderInitial();
}

final class OrderLoadInProgress extends OrderState {
  const OrderLoadInProgress({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

/// The draft is open and can change.
final class OrderEditing extends OrderState {
  const OrderEditing({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

final class OrderLoadFailure extends OrderState {
  const OrderLoadFailure({
    required this.error,
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class OrderWriteInProgress extends OrderState {
  const OrderWriteInProgress({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

/// The case exists; its risk check is being watched.
final class OrderCreateSuccess extends OrderState {
  const OrderCreateSuccess({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

final class OrderRiskCheckUpdated extends OrderState {
  const OrderRiskCheckUpdated({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

/// The pathologist has been asked: the sent screen takes over.
final class OrderSendSuccess extends OrderState {
  const OrderSendSuccess({
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });
}

final class OrderWriteFailure extends OrderState {
  const OrderWriteFailure({
    required this.error,
    super.draft,
    super.tests,
    super.testTypes,
    super.insurers,
    super.pathologists,
    super.riskCheck,
    super.riskCheckSettled,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
