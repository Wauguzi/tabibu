import 'package:material_ui/material_ui.dart';

/// The soft elevations, in one place, so no widget writes its own
/// translucent black. Cards share one shadow; pills and buttons sit a
/// little higher; glass floats highest with a stronger shade in dark.
abstract final class AppShadows {
  /// Card elevation: black 6 %, blur 12, y 4.
  static List<BoxShadow> card() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// The card black for `Material.shadowColor`.
  static final Color cardColor = Colors.black.withValues(alpha: 0.06);

  /// Raised pills and buttons: 8 % black `Material.shadowColor`.
  static final Color raisedColor = Colors.black.withValues(alpha: 0.08);

  /// Floating glass: 8 % in light, 35 % in dark, blur 24, y 8.
  static List<BoxShadow> glass({required bool isDark}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// The dimmed page behind a bottom sheet. Not an elevation, but the one
  /// other translucent black, kept here so widgets never write their own.
  static final Color barrierScrim = Colors.black.withValues(alpha: 0.32);
}
