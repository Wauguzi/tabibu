import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/date_tile.dart';
import 'package:tabibu/features/appointments/presentation/widgets/hero_pill_button.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/home/presentation/widgets/book_prompt_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-08. The patient's appointments tab: the next visit as a hero, the rest
/// by month, and the book prompt when nothing is coming up.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: _uid, role: .patient),
    );
  }

  Future<void> _refresh() async {
    final appointments = context.read<AppointmentsBloc>()
      ..add(AppointmentsRefreshed(uid: _uid, role: .patient));
    await settleRefresh<AppointmentsState>(
      appointments.stream,
      (state) => state is AppointmentsLoadInProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppointmentsBloc>().state;
    final now = nairobiNow();
    final dated = [
      for (final row in state.appointments)
        (appointment: row, start: nairobiTimeOf(row.scheduledStart)),
    ];
    final upcoming = dated
        .where(
          (d) =>
              (d.appointment.statusValue == AppointmentStatus.accepted ||
                  d.appointment.statusValue == AppointmentStatus.requested) &&
              d.start != null &&
              d.start!.isAfter(now),
        )
        .sortedBy((d) => d.start!);
    final past = dated
        .where((d) => !upcoming.contains(d))
        .sortedBy((d) => d.start ?? DateTime.fromMillisecondsSinceEpoch(0))
        .reversed
        .toList();
    final loading =
        state.appointments.isEmpty &&
        (state is AppointmentsInitial || state is AppointmentsLoadInProgress);

    return Scaffold(
      floatingActionButton: upcoming.isEmpty || loading
          ? null
          : Padding(
              // Clears the shell's floating tab bar.
              padding: const EdgeInsets.only(bottom: 96),
              child: Fab(
                icon: Assets.icons.addIcon,
                semanticLabel: context.l10n.appointmentsBookAppointment,
                onTap: () => const FindDoctorRoute().push<void>(context),
              ),
            ),
      body: RoleBackground.patient(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator.adaptive(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                    AppSpacing.screenMargin,
                    MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                  ),
                  sliver: SliverList.list(
                    children: _body(upcoming, past, loading),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(
    List<({AppointmentModel appointment, DateTime? start})> upcoming,
    List<({AppointmentModel appointment, DateTime? start})> past,
    bool loading,
  ) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return [
      Text(l10n.appointmentsTitle, style: textTheme.displaySmall),
      if (upcoming.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.appointmentsSubtitle(upcoming.length, past.length),
          style: textTheme.bodyMedium,
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      if (loading)
        SizedBox(
          height: 280,
          child: LoadingView(semanticLabel: l10n.appointmentsLoadingLabel),
        )
      else if (upcoming.isEmpty) ...[
        BookPromptCard(
          title: l10n.appointmentsEmptyTitle,
          body: l10n.appointmentsEmptyBody,
          actionLabel: l10n.appointmentsBookAppointment,
          onBook: () => const FindDoctorRoute().push<void>(context),
        ),
        if (past.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          ..._pastSection(past),
        ],
      ] else ...[
        _hero(upcoming.first),
        for (final next in upcoming.skip(1)) ...[
          const SizedBox(height: AppSpacing.sm),
          _row(next, 0),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          ..._pastSection(past),
        ],
      ],
    ];
  }

  Widget _hero(({AppointmentModel appointment, DateTime? start}) next) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final appointment = next.appointment;
    final start = next.start ?? nairobiNow();
    // The chip sits above the card: beside the button it overflows.
    final card = AppointmentHeroCard(
      eyebrow: DateFormat('EEE d MMM', language).format(start),
      leading: Avatar(name: appointment.doctorName, radius: 32),
      title: appointment.doctorName,
      body:
          '${appointment.typeValue.description(l10n)} · '
          '${appointment.facilityName}',
      figure: DateFormat('h:mm a', language).format(start),
      primary: HeroPillButton(
        label: l10n.appointmentsViewAppointment,
        onTap: () => PatientAppointmentRoute(
          appointmentUid: appointment.uid,
        ).push<void>(context),
      ),
    );
    if (appointment.statusValue != AppointmentStatus.requested) return card;
    return Column(
      crossAxisAlignment: .start,
      children: [
        StatusChip(label: l10n.appointmentsWaitingDoctor, tone: .neutral),
        const SizedBox(height: AppSpacing.xs),
        card,
      ],
    );
  }

  List<Widget> _pastSection(
    List<({AppointmentModel appointment, DateTime? start})> past,
  ) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final widgets = <Widget>[
      Text(
        l10n.appointmentsPastTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ];
    var lastMonth = '';
    var toneIndex = 0;
    for (final entry in past) {
      final start = entry.start;
      final month = start == null
          ? ''
          : DateFormat('MMMM y', language).format(start);
      if (month != lastMonth) {
        lastMonth = month;
        if (month.isNotEmpty) {
          widgets
            ..add(const SizedBox(height: AppSpacing.sm))
            ..add(
              Text(
                month,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: .w500,
                ),
              ),
            );
        }
      }
      widgets
        ..add(const SizedBox(height: AppSpacing.sm))
        ..add(_row(entry, toneIndex++));
    }
    return widgets;
  }

  Widget _row(
    ({AppointmentModel appointment, DateTime? start}) entry,
    int toneIndex,
  ) {
    final language = Localizations.localeOf(context).languageCode;
    final appointment = entry.appointment;
    final start = entry.start;
    const tones = [IconTone.lavender, IconTone.mint, IconTone.sky];
    return ListRowCard(
      leading: start == null
          ? null
          : DateTile(
              date: start,
              monthLabel: DateFormat(
                'MMM',
                language,
              ).format(start).toUpperCase(),
              tone: tones[toneIndex % tones.length],
            ),
      title: appointment.doctorName,
      subtitle: appointment.facilityName,
      chip: _statusChip(appointment),
      onTap: () => PatientAppointmentRoute(
        appointmentUid: appointment.uid,
      ).push<void>(context),
    );
  }

  /// Chips for requests that ended without a visit; visits carry no outcome
  /// data, so they show none.
  Widget? _statusChip(AppointmentModel appointment) {
    final l10n = context.l10n;
    return switch (appointment.statusValue) {
      .requested => StatusChip(
        label: l10n.appointmentsWaitingDoctor,
        tone: .neutral,
      ),
      .declined => StatusChip(label: l10n.appointmentsDeclined, tone: .closed),
      .cancelled => StatusChip(
        label: l10n.appointmentsCancelled,
        tone: .closed,
      ),
      .expired => StatusChip(label: l10n.appointmentsExpired, tone: .closed),
      .accepted || .completed || .noShow => null,
    };
  }
}
