import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';

/// A white card of signed report text: an optional [title], then each entry
/// as a muted label (left out when empty) over its text, exactly as signed.
class ReportTextCard extends StatelessWidget {
  const ReportTextCard({required this.entries, this.title, super.key});

  final List<(String label, String text)> entries;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = this.title;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.brightness == .dark
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
            if (title != null) Text(title, style: textTheme.titleMedium),
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0 || title != null) const SizedBox(height: AppSpacing.sm),
              if (entries[i].$1.isNotEmpty) ...[
                Text(
                  entries[i].$1,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Text(entries[i].$2, style: textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}
