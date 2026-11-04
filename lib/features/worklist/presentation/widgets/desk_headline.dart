import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The desk's two-line headline: the fact in ink, then the AI's line. That
/// second line is AI-derived, so it wears the AI colour and the sparkle (H-18)
/// where the shared headline would paint it teal.
class DeskHeadline extends StatelessWidget {
  const DeskHeadline({required this.first, required this.second, super.key});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final style = Theme.of(context).textTheme.headlineLarge;
    return Semantics(
      header: true,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(first, style: style?.copyWith(color: scheme.onSurface)),
          Row(
            children: [
              ExcludeSemantics(
                child: AssetIcon(
                  Assets.icons.sparkleIcon,
                  size: 28,
                  color: status.aiDraft,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  second,
                  style: style?.copyWith(color: status.aiDraft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
