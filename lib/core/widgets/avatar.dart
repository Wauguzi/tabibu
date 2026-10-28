import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// A circular avatar: the photo when provided, otherwise initials on a sky
/// tile. Circles suit lists; tiles and profile heroes use rounded rectangles.
class Avatar extends StatelessWidget {
  const Avatar({required this.name, this.image, this.radius = 24, super.key})
    : _circle = true;

  /// The rounded-rectangle variant for tiles and profile heroes.
  const Avatar.tile({
    required this.name,
    this.image,
    this.radius = 24,
    super.key,
  }) : _circle = false;

  final String name;
  final ImageProvider? image;
  final double radius;
  final bool _circle;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final image = this.image;

    final fallback = image == null
        ? Text(
            _initials,
            style: textTheme.titleSmall?.copyWith(color: status.infoText),
          )
        : null;

    if (_circle) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: status.infoContainer,
        backgroundImage: image,
        child: fallback,
      );
    }
    final size = radius * 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: status.infoContainer,
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        alignment: Alignment.center,
        child: fallback,
      ),
    );
  }
}
