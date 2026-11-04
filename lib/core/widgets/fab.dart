import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tappable.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The ink action button pinned over a list: a circle with its glyph, 64 dp
/// unless [size] says otherwise.
class Fab extends StatelessWidget {
  const Fab({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.size = 64,
    super.key,
  });

  final SvgGenImage icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final onTap = this.onTap;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      onTap: onTap,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: .circle,
            color: status.ink,
            boxShadow: AppShadows.card(),
          ),
          child: Tappable(
            onTap: onTap,
            child: Center(
              child: AssetIcon(
                icon,
                size: size * 0.375,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
