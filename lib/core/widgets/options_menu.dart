import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/options_sheet.dart';
import 'package:tabibu/core/widgets/tappable.dart';

/// An options menu anchored under the anchor's bottom-right, over a dimmed
/// page. Closes on an outside tap or back, and returns the tapped value.
Future<T?> showOptionsMenu<T>(
  BuildContext context, {
  required GlobalKey anchor,
  required List<OptionsAction<T>> actions,
}) {
  final box = anchor.currentContext!.findRenderObject()! as RenderBox;
  final anchorCorner = box.localToGlobal(
    Offset(box.size.width, box.size.height),
  );
  final screenWidth = MediaQuery.sizeOf(context).width;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppShadows.barrierScrim,
    pageBuilder: (menuContext, _, _) => Stack(
      children: [
        Positioned(
          right: screenWidth - anchorCorner.dx,
          top: anchorCorner.dy + AppSpacing.xs,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth - 2 * AppSpacing.screenMargin,
            ),
            child: IntrinsicWidth(
              child: _OptionsMenuCard(
                actions: actions,
                onSelect: (value) => Navigator.of(menuContext).pop(value),
              ),
            ),
          ),
        ),
      ],
    ),
    transitionBuilder: (_, animation, _, child) =>
        FadeScaleTransition(animation: animation, child: child),
  );
}

class _OptionsMenuCard<T> extends StatelessWidget {
  const _OptionsMenuCard({required this.actions, required this.onSelect});

  final List<OptionsAction<T>> actions;
  final void Function(T value) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == .dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          for (final action in actions)
            _MenuRow(action: action, onTap: () => onSelect(action.value)),
        ],
      ),
    );
  }
}

class _MenuRow<T> extends StatelessWidget {
  const _MenuRow({required this.action, required this.onTap});

  final OptionsAction<T> action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final destructive = action.destructive;
    final supporting = action.supporting;
    final onTap = this.onTap;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                AssetIcon(
                  action.icon,
                  size: 18,
                  color: destructive ? scheme.error : scheme.onSurface,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        action.label,
                        style: textTheme.bodyLarge?.copyWith(
                          color: destructive ? scheme.error : scheme.onSurface,
                        ),
                      ),
                      if (supporting != null)
                        Text(supporting, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
