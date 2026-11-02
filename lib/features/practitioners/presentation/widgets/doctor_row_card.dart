import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A directory row: avatar, name, supporting line, optional chip, chevron.
class DoctorRowCard extends StatelessWidget {
  const DoctorRowCard({
    required this.name,
    required this.supporting,
    this.image,
    this.chip,
    this.onTap,
    super.key,
  });

  final String name;
  final String supporting;
  final ImageProvider? image;
  final Widget? chip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final chip = this.chip;
    final onTap = this.onTap;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            Avatar(name: name, image: image, radius: 32),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  Text(
                    supporting,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                  if (chip != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    chip,
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              ExcludeSemantics(
                child: AssetIcon(
                  Assets.icons.forwardIcon,
                  size: 22,
                  scaleUp: false,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$name, $supporting',
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}
