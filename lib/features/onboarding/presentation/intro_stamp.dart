import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A slide's title and body at the top, and its illustration centred in the
/// height left below. Scrolls only when the two do not fit.
class IntroSlideLayout extends StatelessWidget {
  const IntroSlideLayout({
    required this.header,
    required this.illustration,
    super.key,
  });

  final Widget header;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // spaceBetween with an empty last child centres the illustration
          // between the header and the bottom.
          child: Column(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .start,
            children: [
              header,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: ExcludeSemantics(child: illustration),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A mock card with a [stamp] laid over its bottom edge: starting a quarter
/// in from the left and tilted down to the right, as in A3 and A5.
class IntroStampedCard extends StatelessWidget {
  const IntroStampedCard({
    required this.card,
    required this.stamp,
    this.overlap = 14,
    super.key,
  });

  final Widget card;
  final Widget stamp;

  /// How far the stamp's top rises over the card's bottom edge.
  final double overlap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: .start,
        children: [
          card,
          Transform.translate(
            offset: Offset(0, -overlap),
            child: Padding(
              padding: EdgeInsets.only(left: constraints.maxWidth * 0.24),
              child: Transform.rotate(angle: 0.05, child: stamp),
            ),
          ),
        ],
      ),
    );
  }
}

/// The stamp itself: an outlined check, a title and a detail line.
class IntroStamp extends StatelessWidget {
  const IntroStamp({
    required this.title,
    required this.detail,
    required this.background,
    required this.foreground,
    required this.iconColor,
    super.key,
  });

  final String title;
  final String detail;
  final Color background;
  final Color foreground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          AssetIcon(Assets.icons.checkSelectedIcon, size: 26, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: foreground),
                ),
                Text(
                  detail,
                  style: textTheme.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
