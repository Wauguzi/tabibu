import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Builds a screen's cards for the signed [report] and its [caseModel]
/// (null until the doctor's cases have loaded).
typedef ReportBodyBuilder =
    List<Widget> Function(
      BuildContext context,
      PathologyReportModel report,
      CaseModel? caseModel,
    );

/// The frame both doctor report screens share: it opens the case's signed
/// report, draws the top bar and the loading, empty, offline and error
/// states, and hands the signed report to [bodyBuilder].
///
/// It reads `ReportReaderState.report` and nothing else from the reader:
/// never the explanations or the approved text (those are the reviewer's),
/// never a draft. It sends one event, [ReportReaderOpened].
class ReportReaderScaffold extends StatefulWidget {
  const ReportReaderScaffold({
    required this.caseUid,
    required this.bodyBuilder,
    this.trailing,
    super.key,
  });

  final String caseUid;
  final ReportBodyBuilder bodyBuilder;

  /// The top bar's trailing control; shown only once there is a report.
  final Widget? trailing;

  @override
  State<ReportReaderScaffold> createState() => _ReportReaderScaffoldState();
}

class _ReportReaderScaffoldState extends State<ReportReaderScaffold> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _uid = switch (session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: _uid, role: .doctor));
    }
    final reader = context.read<ReportReaderBloc>();
    if (reader.state.caseUid != widget.caseUid) _open();
  }

  void _open() => context.read<ReportReaderBloc>().add(
    ReportReaderOpened(uid: _uid, role: .doctor, caseUid: widget.caseUid),
  );

  /// The signed report for this case, or null. A state that belongs to
  /// another case, or holds anything but the current signed version, shows
  /// nothing.
  PathologyReportModel? _signedReport(ReportReaderState state) {
    final report = state.report;
    if (report == null || state.caseUid != widget.caseUid) return null;
    if (report.caseUid != widget.caseUid || !report.isCurrent) return null;
    return report;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ReportReaderBloc>().state;
    final caseModel = context.select<CasesBloc, CaseModel?>(
      (bloc) =>
          bloc.state.cases.firstWhereOrNull((c) => c.uid == widget.caseUid),
    );
    final report = _signedReport(state);
    final loading =
        report == null &&
        (state.caseUid != widget.caseUid ||
            state is ReportReaderInitial ||
            state is ReportReaderLoadInProgress);

    final orderNumber = caseModel?.orderNumber.isNotEmpty == true
        ? caseModel!.orderNumber
        : (report?.orderNumber ?? '');
    final patient = caseModel?.patientName ?? '';
    final subtitle = [
      patient,
      orderNumber,
    ].where((part) => part.isNotEmpty).join(' · ');

    final body = SafeArea(
      child: BlocListener<ReportReaderBloc, ReportReaderState>(
        listenWhen: (_, current) => current is ReportReaderLoadFailure,
        listener: (context, state) {
          if (state case ReportReaderLoadFailure(:final error)) {
            unawaited(
              showTabibuNotification(
                context,
                message: error.description(l10n),
                isError: true,
                dismissLabel: l10n.commonDismiss,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.xlg,
          ),
          children: [
            TopBar(
              backLabel: l10n.commonBack,
              onBack: context.pop,
              title: l10n.reportPdfTitle,
              subtitle: subtitle.isEmpty ? null : subtitle,
              trailing: report == null ? null : widget.trailing,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.offline) ...[
              ConnectivityBanner(
                state: .offline,
                title: l10n.notificationsOfflineTitle,
                body: l10n.notificationsOfflineBody,
                retryLabel: l10n.commonRetry,
                onRetry: _open,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (report != null)
              ..._spaced(widget.bodyBuilder(context, report, caseModel))
            else if (loading)
              LoadingView(semanticLabel: l10n.resultsLoadingLabel)
            else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxlg),
                child: EmptyState(
                  icon: Assets.icons.hourglassIcon,
                  tone: .lavender,
                  title: l10n.doctorCaseReportInProgress,
                  body: l10n.doctorReportInProgressBody,
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(body: RoleBackground.doctor(child: body));
  }

  List<Widget> _spaced(List<Widget> cards) => [
    for (var i = 0; i < cards.length; i++) ...[
      if (i > 0) const SizedBox(height: AppSpacing.sm),
      cards[i],
    ],
  ];
}
