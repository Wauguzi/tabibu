import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_history_row.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_patient_card.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_timeline_card.dart';
import 'package:tabibu/features/cases/presentation/widgets/slides_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-CASE. One case as its doctor reads it: the patient, where the case is,
/// the order, and the report once it is signed.
class DoctorCaseScreen extends StatefulWidget {
  const DoctorCaseScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<DoctorCaseScreen> createState() => _DoctorCaseScreenState();
}

class _DoctorCaseScreenState extends State<DoctorCaseScreen> {
  @override
  void initState() {
    super.initState();
    final uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: uid, role: .doctor));
    }
    cases.add(CaseLogRequested(caseUid: widget.caseUid, role: .doctor));
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: uid, role: .doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final casesState = context.watch<CasesBloc>().state;
    final appointments = context.watch<AppointmentsBloc>().state.appointments;
    final caseModel = casesState.cases.firstWhereOrNull(
      (c) => c.uid == widget.caseUid,
    );
    final loading =
        caseModel == null &&
        (casesState is CasesInitial || casesState is CasesLoadInProgress);

    return Scaffold(
      body: SafeArea(
        child: loading
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TopBar(
                      backLabel: l10n.commonBack,
                      onBack: context.pop,
                    ),
                  ),
                  Expanded(
                    child: LoadingView(semanticLabel: l10n.resultsLoadingLabel),
                  ),
                ],
              )
            : caseModel == null
            ? ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  TopBar(backLabel: l10n.commonBack, onBack: context.pop),
                  const SizedBox(height: AppSpacing.sectionGap),
                  EmptyState(title: l10n.errorDataNotFound),
                ],
              )
            : _Body(
                caseModel: caseModel,
                log: casesState.logs[widget.caseUid] ?? const [],
                appointments: appointments,
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.caseModel,
    required this.log,
    required this.appointments,
  });

  final CaseModel caseModel;
  final List<CaseLogEntryModel> log;
  final List<AppointmentModel> appointments;

  String _stageWords(AppLocalizations l10n) {
    if (caseModel.needsDoctor) return l10n.doctorCaseStageDiscuss;
    if (caseModel.isDone) return l10n.doctorCaseStageClosed;
    return switch (caseModel.doctorStep) {
      <= 1 => l10n.doctorCaseStageOrdered,
      2 => l10n.doctorCaseStageWithPathologist,
      _ => l10n.doctorCaseStageSigned,
    };
  }

  String _appointmentLine(AppLocalizations l10n, String language) {
    final facility = caseModel.doctorFacilityName;
    final appointment = appointments.firstWhereOrNull(
      (a) => a.uid == caseModel.appointmentUid,
    );
    final at = appointment == null
        ? null
        : nairobiTimeOf(appointment.scheduledStart);
    if (appointment == null || at == null) return facility;
    final name = appointment.facilityName.isNotEmpty
        ? appointment.facilityName
        : facility;
    return l10n.doctorCaseAppointmentLine(
      DateFormat('EEE d MMM', language).format(at),
      name,
    );
  }

  /// The case's own timestamp, else the log's entry into [stage].
  DateTime? _at(String raw, CaseStage stage) {
    final direct = nairobiTimeOf(raw);
    if (direct != null) return direct;
    final entry = log.firstWhereOrNull((e) => e.toStageValue == stage);
    return entry == null ? null : nairobiTimeOf(entry.createdAt);
  }

  String _fmt(DateTime? at, String language) =>
      at == null ? '' : DateFormat('EEE d MMM, h:mm a', language).format(at);

  String _priority(AppLocalizations l10n) => switch (caseModel.priorityValue) {
    .routine => l10n.doctorCaseRoutine,
    .priority => l10n.urgencyPriority,
    .urgent => l10n.doctorCaseUrgent,
  };

  List<VerificationStep> _steps(
    BuildContext context,
    AppLocalizations l10n,
    String language,
  ) {
    final test = caseModel.tests
        .map((t) => t.name)
        .where((name) => name.isNotEmpty)
        .join(', ');
    final orderedAt = _fmt(_at(caseModel.createdAt, .orderCreated), language);
    final sampleAt = _fmt(
      _at(caseModel.sampleReceivedAt, .sampleReceived),
      language,
    );
    final signedAt = _fmt(_at('', .reportSigned), language);
    final pathologist = caseModel.pathologistName;
    final reporting = caseModel.currentStageValue == .reportInProgress;
    final readingDetail = reporting
        ? [
            if (pathologist.isNotEmpty) pathologist,
            l10n.doctorCaseReportInProgress,
          ].join(' · ')
        : pathologist;
    final firstName = caseModel.patientName.trim().split(' ').firstOrNull ?? '';

    // Ordered but never sent: the reading step links to the wizard's
    // pathologist step.
    final unsent =
        caseModel.currentStageValue == .orderCreated &&
        caseModel.appointmentUid.isNotEmpty;

    // Done / Now / Next from the doctor step alone. The doctor collects the
    // sample at the visit, so an order with a test has its sample.
    final doneCount = switch (caseModel.doctorStep) {
      1 => caseModel.tests.isEmpty ? 0 : 2,
      2 => 2,
      3 => 4,
      _ => 5,
    };
    VerificationStep step({
      required String title,
      required String supporting,
      required int index,
      SvgGenImage? icon,
      VoidCallback? onSupportingTap,
    }) {
      final state = index < doneCount
          ? VerificationStepState.done
          : (index == doneCount
                ? VerificationStepState.inProgress
                : VerificationStepState.upNext);
      return VerificationStep(
        title: title,
        supporting: supporting,
        state: state,
        chipLabel: switch (state) {
          .done => l10n.chipDone,
          .inProgress => l10n.doctorCaseNow,
          .upNext => l10n.doctorCaseNext,
        },
        stateLabel: switch (state) {
          .done => l10n.chipDone,
          .inProgress => l10n.chipInProgress,
          .upNext => l10n.chipUpNext,
        },
        icon: icon,
        onSupportingTap: onSupportingTap,
      );
    }

    return [
      step(
        title: l10n.doctorCasesOrdered,
        supporting: [
          if (orderedAt.isNotEmpty) orderedAt,
          if (test.isNotEmpty) test,
        ].join(' · '),
        index: 0,
        icon: Assets.icons.documentIcon,
      ),
      step(
        title: l10n.doctorCaseSampleReceived,
        // The doctor collects the sample when ordering, so the order's own
        // time stands in until the lab's receipt is stamped.
        supporting: [
          if (sampleAt.isNotEmpty) sampleAt else orderedAt,
          if (test.isNotEmpty) test,
        ].where((part) => part.isNotEmpty).join(' · '),
        index: 1,
        icon: Assets.icons.testTubeIcon,
      ),
      step(
        title: l10n.doctorCaseReading,
        supporting: unsent ? l10n.doctorCaseAttachPathologist : readingDetail,
        onSupportingTap: unsent
            ? () => unawaited(
                OrderRoute(
                  appointmentUid: caseModel.appointmentUid,
                  caseUid: caseModel.uid,
                ).push<void>(context),
              )
            : null,
        index: 2,
        icon: Assets.icons.verificationBadge,
      ),
      step(
        title: l10n.doctorCaseReportSigned,
        supporting: signedAt,
        index: 3,
        icon: Assets.icons.tickIcon,
      ),
      step(
        title: l10n.doctorCaseDiscussWith(firstName),
        supporting: l10n.doctorCaseDiscussDetail,
        index: 4,
        icon: Assets.icons.calendarIcon,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final test = caseModel.tests.firstOrNull?.name ?? '';
    final stage = _stageWords(l10n);
    final specimen = caseModel.sampleNotes;
    // The model carries no risk-check field, so the row is omitted.
    final orderRows = [
      if (test.isNotEmpty) (l10n.doctorCaseTest, test),
      if (specimen.isNotEmpty) (l10n.doctorCaseSpecimen, specimen),
      (l10n.doctorCasePriority, _priority(l10n)),
    ];
    final openable = caseModel.needsDoctor || caseModel.doctorStep == 3;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TopBar(
          backLabel: l10n.commonBack,
          onBack: context.pop,
          title: caseModel.orderNumber,
          subtitle: test.isEmpty ? stage : l10n.doctorCaseSubtitle(test, stage),
        ),
        const SizedBox(height: AppSpacing.md),
        CasePatientCard(
          caseModel: caseModel,
          line: _appointmentLine(l10n, language),
        ),
        const SizedBox(height: AppSpacing.md),
        CaseTimelineCard(
          title: l10n.doctorCaseTimelineTitle,
          steps: _steps(context, l10n, language),
        ),
        const SizedBox(height: AppSpacing.md),
        KeyValueCard(title: l10n.doctorCaseOrder, rows: orderRows),
        if (caseModel.slideImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SlidesCard(slides: caseModel.slideImages),
        ],
        if (openable) ...[
          const SizedBox(height: AppSpacing.lg),
          TabibuButton.primary(
            label: l10n.doctorReportOpenFull,
            onTap: () => unawaited(
              DoctorReportRoute(caseUid: caseModel.uid).push<void>(context),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        CaseHistoryRow(caseUid: caseModel.uid, role: .doctor),
      ],
    );
  }
}
