import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/hero_pill_button.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/home/presentation/widgets/home_header.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_headline.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_search_entry.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// How many ranked rows "Up next" lists under the hero.
const _upNextCount = 4;

/// PA-01. The pathologist's desk: how many cases wait, the most urgent one,
/// what needs a close read, and the next few in line. What the AI produced is
/// marked as AI throughout and never wears the signed colour (H-18).
class DeskScreen extends StatefulWidget {
  /// [now] is the clock; a test gives it a fixed one.
  const DeskScreen({this.now, super.key});

  final DateTime Function()? now;

  @override
  State<DeskScreen> createState() => _DeskScreenState();
}

class _DeskScreenState extends State<DeskScreen> {
  late final DoctorModel _doctor;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _doctor = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor,
      _ => DoctorModel.empty(),
    };
    final desk = context.read<DeskBloc>();
    if (desk.state.entries.isEmpty) {
      desk.add(DeskRequested(pathologistUid: _doctor.uid));
    }
    final cases = context.read<CasesBloc>().state;
    if (cases.cases.isEmpty && cases.reports.isEmpty) {
      context.read<CasesBloc>().add(
        CasesRequested(uid: _doctor.uid, role: .pathologist),
      );
    }
    final inbox = context.read<NotificationsBloc>();
    if (inbox.state is NotificationsInitial) {
      inbox.add(NotificationsRequested(uid: _doctor.uid));
    }
  }

  void _dispatchRefreshes() {
    context.read<DeskBloc>().add(DeskRefreshed(pathologistUid: _doctor.uid));
    context.read<CasesBloc>().add(
      CasesRefreshed(uid: _doctor.uid, role: .pathologist),
    );
    context.read<NotificationsBloc>().add(
      NotificationsRefreshed(uid: _doctor.uid),
    );
  }

  Future<void> _refresh() async {
    final desk = context.read<DeskBloc>();
    _dispatchRefreshes();
    await settleRefresh<DeskState>(
      desk.stream,
      (state) => state is DeskLoadInProgress,
    );
  }

  void _open(WorklistEntryModel entry) {
    if (entry.caseUid.isEmpty) return;
    unawaited(CaseWorkspaceRoute(caseUid: entry.caseUid).push<void>(context));
  }

  Widget _hero(
    WorklistEntryModel entry, {
    required DeskPatient? patient,
    required DateTime now,
  }) {
    final l10n = context.l10n;
    final waited = waitedOf(entry, now);
    final elapsed = waited == null ? null : elapsedLabel(l10n, waited);
    final order = entry.orderNumber;
    final body = patient == null
        ? ''
        : patient.age > 0 && elapsed != null
        ? l10n.deskHeroWaiting(patient.name, patient.age, elapsed)
        : patient.label;
    // Only a ready pre-read says anything about the AI; a failed one says so
    // in neutral, and the rest stay silent.
    final ai = switch (entry.prereadStatusValue) {
      .ready => AiMark(label: l10n.deskAiDraftReady),
      .failed => StatusChip(label: l10n.deskNoAiDraft, tone: .neutral),
      .queued || .running || null => null,
    };
    return AppointmentHeroCard(
      eyebrow: l10n.deskMostUrgent,
      progress: ai == null
          ? null
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.45,
              ),
              child: ai,
            ),
      title: entry.testName.isEmpty ? order : '$order · ${entry.testName}',
      // The large figure is the time waiting, the one number the desk can
      // stand behind (N-21).
      figure: elapsed,
      subtitle: elapsed == null ? null : l10n.deskWaitingLabel,
      body: body,
      primary: HeroPillButton(
        label: l10n.deskOpenCase,
        onTap: entry.caseUid.isEmpty ? null : () => _open(entry),
      ),
    );
  }

  Widget _bento({
    required List<WorklistEntryModel> entries,
    required int signedCount,
    required int? signedAverage,
    required DateTime now,
  }) {
    final l10n = context.l10n;
    final low = entries.where(isLowConfidence).length;
    final long = entries.where((e) => isWaitingLong(e, now)).toList();
    final oldest = oldestWait(long, now);
    return ShortcutBento(
      tall: ShortcutTile(
        icon: Assets.icons.sparkleIcon,
        tone: .lavender,
        title: l10n.deskLowConfidence,
        body: l10n.deskLowConfidenceBody,
        value: '$low',
        tall: true,
        onTap: () =>
            const DeskListRoute(filter: 'lowConfidence').push<void>(context),
      ),
      top: ShortcutTile(
        icon: Assets.icons.clockIcon,
        tone: .butter,
        title: l10n.deskWaitingOver4h,
        body: oldest == null
            ? l10n.deskSubtitleWaiting(0)
            : l10n.deskWaitingBody(long.length, elapsedLabel(l10n, oldest)),
        onTap: () =>
            const DeskListRoute(filter: 'waitingOver4h').push<void>(context),
      ),
      bottom: ShortcutTile(
        icon: Assets.icons.checkCircleIcon,
        tone: .mint,
        title: l10n.deskSignedToday,
        body: signedAverage == null
            ? null
            : l10n.deskSignedBody(signedCount, signedAverage),
        value: signedAverage == null ? '$signedCount' : null,
        onTap: () => const PathologistSignedRoute().go(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final desk = context.watch<DeskBloc>().state;
    final cases = context.watch<CasesBloc>().state;
    final notifications = context.watch<NotificationsBloc>().state;
    final now = _now();

    final entries = desk.entries;
    final loading =
        (desk is DeskInitial || desk is DeskLoadInProgress) && entries.isEmpty;
    // A failed load is not an empty desk: say nothing about emptiness then.
    final empty = desk is DeskLoadSuccess && entries.isEmpty;
    final signed = signedTodayOf(cases.reports, _doctor.uid, now);

    return ShellTabPage(
      role: .pathologist,
      onRefresh: _refresh,
      children: [
        HomeHeader(
          name: '${_doctor.firstName} ${_doctor.lastName}',
          greeting: l10n.homeGreeting('${_doctor.title} ${_doctor.lastName}'),
          subtitle: l10n.homeSubtitlePractitioner(
            DateFormat('EEE d MMM', language).format(nairobiNow(now)),
            _doctor.facilityName,
          ),
          photoUrl: _doctor.profilePictureUrl,
          notificationsLabel: l10n.profileNotifications,
          onNotifications: () =>
              const PathologistNotificationsRoute().push<void>(context),
          hasUnread: notifications.unread > 0,
          unreadLabel: l10n.deskBellUnread,
        ),
        if (desk.offline || desk is DeskLoadFailure) ...[
          const SizedBox(height: AppSpacing.md),
          ConnectivityBanner(
            state: desk.offline ? .offline : .slow,
            title: l10n.deskSlowConnectionTitle,
            body: l10n.deskSlowConnectionBody,
            retryLabel: l10n.commonRetry,
            onRetry: _dispatchRefreshes,
          ),
        ],
        if (loading) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          LoadingView(
            semanticLabel: MaterialLocalizations.of(
              context,
            ).refreshIndicatorSemanticLabel,
          ),
        ] else if (empty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          // No button: the desk fills from cases doctors send, and there is
          // nothing here for the pathologist to start (F-11).
          EmptyState(
            icon: Assets.icons.documentIcon,
            tone: .lavender,
            title: l10n.deskEmptyTitle,
            body: l10n.deskEmptyBody,
          ),
        ] else if (entries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DeskHeadline(
            first: l10n.deskCasesOnDesk(entries.length),
            second: l10n.deskAiReadFirst,
          ),
          const SizedBox(height: AppSpacing.md),
          _hero(
            entries.first,
            patient: patientOf(caseOf(cases.cases, entries.first)),
            now: now,
          ),
          const SizedBox(height: AppSpacing.md),
          DeskSearchEntry(
            hint: l10n.deskSearchHint,
            onTap: () => const DeskSearchRoute().push<void>(context),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            l10n.deskAllCasesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _bento(
            entries: entries,
            signedCount: signed.count,
            signedAverage: signed.averageMinutes,
            now: now,
          ),
          if (entries.length > 1) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            SectionHeader(
              title: l10n.deskUpNext,
              actionLabel: l10n.doctorCasesFilterAll(entries.length),
              onAction: () => const DeskListRoute().push<void>(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 1; i < entries.length && i <= _upNextCount; i++) ...[
              DeskEntryRow(
                entry: entries[i],
                rank: i + 1,
                now: now,
                patient: patientOf(caseOf(cases.cases, entries[i])),
                onTap: () => _open(entries[i]),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ],
    );
  }
}
