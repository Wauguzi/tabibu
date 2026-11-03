import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/closest_match.dart';
import 'package:tabibu/core/utils/order_number.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// PA-03. Search the pathologist's open cases by case number, test or
/// patient. The screen never opens the keyboard on its own, and leaves the
/// desk's query empty when it closes.
class DeskSearchScreen extends StatefulWidget {
  /// [now] is the clock; a test gives it a fixed one.
  const DeskSearchScreen({this.now, super.key});

  final DateTime Function()? now;

  @override
  State<DeskSearchScreen> createState() => _DeskSearchScreenState();
}

class _DeskSearchScreenState extends State<DeskSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  // Held for dispose: a context is not safe to read from there.
  late final DeskBloc _desk;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _desk = context.read<DeskBloc>();
    final uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    if (_desk.state.entries.isEmpty) {
      _desk.add(DeskRequested(pathologistUid: uid));
    }
    if (context.read<CasesBloc>().state.cases.isEmpty) {
      context.read<CasesBloc>().add(
        CasesRequested(uid: uid, role: .pathologist),
      );
    }
  }

  @override
  void dispose() {
    // The query lives in the desk's state: left behind, it would keep the
    // desk and its list filtered.
    if (!_desk.isClosed) _desk.add(const DeskQueryChanged(query: ''));
    _controller.dispose();
    super.dispose();
  }

  void _changed(String query) {
    setState(() {});
    _desk.add(DeskQueryChanged(query: query));
  }

  void _clear() {
    _controller.clear();
    _changed('');
  }

  /// Entries whose case number, test or patient contains the folded query.
  /// The desk's own query reads the case number and test only, and its list
  /// is narrowed by the filter the person last chose, so the screen searches
  /// every open case itself.
  List<WorklistEntryModel> _matches(
    List<WorklistEntryModel> entries,
    List<CaseModel> cases,
    String query,
  ) {
    final needle = foldForSearch(query);
    if (needle.isEmpty) return entries;
    return [
      for (final entry in entries)
        if (foldForSearch(entry.orderNumber).contains(needle) ||
            foldForSearch(entry.testName).contains(needle) ||
            foldForSearch(
              caseOf(cases, entry)?.patientName ?? '',
            ).contains(needle))
          entry,
    ];
  }

  void _open(WorklistEntryModel entry) {
    if (entry.caseUid.isEmpty) return;
    unawaited(CaseWorkspaceRoute(caseUid: entry.caseUid).push<void>(context));
  }

  List<Widget> _rows(
    List<WorklistEntryModel> shown, {
    required List<WorklistEntryModel> entries,
    required List<CaseModel> cases,
    required DateTime now,
  }) => [
    for (final entry in shown) ...[
      DeskEntryRow(
        entry: entry,
        rank: entries.indexOf(entry) + 1,
        now: now,
        patient: patientOf(caseOf(cases, entry)),
        onTap: () => _open(entry),
      ),
      const SizedBox(height: AppSpacing.sm),
    ],
  ];

  Widget _clearButton(AppLocalizations l10n) => SizedBox(
    width: double.infinity,
    child: TabibuButton.outline(label: l10n.resultsClearSearch, onTap: _clear),
  );

  Widget _caption(BuildContext context, String text) => SizedBox(
    width: double.infinity,
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium,
      textAlign: .center,
    ),
  );

  Widget _wrongNumber(
    BuildContext context, {
    required List<WorklistEntryModel> entries,
    required List<CaseModel> cases,
    required String query,
  }) {
    final l10n = context.l10n;
    final nearest = closestMatch(query, [
      for (final e in entries) e.orderNumber,
    ]);
    final entry = nearest == null
        ? null
        : entries.firstWhere((e) => e.orderNumber == nearest);
    final patient = entry == null ? null : patientOf(caseOf(cases, entry));
    return EmptyState(
      icon: Assets.icons.alertIcon,
      tone: .lavender,
      title: l10n.doctorCasesCheckNumber,
      body: l10n.deskWrongNumberBody,
      actions: [
        if (entry != null) ...[
          _caption(context, l10n.caseSearchClosestMatch),
          SuggestionPill(
            label: patient == null
                ? entry.orderNumber
                : '${entry.orderNumber} · ${patient.name}',
            onTap: () => _open(entry),
          ),
        ],
        _clearButton(l10n),
      ],
    );
  }

  Widget _noResults(
    BuildContext context, {
    required int total,
    required String query,
  }) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Assets.icons.searchRoundedIcon,
      tone: .lavender,
      title: l10n.deskSearchNoCase(query),
      body: l10n.deskSearchNoCaseBody,
      actions: [
        _caption(context, l10n.deskSearchElsewhere),
        SuggestionPill(
          label: l10n.deskSearchSigned,
          onTap: () => const PathologistSignedRoute().go(context),
        ),
        if (total > 0)
          SuggestionPill(
            label: l10n.deskSearchAllCases(total),
            onTap: () => const DeskListRoute().push<void>(context),
          ),
      ],
      tips: Column(
        children: [
          TipsCard(
            title: l10n.resultsEmptyTipsTitle,
            tips: [l10n.deskTipSlide, l10n.deskTipAreas],
          ),
          const SizedBox(height: AppSpacing.md),
          _clearButton(l10n),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final entries = context.watch<DeskBloc>().state.entries;
    final cases = context.watch<CasesBloc>().state.cases;
    final now = _now();
    final query = _controller.text.trim();
    final found = _matches(entries, cases, query);
    // A number that began like one but isn't one gets the format hint; while
    // it still matches a case it is just being typed.
    final wrongNumber =
        query.isNotEmpty && found.isEmpty && looksLikeOrderNumber(query);
    final noResults = query.isNotEmpty && found.isEmpty && !wrongNumber;

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
                title: l10n.deskSearchTitle,
                subtitle: wrongNumber
                    ? l10n.doctorCasesCheckNumber
                    : noResults
                    ? l10n.deskSearchNoResults
                    : query.isEmpty
                    ? null
                    : l10n.deskSearchResults(found.length, query),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  children: [
                    // No autofocus: the person looks first, then types.
                    SearchField(
                      hint: l10n.deskSearchHint,
                      clearLabel: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      controller: _controller,
                      onChanged: _changed,
                    ),
                    if (wrongNumber) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          l10n.caseSearchHint,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: scheme.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (wrongNumber)
                      _wrongNumber(
                        context,
                        entries: entries,
                        cases: cases,
                        query: query,
                      )
                    else if (noResults)
                      _noResults(context, total: entries.length, query: query)
                    else
                      ..._rows(found, entries: entries, cases: cases, now: now),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
