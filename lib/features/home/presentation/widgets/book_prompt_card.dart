import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// The mint nudge to book: title, body and the ink action. Full width on an
/// empty home, slide 1 beside the results slide otherwise.
class BookPromptCard extends StatelessWidget {
  const BookPromptCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onBook,
    super.key,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == .dark;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.mintDark : AppColors.mintLight,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TabibuButton.primary(label: actionLabel, onTap: onBook),
        ],
      ),
    );
  }
}
