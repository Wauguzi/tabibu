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
import 'package:tabibu/features/appointments/presentation/widgets/day_timeline.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The month view of one person's appointments, patient or doctor. Days
/// group by Nairobi civil date whatever the phone's zone; tapping a row
/// opens that appointment.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({required this.role, super.key});

  final Role role;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = nairobiNow();
    _month = DateTime.utc(today.year, today.month);
    _selected = DateTime.utc(today.year, today.month, today.day);
    final appointments = context.read<AppointmentsBloc>().state.appointments;
    if (appointments.isEmpty) {
      final uid = switch (context.read<AuthBloc>().state.session) {
        PatientSession(:final patient) => patient.uid,
        PractitionerSession(:final doctor) => doctor.uid,
        _ => '',
      };
      context.read<AppointmentsBloc>().add(
        AppointmentsRequested(uid: uid, role: widget.role),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final appointments = context.watch<AppointmentsBloc>().state.appointments;
    final byDay = _byNairobiDay(appointments);
    final today = nairobiNow();
    final isTodaySelected =
        _selected.year == today.year &&
        _selected.month == today.month &&
        _selected.day == today.day;
    final body = SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            sliver: SliverList.list(
              children: [
                TopBar(
                  title: l10n.calendarTitle,
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                ),
                const SizedBox(height: AppSpacing.md),
                _monthRow(language),
                const SizedBox(height: AppSpacing.sm),
                _grid(language, byDay),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, d', language).format(_selected),
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ),
                    if (isTodaySelected) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _chip(l10n.calendarToday, filled: true),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.calendarYourDay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                DayTimeline(
                  entries: _entries(byDay[_selected] ?? const [], language),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: widget.role == .patient
          ? RoleBackground.patient(child: body)
          : RoleBackground.doctor(child: body),
    );
  }

  /// Appointments by their Nairobi civil day, as UTC civil keys so no
  /// device-zone day math sneaks in; cancelled, declined and expired rows
  /// stay out of the month.
  Map<DateTime, List<AppointmentModel>> _byNairobiDay(
    List<AppointmentModel> appointments,
  ) {
    final byDay = <DateTime, List<AppointmentModel>>{};
    for (final appointment in appointments) {
      final status = appointment.statusValue;
      if (status == .cancelled || status == .declined || status == .expired) {
        continue;
      }
      final start = nairobiTimeOf(appointment.scheduledStart);
      if (start == null) continue;
      final day = DateTime.utc(start.year, start.month, start.day);
      byDay.putIfAbsent(day, () => []).add(appointment);
    }
    for (final rows in byDay.values) {
      rows.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    }
    return byDay;
  }

  Widget _monthRow(String language) => Row(
    children: [
      Expanded(
        child: Text(
          DateFormat('MMMM y', language).format(_month),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      IconButton(
        icon: AssetIcon(Assets.icons.backIcon, size: 16),
        onPressed: () => setState(() {
          _month = DateTime.utc(_month.year, _month.month - 1);
        }),
      ),
      IconButton(
        icon: AssetIcon(Assets.icons.forwardIcon, size: 16),
        onPressed: () => setState(() {
          _month = DateTime.utc(_month.year, _month.month + 1);
        }),
      ),
    ],
  );

  Widget _grid(String language, Map<DateTime, List<AppointmentModel>> byDay) {
    final scheme = Theme.of(context).colorScheme;
    final first = DateTime.utc(_month.year, _month.month);
    // Weeks start on Monday.
    final lead = (first.weekday - DateTime.monday) % 7;
    final daysInMonth = DateTime.utc(_month.year, _month.month + 1, 0).day;
    final cells = <Widget>[];
    for (var i = 0; i < 7; i++) {
      cells.add(
        Center(
          child: Text(
            // 2024-01-01 was a Monday.
            DateFormat('EEEEE', language).format(DateTime.utc(2024, 1, 1 + i)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime.utc(_month.year, _month.month, day);
      final count = byDay[date]?.length ?? 0;
      final selected = date == _selected;
      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selected = date),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: selected
                  ? BoxDecoration(color: scheme.primary, shape: BoxShape.circle)
                  : null,
              child: Column(
                mainAxisSize: .min,
                mainAxisAlignment: .center,
                children: [
                  Text(
                    '$day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? scheme.onPrimary : null,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected ? scheme.onPrimary : scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _chip(String label, {required bool filled}) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: filled ? Theme.of(context).colorScheme.primary : null,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: filled ? Theme.of(context).colorScheme.onPrimary : null,
      ),
    ),
  );

  List<TimelineEntry> _entries(List<AppointmentModel> rows, String language) {
    final l10n = context.l10n;
    final clock = DateFormat('h:mm a', language);
    final now = nairobiNow();
    final entries = <TimelineEntry>[];
    DateTime? cursor;
    for (final row in rows) {
      final start = nairobiTimeOf(row.scheduledStart);
      if (start == null) continue;
      final stored = nairobiTimeOf(row.scheduledEnd);
      final end = stored != null && stored.isAfter(start)
          ? stored
          : start.add(const Duration(minutes: 30));
      if (cursor != null &&
          start.difference(cursor) >= const Duration(minutes: 30)) {
        entries.add(
          TimelineEntry(
            time: clock.format(cursor),
            title: l10n.doctorHomeFreeGap(start.difference(cursor).inMinutes),
            subtitle: l10n.doctorHomeFreeHint,
            state: .free,
          ),
        );
      }
      if (cursor == null || end.isAfter(cursor)) cursor = end;
      final done = row.statusValue == .completed || !end.isAfter(now);
      final state = done
          ? TimelineEntryState.done
          : start.isAfter(now)
          ? TimelineEntryState.upcoming
          : TimelineEntryState.now;
      final booked = _bookedAgo(row.createdAt, now);
      final subtitle = [
        if (row.symptomText.isNotEmpty)
          row.symptomText
        else
          l10n.calendarNewAppointment,
        if (state == .upcoming && booked.isNotEmpty)
          l10n.doctorHomeBookedAgo(booked),
      ].join(' · ');
      entries.add(
        TimelineEntry(
          time: clock.format(start),
          title: widget.role == .patient ? row.doctorName : row.patientName,
          subtitle: subtitle,
          state: state,
          nowLabel: state == .now ? l10n.calendarNow : null,
          avatar: state == .now
              ? Avatar(
                  name: widget.role == .patient
                      ? row.doctorName
                      : row.patientName,
                )
              : null,
          onTap: () => widget.role == .patient
              ? PatientAppointmentRoute(
                  appointmentUid: row.uid,
                ).push<void>(context)
              : DoctorAppointmentRoute(
                  appointmentUid: row.uid,
                ).push<void>(context),
        ),
      );
    }
    return entries;
  }

  String _bookedAgo(String createdAt, DateTime now) {
    final created = nairobiTimeOf(createdAt);
    if (created == null) return '';
    final days = nairobiDaysBefore(created, now);
    if (days <= 0) return context.l10n.calendarToday;
    if (days == 1) return context.l10n.accessLogYesterday;
    final language = Localizations.localeOf(context).languageCode;
    return DateFormat('d MMM', language).format(created);
  }
}
