import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// One destination in a [FloatingTabBar].
class FloatingTab {
  const FloatingTab({required this.icon, required this.label});

  final SvgGenImage icon;
  final String label;
}

/// The role shells' floating menu: a white pill over the page. The selected
/// tab is an ink pill with its icon and label; the others show the icon
/// alone and keep their label for screen readers.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<FloatingTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == .dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        // Raised in dark by a lighter tone, not a light shadow.
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.glass(isDark: isDark),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            for (var i = 0; i < tabs.length; i++)
              // Only the selected tab carries a label, so only it may shrink
              // (large text on a narrow phone).
              Flexible(
                flex: i == currentIndex ? 1 : 0,
                child: _TabItem(
                  tab: tabs[i],
                  selected: i == currentIndex,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final FloatingTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final onInk = scheme.brightness == .dark
        ? AppColors.inkLight
        : Colors.white;
    final color = selected ? onInk : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      // Tab focus with Enter and Space on the same tap.
      child: FocusableActionDetector(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => onTap(),
          ),
        },
        child: GestureDetector(
          onTap: onTap,
          behavior: .opaque,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Container(
              height: 52,
              constraints: const BoxConstraints(minWidth: 56),
              padding: EdgeInsets.symmetric(
                horizontal: selected ? AppSpacing.md : 0,
              ),
              decoration: selected
                  ? BoxDecoration(
                      color: status.ink,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    )
                  : null,
              child: Row(
                mainAxisSize: .min,
                mainAxisAlignment: .center,
                children: [
                  AssetIcon(tab.icon, size: 22, color: color),
                  if (selected) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        tab.label,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: color),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
