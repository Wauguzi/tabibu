import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/page_dots.dart';

/// Home slides: a paging row with the next slide peeking, dots below.
/// Callers own the slides; this only pages and dots.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({required this.slides, this.height = 240, super.key});

  final List<Widget> slides;
  final double height;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  // A 0.9 page with no end padding leaves the next slide peeking ~40 dp.
  late final PageController _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    return Column(
      mainAxisSize: .min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView(
            controller: _controller,
            padEnds: false,
            onPageChanged: (page) => setState(() => _index = page),
            children: slides,
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: PageDots(count: slides.length, index: _index),
          ),
        ],
      ],
    );
  }
}
