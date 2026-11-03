import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/closest_match.dart';
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
import 'package:tabibu/features/cases/presentation/widgets/case_row.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

enum _CaseFilter { all, ordered, withPathologist, signed, closed }

/// D-CASES. The doctor's cases tab: search, filters and sections by state.
class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  late final String _uid;
  final _search = TextEditingController();
  _CaseFilter _filter = .all;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    if (context.read<CasesBloc>().state.cases.isEmpty) {
      context.read<CasesBloc>().add(CasesRequested(uid: _uid, role: .doctor));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _dispatchRefresh() {
    context.read<CasesBloc>().add(CasesRefreshed(uid: _uid, role: .doctor));
  }

  Future<void> _refresh() async {
    final cases = context.read<CasesBloc>();
    _dispatchRefresh();
    await settleRefresh<CasesState>(
      cases.stream,
      (state) => state is CasesLoadInProgress,
    );
  }

  bool _matches(CaseModel c, _CaseFilter filter) => switch (filter) {
    .all => true,
    .ordered => c.doctorStep == 1,
    .withPathologist => c.doctorStep == 2,
    .signed => c.doctorStep == 3,
    .closed => c.isDone,
  };

  bool _matchesQuery(CaseModel c, String folded) {
    if (folded.isEmpty) return true;
    if (foldForSearch(c.patientName).contains(folded)) return true;
    if (foldForSearch(c.orderNumber).contains(folded)) return true;
    return c.tests.any((t) => foldForSearch(t.name).contains(folded));
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _filter = .all);
  }

  void _open(CaseModel c) {
    if (c.needsDoctor || c.doctorStep == 3) {
      unawaited(DoctorReportRoute(caseUid: c.uid).push<void>(context));
    } else {
      unawaited(DoctorCaseRoute(caseUid: c.uid).push<void>(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CasesBloc>().state;
    final all = state.cases;
    final query = _search.text;
    final folded = foldForSearch(query);
    final open = all.where((c) => !c.isDone).length;
    final needsYou = all.where((c) => c.needsDoctor).length;
    final subtitle = open == 0
        ? l10n.doctorCasesNoneOpen
        : l10n.doctorCasesSubtitle(open, needsYou);
    final loading =
        (state is CasesInitial || state is CasesLoadInProgress) && all.isEmpty;
    final looksLikeNumber = looksLikeOrderNumber(query);
    final searched = all.where((c) => _matchesQuery(c, folded)).toList();
    final noHits = folded.isNotEmpty && searched.isEmpty && !looksLikeNumber;

    return ShellTabPage(
      role: .doctor,
      onRefresh: _refresh,
      children: [
        Text(l10n.tabCases, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        if (state.offline) ...[
          const SizedBox(height: AppSpacing.md),
          ConnectivityBanner(
            state: .offline,
            title: l10n.notificationsOfflineTitle,
            body: subtitle,
            retryLabel: l10n.commonRetry,
            onRetry: _dispatchRefresh,
          ),
        ],
        if (all.isNotEmpty || loading) ...[
          const SizedBox(height: AppSpacing.md),
          SearchField(
            hint: l10n.doctorCasesSearchHint,
            clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
            controller: _search,
            onChanged: (_) => setState(() {}),
          ),
        ],
        if (loading) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          LoadingView(semanticLabel: l10n.resultsLoadingLabel),
        ] else if (looksLikeNumber) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.caseSearchHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _checkNumber(query, all),
        ] else if (noHits) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          _noMatch(query, all),
        ] else if (all.isEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          EmptyState(
            title: l10n.doctorCasesEmptyTitle,
            body: l10n.doctorCasesEmptyBody,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          _chips(all),
          ..._sections(searched),
        ],
      ],
    );
  }

  /// One scrolling row: the five filters take a single line, not two.
  Widget _chips(List<CaseModel> all) {
    final chips = [
      TabibuFilterChip(
        label: context.l10n.doctorCasesFilterAll(all.length),
        selected: _filter == .all,
        onTap: () => setState(() => _filter = .all),
      ),
      TabibuFilterChip(
        label: context.l10n.doctorCasesOrdered,
        selected: _filter == .ordered,
        onTap: () => setState(() => _filter = .ordered),
      ),
      TabibuFilterChip(
        label: context.l10n.doctorCasesWithPathologist,
        selected: _filter == .withPathologist,
        onTap: () => setState(() => _filter = .withPathologist),
      ),
      TabibuFilterChip(
        label: context.l10n.doctorCasesSigned,
        selected: _filter == .signed,
        onTap: () => setState(() => _filter = .signed),
      ),
      TabibuFilterChip(
        label: context.l10n.doctorCasesClosed,
        selected: _filter == .closed,
        onTap: () => setState(() => _filter = .closed),
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      clipBehavior: .none,
      child: Row(
        children: [
          for (final (i, chip) in chips.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            chip,
          ],
        ],
      ),
    );
  }

  List<Widget> _sections(List<CaseModel> searched) {
    final filtered = searched.where((c) => _matches(c, _filter)).toList();
    final needsYou = filtered.where((c) => c.needsDoctor).toList();
    final inProgress = filtered
        .where((c) => !c.isDone && !c.needsDoctor)
        .toList();
    var done = filtered
        .where((c) => c.isDone)
        .sortedBy(
          (c) =>
              DateTime.tryParse(c.createdAt)?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0),
        )
        .reversed
        .toList();
    final capped = _filter != .closed && done.length > 3;
    if (capped) done = done.take(3).toList();
    final l10n = context.l10n;
    return [
      if (needsYou.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _sectionHeader(l10n.doctorCasesNeedsYou, needsYou.length, null, null),
        ..._rows(needsYou),
      ],
      if (inProgress.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _sectionHeader(
          l10n.doctorCasesInProgress,
          inProgress.length,
          null,
          null,
        ),
        ..._rows(inProgress),
      ],
      if (done.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _sectionHeader(
          l10n.doctorCasesDone,
          done.length,
          capped ? l10n.doctorCasesSeeAll : null,
          capped ? () => setState(() => _filter = .closed) : null,
        ),
        ..._rows(done),
      ],
    ];
  }

  List<Widget> _rows(List<CaseModel> cases) => [
    for (final c in cases) ...[
      const SizedBox(height: AppSpacing.sm),
      CaseRow(caseModel: c, highlighted: c.needsDoctor, onTap: () => _open(c)),
    ],
  ];

  Widget _sectionHeader(
    String title,
    int count,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (label, action) = (actionLabel, onAction);
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: textTheme.titleLarge,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$count',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (label != null && action != null) ...[
          const Spacer(),
          Tappable(
            onTap: action,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _caption(String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    textAlign: .center,
  );

  /// A malformed order number: the check block with the closest case pill.
  Widget _checkNumber(String query, List<CaseModel> all) {
    final l10n = context.l10n;
    final match = closestMatch(query, all.map((c) => c.orderNumber));
    final target = match == null
        ? null
        : all.firstWhereOrNull((c) => c.orderNumber == match);
    return EmptyState(
      title: l10n.doctorCasesCheckNumber,
      body: l10n.doctorCasesCheckNumberBody,
      icon: Assets.icons.searchRoundedIcon,
      actions: [
        if (target != null) ...[
          _caption(l10n.caseSearchClosestMatch),
          SuggestionPill(
            label: '${target.orderNumber} · ${target.patientName}',
            onTap: () => unawaited(
              DoctorCaseRoute(caseUid: target.uid).push<void>(context),
            ),
          ),
        ],
        SuggestionPill(label: l10n.resultsClearSearch, onTap: _clearSearch),
      ],
    );
  }

  /// No match: the did-you-mean block, with the name pill when one is close.
  Widget _noMatch(String query, List<CaseModel> all) {
    final l10n = context.l10n;
    final match = closestMatch(query, all.map((c) => c.patientName));
    return EmptyState(
      title: l10n.doctorCasesNoMatchTitle(query.trim()),
      body: l10n.doctorCasesNoMatchBody,
      icon: Assets.icons.searchRoundedIcon,
      actions: [
        if (match != null) ...[
          _caption(l10n.caseSearchDidYouMean),
          SuggestionPill(
            label: match,
            onTap: () => setState(() => _search.text = match),
          ),
        ],
        SuggestionPill(label: l10n.resultsClearSearch, onTap: _clearSearch),
      ],
      tips: TipsCard(
        title: l10n.resultsEmptyTipsTitle,
        tips: [l10n.doctorCasesTipSearch, l10n.doctorCasesTipSeen],
      ),
    );
  }
}
