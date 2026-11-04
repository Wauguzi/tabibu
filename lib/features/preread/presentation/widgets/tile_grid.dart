import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Tone of a pre-read tile cell: tumour / normal / other.
enum TileTone { tumour, normal, other }

/// One square in a [TileGrid].
class TileCell {
  const TileCell({
    required this.id,
    required this.tone,
    this.flagged = false,
    this.unclear = false,
  });

  final String id;
  final TileTone tone;
  final bool flagged;
  final bool unclear;
}

/// Square tile cells for the pathologist's tiles view. Labels come from
/// the caller; the grid never names AI itself.
class TileGrid extends StatelessWidget {
  const TileGrid({
    required this.columns,
    required this.tiles,
    required this.onTap,
    required this.cellLabel,
    super.key,
  }) : assert(columns > 0, 'columns must be positive');

  final int columns;
  final List<TileCell> tiles;
  final ValueChanged<int> onTap;
  final String Function(int index) cellLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.xs;
        final cellWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < tiles.length; i++)
              SizedBox(
                width: cellWidth,
                height: cellWidth,
                child: _TileFace(
                  cell: tiles[i],
                  label: cellLabel(i),
                  onTap: () => onTap(i),
                  fill: switch (tiles[i].tone) {
                    TileTone.tumour => status.aiDraftContainer,
                    TileTone.normal => scheme.surfaceContainerLow,
                    TileTone.other => scheme.outlineVariant,
                  },
                  textStyle: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  attentionDot: status.attentionDot,
                  draftDot: status.aiDraftDot,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TileFace extends StatelessWidget {
  const _TileFace({
    required this.cell,
    required this.label,
    required this.onTap,
    required this.fill,
    required this.textStyle,
    required this.attentionDot,
    required this.draftDot,
  });

  final TileCell cell;
  final String label;
  final VoidCallback onTap;
  final Color fill;
  final TextStyle? textStyle;
  final Color attentionDot;
  final Color draftDot;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.field);
    final face = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: cell.flagged ? Border.all(color: attentionDot, width: 2) : null,
      ),
      child: Stack(
        alignment: .center,
        children: [
          Text(cell.id, style: textStyle),
          if (cell.unclear)
            Positioned(
              top: AppSpacing.xxs,
              right: AppSpacing.xxs,
              child: AssetIcon(
                Assets.icons.infoIcon,
                size: 14,
                color: draftDot,
                scaleUp: false,
              ),
            ),
        ],
      ),
    );

    final child = cell.unclear
        ? DashedBorder(
            color: attentionDot,
            radius: AppRadii.field,
            strokeWidth: 2,
            child: face,
          )
        : face;

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: Tappable(onTap: onTap, child: child),
    );
  }
}
