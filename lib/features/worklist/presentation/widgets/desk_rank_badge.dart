import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// A small ink circle with a case's place on the desk. The rank is its
/// position among all open cases, so a filtered list keeps the numbers.
/// Decorative: the list's order already carries it.
class DeskRankBadge extends StatelessWidget {
  const DeskRankBadge({required this.rank, super.key});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final onInk = scheme.brightness == .dark
        ? AppColors.inkLight
        : AppColors.white;
    return ExcludeSemantics(
      child: Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: status.ink, shape: .circle),
        alignment: .center,
        child: FittedBox(
          fit: .scaleDown,
          child: Text(
            '$rank',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: onInk, fontWeight: .w700),
          ),
        ),
      ),
    );
  }
}
