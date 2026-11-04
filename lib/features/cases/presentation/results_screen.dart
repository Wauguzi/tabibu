import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/result_copy.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/results_slide.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

enum _ResultsFilter { all, withDoctor, shared }

/// P-11a. The patient's Results tab: filters, the with-doctor slide, and rows.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final PatientModel _patient;
  final _search = TextEditingController();
  _ResultsFilter _filter = .all;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _patient = switch (session) {
      PatientSession(:final patient) => patient,
      _ => PatientModel.empty(),
    };
    context.read<CasesBloc>().add(
      CasesRequested(uid: _patient.uid, role: .patient),
    );
    // Discussion dates for the with-doctor slide (same as patient home).
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: _patient.uid, role: .patient),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _dispatchRefresh() {
    context.read<CasesBloc>().add(
      CasesRefreshed(uid: _patient.uid, role: .patient),
    );
    context.read<AppointmentsBloc>().add(
      AppointmentsRefreshed(uid: _patient.uid, role: .patient),
    );
  }

  Future<void> _refresh() async {
    final cases = context.read<CasesBloc>();
    _dispatchRefresh();
    await settleRefresh<CasesState>(
      cases.stream,
      (state) => state is CasesLoadInProgress,
    );
  }

  bool _isWithDoctor(CaseModel c) =>
      c.resultStateValue == .withDoctor ||
      c.resultStateValue == .updateWithDoctor;

  bool _isShared(CaseModel c) => c.resultStateValue == .released;

  bool _matchesQuery(CaseModel c, String folded) {
    if (folded.isEmpty) return true;
    final test = foldForSearch(c.tests.firstOrNull?.name ?? '');
    final doctor = foldForSearch(c.doctorName);
    return test.contains(folded) || doctor.contains(folded);
  }

  PathologyReportModel? _reportFor(CaseModel c, List<PathologyReportModel> rs) {
    if (c.currentReportUid.isEmpty) {
      return rs.firstWhereOrNull((r) => r.caseUid == c.uid);
    }
    return rs.firstWhereOrNull((r) => r.uid == c.currentReportUid);
  }

  String _discussionDate(
    CaseModel c,
    List<AppointmentModel> appointments,
    String language,
  ) {
    final discussion = appointments.firstWhereOrNull(
      (a) => a.uid == c.discussionAppointmentUid,
    );
    final at = discussion == null
        ? null
        : nairobiTimeOf(discussion.scheduledStart);
    if (at == null) return '';
    return DateFormat('EEE d MMM', language).format(at);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final casesState = context.watch<CasesBloc>().state;
    final appointments = context.watch<AppointmentsBloc>().state.appointments;
    final query = _search.text;
    final folded = foldForSearch(query);

    final all = casesState.cases;
    final withDoctorCount = all.where(_isWithDoctor).length;
    final sharedCount = all.where(_isShared).length;

    final searched = all.where((c) => _matchesQuery(c, folded)).toList();
    final filtered = switch (_filter) {
      .all => searched,
      .withDoctor => searched.where(_isWithDoctor).toList(),
      .shared => searched.where(_isShared).toList(),
    };

    final slideCase = searched.firstWhereOrNull(_isWithDoctor);
    final loading =
        (casesState is CasesInitial || casesState is CasesLoadInProgress) &&
        all.isEmpty;
    final noSearchHits = folded.isNotEmpty && searched.isEmpty;
    final showSlide = slideCase != null && _filter != .shared && folded.isEmpty;

    return ShellTabPage(
      role: .patient,
      onRefresh: _refresh,
      children: [
        TwoToneHeadline(
          first: l10n.resultsTitle,
          second: l10n.resultsSubtitle,
          tealSecond: false,
        ),
        if (casesState.offline) ...[
          const SizedBox(height: AppSpacing.md),
          ConnectivityBanner(
            state: .offline,
            title: l10n.resultsOfflineTitle,
            body: l10n.resultsOfflineBody,
            retryLabel: l10n.resultsRetry,
            onRetry: _dispatchRefresh,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        SearchField(
          hint: l10n.resultsSearchHint,
          clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        if (loading) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          LoadingView(semanticLabel: l10n.resultsLoadingLabel),
        ] else if (noSearchHits) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          EmptyState(
            title: l10n.resultsNoResultsTitle(query.trim()),
            body: l10n.resultsNoResultsBody(query.trim()),
            icon: Assets.icons.searchRoundedIcon,
            actions: [
              SuggestionPill(
                label: l10n.resultsClearSearch,
                onTap: () {
                  _search.clear();
                  setState(() {});
                },
              ),
            ],
            tips: TipsCard(
              title: l10n.resultsEmptyTipsTitle,
              tips: [l10n.resultsEmptyTipSearch],
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              TabibuFilterChip(
                label: l10n.resultsFilterAll(all.length),
                selected: _filter == .all,
                onTap: () => setState(() => _filter = .all),
              ),
              TabibuFilterChip(
                label: l10n.resultsFilterWithDoctor(withDoctorCount),
                selected: _filter == .withDoctor,
                onTap: () => setState(() => _filter = .withDoctor),
              ),
              TabibuFilterChip(
                label: l10n.resultsFilterShared(sharedCount),
                selected: _filter == .shared,
                onTap: () => setState(() => _filter = .shared),
              ),
            ],
          ),
          if (showSlide) ...[
            const SizedBox(height: AppSpacing.md),
            ResultsSlide(
              chipLabel: l10n.resultsWithDoctor,
              title: l10n.resultsSlideTitle(
                slideCase.tests.firstOrNull?.name ?? '',
              ),
              body: l10n.resultsSlideBodyFor(
                slideCase.doctorName,
                _discussionDate(slideCase, appointments, language),
              ),
              onTap: () => PatientResultRoute(
                caseUid: slideCase.uid,
              ).push<void>(context),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            l10n.resultsAllResults,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final c in filtered) ...[
            _ResultRow(
              caseModel: c,
              report: _reportFor(c, casesState.reports),
              language: language,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          AttributionLine(text: l10n.resultsPrivacyFooter),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.caseModel,
    required this.report,
    required this.language,
  });

  final CaseModel caseModel;
  final PathologyReportModel? report;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = caseModel.resultStateValue;
    final testName = caseModel.tests.firstOrNull?.name ?? '';
    final (chipLabel, tone, subtitle, icon) = switch (state) {
      .released => (
        l10n.resultsShared,
        StatusTone.signed,
        l10n.resultsRowSharedByFor(
          caseModel.doctorName,
          _date(
            caseModel.releasedAt.isNotEmpty
                ? caseModel.releasedAt
                : report?.signedAt ?? '',
          ),
        ),
        Assets.icons.documentIcon,
      ),
      .withDoctor || .updateWithDoctor => (
        l10n.resultsWithDoctor,
        StatusTone.info,
        l10n.resultsRowOrderedByFor(caseModel.doctorName, l10n.resultsWaiting),
        Assets.icons.documentIcon,
      ),
      .pending => (
        l10n.resultsWaiting,
        StatusTone.neutral,
        l10n.resultsRowOrderedByFor(caseModel.doctorName, l10n.resultsWaiting),
        Assets.icons.calendarIcon,
      ),
    };

    final openable =
        state == .released ||
        state == .withDoctor ||
        state == .updateWithDoctor;

    return ListRowCard(
      title: testName,
      subtitle: subtitle,
      leading: IconTile(icon: icon, tone: .mint),
      chip: StatusChip(label: chipLabel, tone: tone),
      onTap: openable
          ? () => PatientResultRoute(caseUid: caseModel.uid).push<void>(context)
          : null,
    );
  }

  String _date(String raw) {
    final at = nairobiTimeOf(raw);
    if (at == null) return '';
    return DateFormat('d MMM', language).format(at);
  }
}
