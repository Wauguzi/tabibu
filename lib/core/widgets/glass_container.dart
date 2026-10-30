import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// Frosted glass for floating chrome such as the role nav: a blurred,
/// translucent shell with a hairline border and a soft shadow. Tint, border
/// and shadow are chosen per theme.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.radius = AppRadii.pill,
    super.key,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final isDark = Theme.of(context).brightness == .dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: status.glassTint,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: status.glassBorder),
            boxShadow: AppShadows.glass(isDark: isDark),
          ),
          child: child,
        ),
      ),
    );
  }
}
