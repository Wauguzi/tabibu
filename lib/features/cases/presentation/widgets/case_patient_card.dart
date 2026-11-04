import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_status_chip.dart';

/// D-CASE's patient block (bundle 28's shared card has not landed): avatar,
/// name and age, the appointment or facility line, and the stage chip.
class CasePatientCard extends StatelessWidget {
  const CasePatientCard({
    required this.caseModel,
    required this.line,
    super.key,
  });

  final CaseModel caseModel;
  final String line;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final name = caseModel.patientAgeYears > 0
        ? '${caseModel.patientName}, ${caseModel.patientAgeYears}'
        : caseModel.patientName;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Row(
        children: [
          Avatar(name: caseModel.patientName, radius: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(name, style: textTheme.titleMedium),
                if (line.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    line,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                CaseStatusChip(caseModel: caseModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
