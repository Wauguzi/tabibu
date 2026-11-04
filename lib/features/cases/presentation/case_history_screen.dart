import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-/PA-ACCESS-LOG, and the patient's own: the case's stage log, newest
/// first under day headers. Patients receive only patient-visible rows (the
/// sync filters by role); record opens are never logged, so no entry ever
/// reads "opened by". A row the entries cannot fill — a viewer removal names
/// nobody — is left out rather than guessed.
class CaseHistoryScreen extends StatefulWidget {
  /// [now] pins the day headers; tests pass a fixed noon.
  const CaseHistoryScreen({
    required this.caseUid,
    required this.role,
    this.now,
    super.key,
  });

  final String caseUid;
  final Role role;
  final DateTime? now;

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: uid, role: widget.role));
    }
    cases.add(CaseLogRequested(caseUid: widget.caseUid, role: widget.role));
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final casesState = context.watch<CasesBloc>().state;
    final directory = context.watch<DirectoryBloc>().state.all;
    final entries = casesState.logs[widget.caseUid] ?? const [];
    final testNames =
        casesState.cases
            .firstWhereOrNull((c) => c.uid == widget.caseUid)
            ?.tests
            .map((t) => t.name)
            .where((name) => name.isNotEmpty)
            .join(', ') ??
        '';
    final now = nairobiNow(widget.now);
    final rows = _rows(l10n, entries, testNames, directory);
    final loading =
        entries.isEmpty &&
        (casesState is CasesInitial || casesState is CasesLoadInProgress);
    final failure = casesState is CasesLoadFailure ? casesState.error : null;

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
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.accessLogTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (loading)
                  LoadingView(semanticLabel: l10n.accessLogTitle)
                else if (failure != null)
                  Text(
                    failure.description(l10n),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                else if (rows.isEmpty)
                  EmptyState(
                    icon: Assets.icons.clockIcon,
                    title: l10n.accessLogEmpty,
                  )
                else ...[
                  Text(
                    l10n.accessLogBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final group in _groups(rows, now)) ...[
                    _DayHeader(at: group.at, now: now, language: language),
                    const SizedBox(height: AppSpacing.xs),
                    _HistoryGroup(rows: group.rows, language: language),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: switch (widget.role) {
        .patient => RoleBackground.patient(child: body),
        .pathologist => RoleBackground.pathologist(child: body),
        _ => RoleBackground.doctor(child: body),
      },
    );
  }

  /// Newest first; entries without a line or a readable date stay out.
  List<({String line, DateTime at})> _rows(
    AppLocalizations l10n,
    List<CaseLogEntryModel> entries,
    String testNames,
    List<PractitionerModel> directory,
  ) {
    final rows = <({String line, DateTime at})>[];
    final ordered = entries.sortedBy((e) => e.createdAt).reversed.toList();
    for (final entry in ordered) {
      final at = nairobiTimeOf(entry.createdAt);
      final line = _line(l10n, entry, testNames, directory);
      if (at == null || line == null) continue;
      rows.add((line: line, at: at));
    }
    return rows;
  }

  /// The action first: a share self-transitions to OrderCreated and must
  /// read as a share. Viewer removals log no identity and stages outside
  /// the keys (requests, pre-reads, discussions) have no line.
  String? _line(
    AppLocalizations l10n,
    CaseLogEntryModel entry,
    String testNames,
    List<PractitionerModel> directory,
  ) => switch (entry.actionTypeValue) {
    .share => l10n.accessLogShared(_actorName(l10n, entry, directory)),
    .reject => l10n.accessLogRejected,
    .expire => l10n.accessLogExpired,
    .reassign => l10n.accessLogReassigned,
    .cancel => l10n.accessLogCancelled,
    .removeViewer => null,
    .revise => l10n.accessLogRevised,
    .receive => l10n.accessLogReceived,
    .addSlides => l10n.accessLogSlidesAdded,
    .none => switch (entry.toStageValue) {
      .orderCreated =>
        testNames.isEmpty ? null : l10n.accessLogOrdered(testNames),
      .sampleReceived => l10n.accessLogReceived,
      .reportSigned => l10n.accessLogSigned,
      .cancelled => l10n.accessLogCancelled,
      _ => null,
    },
  };

  /// The clinician who joined on a share; the role when the directory does
  /// not know them.
  String _actorName(
    AppLocalizations l10n,
    CaseLogEntryModel entry,
    List<PractitionerModel> directory,
  ) {
    final found = directory.firstWhereOrNull(
      (p) => p.uid == entry.createdByUid,
    );
    if (found != null && found.fullName.isNotEmpty) return found.fullName;
    return entry.actorRoleValue == .pathologist
        ? l10n.rolePathologist
        : l10n.roleDoctor;
  }

  List<({DateTime at, List<({String line, DateTime at})> rows})> _groups(
    List<({String line, DateTime at})> rows,
    DateTime now,
  ) {
    final groups = <({DateTime at, List<({String line, DateTime at})> rows})>[];
    for (final row in rows) {
      final last = groups.lastOrNull;
      final sameDay = last != null && nairobiDaysBefore(row.at, last.at) == 0;
      if (last != null && sameDay) {
        last.rows.add(row);
      } else {
        groups.add((at: row.at, rows: [row]));
      }
    }
    return groups;
  }
}

/// Today, Yesterday, else the date: the keys name only the first two.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.at,
    required this.now,
    required this.language,
  });

  final DateTime at;
  final DateTime now;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final behind = nairobiDaysBefore(at, now);
    final text = behind <= 0
        ? l10n.accessLogToday
        : behind == 1
        ? l10n.accessLogYesterday
        : DateFormat('d MMM yyyy', language).format(at);
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

/// One day's entries on a card, hairlines between, each with its time.
class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({required this.rows, required this.language});

  final List<({String line, DateTime at})> rows;
  final String language;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final clock = DateFormat('h:mm a', language);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
            Padding(
              padding: AppStyles.cardPadding,
              child: Row(
                children: [
                  IconTile(icon: Assets.icons.clockIcon, tone: .neutral),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      rows[i].line,
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    clock.format(rows[i].at),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
