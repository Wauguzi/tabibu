import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Every unsigned AI output sits in this frame (design system §4.1). The
/// label rides in the frame's own header, so it scrolls with the content and
/// can never be scrolled apart from it. Signed or approved text never uses it.
class AiDraftFrame extends StatefulWidget {
  const AiDraftFrame({
    required this.label,
    required this.child,
    this.detail,
    this.footer,
    super.key,
  });

  /// "AI draft — not signed".
  final String label;
  final Widget child;

  /// The model names, shown when the header is expanded.
  final String? detail;
  final Widget? footer;

  @override
  State<AiDraftFrame> createState() => _AiDraftFrameState();
}

class _AiDraftFrameState extends State<AiDraftFrame> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final detail = widget.detail;
    final footer = widget.footer;

    final label = Row(
      children: [
        AssetIcon(Assets.icons.sparkleIcon, size: 18, color: status.aiDraft),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            widget.label,
            style: textTheme.labelMedium?.copyWith(color: status.aiDraft),
          ),
        ),
        if (detail != null)
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: AssetIcon(
              Assets.icons.dropDownIcon,
              size: 18,
              color: status.aiDraft,
              scaleUp: false,
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      label: widget.label,
      child: DashedBorder(
        color: status.draftBorder,
        radius: AppRadii.card,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: status.draftSurface,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: [
              if (detail == null)
                ExcludeSemantics(child: label)
              else
                Tappable(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: ExcludeSemantics(child: label),
                ),
              if (detail != null && _expanded) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  detail,
                  style: textTheme.bodySmall?.copyWith(color: status.aiDraft),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              widget.child,
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.sm),
                footer,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
