import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Doctor notes on a case: title, body or placeholder, optional edit.
class NotesCard extends StatelessWidget {
  const NotesCard({
    required this.title,
    required this.text,
    required this.placeholder,
    required this.editLabel,
    this.onEdit,
    super.key,
  });

  final String title;
  final String text;
  final String placeholder;
  final String editLabel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onEdit = this.onEdit;
    final empty = text.trim().isEmpty;
    final body = empty ? placeholder : text;

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
            Row(
              children: [
                Expanded(child: Text(title, style: textTheme.titleMedium)),
                if (onEdit != null)
                  CircleIconButton(
                    icon: Assets.icons.editIcon,
                    onTap: onEdit,
                    semanticLabel: editLabel,
                    onCard: true,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: textTheme.bodyLarge?.copyWith(
                color: empty ? scheme.onSurfaceVariant : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
