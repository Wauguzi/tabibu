import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The header of every pushed screen: back circle, centred title, trailing
/// action. A plain row, not an AppBar, so pushed screens share one look.
class TopBar extends StatelessWidget {
  const TopBar({
    required this.backLabel,
    required this.onBack,
    this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String backLabel;
  final VoidCallback? onBack;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = this.title;
    final subtitle = this.subtitle;
    return Row(
      children: [
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: onBack,
          semanticLabel: backLabel,
        ),
        // The gap keeps a long title or a patient and order number off the
        // circles on both sides; the text centres in what is left.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              mainAxisSize: .min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: textTheme.titleMedium,
                    textAlign: .center,
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: textTheme.bodySmall,
                    textAlign: .center,
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
              ],
            ),
          ),
        ),
        trailing ?? const SizedBox(width: 48, height: 48),
      ],
    );
  }
}

/// The trailing options button for a [TopBar].
class MoreButton extends StatelessWidget {
  const MoreButton({
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: Assets.icons.moreIcon,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }
}
