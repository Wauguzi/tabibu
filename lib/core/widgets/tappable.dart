import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A tap a keyboard reaches with Tab and fires with Enter or Space.
///
/// [minSize] pads the hit target to at least 48 dp without shrinking the
/// child; [semanticLabel] is what a screen reader announces for the control.
class Tappable extends StatelessWidget {
  const Tappable({
    required this.onTap,
    required this.child,
    this.minSize = 48,
    this.semanticLabel,
    super.key,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// Minimum width and height of the hit target. Defaults to 48.
  final double minSize;

  /// Announced when set; otherwise the child's own semantics stand.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final label = semanticLabel;
    // A floor on the hit target, not a change of layout: the child keeps the
    // size it asks for (so a full-width row stays full width, and nothing here
    // needs intrinsic sizes, which LayoutBuilder and lists cannot give), and
    // only a child smaller than [minSize] is centred in a larger box.
    Widget body = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: label == null ? child : ExcludeSemantics(child: child),
      ),
    );
    if (label != null) {
      body = Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        child: body,
      );
    }
    return FocusableActionDetector(
      enabled: onTap != null,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => onTap?.call(),
        ),
      },
      child: GestureDetector(onTap: onTap, behavior: .opaque, child: body),
    );
  }
}
