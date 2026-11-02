import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A review section: title with an edit link and label/value rows.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.rows,
    this.editLabel,
    this.onEdit,
    super.key,
  });

  final String title;
  final List<(String, String)> rows;
  final String? editLabel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final isDark = scheme.brightness == .dark;
    final editLabel = this.editLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Raised in dark by a lighter tone, not a light shadow.
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              if (editLabel != null)
                Semantics(
                  button: true,
                  onTap: onEdit,
                  child: Tappable(
                    onTap: onEdit,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          AssetIcon(
                            Assets.icons.editIcon,
                            size: 18,
                            color: status.primaryText,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            editLabel,
                            style: textTheme.titleSmall?.copyWith(
                              color: status.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (label, value) in rows)
            SummaryCardRow(label: label, value: value),
        ],
      ),
    );
  }
}

/// One label/value row, shared with the key-value card.
class SummaryCardRow extends StatelessWidget {
  const SummaryCardRow({
    required this.label,
    required this.value,
    this.valueStyle,
    super.key,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: valueStyle ?? textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
