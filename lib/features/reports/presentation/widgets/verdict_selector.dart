import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// One labelled row of mutually exclusive chips (Agree / Partly / …).
/// Nothing is preselected (H-16).
class VerdictSelector<T> extends StatelessWidget {
  const VerdictSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final List<(T value, String text)> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(label, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (value, text) in options)
              TabibuFilterChip(
                label: text,
                selected: selected == value,
                onTap: selected == value ? null : () => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Overall 1–5 score circles. Nothing is preselected (H-16).
class OverallScore extends StatelessWidget {
  const OverallScore({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.semanticLabelFor,
    super.key,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final String label;
  final String Function(int) semanticLabelFor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final value = this.value;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(label, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            for (var i = 1; i <= 5; i++)
              Semantics(
                button: true,
                label: semanticLabelFor(i),
                onTap: () => onChanged(i),
                child: Tappable(
                  onTap: () => onChanged(i),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: .circle,
                          color: value != null && i <= value
                              ? scheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: value != null && i <= value
                                ? scheme.primary
                                : scheme.outline,
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Text(
                              '$i',
                              style: textTheme.labelLarge?.copyWith(
                                color: value != null && i <= value
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                                fontWeight: .w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
