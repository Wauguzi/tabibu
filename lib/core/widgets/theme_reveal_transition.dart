import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// A growing-circle clip anchored at [center], sized to cover the clipped
/// area once [fraction] reaches 1: it reveals the new theme diagonally from
/// one corner to the farthest one.
class _CircleRevealClipper extends CustomClipper<Path> {
  const _CircleRevealClipper({required this.fraction, required this.center});

  final double fraction;
  final Alignment center;

  @override
  Path getClip(Size size) {
    final centerOffset = center.alongSize(size);
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final maxRadius = corners
        .map((corner) => (corner - centerOffset).distance)
        .reduce((a, b) => a > b ? a : b);

    return Path()..addOval(
      Rect.fromCircle(center: centerOffset, radius: maxRadius * fraction),
    );
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.center != center;
}

/// Wraps [child] and plays a circular reveal whenever [brightness] changes,
/// replacing the default instant theme swap. With reduced motion the swap
/// stays instant: no snapshot, no animation.
///
/// Captures the previous look as a static snapshot via
/// [RenderRepaintBoundary.toImage] instead of keeping two live trees
/// mounted, so only one live tree ever exists and the old look is a picture.
class ThemeRevealTransition extends StatefulWidget {
  const ThemeRevealTransition({
    required this.brightness,
    required this.child,
    super.key,
  });

  final Brightness brightness;
  final Widget child;

  @override
  State<ThemeRevealTransition> createState() => _ThemeRevealTransitionState();
}

class _ThemeRevealTransitionState extends State<ThemeRevealTransition>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  ui.Image? _snapshot;
  // Switching to dark grows from the top-left; switching to light reverses
  // the same path from the bottom-right.
  Alignment _center = Alignment.topLeft;

  @override
  void initState() {
    super.initState();
    // Eagerly here rather than lazily at first use: build() only touches
    // the controller while a transition is in flight, so a lazy field
    // could first-initialize inside dispose(), where createTicker() is
    // unsafe because the element is deactivated.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThemeRevealTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness == widget.brightness) return;
    // Reduced motion swaps instantly: the child already carries the new
    // theme, so skipping the snapshot leaves the swap complete.
    if (MediaQuery.disableAnimationsOf(context)) return;

    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.attached) return;

    _center = widget.brightness == .dark
        ? Alignment.topLeft
        : Alignment.bottomRight;

    // The old frame is still what's composited here: this widget has the
    // new brightness, but nothing has repainted yet, so this captures the
    // previous theme's look.
    unawaited(
      boundary.toImage(pixelRatio: View.of(context).devicePixelRatio).then((
        image,
      ) {
        if (!mounted) {
          image.dispose();
          return;
        }
        final oldSnapshot = _snapshot;
        setState(() => _snapshot = image);
        oldSnapshot?.dispose();
        unawaited(
          _controller.forward(from: 0).whenComplete(() {
            if (!mounted) return;
            setState(() => _snapshot = null);
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveChild = RepaintBoundary(key: _boundaryKey, child: widget.child);
    final snapshot = _snapshot;

    if (snapshot == null) return liveChild;

    return Stack(
      children: [
        Positioned.fill(
          child: RawImage(image: snapshot, fit: .cover),
        ),
        AnimatedBuilder(
          animation: _reveal,
          builder: (context, _) => ClipPath(
            clipper: _CircleRevealClipper(
              fraction: _reveal.value,
              center: _center,
            ),
            child: liveChild,
          ),
        ),
      ],
    );
  }
}
