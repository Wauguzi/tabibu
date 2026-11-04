import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/verdict_selector.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The five verdicts and overall score. Nothing is preselected (H-16).
class WorkspaceScoreCard extends StatelessWidget {
  const WorkspaceScoreCard({
    required this.findings,
    required this.impression,
    required this.urgency,
    required this.measurements,
    required this.tiles,
    required this.overall,
    required this.comment,
    required this.onFindings,
    required this.onImpression,
    required this.onUrgency,
    required this.onMeasurements,
    required this.onTiles,
    required this.onOverall,
    required this.onSave,
    this.enabled = true,
    this.saving = false,
    super.key,
  });

  final String? findings;
  final String? impression;
  final String? urgency;
  final String? measurements;
  final String? tiles;
  final int? overall;
  final TextEditingController comment;
  final ValueChanged<String> onFindings;
  final ValueChanged<String> onImpression;
  final ValueChanged<String> onUrgency;
  final ValueChanged<String> onMeasurements;
  final ValueChanged<String> onTiles;
  final ValueChanged<int> onOverall;
  final VoidCallback? onSave;
  final bool enabled;

  /// The score is on its way to the server: the button spins.
  final bool saving;

  bool get _complete =>
      findings != null &&
      impression != null &&
      urgency != null &&
      measurements != null &&
      tiles != null &&
      overall != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final agree = [
      ('Agree', l10n.scoreAgree),
      ('PartlyAgree', l10n.scorePartlyAgree),
      ('Disagree', l10n.scoreDisagree),
    ];
    final measure = [
      ('Accepted', l10n.scoreAccepted),
      ('Corrected', l10n.scoreCorrected),
      ('NotApplicable', l10n.scoreNotApplicable),
    ];
    final tile = [
      ('Good', l10n.scoreGood),
      ('Acceptable', l10n.scoreAcceptable),
      ('Poor', l10n.scorePoor),
      ('NotApplicable', l10n.scoreNotApplicable),
    ];

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(l10n.scoreTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        VerdictSelector<String>(
          label: l10n.reportQuestionFindings,
          options: agree,
          selected: findings,
          onSelected: onFindings,
        ),
        const SizedBox(height: AppSpacing.md),
        VerdictSelector<String>(
          label: l10n.reportSectionImpression,
          options: agree,
          selected: impression,
          onSelected: onImpression,
        ),
        const SizedBox(height: AppSpacing.md),
        VerdictSelector<String>(
          label: l10n.scoreUrgency,
          options: agree,
          selected: urgency,
          onSelected: onUrgency,
        ),
        const SizedBox(height: AppSpacing.md),
        VerdictSelector<String>(
          label: l10n.reportPdfMeasurements,
          options: measure,
          selected: measurements,
          onSelected: onMeasurements,
        ),
        const SizedBox(height: AppSpacing.md),
        VerdictSelector<String>(
          label: l10n.scoreTiles,
          options: tile,
          selected: tiles,
          onSelected: onTiles,
        ),
        const SizedBox(height: AppSpacing.md),
        OverallScore(
          value: overall,
          onChanged: onOverall,
          label: l10n.scoreOverall,
          semanticLabelFor: l10n.scoreOutOfFive,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuTextField(
          label: l10n.scoreComment,
          controller: comment,
          maxLines: 3,
          readOnly: !enabled,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.scoreSave,
          isLoading: saving,
          onTap: enabled && !saving && _complete ? onSave : null,
        ),
      ],
    );
  }
}
