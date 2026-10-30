import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/tappable.dart';

/// The app's button in its four variants: the ink primary, the soft
/// secondary, the white outline and the text-only ghost. At most one primary
/// per screen. Grows with the text size instead of clipping.
class TabibuButton extends StatefulWidget {
  const TabibuButton.primary({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.minHeight = 56,
    super.key,
  }) : _variant = _ButtonVariant.primary,
       foregroundColor = null;

  const TabibuButton.secondary({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.minHeight = 56,
    super.key,
  }) : _variant = _ButtonVariant.secondary,
       foregroundColor = null;

  const TabibuButton.outline({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.minHeight = 56,
    super.key,
  }) : _variant = _ButtonVariant.outline,
       foregroundColor = null;

  const TabibuButton.ghost({
    required this.label,
    required this.onTap,
    this.foregroundColor,
    this.icon,
    this.isLoading = false,
    this.minHeight = 48,
    super.key,
  }) : _variant = _ButtonVariant.ghost;

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool isLoading;
  final double minHeight;

  /// Ghost-only text color override, for teal links on light screens.
  final Color? foregroundColor;

  final _ButtonVariant _variant;

  bool get _enabled => onTap != null && !isLoading;

  @override
  State<TabibuButton> createState() => _TabibuButtonState();
}

class _TabibuButtonState extends State<TabibuButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  // Disabled mid-press (Continue turning to loading), the release never
  // arrives; the press ends with the button's enabled state.
  @override
  void didUpdateWidget(TabibuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget._enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final label = widget.label;
    final icon = widget.icon;
    final isLoading = widget.isLoading;
    final minHeight = widget.minHeight;
    final foregroundColor = widget.foregroundColor;
    final variant = widget._variant;
    final enabled = widget._enabled;

    final background = switch (variant) {
      .primary => enabled ? status.ink : scheme.surfaceContainerHigh,
      .secondary => scheme.surfaceContainerHigh,
      .outline => scheme.surfaceContainerLowest,
      .ghost => Colors.transparent,
    };
    final foreground =
        foregroundColor ??
        switch (variant) {
          .primary =>
            enabled
                ? (scheme.brightness == .dark
                      ? AppColors.inkLight
                      : Colors.white)
                : scheme.onSurfaceVariant,
          .secondary => enabled ? scheme.onSurface : scheme.onSurfaceVariant,
          .outline => enabled ? scheme.onSurface : scheme.onSurfaceVariant,
          .ghost => scheme.onSurface,
        };

    final onTap = enabled ? widget.onTap : null;
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      onTap: onTap,
      excludeSemantics: true,
      child: Opacity(
        opacity: variant == _ButtonVariant.ghost && !enabled ? 0.5 : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            elevation: variant == _ButtonVariant.outline ? 2 : 0,
            shadowColor: AppShadows.raisedColor,
            // Taps give no ripple anywhere.
            child: Tappable(
              onTap: onTap,
              // Pressed feedback observes the pointer here; Tappable owns
              // the tap. Translucent, so empty padding presses too.
              child: Listener(
                behavior: .translucent,
                onPointerDown: onTap == null ? null : (_) => _setPressed(true),
                onPointerUp: (_) => _setPressed(false),
                onPointerCancel: (_) => _setPressed(false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _pressed && enabled ? 0.6 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xlg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: SpinKitCircle(color: foreground, size: 24),
                            )
                          : Row(
                              mainAxisSize: .min,
                              children: [
                                if (icon != null) ...[
                                  IconTheme(
                                    data: IconThemeData(
                                      color: foreground,
                                      size: 22,
                                    ),
                                    child: icon,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                ],
                                Flexible(
                                  child: Text(
                                    label,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: foreground,
                                    ),
                                    textAlign: .center,
                                  ),
                                ),
                              ],
                            ),
                    ),
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

enum _ButtonVariant { primary, secondary, outline, ghost }
