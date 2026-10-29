import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoSheetRoute;
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

/// A bottom sheet on a native Cupertino sheet route: the theme's lowest
/// surface, top-rounded, with the route's drag handle, a title, subtitle and
/// content, as designed (no close control). Dragging down, tapping above it,
/// back and the screen reader's escape gesture dismiss it.
class TabibuBottomSheet extends StatelessWidget {
  const TabibuBottomSheet({
    required this.title,
    required this.child,
    required this.scrollController,
    this.subtitle,
    this.cancelLabel,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? cancelLabel;

  /// The route's controller: dragging scrolled-to-top content dismisses.
  final ScrollController scrollController;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget Function(BuildContext context) builder,
    String? subtitle,
    String? cancelLabel,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      CupertinoSheetRoute<T>(
        showDragHandle: true,
        scrollableBuilder: (context, sc) => TabibuBottomSheet(
          title: title,
          subtitle: subtitle,
          cancelLabel: cancelLabel,
          scrollController: sc,
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final cancelLabel = this.cancelLabel;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.card),
      ),
      child: Material(
        color: scheme.surfaceContainerLowest,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              // The native handle floats over this space; the old custom
              // handle block cleared the same 32.
              AppSpacing.xxlg,
              AppSpacing.screenMargin,
              AppSpacing.screenMargin + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.md),
                child,
                if (cancelLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TabibuButton.ghost(
                    label: cancelLabel,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
