import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_avatar_stack.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The inviter named on an invite: the member who invited [myUid], else the
/// owner.
ConversationMemberModel mdtInviterOf(ConversationModel consult, String myUid) {
  final invitedBy = consult.members[myUid]?.invitedByUid ?? '';
  return consult.members[invitedBy] ??
      consult.members[consult.createdByUid] ??
      const ConversationMemberModel();
}

/// An invite to a consult: who asked, what about, and Accept or Decline.
/// It shows only what an invitee may see: the inviter, the subject and the
/// specialty asked for. No case summary, no messages (rule 1).
class MdtInviteCard extends StatelessWidget {
  const MdtInviteCard({
    required this.consult,
    required this.inviter,
    required this.onAccept,
    required this.onDecline,
    this.busy = false,
    super.key,
  });

  final ConversationModel consult;
  final ConversationMemberModel inviter;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  /// A response is in flight; neither button takes a second tap.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final name = mdtMemberName(inviter);
    final about = mdtInviteAbout(consult, l10n);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.signedContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              MdtAvatarStack(members: [inviter]),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      l10n.mdtInvitedBy(name),
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                    Text(
                      l10n.mdtInviteCase(mdtRef(consult), about),
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TabibuButton.primary(
                  label: l10n.mdtAccept,
                  onTap: busy ? null : onAccept,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TabibuButton.outline(
                  label: l10n.mdtDecline,
                  onTap: busy ? null : onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
