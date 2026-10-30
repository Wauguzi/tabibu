/// Spacing scale for padding, margins and gaps.
///
/// Base unit 4. New code uses these tokens instead of on-scale pixel values.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xlg = 24;
  static const double xxlg = 32;

  /// Screen side margins (§5).
  static const double screenMargin = 20;

  /// Gaps inside bento grids (§5).
  static const double bentoGap = 12;

  /// Gaps between screen sections (§5).
  static const double sectionGap = 20;
}
