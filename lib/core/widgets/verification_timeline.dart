import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A verification tracker's state per step.
enum VerificationStepState { done, inProgress, upNext }

/// One step of the tracker: its icon, text, state and chip label.
class VerificationStep {
  const VerificationStep({
    required this.title,
    required this.supporting,
    required this.state,
    required this.chipLabel,
    required this.stateLabel,
    this.icon,
  });

  /// The mark icon for current and upcoming steps; done steps show a check.
  final SvgGenImage? icon;
  final String title;
  final String supporting;
  final VerificationStepState state;
  final String chipLabel;

  /// The state announced to screen readers ("Done", "In progress"...).
  final String stateLabel;
}

/// The verification tracker: status marks joined by a line, each with a
/// title, supporting text and a Done / In progress / Up next chip.
class VerificationTimeline extends StatelessWidget {
  const VerificationTimeline({
    required this.title,
    required this.progressLabel,
    required this.steps,
    super.key,
  });

  final String title;
  final String progressLabel;
  final List<VerificationStep> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              Text(progressLabel, style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              step: steps[i],
              isLast: i == steps.length - 1,
              lineColor:
                  steps[i].state == VerificationStepState.done &&
                      i < steps.length - 1
                  ? status.signedDot
                  : scheme.outlineVariant,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.lineColor,
  });

  final VerificationStep step;
  final bool isLast;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final icon = step.icon;
    if (step.state != VerificationStepState.done && icon == null) {
      throw StateError('A ${step.state.name} step needs an icon.');
    }
    final mark = switch (step.state) {
      VerificationStepState.done => StatusMark.done(
        label: step.stateLabel,
        diameter: 40,
      ),
      VerificationStepState.inProgress => StatusMark.current(
        icon: icon,
        label: step.stateLabel,
        diameter: 40,
      ),
      VerificationStepState.upNext => StatusMark.pending(
        icon: icon,
        label: step.stateLabel,
        diameter: 40,
      ),
    };
    final tone = switch (step.state) {
      VerificationStepState.done => StatusTone.signed,
      VerificationStepState.inProgress => StatusTone.attention,
      VerificationStepState.upNext => StatusTone.neutral,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              mark,
              if (!isLast)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(step.title, style: textTheme.titleSmall),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      StatusChip(label: step.chipLabel, tone: tone),
                    ],
                  ),
                  Text(step.supporting, style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
