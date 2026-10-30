import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A field that opens a picker (date, county, title, specialties) instead of
/// the keyboard. Drawn like [TabibuTextField]; announced as one button.
/// Either [value] (with [hint] while empty) or [child] fills the box.
class PickerField extends StatelessWidget {
  const PickerField({
    required this.label,
    required this.onTap,
    this.required = false,
    this.hint,
    this.value,
    this.child,
    this.leading,
    this.errorText,
    this.excludeSemantics = true,
    super.key,
  }) : assert(
         value != null || child != null || hint != null,
         'The box shows a value, a child, or a hint.',
       );

  final String label;
  final bool required;
  final String? hint;
  final String? value;
  final Widget? child;
  final SvgGenImage? leading;
  final String? errorText;
  final VoidCallback? onTap;

  /// False when [child] carries its own actions (F2's removable chips),
  /// which must stay visible to screen readers.
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasError = errorText != null;
    final value = this.value;
    final leading = this.leading;

    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: hasError ? Border.all(color: scheme.error) : null,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            AssetIcon(
              leading,
              size: 22,
              color: scheme.onSurfaceVariant,
              scaleUp: false,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child:
                child ??
                Text(
                  value ?? hint ?? '',
                  style: textTheme.bodyLarge?.copyWith(
                    color: value == null ? scheme.onSurfaceVariant : null,
                  ),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
          ),
          AssetIcon(
            Assets.icons.dropDownIcon,
            size: 22,
            color: scheme.onSurfaceVariant,
            scaleUp: false,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: textTheme.titleMedium,
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          button: true,
          enabled: onTap != null,
          label: value == null ? label : '$label, $value',
          excludeSemantics: excludeSemantics,
          child: Tappable(onTap: onTap, child: box),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
            maxLines: 3,
          ),
        ],
      ],
    );
  }
}
