import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';

/// The pinned bottom row: secondary left, primary right, over a fade that
/// softens content scrolling underneath.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.primary, this.secondary, super.key});

  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = this.secondary;
    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            colors: [scheme.surface.withValues(alpha: 0), scheme.surface],
          ),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenMargin,
                right: AppSpacing.screenMargin,
                bottom: AppSpacing.sm,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: .stretch,
                  children: [
                    if (secondary != null) ...[
                      Expanded(child: secondary),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(child: primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
