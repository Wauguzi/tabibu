import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Pan/zoom slide panel with an optional heatmap overlay, tiles entry and
/// viridis legend. Labels and images come from the caller.
class SlideViewer extends StatefulWidget {
  const SlideViewer({
    required this.image,
    required this.heatmapOn,
    required this.onHeatmapChanged,
    required this.heatmapLabel,
    required this.tilesLabel,
    required this.scaleLabel,
    required this.legendLow,
    required this.legendHigh,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    this.onTiles,
    this.heatmap,
    super.key,
  });

  final ImageProvider image;
  final bool heatmapOn;
  final ValueChanged<bool> onHeatmapChanged;
  final String heatmapLabel;
  final String tilesLabel;

  /// Null hides the Tiles control (CS-03 is not built yet).
  final VoidCallback? onTiles;
  final String scaleLabel;
  final String legendLow;
  final String legendHigh;
  final String zoomInLabel;
  final String zoomOutLabel;
  final ImageProvider? heatmap;

  static const double minScale = 1;
  static const double maxScale = 8;
  static const double zoomStep = 0.5;

  @override
  State<SlideViewer> createState() => _SlideViewerState();
}

class _SlideViewerState extends State<SlideViewer> {
  late final TransformationController _transform;

  @override
  void initState() {
    super.initState();
    _transform = TransformationController();
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  double get _scale => _transform.value.getMaxScaleOnAxis();

  void _nudgeScale(double delta) {
    final next = (_scale + delta).clamp(
      SlideViewer.minScale,
      SlideViewer.maxScale,
    );
    if (next == _scale) return;
    final ratio = next / _scale;
    _transform.value = Matrix4.copy(_transform.value)
      ..multiply(Matrix4.diagonal3Values(ratio, ratio, 1));
    setState(() {});
  }

  Widget _fallback(ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Center(
        child: AssetIcon(
          Assets.icons.photoIcon,
          size: 32,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final onInk = isDark ? AppColors.inkLight : AppColors.white;
    final heatmap = widget.heatmap;
    final imageRadius = BorderRadius.circular(AppRadii.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Prefer 4:3; shrink under a tight parent so the legend still fits.
            var imageHeight = width * 3 / 4;
            if (constraints.hasBoundedHeight) {
              const legendBlock = AppSpacing.sm + 20;
              final budget = constraints.maxHeight - legendBlock;
              if (budget > 0 && budget < imageHeight) {
                imageHeight = budget;
              }
            }

            return Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                SizedBox(
                  width: width,
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: imageRadius,
                    child: Stack(
                      fit: .expand,
                      children: [
                        InteractiveViewer(
                          transformationController: _transform,
                          minScale: SlideViewer.minScale,
                          maxScale: SlideViewer.maxScale,
                          child: Stack(
                            fit: .expand,
                            children: [
                              Positioned.fill(
                                child: Image(
                                  image: widget.image,
                                  fit: .cover,
                                  errorBuilder: (_, _, _) => _fallback(scheme),
                                ),
                              ),
                              if (widget.heatmapOn && heatmap != null)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.55,
                                    child: Image(
                                      image: heatmap,
                                      fit: .cover,
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.xs,
                          left: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: Row(
                            crossAxisAlignment: .start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    _HeatmapPill(
                                      label: widget.heatmapLabel,
                                      value: widget.heatmapOn,
                                      onChanged: widget.onHeatmapChanged,
                                    ),
                                    if (widget.onTiles != null)
                                      _TilesPill(
                                        label: widget.tilesLabel,
                                        onTap: widget.onTiles!,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _ZoomPill(
                                zoomInLabel: widget.zoomInLabel,
                                zoomOutLabel: widget.zoomOutLabel,
                                onZoomIn: () =>
                                    _nudgeScale(SlideViewer.zoomStep),
                                onZoomOut: () =>
                                    _nudgeScale(-SlideViewer.zoomStep),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.xs,
                          bottom: AppSpacing.xs,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: status.ink,
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              child: Text(
                                widget.scaleLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: onInk,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      widget.legendLow,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          gradient: const LinearGradient(
                            colors: AppColors.overlayHeatmap,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.legendHigh,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeatmapPill extends StatelessWidget {
  const _HeatmapPill({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MergeSemantics(
      child: Semantics(
        label: label,
        toggled: value,
        onTap: () => onChanged(!value),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.card(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: .w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                ExcludeSemantics(
                  child: Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: .shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TilesPill extends StatelessWidget {
  const _TilesPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: Tappable(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.card(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: .w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomPill extends StatelessWidget {
  const _ZoomPill({
    required this.zoomInLabel,
    required this.zoomOutLabel,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final String zoomInLabel;
  final String zoomOutLabel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Column(
          mainAxisSize: .min,
          children: [
            CircleIconButton(
              icon: Assets.icons.zoomInIcon,
              onTap: onZoomIn,
              semanticLabel: zoomInLabel,
              onCard: true,
              iconSize: 20,
            ),
            // A hairline set in from the sides so it never meets the edges.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Divider(
                height: 1,
                thickness: 1,
                color: scheme.outlineVariant,
              ),
            ),
            CircleIconButton(
              icon: Assets.icons.zoomOutIcon,
              onTap: onZoomOut,
              semanticLabel: zoomOutLabel,
              onCard: true,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
