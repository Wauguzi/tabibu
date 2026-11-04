import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';

/// A member's photo, or their initials when they have none.
ImageProvider? mdtMemberImage(ConversationMemberModel member) =>
    member.profilePictureUrl.isEmpty
    ? null
    : NetworkImage(member.profilePictureUrl);

/// Up to three overlapping member avatars, for a list row.
class MdtAvatarStack extends StatelessWidget {
  const MdtAvatarStack({required this.members, super.key});

  final List<ConversationMemberModel> members;

  static const double _radius = 20;
  static const double _step = 28;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(3).toList();
    final width = shown.isEmpty
        ? 0.0
        : _radius * 2 + _step * (shown.length - 1);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: _radius * 2,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: _step * i,
                child: Avatar(
                  name: mdtMemberName(shown[i]),
                  image: mdtMemberImage(shown[i]),
                  radius: _radius,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
