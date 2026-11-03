import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/diff_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// CS-09. The AI draft against the signed report, for the signer only: the
/// impression/diagnosis and findings/comments pairs, each AI text on the AI
/// surface and each signed text on the edited surface (H-5).
class CompareScreen extends StatefulWidget {
  const CompareScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  @override
  void initState() {
    super.initState();
    final me = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final workspace = context.read<CaseWorkspaceBloc>();
    if (workspace.state.caseUid != widget.caseUid) {
      workspace.add(
        CaseWorkspaceOpened(caseUid: widget.caseUid, pathologistUid: me),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CaseWorkspaceBloc>().state;
    final me = switch (context.watch<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final signed = state.signed;
    final preread = state.preread;
    final gated =
        signed == null || preread == null || signed.pathologistUid != me;
    final orderNumber =
        state.caseModel?.orderNumber ?? signed?.orderNumber ?? '';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TopBar(
              backLabel: l10n.commonBack,
              onBack: context.pop,
              title: l10n.compareTitle,
              subtitle: gated ? null : l10n.compareSubtitle(orderNumber),
            ),
            if (gated) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              // One message for a missing pre-read and for a report signed
              // by someone else: the gate must not say which (H-4).
              EmptyState(title: l10n.compareNoDraft),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              NoticeCard(
                variant: .info,
                icon: Assets.icons.documentIcon,
                body: l10n.compareSummary(_signedDate(signed)),
              ),
              const SizedBox(height: AppSpacing.md),
              _pair(
                field: l10n.reportSectionDiagnosis,
                aiText: preread.draft.impression,
                yoursText: signed.diagnosis,
              ),
              const SizedBox(height: AppSpacing.md),
              _pair(
                field: l10n.reportQuestionFindings,
                aiText: preread.draft.findings
                    .map((f) => f.text)
                    .where((t) => t.isNotEmpty)
                    .join('\n'),
                yoursText: signed.comments,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _signedDate(PathologyReportModel signed) {
    final at = nairobiTimeOf(signed.signedAt);
    if (at == null) return '';
    final language = Localizations.localeOf(context).languageCode;
    return DateFormat('EEE d MMM', language).format(at);
  }

  /// One AI/signed pair; equal texts carry the "No change" marker.
  Widget _pair({
    required String field,
    required String aiText,
    required String yoursText,
  }) {
    final l10n = context.l10n;
    return DiffCard(
      field: field,
      aiLabel: l10n.workspaceAiDraft,
      aiText: aiText,
      yoursLabel: l10n.compareYourReport,
      yoursText: yoursText,
      note: aiText == yoursText ? l10n.compareNoChange : null,
    );
  }
}
