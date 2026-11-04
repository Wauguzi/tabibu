import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_avatar_stack.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// What the members sheet asks for. The screen confirms and acts once the
/// sheet has closed.
sealed class MdtMembersChoice {
  const MdtMembersChoice();
}

final class MdtChoseInvite extends MdtMembersChoice {
  const MdtChoseInvite();
}

final class MdtChoseLeave extends MdtMembersChoice {
  const MdtChoseLeave();
}

final class MdtChoseRemove extends MdtMembersChoice {
  const MdtChoseRemove(this.memberUid);

  final String memberUid;
}

/// The consult's members, with the actions this person may take: the owner
/// invites and removes, any other member leaves. A closed consult offers
/// none. Returns the choice, or null when dismissed.
Future<MdtMembersChoice?> showMdtMembersSheet(
  BuildContext context, {
  required ConversationModel consult,
  required String myUid,
}) {
  final l10n = context.l10n;
  final members = mdtAcceptedMembers(consult);
  final language = Localizations.localeOf(context).languageCode;
  return showSettledSheet<MdtMembersChoice>(
    context,
    title: mdtConsultTitle(consult, l10n),
    subtitle: l10n.mdtMemberCount(
      members.length,
      mdtDateLabel(consult.createdAt, language),
    ),
    builder: (sheet) => _MembersBody(
      consult: consult,
      members: members,
      myUid: myUid,
      onChoose: (choice) => Navigator.of(sheet).pop(choice),
    ),
  );
}

class _MembersBody extends StatelessWidget {
  const _MembersBody({
    required this.consult,
    required this.members,
    required this.myUid,
    required this.onChoose,
  });

  final ConversationModel consult;
  final List<ConversationMemberModel> members;
  final String myUid;
  final ValueChanged<MdtMembersChoice> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = consult.statusValue == .open;
    final iOwn = consult.createdByUid == myUid;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final member in members)
          _MemberRow(
            member: member,
            isMe: member.uid == myUid,
            // The owner cannot be removed, and only the owner removes.
            onRemove: open && iOwn && member.uid != consult.createdByUid
                ? () => onChoose(MdtChoseRemove(member.uid))
                : null,
          ),
        const SizedBox(height: AppSpacing.sm),
        if (open && iOwn)
          TabibuButton.secondary(
            label: l10n.mdtInviteColleague,
            icon: AssetIcon(Assets.icons.addIcon, size: 20),
            onTap: () => onChoose(const MdtChoseInvite()),
          )
        else if (open && members.any((m) => m.uid == myUid))
          TabibuButton.ghost(
            label: l10n.mdtLeaveAction,
            foregroundColor: Theme.of(context).colorScheme.error,
            onTap: () => onChoose(const MdtChoseLeave()),
          ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isMe,
    required this.onRemove,
  });

  final ConversationMemberModel member;
  final bool isMe;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final specialty = mdtSpecialtyLabel(member.specialty, l10n);
    final onRemove = this.onRemove;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Avatar(name: mdtMemberName(member), image: mdtMemberImage(member)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mdtMemberName(member),
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: AppSpacing.xs),
                      StatusChip(label: l10n.mdtYou, tone: .neutral),
                    ],
                  ],
                ),
                if (specialty.isNotEmpty)
                  Text(
                    specialty,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            TabibuButton.ghost(
              label: l10n.mdtRemoveAction,
              foregroundColor: Theme.of(context).colorScheme.error,
              onTap: onRemove,
            ),
        ],
      ),
    );
  }
}
