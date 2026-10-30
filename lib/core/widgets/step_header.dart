import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A stepped-flow header: back button, segmented progress bars and the
/// `n/N` count. Bars up to and including the current step fill with ink.
class StepHeader extends StatelessWidget {
  const StepHeader({
    required this.step,
    required this.total,
    required this.progressLabel,
    required this.backLabel,
    required this.onBack,
    super.key,
  }) : assert(step >= 1 && step <= total, 'Step stays within the flow.');

  final int step;
  final int total;
  final String progressLabel;
  final String backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: onBack,
          semanticLabel: backLabel,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Semantics(
            label: progressLabel,
            excludeSemantics: true,
            child: Row(
              children: [
                for (var i = 1; i <= total; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= step
                            ? status.ink
                            : scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  if (i < total) const SizedBox(width: AppSpacing.xs),
                ],
                const SizedBox(width: AppSpacing.md),
                Text('$step/$total', style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
