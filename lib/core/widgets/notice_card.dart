import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Notice tones. `error` covers failure notices such as wrong passwords.
enum NoticeVariant { info, attention, neutral, aiDraft, signed, private, error }

/// A notice card: an icon with a title and body on the tone's container.
/// The title is optional; several notices lead with the body alone. Draft
/// and signed notices carry fixed icons (and the draft a dashed frame), so
/// the caller must not pass one for them. An [action], such as a link, sits
/// under the body.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    required this.body,
    required this.variant,
    this.icon,
    this.title,
    this.action,
    super.key,
  }) : assert(
         icon == null ||
             (variant != NoticeVariant.aiDraft &&
                 variant != NoticeVariant.signed),
         'Draft and signed notices carry their own icons.',
       );

  final SvgGenImage? icon;
  final String? title;
  final String body;
  final NoticeVariant variant;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground) = switch (variant) {
      NoticeVariant.info => (status.infoContainer, status.infoText),
      NoticeVariant.attention => (
        status.attentionContainer,
        status.attentionText,
      ),
      NoticeVariant.neutral => (status.neutralContainer, status.neutralText),
      NoticeVariant.aiDraft => (status.aiDraftContainer, status.aiDraft),
      NoticeVariant.signed => (status.signedContainer, status.signed),
      NoticeVariant.private => (
        status.lowConfidenceContainer,
        status.lowConfidenceText,
      ),
      NoticeVariant.error => (status.errorContainer, scheme.error),
    };

    final icon = this.icon;
    assert(
      icon != null ||
          variant == NoticeVariant.aiDraft ||
          variant == NoticeVariant.signed,
      'Every other notice names its icon.',
    );
    // Never throw in build: a missing icon in release falls back to info.
    final effectiveIcon = switch (variant) {
      NoticeVariant.aiDraft => Assets.icons.inProgressIcon,
      NoticeVariant.signed => Assets.icons.verificationBadge,
      _ => icon ?? Assets.icons.infoIcon,
    };

    final title = this.title;
    final action = this.action;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.notice),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetIcon(effectiveIcon, size: 22, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(color: foreground),
                  ),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(color: foreground),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (variant != NoticeVariant.aiDraft) return card;
    return DashedBorder(
      color: status.draftBorder,
      radius: AppRadii.notice,
      child: card,
    );
  }
}
