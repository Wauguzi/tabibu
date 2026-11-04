import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The banner on a demo alert (H-10): it is synthetic and reaches nobody.
class AlertDemoBanner extends StatelessWidget {
  const AlertDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: status.alertNotice),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Text(
        context.l10n.alertReviewDemoBanner,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: status.alertNotice,
          fontWeight: .w600,
        ),
      ),
    );
  }
}
