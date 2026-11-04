import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A white list row: leading visual, title lines with an optional chip, and
/// a right column of trailing text, unread dot and chevron.
class ListRowCard extends StatelessWidget {
  const ListRowCard({
    required this.title,
    this.leading,
    this.subtitle,
    this.chip,
    this.trailingText,
    this.unread = false,
    this.chevron = true,
    this.onTap,
    super.key,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final Widget? chip;
  final String? trailingText;
  final bool unread;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;

    final leading = this.leading;
    final subtitle = this.subtitle;
    final chip = this.chip;
    final trailingText = this.trailingText;
    final onTap = this.onTap;
    final card = Container(
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
            if (leading != null) ...[
              Align(alignment: .topCenter, child: leading),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall,
                      maxLines: 3,
                      overflow: .ellipsis,
                    ),
                  if (chip != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    chip,
                  ],
                ],
              ),
            ),
            if (trailingText != null || unread || chevron) ...[
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .end,
                children: [
                  Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .end,
                    children: [
                      if (trailingText != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            trailingText,
                            style: textTheme.labelSmall,
                            maxLines: 1,
                            overflow: .ellipsis,
                            textAlign: .right,
                          ),
                        ),
                      if (trailingText != null && unread)
                        const SizedBox(height: AppSpacing.xxs),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: .circle,
                            color: scheme.primary,
                          ),
                        ),
                    ],
                  ),
                  if (chevron)
                    ExcludeSemantics(
                      child: AssetIcon(
                        Assets.icons.forwardIcon,
                        size: 22,
                        scaleUp: false,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
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
        enabled: true,
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}
