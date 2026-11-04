import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A playable summary card: ink circle control, title and supporting line.
class ListenCard extends StatelessWidget {
  const ListenCard({
    required this.title,
    required this.supporting,
    required this.playing,
    required this.onToggle,
    required this.playLabel,
    required this.pauseLabel,
    super.key,
  });

  final String title;
  final String supporting;
  final bool playing;
  final VoidCallback? onToggle;
  final String playLabel;
  final String pauseLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onInk = isDark ? AppColors.inkLight : AppColors.white;
    final onToggle = this.onToggle;
    final label = playing ? pauseLabel : playLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          children: [
            Semantics(
              label: label,
              button: true,
              enabled: onToggle != null,
              onTap: onToggle,
              excludeSemantics: true,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Material(
                  color: status.ink,
                  shape: const CircleBorder(),
                  child: Tappable(
                    onTap: onToggle,
                    child: Center(
                      // No pause glyph yet: playing keeps the in-progress mark.
                      child: AssetIcon(
                        playing
                            ? Assets.icons.inProgressIcon
                            : Assets.icons.playIcon,
                        size: 24,
                        color: onInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  Text(
                    supporting,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
