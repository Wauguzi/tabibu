import 'package:material_ui/material_ui.dart';
import 'package:tabibu/gen/fonts.gen.dart';

/// Card padding and the numeric text style. Shadows live in AppShadows,
/// radii in AppRadii.
abstract final class AppStyles {
  /// Big figures (counts, results): 40 bold with tabular figures so columns
  /// of numbers align.
  static const TextStyle numericLarge = TextStyle(
    fontFamily: FontFamily.manrope,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Inner padding for primary card containers. Deliberately off the
  /// spacing scale: the sheet sets card padding to 18.
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
}
