import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

/// The step transition for stepped flows: a horizontal shared-axis slide,
/// forward or back. Key [child] distinctly per step so the switcher can
/// tell them apart. With reduced motion the steps cross-fade in place.
class StepTransitionSwitcher extends StatelessWidget {
  const StepTransitionSwitcher({
    required this.child,
    this.reverse = false,
    super.key,
  });

  final Widget child;

  /// True when stepping back, so the incoming step slides in from the left.
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return PageTransitionSwitcher(
      reverse: reverse,
      transitionBuilder: (child, animation, secondaryAnimation) {
        if (reduceMotion) {
          return FadeTransition(opacity: animation, child: child);
        }
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: child,
    );
  }
}
