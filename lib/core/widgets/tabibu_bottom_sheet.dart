import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A bottom sheet: white, top-rounded, with a drag handle, title, close
/// control, subtitle and content over a blurred page. Dragging the handle
/// dismisses it; so does the close control, for people who cannot drag.
class TabibuBottomSheet extends StatelessWidget {
  const TabibuBottomSheet({
    required this.title,
    required this.closeLabel,
    required this.child,
    this.subtitle,
    this.cancelLabel,
    super.key,
  });

  final String title;
  final String closeLabel;
  final String? subtitle;
  final Widget child;
  final String? cancelLabel;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String closeLabel,
    required Widget Function(BuildContext context) builder,
    String? subtitle,
    String? cancelLabel,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppShadows.barrierScrim,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TabibuBottomSheet(
            title: title,
            closeLabel: closeLabel,
            subtitle: subtitle,
            cancelLabel: cancelLabel,
            child: builder(context),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final cancelLabel = this.cancelLabel;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.card),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.sm,
            AppSpacing.screenMargin,
            AppSpacing.screenMargin + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 200) {
                    Navigator.of(context).maybePop();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: Text(title, style: textTheme.titleLarge)),
                  CircleIconButton(
                    icon: Assets.icons.cancelIcon,
                    onTap: () => Navigator.of(context).maybePop(),
                    semanticLabel: closeLabel,
                    onCard: true,
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.md),
              Flexible(child: child),
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
    );
  }
}
