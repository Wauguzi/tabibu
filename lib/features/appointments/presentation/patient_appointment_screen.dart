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
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/cancel_sheet.dart';
import 'package:tabibu/features/appointments/presentation/widgets/reschedule_sheet.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_row_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-09 and P-10. One screen for an appointment by state: the doctor, when /
/// where / why, the before-you-come checklist while it is upcoming, and the
/// results link when a past visit has a case. [moved] marks a landing from
/// the reschedule sheet, which says where the visit went.
class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({
    required this.appointmentUid,
    this.moved = false,
    super.key,
  });

  final String appointmentUid;
  final bool moved;

  @override
  State<PatientAppointmentScreen> createState() =>
      _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen> {
  /// A cancel or reschedule this screen sent and still waits on.
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    final appointments = context.read<AppointmentsBloc>().state.appointments;
    if (appointments.firstWhereOrNull((a) => a.uid == widget.appointmentUid) ==
        null) {
      final uid = switch (session) {
        PatientSession(:final patient) => patient.uid,
        _ => '',
      };
      context.read<AppointmentsBloc>().add(
        AppointmentsRequested(uid: uid, role: .patient),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = context
        .watch<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == widget.appointmentUid);
    final body = SafeArea(
      child: appointment == null
          ? _missing()
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                  ),
                  sliver: SliverList.list(children: _detail(appointment)),
                ),
              ],
            ),
    );
    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listener: _onAppointmentsState,
      child: Scaffold(body: RoleBackground.patient(child: body)),
    );
  }

  void _onAppointmentsState(BuildContext context, AppointmentsState state) {
    switch (state) {
      case AppointmentWriteInProgress():
        return;
      case AppointmentWriteFailure(:final error) when _acting:
        _acting = false;
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(context.l10n),
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      case AppointmentRescheduleSuccess(:final appointment) when _acting:
        _acting = false;
        unawaited(
          context.push<void>(
            PatientAppointmentRoute(appointmentUid: appointment.uid).location,
            extra: true,
          ),
        );
      case AppointmentCancelSuccess():
        _acting = false;
      default:
        return;
    }
  }

  /// Loading until the sync answers, then the not-found empty state.
  Widget _missing() {
    final l10n = context.l10n;
    final state = context.watch<AppointmentsBloc>().state;
    final loaded =
        state is! AppointmentsInitial && state is! AppointmentsLoadInProgress;
    if (!loaded) {
      return CustomScrollView(
        slivers: [
          _topBarSliver(null, null),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: LoadingView(
                  semanticLabel: l10n.appointmentDetailLoadingLabel,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        _topBarSliver(null, null),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: EmptyState(
              title: l10n.appointmentDetailNotFoundTitle,
              icon: Assets.icons.searchRoundedIcon,
              body: l10n.appointmentDetailNotFoundBody,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _detail(AppointmentModel appointment) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final start = nairobiTimeOf(appointment.scheduledStart) ?? nairobiNow();
    final upcoming =
        (appointment.statusValue == AppointmentStatus.accepted ||
            appointment.statusValue == AppointmentStatus.requested) &&
        start.isAfter(nairobiNow());
    final caseUid = appointment.discussedCaseUid.isNotEmpty
        ? appointment.discussedCaseUid
        : appointment.caseUids.firstOrNull;
    return [
      TopBar(
        title: appointment.typeValue.description(context.l10n),
        subtitle:
            '${DateFormat('EEE d MMM', language).format(start)} · '
            '${DateFormat('h:mm a', language).format(start)}',
        backLabel: l10n.commonBack,
        onBack: context.pop,
        trailing: IconButton(
          icon: AssetIcon(Assets.icons.calendarIcon, size: 20),
          tooltip: l10n.calendarTitle,
          onPressed: () => const PatientCalendarRoute().push<void>(context),
        ),
      ),
      if (widget.moved) ...[
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .info,
          icon: Assets.icons.infoIcon,
          title: l10n.rescheduleMovedTo(
            '${DateFormat('EEE d MMM', language).format(start)} · '
            '${DateFormat('h:mm a', language).format(start)}',
          ),
          body: l10n.rescheduleDoctorTold(appointment.doctorName),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      DoctorRowCard(
        name: appointment.doctorName,
        supporting: _doctorSupporting(appointment),
      ),
      const SizedBox(height: AppSpacing.md),
      GroupedRowsCard(
        children: [
          GroupedRow(
            icon: Assets.icons.calendarIcon,
            tone: .sky,
            title:
                '${DateFormat('EEE d MMM', language).format(start)} · '
                '${DateFormat('h:mm a', language).format(start)}',
          ),
          GroupedRow(
            icon: Assets.icons.facilityIcon,
            tone: .mint,
            title: appointment.facilityName,
          ),
          if (appointment.symptomText.isNotEmpty)
            GroupedRow(
              icon: Assets.icons.documentIcon,
              tone: .lavender,
              title: appointment.symptomText,
            ),
          GroupedRow(
            icon: Assets.icons.chatIcon,
            tone: .mint,
            title: l10n.chatRowTitle,
            onTap: () => unawaited(
              PatientAppointmentChatRoute(
                appointmentUid: appointment.uid,
              ).push<void>(context),
            ),
          ),
          if (!upcoming && caseUid != null)
            GroupedRow(
              icon: Assets.icons.testTubeIcon,
              tone: .butter,
              title: l10n.appointmentDetailSeeResults,
              onTap: () =>
                  PatientResultRoute(caseUid: caseUid).push<void>(context),
            ),
        ],
      ),
      if (upcoming) ...[
        const SizedBox(height: AppSpacing.md),
        ChecklistCard(
          title: l10n.appointmentDetailBeforeYouCome,
          items: [
            l10n.appointmentDetailBeforeEarly,
            l10n.appointmentDetailBeforeBring,
            l10n.appointmentDetailBeforeGuest,
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        TabibuButton.primary(
          label: l10n.rescheduleButton,
          onTap: () => _reschedule(appointment),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Tappable(
            onTap: () => _cancel(appointment),
            semanticLabel: l10n.cancelAppointmentConfirm,
            child: Text(
              l10n.cancelAppointmentConfirm,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.rescheduleFootnote(appointment.doctorName),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ];
  }

  Future<void> _reschedule(AppointmentModel appointment) async {
    final choice = await RescheduleSheet.show(
      context,
      appointment: appointment,
    );
    if (choice == null || !mounted) return;
    final session = context.read<AuthBloc>().state.session;
    final patientUid = switch (session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    _acting = true;
    context.read<AppointmentsBloc>().add(
      AppointmentRescheduleRequested(
        appointmentUid: appointment.uid,
        patientUid: patientUid,
        doctorUid: appointment.doctorUid,
        type: appointment.type,
        start: choice.start,
        cancelledByUid: patientUid,
        caseUid: appointment.discussedCaseUid.isNotEmpty
            ? appointment.discussedCaseUid
            : (appointment.caseUids.firstOrNull ?? ''),
        symptomText: appointment.symptomText,
      ),
    );
  }

  Future<void> _cancel(AppointmentModel appointment) async {
    final choice = await CancelSheet.show(
      context,
      appointment: appointment,
      isDoctor: false,
    );
    if (choice == null || !mounted) return;
    final session = context.read<AuthBloc>().state.session;
    final patientUid = switch (session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    _acting = true;
    context.read<AppointmentsBloc>().add(
      AppointmentCancelRequested(
        appointmentUid: appointment.uid,
        cancelledByUid: patientUid,
        reason: choice.reason,
        note: choice.note,
      ),
    );
  }

  Widget _topBarSliver(String? title, String? subtitle) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screenMargin,
      AppSpacing.md,
      AppSpacing.screenMargin,
      0,
    ),
    sliver: SliverToBoxAdapter(
      child: TopBar(
        title: title,
        subtitle: subtitle,
        backLabel: context.l10n.commonBack,
        onBack: context.pop,
      ),
    ),
  );

  /// Specialty from the directory with the facility, or whichever exists.
  String _doctorSupporting(AppointmentModel appointment) {
    final directory = context.watch<DirectoryBloc>().state;
    final raw = directory.all
        .firstWhereOrNull((d) => d.uid == appointment.doctorUid)
        ?.specialties
        .firstOrNull;
    final specialty = raw == null || raw.isEmpty
        ? ''
        : Specialty.fromValue(raw)?.description(context.l10n) ?? raw;
    final facility = appointment.facilityName;
    if (specialty.isEmpty) return facility;
    if (facility.isEmpty) return specialty;
    return '$specialty · $facility';
  }
}
