import 'package:material_ui/material_ui.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// An asset icon at an exact box size. The assets mix intrinsic sizes, so
/// every icon renders through here to keep glyph sizes on spec.
///
/// Single-colour glyphs tint to [color], defaulting to onSurface so no glyph
/// is left at its hardcoded fill's mercy in dark mode. Multicolour art sets
/// [preserveColors] and keeps its fills. [scaleUp] false keeps a glyph at
/// its drawn size, for chevrons whose tight viewBoxes would otherwise swell.
class AssetIcon extends StatelessWidget {
  const AssetIcon(
    this.asset, {
    required this.size,
    this.color,
    this.preserveColors = false,
    this.scaleUp = true,
    super.key,
  });

  final SvgGenImage asset;
  final double size;
  final Color? color;
  final bool preserveColors;
  final bool scaleUp;

  @override
  Widget build(BuildContext context) {
    final tint = preserveColors
        ? null
        : (color ?? Theme.of(context).colorScheme.onSurface);
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: scaleUp ? .contain : .scaleDown,
        child: asset.svg(
          colorFilter: tint == null ? null : ColorFilter.mode(tint, .srcIn),
        ),
      ),
    );
  }
}
