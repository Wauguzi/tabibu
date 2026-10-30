import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A selectable option: icon tile, title and supporting text with a
/// selection mark. Selected fills mint; the mark can lead for icon-less
/// multi-select lists, or give way to a chevron on an action row.
class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone = .mint,
    this.supporting,
    this.markLeading = false,
    this.chevron = false,
    this.onSheet = false,
    super.key,
  });

  final String title;
  final String? supporting;
  final SvgGenImage? icon;
  final IconTone tone;
  final bool selected;
  final VoidCallback? onTap;

  /// Puts the selection mark first and drops the tile, for multi-select.
  final bool markLeading;

  /// An action row rather than a choice: a chevron replaces the mark,
  /// nothing is announced as selected, and it rests on a tinted container
  /// with no shadow, as E2b draws it.
  final bool chevron;

  /// On a sheet, which in dark is the card's own tone: the card is raised by
  /// a lighter one. In light it stays white with its shadow, so a selected
  /// mint card stands out as it does on a page.
  final bool onSheet;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final selectedFill = isDark ? AppColors.mintDark : AppColors.mintLight;
    final restingFill = chevron
        ? (isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow)
        : (onSheet && isDark
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLowest);

    final supporting = this.supporting;
    final onTap = this.onTap;
    // The mark's announcement merges into the card's own, so its label is
    // never read; the title stands in.
    final mark = ExcludeSemantics(
      child: StatusMark.selection(selected: selected, label: title),
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: chevron ? null : selected,
        enabled: onTap != null,
        inMutuallyExclusiveGroup: !markLeading && !chevron,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: Material(
            color: selected ? selectedFill : restingFill,
            borderRadius: BorderRadius.circular(AppRadii.card),
            elevation: chevron ? 0 : 2,
            shadowColor: AppShadows.cardColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    if (markLeading) ...[
                      mark,
                      const SizedBox(width: AppSpacing.sm),
                    ] else if (icon != null) ...[
                      IconTile(icon: icon!, tone: tone),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          if (supporting != null)
                            Text(supporting, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (!markLeading) ...[
                      const SizedBox(width: AppSpacing.sm),
                      if (chevron)
                        ExcludeSemantics(
                          child: AssetIcon(
                            Assets.icons.forwardIcon,
                            size: 22,
                            scaleUp: false,
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      else
                        mark,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
