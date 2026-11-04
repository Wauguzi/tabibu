import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_avatar_stack.dart';
import 'package:tabibu/l10n/l10n.dart';

/// One consult on the MDT tab: the members, the case, the last message and
/// when. A closed consult reads "Case completed, consult closed".
class MdtConsultRow extends StatelessWidget {
  const MdtConsultRow({
    required this.consult,
    required this.myUid,
    required this.onTap,
    super.key,
  });

  final ConversationModel consult;
  final String myUid;
  final VoidCallback onTap;

  String _subtitle(AppLocalizations l10n) {
    if (consult.statusValue == .closed) return l10n.mdtClosedSubtitle;
    final last = consult.lastMessage;
    if (last.text.isEmpty) return '';
    final sender = last.senderUid == myUid
        ? l10n.mdtYou
        : mdtMemberShortName(consult.members[last.senderUid] ?? .empty());
    return sender.isEmpty ? last.text : l10n.mdtPreview(last.text, sender);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final closed = consult.statusValue == .closed;
    final when = closed
        ? mdtDateLabel(
            consult.closedAt.isEmpty ? consult.lastUpdatedAt : consult.closedAt,
            language,
          )
        : mdtRowTime(consult.lastMessageAt, language);
    final subtitle = _subtitle(l10n);
    return ListRowCard(
      leading: MdtAvatarStack(members: mdtAcceptedMembers(consult)),
      title: mdtConsultTitle(consult, l10n),
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailingText: when.isEmpty ? null : when,
      chevron: false,
      onTap: onTap,
    );
  }
}
