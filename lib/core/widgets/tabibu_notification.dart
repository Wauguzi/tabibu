import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/tappable.dart';

/// An error or info notification, shown near the top of the screen. It
/// enters with a fade-and-scale transition, dismisses on tap or after a few
/// seconds, and reverses the same transition on exit.
Future<void> showTabibuNotification(
  BuildContext context, {
  required String message,
  required bool isError,
  required String dismissLabel,
  Duration duration = const Duration(seconds: 4),
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, _) => _NotificationBody(
      message: message,
      isError: isError,
      dismissLabel: dismissLabel,
      duration: duration,
    ),
    transitionBuilder: (context, animation, _, child) {
      return FadeScaleTransition(animation: animation, child: child);
    },
  );
}

class _NotificationBody extends StatefulWidget {
  const _NotificationBody({
    required this.message,
    required this.isError,
    required this.dismissLabel,
    required this.duration,
  });

  final String message;
  final bool isError;
  final String dismissLabel;
  final Duration duration;

  @override
  State<_NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<_NotificationBody> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == .dark;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Semantics(
            label: widget.message,
            hint: widget.dismissLabel,
            button: true,
            onTap: () => Navigator.of(context).maybePop(),
            excludeSemantics: true,
            child: Tappable(
              onTap: () => Navigator.of(context).maybePop(),
              child: Material(
                color: widget.isError
                    ? AppColors.errorLight
                    : isDark
                    ? AppColors.notificationInfoDark
                    : AppColors.notificationInfoLight,
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    widget.message,
                    style: textTheme.titleSmall?.copyWith(color: Colors.white),
                    textAlign: .center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
