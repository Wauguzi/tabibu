import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// One time slot in a [SlotChipRow].
class SlotOption {
  const SlotOption({
    required this.label,
    required this.taken,
    this.semanticLabel,
  });

  final String label;
  final bool taken;

  /// The caller's localised reading, e.g. "10:30 AM, taken".
  final String? semanticLabel;
}

/// A horizontal row of time pills. Selected is ink; taken is struck through,
/// faded and disabled.
class SlotChipRow extends StatelessWidget {
  const SlotChipRow({
    required this.slots,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<SlotOption> slots;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: .horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final isSelected = index == selected;
          return _SlotChip(
            slot: slot,
            selected: isSelected,
            onTap: slot.taken ? null : () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final SlotOption slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final taken = slot.taken;
    final onTap = this.onTap;

    final foreground = taken
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? (isDark ? AppColors.inkLight : Colors.white)
        : scheme.onSurface;

    final chip = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Material(
        color: taken
            ? (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest)
            : selected
            ? status.ink
            : (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        elevation: selected || taken ? 0 : 2,
        shadowColor: AppShadows.cardColor,
        child: Opacity(
          opacity: taken ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Center(
              child: Text(
                slot.label,
                style: textTheme.titleMedium?.copyWith(
                  color: foreground,
                  decoration: taken ? .lineThrough : null,
                  decorationColor: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        enabled: onTap != null,
        label: slot.semanticLabel ?? slot.label,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(child: chip),
        ),
      ),
    );
  }
}
