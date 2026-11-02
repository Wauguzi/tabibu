import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/summary_card.dart';

/// A review card of label/value rows with an optional title and footer, on
/// [SummaryCard]'s row layout but with no edit link.
class KeyValueCard extends StatelessWidget {
  const KeyValueCard({required this.rows, this.title, this.footer, super.key});

  final List<(String, String)> rows;
  final String? title;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    final title = this.title;
    final footer = this.footer;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          if (title != null) ...[
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
          ],
          for (final (label, value) in rows)
            SummaryCardRow(
              label: label,
              value: value,
              valueStyle: textTheme.labelMedium,
            ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer,
          ],
        ],
      ),
    );
  }
}
