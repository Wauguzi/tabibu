import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_details_step.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_patient_step.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_send_step.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_tests_step.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-ORDER-CATALOGUE to D-ORDER-PATHOLOGIST (F-12): tests, details, then the
/// risk check and the pathologist. Once the case is created the first two
/// steps are closed: back from the last step leaves the wizard, and the
/// draft waits in [OrderBloc] for the doctor to come back to it. Opened
/// with no appointment (the home "+"), a Patient step comes first.
class OrderScreen extends StatefulWidget {
  const OrderScreen({this.appointmentUid = '', this.caseUid = '', super.key});

  final String appointmentUid;
  final String caseUid;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _step = 0;
  bool _started = false;
  String _chosenUid = '';

  /// The "+" path: no visit fixed, so the wizard starts at Patient.
  bool get _pickPatient =>
      widget.appointmentUid.isEmpty && widget.caseUid.isEmpty;

  int get _total => _pickPatient ? 4 : 3;

  /// The visit the draft hangs off: the route's, or the picked patient's.
  String get _effectiveUid =>
      widget.appointmentUid.isEmpty ? _chosenUid : widget.appointmentUid;

  String get _doctorUid => switch (context.read<AuthBloc>().state.session) {
    PractitionerSession(:final doctor) => doctor.uid,
    _ => '',
  };

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// Opens the draft once the appointment is known; a resumed draft whose
  /// case already exists opens on its last step.
  void _start() {
    if (_started) return;
    final doctorUid = _doctorUid;
    final appointment = context
        .read<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == _effectiveUid);
    if (appointment == null || doctorUid.isEmpty) return;
    _started = true;
    final order = context.read<OrderBloc>();
    if (widget.caseUid.isNotEmpty ||
        (order.state.draft.appointmentUid == _effectiveUid &&
            order.state.draft.created)) {
      _step = _total - 1;
    }
    // A reopened order never offers a pathologist who already refused.
    final declined = widget.caseUid.isEmpty
        ? const <String>[]
        : context
                  .read<CasesBloc>()
                  .state
                  .cases
                  .firstWhereOrNull((c) => c.uid == widget.caseUid)
                  ?.declinedPathologistUids ??
              const <String>[];
    order.add(
      OrderStarted(
        appointmentUid: appointment.uid,
        patientId: appointment.patientId,
        patientName: appointment.patientName,
        doctorUid: doctorUid,
        caseUid: widget.caseUid,
        declinedPathologistUids: declined,
      ),
    );
  }

  /// A patient picked on the first step: the same visit just advances;
  /// another visit restarts, confirming first when the draft has content.
  Future<void> _choose(AppointmentModel appointment) async {
    final order = context.read<OrderBloc>();
    if (order.state.draft.appointmentUid == appointment.uid) {
      setState(() {
        _chosenUid = appointment.uid;
        _step = order.state.draft.created ? _total - 1 : 1;
      });
      return;
    }
    if (order.state.draft.hasContent) {
      final l10n = context.l10n;
      final confirmed = await showSettledSheet<bool>(
        context,
        title: l10n.orderPatientChangeTitle(appointment.patientName),
        subtitle: l10n.orderPatientChangeBody,
        cancelLabel: l10n.commonCancel,
        builder: (sheet) => TabibuButton.primary(
          label: l10n.orderPatientChangeConfirm,
          onTap: () => Navigator.of(sheet).pop(true),
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    _started = true;
    order.add(
      OrderStarted(
        appointmentUid: appointment.uid,
        patientId: appointment.patientId,
        patientName: appointment.patientName,
        doctorUid: _doctorUid,
      ),
    );
    setState(() {
      _chosenUid = appointment.uid;
      _step = 1;
    });
  }

  void _back() {
    final created = context.read<OrderBloc>().state.draft.created;
    if (_step == 0 || created) {
      context.pop();
      return;
    }
    setState(() => _step--);
  }

  void _next() => setState(() => _step++);

  void _onState(BuildContext context, OrderState state) {
    final l10n = context.l10n;
    switch (state) {
      case OrderCreateSuccess():
        setState(() => _step = _total - 1);
      case OrderSendSuccess(:final draft):
        OrderSentRoute(caseUid: draft.caseUid).pushReplacement(context);
      case OrderWriteFailure(:final error) || OrderLoadFailure(:final error):
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(l10n),
            isError: true,
            dismissLabel: l10n.commonDismiss,
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<AppointmentsBloc, AppointmentsState>(
      // The doctor's appointments may still be loading on a cold start.
      listener: (_, _) => _start(),
      child: BlocConsumer<OrderBloc, OrderState>(
        listenWhen: (previous, current) =>
            current.draft.appointmentUid == _effectiveUid &&
            previous.runtimeType != current.runtimeType,
        listener: _onState,
        builder: (context, state) {
          final mine = state.draft.appointmentUid == _effectiveUid;
          final loading =
              !mine || state is OrderInitial || state is OrderLoadInProgress;
          return PopScope(
            canPop: _step == 0 || state.draft.created,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back();
            },
            // A tap on empty space drops the keyboard; fields and buttons
            // keep their own taps.
            child: GestureDetector(
              behavior: .translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenMargin,
                          AppSpacing.sm,
                          AppSpacing.screenMargin,
                          0,
                        ),
                        child: StepHeader(
                          step: _step + 1,
                          total: _total,
                          progressLabel: l10n.orderStepProgress(
                            _step + 1,
                            _total,
                          ),
                          backLabel: l10n.commonBack,
                          onBack: _back,
                        ),
                      ),
                      Expanded(
                        child: _pickPatient && _step == 0
                            ? OrderPatientStep(
                                appointments: context
                                    .watch<AppointmentsBloc>()
                                    .state
                                    .appointments,
                                doctorUid: _doctorUid,
                                now: DateTime.now(),
                                selectedAppointmentUid: _effectiveUid,
                                onPick: (a) => unawaited(_choose(a)),
                              )
                            : loading
                            ? _waiting(context)
                            : switch (_pickPatient ? _step - 1 : _step) {
                                0 => OrderTestsStep(
                                  state: state,
                                  onNext: _next,
                                ),
                                1 => OrderDetailsStep(state: state),
                                _ => OrderSendStep(state: state),
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The spinner, or "not found" once the appointments have loaded without
  /// this one.
  Widget _waiting(BuildContext context) {
    final l10n = context.l10n;
    final appointments = context.watch<AppointmentsBloc>().state;
    final missing =
        appointments is AppointmentsLoadSuccess &&
        appointments.appointments.none((a) => a.uid == _effectiveUid);
    if (missing) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: EmptyState(
          icon: Assets.icons.alertIcon,
          title: l10n.orderAppointmentMissing,
        ),
      );
    }
    return Center(child: LoadingView(semanticLabel: l10n.orderLoadingLabel));
  }
}
