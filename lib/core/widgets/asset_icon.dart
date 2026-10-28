import 'package:material_ui/material_ui.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// An asset icon at an exact box size, optionally tinted. The assets mix
/// intrinsic sizes, so every icon renders through here to keep glyph sizes
/// on spec.
class AssetIcon extends StatelessWidget {
  const AssetIcon(this.asset, {required this.size, this.color, super.key});

  final SvgGenImage asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color;
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: asset.svg(
          colorFilter: tint == null
              ? null
              : ColorFilter.mode(tint, BlendMode.srcIn),
        ),
      ),
    );
  }
}
