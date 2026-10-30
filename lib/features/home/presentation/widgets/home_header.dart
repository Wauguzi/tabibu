import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The home tab's top row: the person's photo, a greeting with where and
/// when under it, and the notifications bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.name,
    required this.greeting,
    required this.subtitle,
    required this.notificationsLabel,
    this.photoUrl = '',
    super.key,
  });

  /// For the avatar's initials when there is no photo.
  final String name;
  final String greeting;
  final String subtitle;
  final String notificationsLabel;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Avatar(
          name: name,
          image: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
          radius: 28,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(greeting, style: textTheme.titleMedium),
              Text(
                subtitle,
                style: textTheme.bodyMedium,
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // The inbox is a later screen; the bell is in place for it.
        CircleIconButton(
          icon: Assets.icons.notificationBellIcon,
          onTap: null,
          semanticLabel: notificationsLabel,
        ),
      ],
    );
  }
}
