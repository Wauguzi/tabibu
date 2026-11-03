import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_avatar_stack.dart';

/// One text message: mine on ink to the right, a colleague's on white to the
/// left with their photo.
class MdtMessageBubble extends StatelessWidget {
  const MdtMessageBubble({
    required this.message,
    required this.mine,
    required this.sender,
    super.key,
  });

  final MessageModel message;
  final bool mine;
  final ConversationMemberModel sender;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final language = Localizations.localeOf(context).languageCode;
    final background = mine
        ? status.ink
        : (isDark
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLowest);
    final foreground = mine
        ? (isDark ? AppColors.inkLight : AppColors.white)
        : scheme.onSurface;
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            message.text,
            style: textTheme.bodyLarge?.copyWith(color: foreground),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            mdtClockLabel(message.sentAt, language),
            style: textTheme.labelSmall?.copyWith(
              color: foreground.withValues(alpha: 0.7),
            ),
            textAlign: .end,
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: mine ? .end : .start,
        crossAxisAlignment: .end,
        children: [
          if (!mine) ...[
            ExcludeSemantics(
              child: Avatar(
                name: mdtMemberName(sender),
                image: mdtMemberImage(sender),
                radius: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

/// A small centred line in the thread, such as "You joined".
class MdtThreadEvent extends StatelessWidget {
  const MdtThreadEvent({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(label, style: textTheme.bodySmall),
        ),
      ),
    );
  }
}
