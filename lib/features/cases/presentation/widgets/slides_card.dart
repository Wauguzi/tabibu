import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/slide_image_model.dart';
import 'package:tabibu/features/preread/data/datasources/preread_storage.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The slides on a case: a thumbnail for each, and a tap opens it at full size
/// to pan and zoom. The picture only, with no AI overlay: what the doctor
/// attached is what the doctor and the pathologist both see. The Storage rules
/// let the case's own doctor and its accepted pathologist read them.
class SlidesCard extends StatefulWidget {
  const SlidesCard({required this.slides, this.urlFor, super.key});

  final List<SlideImageModel> slides;

  /// Resolves a Storage path to a URL; the app's own storage by default.
  final Future<String?> Function(String path)? urlFor;

  @override
  State<SlidesCard> createState() => _SlidesCardState();
}

class _SlidesCardState extends State<SlidesCard> {
  final _urls = <String, String?>{};

  Future<String?> Function(String) get _resolve =>
      widget.urlFor ?? getIt<PrereadStorage>().downloadUrl;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(SlidesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides != widget.slides) unawaited(_load());
  }

  Future<void> _load() async {
    for (final slide in widget.slides) {
      if (slide.path.isEmpty || _urls.containsKey(slide.path)) continue;
      final url = await _resolve(slide.path);
      if (!mounted) return;
      setState(() => _urls[slide.path] = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final slides = widget.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(l10n.orderSlidesTitle, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.workspaceRequestSlides(slides.length),
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final slide in slides)
                  _Thumb(
                    url: _urls[slide.path],
                    resolved: _urls.containsKey(slide.path),
                    scale: slide.micronsPerPixel,
                    onTap: _urls[slide.path] == null
                        ? null
                        : () => unawaited(
                            _open(context, _urls[slide.path]!, slide),
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url, SlideImageModel slide) =>
      showDialog<void>(
        context: context,
        builder: (_) => _FullSlide(url: url, scale: slide.micronsPerPixel),
      );
}

String _scaleLabel(double micronsPerPixel) {
  if (micronsPerPixel <= 0) return '';
  return '${micronsPerPixel.toStringAsFixed(micronsPerPixel >= 1 ? 0 : 3)} µm/px';
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.url,
    required this.resolved,
    required this.scale,
    required this.onTap,
  });

  final String? url;
  final bool resolved;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final url = this.url;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.field),
      child: SizedBox(
        width: 96,
        height: 96,
        child: url == null
            ? ColoredBox(
                color: scheme.surfaceContainerLow,
                child: Center(
                  child: resolved
                      ? AssetIcon(
                          Assets.icons.alertIcon,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        )
                      : const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                ),
              )
            : Image.network(
                url,
                fit: .cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: scheme.surfaceContainerLow,
                  child: Center(
                    child: AssetIcon(
                      Assets.icons.alertIcon,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
      ),
    );
    final caption = _scaleLabel(scale);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Tappable(onTap: onTap, child: image),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(caption, style: textTheme.labelSmall),
        ],
      ],
    );
  }
}

class _FullSlide extends StatelessWidget {
  const _FullSlide({required this.url, required this.scale});

  final String url;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final caption = _scaleLabel(scale);
    return Dialog.fullscreen(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Assets.icons.backIcon,
                    semanticLabel: l10n.commonBack,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      caption.isEmpty
                          ? l10n.orderSlidesTitle
                          : '${l10n.orderSlidesTitle} · $caption',
                      style: textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                maxScale: 8,
                child: Center(child: Image.network(url, fit: .contain)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
