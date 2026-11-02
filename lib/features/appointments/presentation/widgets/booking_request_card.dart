import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A pending booking request: patient, when, type, Accept and Decline.
class BookingRequestCard extends StatelessWidget {
  const BookingRequestCard({
    required this.name,
    required this.when,
    required this.type,
    required this.acceptLabel,
    required this.declineLabel,
    required this.onAccept,
    required this.onDecline,
    this.supporting,
    this.languageChip,
    this.image,
    this.busy = false,
    super.key,
  });

  final String name;
  final String when;
  final String type;
  final String acceptLabel;
  final String declineLabel;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? supporting;
  final Widget? languageChip;
  final ImageProvider? image;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final languageChip = this.languageChip;
    final supporting = this.supporting;
    final accept = busy ? null : onAccept;
    final decline = busy ? null : onDecline;

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
              crossAxisAlignment: .start,
              children: [
                Avatar(name: name, image: image, radius: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(name, style: textTheme.titleMedium),
                      Text(
                        '$when · $type',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (supporting != null)
                        Text(
                          supporting,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      if (languageChip != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        languageChip,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TabibuButton.secondary(
                    label: declineLabel,
                    onTap: decline,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TabibuButton.primary(
                    label: acceptLabel,
                    onTap: accept,
                    isLoading: busy,
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
