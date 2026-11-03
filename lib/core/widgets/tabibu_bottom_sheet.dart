import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoSheetRoute;
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

/// A bottom sheet on a native Cupertino sheet route: the theme's lowest
/// surface, top-rounded, with the route's drag handle, a title, subtitle and
/// content, as designed (no close control). Dragging down, tapping above it,
/// back and the screen reader's escape gesture dismiss it. A [leading] icon,
/// as on a confirmation, centres the header under it.
class TabibuBottomSheet extends StatelessWidget {
  const TabibuBottomSheet({
    required this.child,
    required this.scrollController,
    this.title,
    this.subtitle,
    this.cancelLabel,
    this.leading,
    super.key,
  });

  /// Null for sheets whose content opens with its own heading (the month
  /// date picker).
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final String? cancelLabel;

  /// The route's controller: dragging scrolled-to-top content dismisses.
  final ScrollController scrollController;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    String? title,
    String? subtitle,
    String? cancelLabel,
    Widget? leading,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      CupertinoSheetRoute<T>(
        showDragHandle: true,
        scrollableBuilder: (context, sc) => TabibuBottomSheet(
          title: title,
          subtitle: subtitle,
          cancelLabel: cancelLabel,
          leading: leading,
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
    final title = this.title;
    final subtitle = this.subtitle;
    final cancelLabel = this.cancelLabel;
    final leading = this.leading;
    final align = leading == null ? TextAlign.start : TextAlign.center;

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
              // The native handle floats over this space.
              AppSpacing.xxlg,
              AppSpacing.screenMargin,
              AppSpacing.screenMargin + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                if (leading != null) ...[
                  Center(child: leading),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (title != null)
                  Text(title, style: textTheme.titleLarge, textAlign: align),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: textTheme.bodyMedium, textAlign: align),
                ],
                if (title != null || subtitle != null)
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
