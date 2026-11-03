import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_language.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-14. What the patient's doctor approved, and nothing else. It reads
/// `ReportReaderState.approved` only: it never touches the AI drafts, so an
/// unapproved explanation has no way onto this screen (F-8). With no
/// approved text it offers the released report alone.
class ExplainedResultScreen extends StatefulWidget {
  const ExplainedResultScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<ExplainedResultScreen> createState() => _ExplainedResultScreenState();
}

class _ExplainedResultScreenState extends State<ExplainedResultScreen> {
  String? _language;

  @override
  void initState() {
    super.initState();
    final reader = context.read<ReportReaderBloc>();
    final current = reader.state;
    if (current.caseUid == widget.caseUid && current.role == .patient) return;
    final session = context.read<AuthBloc>().state.session;
    final uid = switch (session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    reader.add(
      ReportReaderOpened(uid: uid, role: .patient, caseUid: widget.caseUid),
    );
  }

  /// The doctor's approved texts for this case, by language; empty for any
  /// other case or role.
  Map<String, ReportTextApprovedModel> _approved(ReportReaderState state) {
    if (state.caseUid != widget.caseUid || state.role != .patient) {
      return const {};
    }
    return state.approved;
  }

  void _openReport() => unawaited(
    PatientResultRoute(caseUid: widget.caseUid).push<void>(context),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<ReportReaderBloc>().state;
    final approved = _approved(state);
    final languages = approved.keys.toList()..sort();
    final preferred = _language ?? Localizations.localeOf(context).languageCode;
    final language = approved.containsKey(preferred)
        ? preferred
        : (languages.isEmpty ? null : languages.first);
    final selected = language == null ? null : approved[language];
    final loading =
        selected == null &&
        (state.caseUid != widget.caseUid ||
            state is ReportReaderInitial ||
            state is ReportReaderLoadInProgress);
    final doctor = selected?.approverName ?? '';
    final pathologist = state.report?.signedByName ?? '';

    final body = BlocListener<ReportReaderBloc, ReportReaderState>(
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
          TopBar(backLabel: l10n.commonBack, onBack: context.pop),
          const SizedBox(height: AppSpacing.md),
          if (selected != null) ...[
            if (state.offline) ...[
              ConnectivityBanner(
                state: .offline,
                title: l10n.explainedSavedTitle,
                body: l10n.explainedSavedBody,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (doctor.isNotEmpty) ...[
              Text(
                l10n.explainedHeadline(doctor),
                style: textTheme.headlineMedium?.copyWith(fontWeight: .w700),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            AttributionLine(text: l10n.explainedAiAttribution),
            if (languages.length > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final code in languages)
                    TabibuFilterChip(
                      label: explanationLanguageName(l10n, code),
                      selected: code == language,
                      onTap: () => setState(() => _language = code),
                    ),
                ],
              ),
            ],
            // No listen card until there is audio to play.
            const SizedBox(height: AppSpacing.md),
            ReportTextCard(
              entries: [
                for (final text in selected.approvedText.values) ('', text),
              ],
            ),
            if (doctor.isNotEmpty && pathologist.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AttributionLine(
                text: l10n.explainedSharedBy(doctor, pathologist),
              ),
            ],
          ] else if (loading)
            LoadingView(semanticLabel: l10n.resultsLoadingLabel),
          if (!loading) ...[
            const SizedBox(height: AppSpacing.md),
            TabibuButton.secondary(
              label: l10n.explainedViewFullReport,
              onTap: _openReport,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      body: RoleBackground.patient(child: SafeArea(child: body)),
    );
  }
}
