import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/closest_match.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/order_number.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/signed_report_row.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

enum _SignedFilter { today, week, notifiable }

/// PA-06. The pathologist's signed tab: only reports they signed, newest
/// first, with the day's count and the week's.
class SignedScreen extends StatefulWidget {
  const SignedScreen({super.key});

  @override
  State<SignedScreen> createState() => _SignedScreenState();
}

class _SignedScreenState extends State<SignedScreen> {
  late final String _me;
  final _search = TextEditingController();
  _SignedFilter _filter = .today;

  @override
  void initState() {
    super.initState();
    _me = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    if (context.read<CasesBloc>().state.reports.isEmpty) {
      context.read<CasesBloc>().add(
        CasesRequested(uid: _me, role: .pathologist),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _dispatchRefresh() {
    context.read<CasesBloc>().add(CasesRefreshed(uid: _me, role: .pathologist));
  }

  Future<void> _refresh() async {
    final cases = context.read<CasesBloc>();
    _dispatchRefresh();
    await settleRefresh<CasesState>(
      cases.stream,
      (state) => state is CasesLoadInProgress,
    );
  }

  DateTime? _signedAt(PathologyReportModel r) => nairobiTimeOf(r.signedAt);

  bool _signedSince(PathologyReportModel r, DateTime start) {
    final at = _signedAt(r);
    return at != null && !at.isBefore(start);
  }

  bool _matches(PathologyReportModel r, _SignedFilter filter) =>
      switch (filter) {
        .today => _signedSince(r, _todayStart),
        .week => _signedSince(r, _weekStart),
        .notifiable => r.notifiableFindings.isNotEmpty,
      };

  bool _matchesQuery(
    PathologyReportModel r,
    String folded,
    Map<String, CaseModel> cases,
  ) {
    if (folded.isEmpty) return true;
    if (foldForSearch(r.orderNumber).contains(folded)) return true;
    if (foldForSearch(r.testName).contains(folded)) return true;
    final name = cases[r.caseUid]?.patientName ?? '';
    return foldForSearch(name).contains(folded);
  }

  late final DateTime _todayStart = _dayStart(nairobiNow());
  late final DateTime _weekStart = _todayStart.subtract(
    Duration(days: nairobiNow().weekday - 1),
  );

  static DateTime _dayStart(DateTime wall) =>
      DateTime.utc(wall.year, wall.month, wall.day);

  String _subtitle(
    PathologyReportModel r,
    AppLocalizations l10n,
    String language,
  ) {
    final at = _signedAt(r)!;
    final base = _signedSince(r, _todayStart)
        ? l10n.signedTabSignedTime(DateFormat('h:mm a', language).format(at))
        : l10n.signedTabSignedDate(
            DateFormat('EEE d MMM', language).format(at),
          );
    if (r.notifiableFindings.isEmpty) return base;
    return '$base · ${l10n.signedTabEventSent}';
  }

  String? _average(List<PathologyReportModel> set, AppLocalizations l10n) {
    var seconds = 0;
    var count = 0;
    for (final r in set) {
      final start = nairobiTimeOf(r.startedAt);
      final end = _signedAt(r);
      if (start == null || end == null || end.isBefore(start)) continue;
      seconds += end.difference(start).inSeconds;
      count++;
    }
    if (count == 0) return null;
    return l10n.signedTabAvgMinutes((seconds / count / 60).round());
  }

  /// The desk case a no-hit query points at, by number or joined name.
  WorklistEntryModel? _deskMatch(
    String query,
    List<WorklistEntryModel> entries,
    Map<String, CaseModel> cases,
  ) {
    final folded = foldForSearch(query);
    if (folded.isEmpty || entries.isEmpty) return null;
    for (final e in entries) {
      final name = cases[e.caseUid]?.patientName ?? '';
      if (foldForSearch(e.orderNumber).contains(folded)) return e;
      if (name.isNotEmpty && foldForSearch(name).contains(folded)) return e;
    }
    final numbers = entries.map((e) => e.orderNumber);
    final names = entries.map((e) => cases[e.caseUid]?.patientName ?? '');
    final near = closestMatch(query, [...numbers, ...names]);
    if (near == null) return null;
    return entries.firstWhereOrNull(
      (e) => e.orderNumber == near || cases[e.caseUid]?.patientName == near,
    );
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _filter = .today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final state = context.watch<CasesBloc>().state;
    final desk = context.watch<DeskBloc>().state.entries;
    final cases = {for (final c in state.cases) c.uid: c};
    // The signer's own current reports only (H-4); newest first. A
    // signedAt that isn't an instant reads as unset.
    final mine = state.reports
        .where(
          (r) =>
              r.pathologistUid == _me &&
              r.isCurrent &&
              nairobiTimeOf(r.signedAt) != null,
        )
        .sortedBy(
          (r) =>
              DateTime.tryParse(r.signedAt)?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0),
        )
        .reversed
        .toList();
    final query = _search.text;
    final folded = foldForSearch(query);
    final loading =
        (state is CasesInitial || state is CasesLoadInProgress) &&
        state.reports.isEmpty;
    final looksLikeNumber = looksLikeOrderNumber(query);
    final searched = mine
        .where((r) => _matches(r, _filter) && _matchesQuery(r, folded, cases))
        .toList();
    final noHits = folded.isNotEmpty && searched.isEmpty;
    final tileSet = mine
        .where((r) => _matches(r, _filter == .week ? .week : .today))
        .toList();

    return ShellTabPage(
      role: .pathologist,
      onRefresh: _refresh,
      children: [
        Text(l10n.tabSigned, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.signedTabSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (state.offline) ...[
          const SizedBox(height: AppSpacing.md),
          ConnectivityBanner(
            state: .offline,
            title: l10n.notificationsOfflineTitle,
            body: l10n.signedTabSubtitle,
            retryLabel: l10n.commonRetry,
            onRetry: _dispatchRefresh,
          ),
        ],
        if (mine.isNotEmpty || loading) ...[
          const SizedBox(height: AppSpacing.md),
          SearchField(
            hint: l10n.deskSearchHint,
            clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
            controller: _search,
            onChanged: (_) => setState(() {}),
          ),
        ],
        if (looksLikeNumber) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.caseSearchHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (loading) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          LoadingView(semanticLabel: l10n.resultsLoadingLabel),
        ] else if (noHits) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          _noResults(query, desk, cases),
        ] else if (mine.isEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          EmptyState(
            title: l10n.signedTabEmptyTitle,
            body: l10n.signedTabEmptyBody,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          ShortcutTile(
            icon: Assets.icons.checkCircleIcon,
            tone: .mint,
            value: '${tileSet.length}',
            title: _filter == .week
                ? l10n.signedTabSignedWeek
                : l10n.deskSignedToday,
            body: _average(tileSet, l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          _chips(),
          const SizedBox(height: AppSpacing.md),
          for (final r in searched) ...[
            SignedReportRow(
              report: r,
              subtitle: _subtitle(r, l10n, language),
              onTap: () => unawaited(
                CaseWorkspaceRoute(caseUid: r.caseUid).push<void>(context),
              ),
              onCompare: () => unawaited(
                CompareRoute(caseUid: r.caseUid).push<void>(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }

  Widget _chips() => Wrap(
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    children: [
      TabibuFilterChip(
        label: context.l10n.signedTabToday,
        selected: _filter == .today,
        onTap: () => setState(() => _filter = .today),
      ),
      TabibuFilterChip(
        label: context.l10n.signedTabWeek,
        selected: _filter == .week,
        onTap: () => setState(() => _filter = .week),
      ),
      TabibuFilterChip(
        label: context.l10n.signedTabNotifiable,
        selected: _filter == .notifiable,
        onTap: () => setState(() => _filter = .notifiable),
      ),
    ],
  );

  Widget _noResults(
    String query,
    List<WorklistEntryModel> entries,
    Map<String, CaseModel> cases,
  ) {
    final l10n = context.l10n;
    final match = _deskMatch(query, entries, cases);
    return EmptyState(
      title: l10n.signedTabNoResultsTitle(query.trim()),
      body: match == null ? null : l10n.signedTabStillOnDesk,
      icon: Assets.icons.searchRoundedIcon,
      tone: .lavender,
      actions: [
        if (match != null) ...[
          Text(
            l10n.signedTabGoToCase,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: .center,
          ),
          SuggestionPill(
            label: l10n.signedTabOpenCase(match.orderNumber),
            onTap: () => unawaited(
              CaseWorkspaceRoute(caseUid: match.caseUid).push<void>(context),
            ),
          ),
        ],
        SuggestionPill(label: l10n.resultsClearSearch, onTap: _clearSearch),
      ],
      tips: TipsCard(
        title: l10n.resultsEmptyTipsTitle,
        tips: [l10n.signedTabNoResultsTip],
      ),
    );
  }
}
