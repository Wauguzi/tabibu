import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A full-report file card: thumbnail, name, meta, Download and optional Share.
class ReportFileCard extends StatelessWidget {
  const ReportFileCard({
    required this.title,
    required this.fileName,
    required this.meta,
    required this.downloadLabel,
    required this.onDownload,
    this.shareLabel,
    this.onShare,
    super.key,
  });

  final String title;
  final String fileName;
  final String meta;
  final String downloadLabel;
  final VoidCallback? onDownload;
  final String? shareLabel;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final shareLabel = this.shareLabel;
    final onShare = this.onShare;
    final showShare = onShare != null && shareLabel != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconTile(icon: Assets.icons.documentIcon, tone: .lavender),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        fileName,
                        style: textTheme.titleSmall,
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                      Text(
                        meta,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TabibuButton.primary(
                    label: downloadLabel,
                    onTap: onDownload,
                    minHeight: 48,
                  ),
                ),
                if (showShare) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TabibuButton.secondary(
                      label: shareLabel,
                      onTap: onShare,
                      minHeight: 48,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
