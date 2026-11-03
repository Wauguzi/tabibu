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
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_details_step.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_send_step.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_tests_step.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-ORDER-CATALOGUE to D-ORDER-PATHOLOGIST (F-12): tests, details, then the
/// risk check and the pathologist. Once the case is created the first two
/// steps are closed: back from the last step leaves the wizard, and the
/// draft waits in [OrderBloc] for the doctor to come back to it.
class OrderScreen extends StatefulWidget {
  const OrderScreen({
    required this.appointmentUid,
    this.caseUid = '',
    super.key,
  });

  final String appointmentUid;
  final String caseUid;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const _total = 3;
  int _step = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// Opens the draft once the appointment is known; a resumed draft whose
  /// case already exists opens on its last step.
  void _start() {
    if (_started) return;
    final doctorUid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final appointment = context
        .read<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == widget.appointmentUid);
    if (appointment == null || doctorUid.isEmpty) return;
    _started = true;
    final order = context.read<OrderBloc>();
    if (widget.caseUid.isNotEmpty ||
        (order.state.draft.appointmentUid == widget.appointmentUid &&
            order.state.draft.created)) {
      _step = _total - 1;
    }
    order.add(
      OrderStarted(
        appointmentUid: appointment.uid,
        patientId: appointment.patientId,
        patientName: appointment.patientName,
        doctorUid: doctorUid,
        caseUid: widget.caseUid,
      ),
    );
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
            current.draft.appointmentUid == widget.appointmentUid &&
            previous.runtimeType != current.runtimeType,
        listener: _onState,
        builder: (context, state) {
          final mine = state.draft.appointmentUid == widget.appointmentUid;
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
                        child: loading
                            ? _waiting(context)
                            : switch (_step) {
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
        appointments.appointments.none((a) => a.uid == widget.appointmentUid);
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
