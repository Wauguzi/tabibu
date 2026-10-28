import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';

/// Page dots for intro carousels: the current page stretches into a teal
/// pill while the rest stay quiet dots.
class PageDots extends StatelessWidget {
  const PageDots({required this.count, required this.index, super.key})
    : assert(index >= 0 && index < count, 'Index stays within the pages.');

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: i == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (i < count - 1) const SizedBox(width: AppSpacing.xxs),
        ],
      ],
    );
  }
}
