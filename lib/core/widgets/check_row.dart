import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A checkbox with its label as one tap target: terms, the protocol
/// confirmation, the signing attestation. Unticked unless the caller says
/// otherwise; [onChanged] null disables it.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.circle = false,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Draws the circled tick and the empty circle in place of the square box.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Tappable(
          onTap: onChanged == null ? null : () => onChanged(!value),
          child: Material(
            color: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  if (circle)
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: AssetIcon(
                            value
                                ? Assets.icons.checkSelectedIcon
                                : Assets.icons.checkUnselectedIcon,
                            size: 24,
                            color: onChanged == null
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onSurface,
                            scaleUp: false,
                          ),
                        ),
                      ),
                    )
                  else
                    ExcludeFocus(
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged == null
                            ? null
                            : (checked) => onChanged(checked ?? false),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(label, style: textTheme.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
