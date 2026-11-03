import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Why the alert was raised, as plain facts outside any AI frame: the
/// week's confirmed count for [test], and the area's usual level when the
/// detector has one. Nothing here is AI-written.
class AlertEvidenceCard extends StatelessWidget {
  const AlertEvidenceCard({
    required this.evidence,
    required this.area,
    required this.test,
    super.key,
  });

  final AlertEvidenceModel evidence;
  final String area;

  /// The confirming test's name, as the register spells it.
  final String test;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    // A detector without a baseline (a manual request) has no usual level.
    final baseline = evidence.baselineMean.round();
    final hasBaseline = evidence.windowWeeks > 0 && baseline > 0;
    final above =
        hasBaseline && evidence.confirmedCount > evidence.baselineMean;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  l10n.alertReviewWhyThisAlert,
                  style: textTheme.titleMedium,
                ),
              ),
              if (above) ...[
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: StatusChip(
                    label: l10n.alertReviewAboveBaseline,
                    tone: .attention,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.alertReviewSignalCases(evidence.confirmedCount, test),
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (hasBaseline)
            Text(
              l10n.alertReviewSignalBaseline(area, baseline),
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
