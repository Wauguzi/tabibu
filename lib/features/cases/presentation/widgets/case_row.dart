import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_status_chip.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A doctor's case row: avatar, the order number with its test and the
/// status, then the six-step progress full width. Needs-you rows fill with
/// the primary container.
class CaseRow extends StatelessWidget {
  const CaseRow({
    required this.caseModel,
    required this.highlighted,
    required this.onTap,
    super.key,
  });

  final CaseModel caseModel;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final l10n = context.l10n;
    final onTap = this.onTap;
    final test = caseModel.tests.firstOrNull?.name ?? '';
    final title = test.isEmpty
        ? caseModel.orderNumber
        : '${caseModel.orderNumber} · $test';
    final step = caseModel.doctorStep.clamp(0, 5);
    final (chipLabel, _) = CaseStatusChip.partsOf(caseModel, l10n);

    final card = Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: highlighted
            ? scheme.primaryContainer
            : isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              Avatar(name: caseModel.patientName, radius: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CaseStatusChip(caseModel: caseModel),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ExcludeSemantics(
                child: AssetIcon(
                  Assets.icons.forwardIcon,
                  size: 22,
                  scaleUp: false,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ExcludeSemantics(
            child: CaseStepper(
              labels: const ['', '', '', '', '', ''],
              current: step,
              semanticLabel: l10n.stepProgress(step + 1, 6),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '$title, ${l10n.stepProgress(step + 1, 6)}, $chipLabel',
        onTap: onTap,
        child: Tappable(onTap: onTap, child: card),
      ),
    );
  }
}
