import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// PA-06's signed row: ListRowCard chrome with two independent taps, so the
/// row opens the workspace while "Compare" opens the comparison. (A link
/// nested in a tappable card would fire both.)
class SignedReportRow extends StatelessWidget {
  const SignedReportRow({
    required this.report,
    required this.subtitle,
    required this.onTap,
    required this.onCompare,
    super.key,
  });

  final PathologyReportModel report;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final l10n = context.l10n;
    final test = report.testName;
    final title = test.isEmpty
        ? report.orderNumber
        : '${report.orderNumber} · $test';
    final notifiable = report.notifiableFindings.isNotEmpty;
    final onTap = this.onTap;
    final onCompare = this.onCompare;

    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '$title, $subtitle',
                onTap: onTap,
                child: Tappable(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .end,
              children: [
                StatusChip(
                  label: notifiable
                      ? l10n.signedTabNotifiable
                      : l10n.signedTabSent,
                  tone: notifiable ? .attention : .closed,
                ),
                Semantics(
                  button: true,
                  label: l10n.signedTabCompare,
                  onTap: onCompare,
                  child: Tappable(
                    onTap: onCompare,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Text(
                        l10n.signedTabCompare,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
