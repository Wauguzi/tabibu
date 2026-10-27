import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';

/// Shared surface tokens: one shadow, one card geometry, one sheet radius.
abstract final class AppStyles {
  /// Standard elevated-card shadow. Subtle by design: clinical content sits
  /// on flat surfaces, so nothing decorative competes with the image.
  static List<BoxShadow> cardShadow({required bool isDark}) => <BoxShadow>[
    BoxShadow(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2.5),
    ),
  ];

  /// Corner radius for primary card containers.
  static const double cardRadius = 28;

  /// Inner padding for primary card containers.
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.md);

  /// Top corner radius for bottom sheets (the Material 3 default).
  static const double sheetRadius = 28;
}
