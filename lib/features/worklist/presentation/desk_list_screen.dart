import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_search_entry.dart';
import 'package:tabibu/l10n/l10n.dart';

/// PA-02. Every open case on the desk, ranked, with the four filters. A row
/// keeps its place on the whole desk when a filter hides the others.
class DeskListScreen extends StatefulWidget {
  /// [now] is the clock; a test gives it a fixed one.
  const DeskListScreen({required this.filter, this.now, super.key});

  /// The filter the list opens on.
  final DeskFilter filter;
  final DateTime Function()? now;

  @override
  State<DeskListScreen> createState() => _DeskListScreenState();
}

class _DeskListScreenState extends State<DeskListScreen> {
  late final String _uid;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final desk = context.read<DeskBloc>()
      ..add(DeskFilterChanged(filter: widget.filter));
    if (desk.state.entries.isEmpty) {
      desk.add(DeskRequested(pathologistUid: _uid));
    }
    final cases = context.read<CasesBloc>().state;
    if (cases.cases.isEmpty) {
      context.read<CasesBloc>().add(
        CasesRequested(uid: _uid, role: .pathologist),
      );
    }
  }

  Future<void> _refresh() async {
    final desk = context.read<DeskBloc>()
      ..add(DeskRefreshed(pathologistUid: _uid));
    context.read<CasesBloc>().add(
      CasesRefreshed(uid: _uid, role: .pathologist),
    );
    await settleRefresh<DeskState>(
      desk.stream,
      (state) => state is DeskLoadInProgress,
    );
  }

  /// What the filter keeps. The desk's own low-confidence filter looks at the
  /// stored band alone, which a pre-read that never finished still carries;
  /// the list keeps only what the AI actually read (H-18).
  bool _kept(WorklistEntryModel entry, DeskFilter filter) =>
      filter != .lowConfidence || isLowConfidence(entry);

  String _subtitle(
    AppLocalizations l10n, {
    required DeskFilter filter,
    required int count,
    required Duration? oldest,
  }) => switch (filter) {
    .all =>
      oldest == null
          ? l10n.deskCasesOnDesk(count)
          : l10n.deskSubtitleAll(count, elapsedLabel(l10n, oldest)),
    .lowConfidence => l10n.deskSubtitleLowConfidence(count),
    .waitingOver4h => l10n.deskSubtitleWaiting(count),
    .notifiable => l10n.deskSubtitleNotifiable(count),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final desk = context.watch<DeskBloc>().state;
    final cases = context.watch<CasesBloc>().state.cases;
    final now = _now();

    final entries = desk.entries;
    final filter = desk.filter;
    final rows = desk.visible.where((e) => _kept(e, filter)).toList();
    final loading =
        (desk is DeskInitial || desk is DeskLoadInProgress) && entries.isEmpty;
    final lowCount = entries.where(isLowConfidence).length;
    final waitingCount = entries.where((e) => isWaitingLong(e, now)).length;
    final notifiableCount = entries.where(isNotifiable).length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              TopBar(
                backLabel: l10n.commonBack,
                onBack: context.pop,
                title: l10n.deskAllCasesTitle,
                // A count line comes from data and never shows over none.
                subtitle: entries.isEmpty
                    ? null
                    : _subtitle(
                        l10n,
                        filter: filter,
                        count: rows.length,
                        oldest: oldestWait(entries, now),
                      ),
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    children: [
                      DeskSearchEntry(
                        hint: l10n.deskSearchHint,
                        onTap: () =>
                            const DeskSearchRoute().push<void>(context),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (loading)
                        LoadingView(
                          semanticLabel: MaterialLocalizations.of(
                            context,
                          ).refreshIndicatorSemanticLabel,
                        )
                      else ...[
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            TabibuFilterChip(
                              label: l10n.doctorCasesFilterAll(entries.length),
                              selected: filter == .all,
                              onTap: () => _select(.all),
                            ),
                            TabibuFilterChip(
                              label: l10n.deskFilterLowConfidence(lowCount),
                              selected: filter == .lowConfidence,
                              onTap: () => _select(.lowConfidence),
                            ),
                            TabibuFilterChip(
                              label: l10n.deskFilterWaiting(waitingCount),
                              selected: filter == .waitingOver4h,
                              onTap: () => _select(.waitingOver4h),
                            ),
                            TabibuFilterChip(
                              label: l10n.deskFilterNotifiable(notifiableCount),
                              selected: filter == .notifiable,
                              onTap: () => _select(.notifiable),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (var i = 0; i < rows.length; i++) ...[
                          DeskEntryRow(
                            entry: rows[i],
                            rank: i + 1,
                            now: now,
                            patient: patientOf(caseOf(cases, rows[i])),
                            onTap: rows[i].caseUid.isEmpty
                                ? null
                                : () => CaseWorkspaceRoute(
                                    caseUid: rows[i].caseUid,
                                  ).push<void>(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(DeskFilter filter) =>
      context.read<DeskBloc>().add(DeskFilterChanged(filter: filter));
}
