import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/tappable.dart';

/// A checkbox with its label as one tap target: terms, the protocol
/// confirmation, the signing attestation. Unticked unless the caller says
/// otherwise; [onChanged] null disables it.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

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
