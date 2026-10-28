import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';

/// The eight status tones. Each resolves to a container, dot and text color.
enum StatusTone {
  info,
  signed,
  attention,
  lowConfidence,
  closed,
  neutral,
  aiDraft,
  brand,
}

/// A status chip: a dot and a label on the tone's container. Status meaning
/// always pairs color with text.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (background, dot, foreground) = switch (tone) {
      StatusTone.info => (
        status.infoContainer,
        status.infoDot,
        status.infoText,
      ),
      StatusTone.signed => (
        status.signedContainer,
        status.signedDot,
        status.signed,
      ),
      StatusTone.attention => (
        status.attentionContainer,
        status.attentionDot,
        status.attentionText,
      ),
      StatusTone.lowConfidence => (
        status.lowConfidenceContainer,
        status.lowConfidenceDot,
        status.lowConfidenceText,
      ),
      StatusTone.closed => (
        status.closedContainer,
        status.closedDot,
        status.closedText,
      ),
      StatusTone.neutral => (
        status.neutralContainer,
        status.neutralDot,
        status.neutralText,
      ),
      StatusTone.aiDraft => (
        status.aiDraftContainer,
        status.aiDraftDot,
        status.aiDraft,
      ),
      StatusTone.brand => (
        status.brandContainer,
        status.brandDot,
        status.brandText,
      ),
    };

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (tone != StatusTone.aiDraft) return chip;
    return DashedBorder(
      color: status.draftBorder,
      radius: AppRadii.pill,
      child: chip,
    );
  }
}
