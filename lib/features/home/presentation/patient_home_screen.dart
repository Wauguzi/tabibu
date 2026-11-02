import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/utils/text_scale.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/hero_pill_button.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/home/presentation/widgets/book_prompt_card.dart';
import 'package:tabibu/features/home/presentation/widgets/home_header.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_grid_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/results_slide.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-01. The patient home tab: header, health notice, the appointment/results
/// carousel or the book prompt, and doctors near you.
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late final PatientModel _patient;
  late final RoleHelper _roles;

  /// The hero's height at text scale 1, grown with the reader's text size
  /// (`scaledForText`) so Kiswahili at 1.3x still fits.
  static const _carouselBaseHeight = 380.0;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _patient = switch (session) {
      PatientSession(:final patient) => patient,
      _ => PatientModel.empty(),
    };
    _roles = switch (session) {
      PatientSession(:final roles) => roles,
      _ => RoleHelper.none,
    };
    context.read<NotificationsBloc>().add(
      NotificationsRequested(uid: _patient.uid),
    );
    context.read<PublicAlertsBloc>().add(
      PublicAlertsRequested(
        county: _patient.county,
        demo: _roles.isDemo,
        clinician: false,
      ),
    );
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: _patient.uid, role: .patient),
    );
    context.read<CasesBloc>().add(
      CasesRequested(uid: _patient.uid, role: .patient),
    );
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  void _dispatchRefreshes() {
    context.read<NotificationsBloc>().add(
      NotificationsRefreshed(uid: _patient.uid),
    );
    // Alerts have no refresh event; the request is idempotent.
    context.read<PublicAlertsBloc>().add(
      PublicAlertsRequested(
        county: _patient.county,
        demo: _roles.isDemo,
        clinician: false,
      ),
    );
    context.read<AppointmentsBloc>().add(
      AppointmentsRefreshed(uid: _patient.uid, role: .patient),
    );
    context.read<CasesBloc>().add(
      CasesRefreshed(uid: _patient.uid, role: .patient),
    );
    context.read<DirectoryBloc>().add(const DirectoryRefreshed());
  }

  Future<void> _refresh() async {
    final appointments = context.read<AppointmentsBloc>();
    _dispatchRefreshes();
    await settleRefresh<AppointmentsState>(
      appointments.stream,
      (state) => state is AppointmentsLoadInProgress,
    );
  }

  /// The earliest accepted appointment still in the future, with its Nairobi
  /// start.
  ({AppointmentModel appointment, DateTime start})? _nextAppointment(
    List<AppointmentModel> rows,
    DateTime now,
  ) {
    AppointmentModel? next;
    DateTime? start;
    for (final row in rows) {
      if (row.statusValue != AppointmentStatus.accepted) continue;
      final at = nairobiTimeOf(row.scheduledStart);
      if (at == null || !at.isAfter(now)) continue;
      if (start == null || at.isBefore(start)) {
        next = row;
        start = at;
      }
    }
    return next == null || start == null
        ? null
        : (appointment: next, start: start);
  }

  String _specialtyOf(
    String doctorUid,
    List<PractitionerModel> directory,
    AppLocalizations l10n,
  ) {
    final raw = directory
        .firstWhereOrNull((d) => d.uid == doctorUid)
        ?.specialties
        .firstOrNull;
    if (raw == null || raw.isEmpty) return '';
    return Specialty.fromValue(raw)?.description(l10n) ?? raw;
  }

  String _headlineOf(PublicAlertModel notice, String language) =>
      notice.patientText[language]?.headline ??
      notice.patientText['en']?.headline ??
      '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final notifications = context.watch<NotificationsBloc>().state;
    final alerts = context.watch<PublicAlertsBloc>().state;
    final appointments = context.watch<AppointmentsBloc>().state;
    final cases = context.watch<CasesBloc>().state;
    final directory = context.watch<DirectoryBloc>().state;

    final now = nairobiNow();
    final next = _nextAppointment(appointments.appointments, now);
    final resultsCase = cases.cases.firstWhereOrNull(
      (c) =>
          c.resultStateValue == ResultState.withDoctor ||
          c.resultStateValue == ResultState.updateWithDoctor,
    );
    // The bloc emits newest first.
    final notice = alerts.alerts.firstOrNull;
    final offline =
        notifications.offline ||
        alerts.offline ||
        appointments.offline ||
        cases.offline ||
        directory.offline;
    final heroLoading =
        next == null &&
        resultsCase == null &&
        (appointments is AppointmentsInitial ||
            appointments is AppointmentsLoadInProgress ||
            cases is CasesInitial ||
            cases is CasesLoadInProgress);

    return ShellTabPage(
      role: .patient,
      onRefresh: _refresh,
      children: [
        HomeHeader(
          name: _patient.fullName,
          greeting: l10n.patientHomeGreeting(_patient.firstName),
          subtitle: l10n.patientHomeSubtitle(
            _patient.subCounty,
            DateFormat('EEE d MMM', language).format(now),
          ),
          photoUrl: _patient.profilePictureUrl,
          notificationsLabel: l10n.patientHomeNotificationsLabel,
          onNotifications: () =>
              const PatientNotificationsRoute().push<void>(context),
          hasUnread: notifications.unread > 0,
          unreadLabel: l10n.patientHomeBellUnreadLabel,
        ),
        if (offline) ...[
          const SizedBox(height: AppSpacing.md),
          ConnectivityBanner(
            state: .offline,
            title: l10n.notificationsOfflineTitle,
            body: l10n.patientHomeOfflineBody,
            retryLabel: l10n.patientHomeRetry,
            onRetry: _dispatchRefreshes,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        TwoToneHeadline(
          first: l10n.patientHomeHeadlineFirst,
          second: l10n.patientHomeHeadlineSecond,
          tealSecond: false,
        ),
        if (notice != null) ...[
          const SizedBox(height: AppSpacing.md),
          _NoticeStrip(
            label: l10n.patientHomeNoticeLabel(notice.countyName),
            headline: _headlineOf(notice, language),
            onTap: () =>
                HealthNoticeRoute(alertUid: notice.uid).push<void>(context),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _heroArea(
          next: next,
          resultsCase: resultsCase,
          loading: heroLoading,
          appointments: appointments.appointments,
          directory: directory.all,
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(
          title: l10n.patientHomeDoctorsNearYou,
          actionLabel: l10n.patientHomeSeeAll,
          onAction: () => const FindDoctorRoute().push<void>(context),
        ),
        if (!offline) ...[
          const SizedBox(height: AppSpacing.sm),
          _searchField(),
        ],
        const SizedBox(height: AppSpacing.sm),
        ..._doctorRows(directory.visible),
      ],
    );
  }

  Widget _heroArea({
    required ({AppointmentModel appointment, DateTime start})? next,
    required CaseModel? resultsCase,
    required bool loading,
    required List<AppointmentModel> appointments,
    required List<PractitionerModel> directory,
  }) {
    if (next == null && resultsCase == null) {
      if (loading) {
        return SizedBox(
          height: scaledForText(context, _carouselBaseHeight),
          child: LoadingView(
            semanticLabel: context.l10n.patientHomeLoadingLabel,
          ),
        );
      }
      return _bookPrompt();
    }
    final slides = [
      if (next == null) _bookPrompt() else _appointmentSlide(next, directory),
      if (resultsCase != null) _resultsSlide(resultsCase, appointments),
    ];
    return HeroCarousel(
      height: scaledForText(context, _carouselBaseHeight),
      slides: [
        for (var i = 0; i < slides.length; i++)
          Semantics(
            label: context.l10n.patientHomeSlideLabel(i + 1, slides.length),
            child: slides[i],
          ),
      ],
    );
  }

  Widget _appointmentSlide(
    ({AppointmentModel appointment, DateTime start}) next,
    List<PractitionerModel> directory,
  ) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final appointment = next.appointment;
    final specialty = _specialtyOf(appointment.doctorUid, directory, l10n);
    return AppointmentHeroCard(
      eyebrow: l10n.patientHomeEyebrow(
        -nairobiDaysBefore(next.start, nairobiNow()),
      ),
      title: DateFormat('EEE d MMM', language).format(next.start),
      figure: DateFormat('h:mm a', language).format(next.start),
      body: specialty.isEmpty
          ? '${appointment.doctorName} · ${appointment.facilityName}'
          : '${appointment.doctorName} · $specialty, '
                '${appointment.facilityName}',
      primary: HeroPillButton(
        label: l10n.patientHomeDetails,
        onTap: () => PatientAppointmentRoute(
          appointmentUid: appointment.uid,
        ).push<void>(context),
      ),
    );
  }

  Widget _resultsSlide(
    CaseModel resultsCase,
    List<AppointmentModel> appointments,
  ) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final discussion = appointments.firstWhereOrNull(
      (a) => a.uid == resultsCase.discussionAppointmentUid,
    );
    final at = discussion == null
        ? null
        : nairobiTimeOf(discussion.scheduledStart);
    return ResultsSlide(
      chipLabel: l10n.patientHomeWithDoctor,
      title: l10n.patientHomeResultsTitle(
        resultsCase.tests.firstOrNull?.name ?? '',
      ),
      body: at == null
          ? l10n.patientHomeResultsBodyNoDate(resultsCase.doctorName)
          : l10n.patientHomeResultsBody(
              resultsCase.doctorName,
              DateFormat('EEE d MMM', language).format(at),
            ),
      onTap: () =>
          PatientResultRoute(caseUid: resultsCase.uid).push<void>(context),
    );
  }

  Widget _bookPrompt() {
    final l10n = context.l10n;
    return BookPromptCard(
      title: l10n.patientHomeNoAppointments,
      body: l10n.patientHomeBookPromptBody,
      actionLabel: l10n.patientHomeBookNow,
      onBook: () => const FindDoctorRoute().push<void>(context),
    );
  }

  Widget _searchField() {
    final l10n = context.l10n;
    void open() => const FindDoctorRoute().push<void>(context);
    return Semantics(
      button: true,
      label: l10n.patientHomeSearchHint,
      onTap: open,
      excludeSemantics: true,
      child: Tappable(
        onTap: open,
        child: IgnorePointer(
          child: SearchField(
            hint: l10n.patientHomeSearchHint,
            clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
          ),
        ),
      ),
    );
  }

  List<Widget> _doctorRows(List<PractitionerModel> visible) {
    final mine = visible
        .where((d) => d.subCounty == _patient.subCounty)
        .toList();
    final rest = visible
        .where((d) => d.subCounty != _patient.subCounty)
        .toList();
    final ordered = [...mine, ...rest].take(4).toList();
    final rows = <Widget>[];
    for (var i = 0; i < ordered.length; i += 2) {
      if (i > 0) {
        rows.add(const SizedBox(height: AppSpacing.bentoGap));
      }
      final pair = ordered.skip(i).take(2).toList();
      rows.add(
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(child: _doctorCard(pair[0])),
            if (pair.length == 2) ...[
              const SizedBox(width: AppSpacing.bentoGap),
              Expanded(child: _doctorCard(pair[1])),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }
    return rows;
  }

  Widget _doctorCard(PractitionerModel doctor) {
    final l10n = context.l10n;
    final raw = doctor.specialties.firstOrNull ?? '';
    return DoctorGridCard(
      name: doctor.fullName,
      specialty: raw.isEmpty
          ? ''
          : Specialty.fromValue(raw)?.description(l10n) ?? raw,
      onTap: () =>
          PractitionerProfileRoute(doctorUid: doctor.uid).push<void>(context),
      image: doctor.profilePictureUrl.isEmpty
          ? null
          : NetworkImage(doctor.profilePictureUrl),
    );
  }
}

/// The health notice strip: an info-tone card reading label and headline as
/// one tap.
class _NoticeStrip extends StatelessWidget {
  const _NoticeStrip({
    required this.label,
    required this.headline,
    required this.onTap,
  });

  final String label;
  final String headline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final onTap = this.onTap;
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$label, $headline',
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              padding: AppStyles.cardPadding,
              decoration: BoxDecoration(
                color: status.infoContainer,
                borderRadius: BorderRadius.circular(AppRadii.notice),
              ),
              child: Row(
                children: [
                  IconTile(icon: Assets.icons.infoIcon, tone: .white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodySmall?.copyWith(
                            color: status.infoText,
                            fontWeight: .w500,
                          ),
                        ),
                        Text(
                          headline,
                          style: textTheme.bodyLarge?.copyWith(
                            color: status.infoText,
                            fontWeight: .w500,
                          ),
                          maxLines: 2,
                          overflow: .ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AssetIcon(
                    Assets.icons.forwardIcon,
                    size: 22,
                    scaleUp: false,
                    color: status.infoText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white pill on the teal hero. No [TabibuButton] variant stays white in
/// both themes, so the hero owns this one.
