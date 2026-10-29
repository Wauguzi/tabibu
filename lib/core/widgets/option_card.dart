import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A selectable option: icon tile, title and supporting text with a
/// selection mark. Selected fills mint; the mark can lead for icon-less
/// multi-select lists, or yield to a custom trailing such as a chevron.
class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone = .mint,
    this.supporting,
    this.markLeading = false,
    this.trailing,
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

  /// Overrides the trailing selection mark, e.g. with a chevron.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final selectedFill = isDark ? AppColors.mintDark : AppColors.mintLight;

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
        selected: selected,
        enabled: onTap != null,
        inMutuallyExclusiveGroup: !markLeading,
        onTap: onTap,
        // Tab focus with Enter and Space on the same tap.
        child: FocusableActionDetector(
          enabled: onTap != null,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => onTap?.call(),
            ),
          },
          child: Material(
            color: selected ? selectedFill : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            elevation: 2,
            shadowColor: AppShadows.cardColor,
            child: GestureDetector(
              onTap: onTap,
              behavior: .opaque,
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
                        trailing ?? mark,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
