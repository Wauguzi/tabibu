import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A tap a keyboard reaches with Tab and fires with Enter or Space.
class Tappable extends StatelessWidget {
  const Tappable({required this.onTap, required this.child, super.key});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
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
      child: GestureDetector(onTap: onTap, behavior: .opaque, child: child),
    );
  }
}
