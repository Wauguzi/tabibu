import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_timeline.dart';
import 'package:tabibu/features/appointments/presentation/widgets/hero_pill_button.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/mdt_routes.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_card.dart';
import 'package:tabibu/features/home/presentation/widgets/home_header.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A free stretch between two appointments is worth showing from this long.
const _minFreeGap = Duration(minutes: 30);

/// One of today's appointments with its Nairobi window and where it stands.
class _Slot {
  const _Slot({
    required this.appointment,
    required this.start,
    required this.end,
    required this.state,
  });

  final AppointmentModel appointment;
  final DateTime start;
  final DateTime end;
  final TimelineEntryState state;
}

/// D-HOME. The doctor's Today tab: the day at a glance, the appointment under
/// way or next, the day's timeline, and what needs the doctor.
class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late final DoctorModel _doctor;
  late final RoleHelper _roles;

  /// The unread booking requests seen so far, to spot a new one arriving.
  late Set<String> _seenRequests;

  /// False until the inbox has loaded once: what is already there on first
  /// load is not "new".
  late bool _inboxSeeded;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _doctor = switch (session) {
      PractitionerSession(:final doctor) => doctor,
      _ => DoctorModel.empty(),
    };
    _roles = switch (session) {
      PractitionerSession(:final roles) => roles,
      _ => RoleHelper.none,
    };
    final inbox = context.read<NotificationsBloc>().state;
    _inboxSeeded =
        inbox is! NotificationsInitial && inbox is! NotificationsLoadInProgress;
    _seenRequests = _unreadRequestIds(inbox.items);
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: _doctor.uid, role: .doctor),
    );
    context.read<CasesBloc>().add(
      CasesRequested(uid: _doctor.uid, role: .doctor),
    );
    context.read<NotificationsBloc>().add(
      NotificationsRequested(uid: _doctor.uid),
    );
    context.read<MdtBloc>().add(MdtRequested(uid: _doctor.uid, role: .doctor));
    // Only an approver may read the queue (S-2); anyone else never asks.
    if (_roles.canApproveAlerts) {
      context.read<AlertReviewBloc>().add(const AlertQueueRequested());
    }
  }

  Set<String> _unreadRequestIds(List<NotificationModel> items) => {
    for (final item in items)
      if (!item.isRead &&
          NotificationTemplate.fromValue(item.templateKey) ==
              .appointmentRequested)
        item.uid,
  };

  /// The inbox is live: a booking request that lands while the tab is open
  /// refreshes the appointments so the booking count follows.
  void _onInbox(NotificationsState state) {
    if (state is NotificationsInitial || state is NotificationsLoadInProgress) {
      return;
    }
    final unread = _unreadRequestIds(state.items);
    final arrived = unread.difference(_seenRequests).isNotEmpty;
    _seenRequests = unread;
    if (!_inboxSeeded) {
      _inboxSeeded = true;
      return;
    }
    if (arrived) {
      context.read<AppointmentsBloc>().add(
        AppointmentsRefreshed(uid: _doctor.uid, role: .doctor),
      );
    }
  }

  void _dispatchRefreshes() {
    context.read<NotificationsBloc>().add(
      NotificationsRefreshed(uid: _doctor.uid),
    );
    context.read<AppointmentsBloc>().add(
      AppointmentsRefreshed(uid: _doctor.uid, role: .doctor),
    );
    context.read<CasesBloc>().add(
      CasesRefreshed(uid: _doctor.uid, role: .doctor),
    );
    // The queue has no refresh event; the request reads it live again.
    if (_roles.canApproveAlerts) {
      context.read<AlertReviewBloc>().add(const AlertQueueRequested());
    }
  }

  Future<void> _refresh() async {
    final appointments = context.read<AppointmentsBloc>();
    _dispatchRefreshes();
    await settleRefresh<AppointmentsState>(
      appointments.stream,
      (state) => state is AppointmentsLoadInProgress,
    );
  }

  /// Today's accepted and completed appointments by start, each with where it
  /// stands against [now] (all Nairobi wall-clock times).
  List<_Slot> _slotsOf(List<AppointmentModel> rows, DateTime now) {
    final slots = <_Slot>[];
    for (final row in rows) {
      final status = row.statusValue;
      if (status != .accepted && status != .completed) continue;
      final start = nairobiTimeOf(row.scheduledStart);
      if (start == null || nairobiDaysBefore(start, now) != 0) continue;
      final stored = nairobiTimeOf(row.scheduledEnd);
      final end = stored != null && stored.isAfter(start)
          ? stored
          : start.add(const Duration(minutes: slotMinutes));
      final state = status == .completed || !end.isAfter(now)
          ? TimelineEntryState.done
          : start.isAfter(now)
          ? TimelineEntryState.upcoming
          : TimelineEntryState.now;
      slots.add(_Slot(appointment: row, start: start, end: end, state: state));
    }
    return slots..sort((a, b) => a.start.compareTo(b.start));
  }

  bool _isWithDoctor(CaseModel c) =>
      c.resultStateValue == .withDoctor ||
      c.resultStateValue == .updateWithDoctor;

  /// The case an appointment discusses, if any.
  CaseModel? _caseOf(AppointmentModel appointment, List<CaseModel> cases) =>
      cases.firstWhereOrNull(
        (c) =>
            c.uid.isNotEmpty && c.uid == appointment.discussedCaseUid ||
            c.discussionAppointmentUid.isNotEmpty &&
                c.discussionAppointmentUid == appointment.uid,
      );

  /// The draft that has waited longest for a decision.
  AlertModel? _oldestAlert(List<AlertModel> queue) {
    DateTime? when(AlertModel a) => DateTime.tryParse(
      [
        a.draftedAt,
        a.requestedAt,
        a.createdAt,
      ].firstWhere((s) => s.isNotEmpty, orElse: () => ''),
    );
    final dated = queue.where((a) => when(a) != null).toList()
      ..sort((a, b) => when(a)!.compareTo(when(b)!));
    return dated.firstOrNull ?? queue.firstOrNull;
  }

  List<TimelineEntry> _entries({
    required List<_Slot> slots,
    required List<CaseModel> cases,
    required String language,
  }) {
    final l10n = context.l10n;
    final clock = DateFormat('h:mm a', language);
    final entries = <TimelineEntry>[];
    DateTime? cursor;
    for (final slot in slots) {
      final appointment = slot.appointment;
      if (cursor != null && slot.start.difference(cursor) >= _minFreeGap) {
        entries.add(
          TimelineEntry(
            time: clock.format(cursor),
            title: l10n.doctorHomeFreeGap(
              slot.start.difference(cursor).inMinutes,
            ),
            subtitle: l10n.doctorHomeFreeHint,
            state: .free,
          ),
        );
      }
      if (cursor == null || slot.end.isAfter(cursor)) cursor = slot.end;

      final booked = nairobiTimeOf(appointment.createdAt);
      final subtitle = [
        _caseOf(appointment, cases)?.tests.firstOrNull?.name ?? '',
        if (slot.state == .upcoming && booked != null)
          l10n.doctorHomeBookedAgo(
            DateFormat('d MMM', language).format(booked),
          ),
      ].where((part) => part.isNotEmpty).join(' · ');
      entries.add(
        TimelineEntry(
          time: clock.format(slot.start),
          title: appointment.patientName,
          subtitle: subtitle,
          state: slot.state,
          nowLabel: slot.state == .now ? l10n.doctorHomeNow : null,
          avatar: slot.state == .now
              ? Avatar(name: appointment.patientName)
              : null,
          onTap: () => DoctorAppointmentRoute(
            appointmentUid: appointment.uid,
          ).push<void>(context),
        ),
      );
    }
    return entries;
  }

  Widget _hero({
    required _Slot slot,
    required int index,
    required int count,
    required List<CaseModel> cases,
    required String language,
  }) {
    final l10n = context.l10n;
    final appointment = slot.appointment;
    final linked = _caseOf(appointment, cases);
    final signed = linked != null && _isWithDoctor(linked);
    final time = DateFormat('h:mm a', language).format(slot.start);
    final age = linked?.patientAgeYears ?? 0;
    return AppointmentHeroCard(
      eyebrow: slot.state == .now ? l10n.doctorHomeNowPill(time) : time,
      progress: Text(
        l10n.doctorHomeAppointmentCount(index, count),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
      ),
      leading: Avatar(name: appointment.patientName, radius: 36),
      title: age > 0
          ? '${appointment.patientName}, $age'
          : appointment.patientName,
      body: [
        linked?.tests.firstOrNull?.name ?? '',
        if (signed) l10n.doctorHomeReportSigned,
      ].where((part) => part.isNotEmpty).join(' · '),
      primary: HeroPillButton(
        label: signed
            ? l10n.doctorHomeOpenReport
            : l10n.doctorHomeStartAppointment,
        onTap: () => DoctorAppointmentRoute(
          appointmentUid: appointment.uid,
        ).push<void>(context),
      ),
    );
  }

  Widget _needsYou({
    required List<CaseModel> ready,
    required int requested,
    required List<AlertModel> queue,
  }) {
    final l10n = context.l10n;
    final reports = ShortcutTile(
      icon: Assets.icons.documentIcon,
      tone: .lavender,
      title: l10n.doctorHomeReportsTile,
      value: '${ready.length}',
      body: ready.firstOrNull?.patientName,
      tall: true,
      onTap: () => const ReportsReadyRoute().push<void>(context),
    );
    final bookings = ShortcutTile(
      icon: Assets.icons.calendarIcon,
      tone: .sky,
      title: l10n.doctorHomeBookingsTile,
      body: l10n.doctorHomeNewToday(requested),
      onTap: () => const BookingRequestsRoute().push<void>(context),
    );
    final oldest = _roles.canApproveAlerts ? _oldestAlert(queue) : null;
    if (oldest == null) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(child: reports),
            const SizedBox(width: AppSpacing.bentoGap),
            Expanded(child: bookings),
          ],
        ),
      );
    }
    return ShortcutBento(
      tall: reports,
      top: bookings,
      bottom: ShortcutTile(
        icon: Assets.icons.infoIcon,
        tone: .butter,
        title: l10n.doctorHomeAlertTile,
        body: oldest.countyName,
        badge: StatusChip(
          label: l10n.doctorHomeAlertNew(queue.length),
          tone: .attention,
        ),
        onTap: () => AlertReviewRoute(alertUid: oldest.uid).push<void>(context),
      ),
    );
  }

  /// A pending consult invitation: who asked, what about, and a way in. The
  /// invitation screen holds the accept and decline, with their confirmation.
  Widget _mdtInvite(ConversationModel consult) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final inviter = mdtInviterOf(consult, _doctor.uid);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  l10n.doctorHomeMdtInvite(mdtMemberName(inviter)),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${mdtRef(consult)} · ${mdtInviteAbout(consult, l10n)}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 104,
            child: TabibuButton.primary(
              label: l10n.doctorHomeMdtJoin,
              onTap: () => unawaited(
                mdtConsultRoute(.doctor, consult.uid).push<void>(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// When the data on screen was last written, for the offline note.
  DateTime _savedAt(
    List<AppointmentModel> appointments,
    List<CaseModel> cases,
    DateTime now,
  ) {
    final stamps = [
      for (final a in appointments) nairobiTimeOf(a.lastUpdatedAt),
      for (final c in cases) nairobiTimeOf(c.lastUpdatedAt),
    ].nonNulls.toList()..sort();
    return stamps.lastOrNull ?? now;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final notifications = context.watch<NotificationsBloc>().state;
    final appointments = context.watch<AppointmentsBloc>().state;
    final cases = context.watch<CasesBloc>().state;
    final queue = _roles.canApproveAlerts
        ? context.watch<AlertReviewBloc>().state.queue
        : const <AlertModel>[];
    final invite = context.watch<MdtBloc>().state.invites.firstOrNull;

    final now = nairobiNow();
    final slots = _slotsOf(appointments.appointments, now);
    final ready = cases.cases.where(_isWithDoctor).toList();
    final requested = appointments.appointments
        .where((a) => a.isRequested)
        .length;
    final current =
        slots.firstWhereOrNull((s) => s.state == .now) ??
        slots.firstWhereOrNull((s) => s.state == .upcoming);
    final offline =
        notifications.offline || appointments.offline || cases.offline;
    final loading =
        (appointments is AppointmentsInitial ||
                appointments is AppointmentsLoadInProgress) &&
            appointments.appointments.isEmpty ||
        (cases is CasesInitial || cases is CasesLoadInProgress) &&
            cases.cases.isEmpty;
    // A pending booking or alert is work, so the day is not empty with one.
    final empty =
        !loading &&
        slots.isEmpty &&
        ready.isEmpty &&
        requested == 0 &&
        queue.isEmpty;
    final entries = _entries(
      slots: slots,
      cases: cases.cases,
      language: language,
    );

    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (_, state) => _onInbox(state),
      child: ShellTabPage(
        role: .doctor,
        onRefresh: _refresh,
        children: [
          HomeHeader(
            name: '${_doctor.firstName} ${_doctor.lastName}',
            greeting: l10n.homeGreeting('${_doctor.title} ${_doctor.lastName}'),
            subtitle: l10n.homeSubtitlePractitioner(
              DateFormat('EEE d MMM', language).format(now),
              _doctor.facilityName,
            ),
            photoUrl: _doctor.profilePictureUrl,
            notificationsLabel: l10n.profileNotifications,
            onNotifications: () =>
                const DoctorNotificationsRoute().push<void>(context),
            hasUnread: notifications.unread > 0,
            unreadLabel: l10n.doctorHomeBellUnread,
          ),
          if (offline) ...[
            const SizedBox(height: AppSpacing.md),
            ConnectivityBanner(
              state: .offline,
              title: l10n.doctorHomeOfflineTitle,
              body: l10n.doctorHomeOfflineBody(
                DateFormat(
                  'h:mm a',
                  language,
                ).format(_savedAt(appointments.appointments, cases.cases, now)),
              ),
              retryLabel: l10n.doctorHomeRetry,
              onRetry: _dispatchRefreshes,
            ),
          ],
          if (loading) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            LoadingView(semanticLabel: l10n.doctorHomeLoadingLabel),
          ] else if (empty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            EmptyState(
              icon: Assets.icons.calendarIcon,
              tone: .lavender,
              title: l10n.doctorHomeEmptyTitle,
              body: l10n.doctorHomeEmptyBody(_doctor.facilityName),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            TwoToneHeadline(
              first: l10n.doctorHomeAppointmentsToday(slots.length),
              second: l10n.doctorHomeReportsReady(ready.length),
            ),
            if (current != null) ...[
              const SizedBox(height: AppSpacing.md),
              _hero(
                slot: current,
                index: slots.indexOf(current) + 1,
                count: slots.length,
                cases: cases.cases,
                language: language,
              ),
            ],
            const SizedBox(height: AppSpacing.sectionGap),
            SectionHeader(
              title: l10n.doctorHomeYourDay,
              actionLabel: l10n.calendarTitle,
              onAction: () => const DoctorCalendarRoute().push<void>(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isNotEmpty)
              DayTimeline(entries: entries)
            else
              Text(
                l10n.doctorHomeAppointmentsToday(0),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.sectionGap),
            SectionHeader(title: l10n.doctorHomeNeedsYou),
            const SizedBox(height: AppSpacing.sm),
            _needsYou(ready: ready, requested: requested, queue: queue),
            if (invite != null) ...[
              const SizedBox(height: AppSpacing.md),
              _mdtInvite(invite),
            ],
          ],
        ],
      ),
    );
  }
}
