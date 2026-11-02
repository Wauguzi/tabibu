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
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_row_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-09 and P-10. One screen for an appointment by state: the doctor, when /
/// where / why, the before-you-come checklist while it is upcoming, and the
/// results link when a past visit has a case.
class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({required this.appointmentUid, super.key});

  final String appointmentUid;

  @override
  State<PatientAppointmentScreen> createState() =>
      _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen> {
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
    return Scaffold(body: RoleBackground.patient(child: body));
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
      ),
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
      ],
    ];
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
