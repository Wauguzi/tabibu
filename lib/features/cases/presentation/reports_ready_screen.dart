import 'package:collection/collection.dart';
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
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-REPORTS-READY. The doctor's signed reports not yet discussed with the
/// patient, newest signed first.
class ReportsReadyScreen extends StatefulWidget {
  const ReportsReadyScreen({super.key});

  @override
  State<ReportsReadyScreen> createState() => _ReportsReadyScreenState();
}

class _ReportsReadyScreenState extends State<ReportsReadyScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _uid = switch (session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    context.read<CasesBloc>().add(CasesRequested(uid: _uid, role: .doctor));
  }

  Future<void> _refresh() async {
    final cases = context.read<CasesBloc>()
      ..add(CasesRefreshed(uid: _uid, role: .doctor));
    await settleRefresh<CasesState>(
      cases.stream,
      (state) => state is CasesLoadInProgress,
    );
  }

  bool _isWithDoctor(CaseModel c) =>
      c.resultStateValue == .withDoctor ||
      c.resultStateValue == .updateWithDoctor;

  PathologyReportModel? _reportFor(CaseModel c, List<PathologyReportModel> rs) {
    if (c.currentReportUid.isEmpty) {
      return rs.firstWhereOrNull((r) => r.caseUid == c.uid);
    }
    return rs.firstWhereOrNull((r) => r.uid == c.currentReportUid);
  }

  /// Newest signature first; a report with no readable date goes last.
  List<CaseModel> _ordered(CasesState state) {
    DateTime? signedAt(CaseModel c) =>
        DateTime.tryParse(_reportFor(c, state.reports)?.signedAt ?? '');
    final ready = state.cases.where(_isWithDoctor).toList();
    return ready.sorted((a, b) {
      final x = signedAt(a);
      final y = signedAt(b);
      if (x == null || y == null) {
        return x == null && y == null ? 0 : (x == null ? 1 : -1);
      }
      return y.compareTo(x);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CasesBloc>().state;
    final ready = _ordered(state);
    final loading =
        (state is CasesInitial || state is CasesLoadInProgress) &&
        state.cases.isEmpty;

    final body = SafeArea(
      child: RefreshIndicator.adaptive(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                AppSpacing.xlg,
              ),
              sliver: SliverList.list(
                children: [
                  TopBar(
                    title: l10n.reportsReadyTitle,
                    subtitle: loading || ready.isEmpty
                        ? null
                        : l10n.reportsReadySubtitle(ready.length),
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (loading)
                    LoadingView(semanticLabel: l10n.reportsReadyLoadingLabel)
                  else if (ready.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxlg),
                      child: EmptyState(
                        icon: Assets.icons.documentIcon,
                        tone: .lavender,
                        title: l10n.reportsReadyEmptyTitle,
                        body: l10n.reportsReadyEmptyBody,
                      ),
                    )
                  else ...[
                    for (final c in ready) ...[
                      ListRowCard(
                        leading: Avatar(name: c.patientName),
                        title: c.patientName,
                        subtitle: [
                          c.orderNumber,
                          c.tests.firstOrNull?.name ?? '',
                        ].where((part) => part.isNotEmpty).join(' · '),
                        chip: StatusChip(
                          label: l10n.reportsReadySigned,
                          tone: .signed,
                        ),
                        onTap: () => DoctorReportRoute(
                          caseUid: c.uid,
                        ).push<void>(context),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    NoticeCard(
                      icon: Assets.icons.infoIcon,
                      variant: .neutral,
                      body: l10n.reportsReadyNotice,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(body: RoleBackground.doctor(child: body));
  }
}
