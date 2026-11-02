import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
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
    this.onNotifications,
    this.hasUnread = false,
    this.unreadLabel,
    super.key,
  });

  /// For the avatar's initials when there is no photo.
  final String name;
  final String greeting;
  final String subtitle;
  final String notificationsLabel;
  final String photoUrl;
  final VoidCallback? onNotifications;
  final bool hasUnread;

  /// The bell's localised reading while [hasUnread], e.g. "Notifications,
  /// unread".
  final String? unreadLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        // The bell's white circle: pale initials alone fade into the wash.
        Material(
          color: scheme.surfaceContainerLowest,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: AppShadows.raisedColor,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Avatar(
              name: name,
              image: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
              radius: 25,
            ),
          ),
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
        Stack(
          children: [
            CircleIconButton(
              icon: Assets.icons.notificationBellIcon,
              onTap: onNotifications,
              semanticLabel: hasUnread
                  ? unreadLabel ?? notificationsLabel
                  : notificationsLabel,
            ),
            if (hasUnread)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: scheme.error,
                    border: Border.all(
                      color: scheme.surfaceContainerLowest,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
