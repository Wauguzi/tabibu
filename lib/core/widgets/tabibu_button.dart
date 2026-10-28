import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';

/// The app's button in its four variants: the ink primary, the soft
/// secondary, the white outline and the text-only ghost. At most one primary
/// per screen. Grows with the text size instead of clipping.
class TabibuButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final background = switch (_variant) {
      _ButtonVariant.primary =>
        _enabled ? status.ink : scheme.surfaceContainerHigh,
      _ButtonVariant.secondary => scheme.surfaceContainerHigh,
      _ButtonVariant.outline => scheme.surfaceContainerLowest,
      _ButtonVariant.ghost => Colors.transparent,
    };
    final foreground =
        foregroundColor ??
        switch (_variant) {
          _ButtonVariant.primary =>
            _enabled
                ? (scheme.brightness == Brightness.dark
                      ? AppColors.inkLight
                      : Colors.white)
                : scheme.onSurfaceVariant,
          _ButtonVariant.secondary =>
            _enabled ? scheme.onSurface : scheme.onSurfaceVariant,
          _ButtonVariant.outline =>
            _enabled ? scheme.onSurface : scheme.onSurfaceVariant,
          _ButtonVariant.ghost => scheme.onSurface,
        };

    final onTap = _enabled ? this.onTap : null;
    return Semantics(
      label: label,
      button: true,
      enabled: _enabled,
      onTap: onTap,
      excludeSemantics: true,
      child: Opacity(
        opacity: _variant == _ButtonVariant.ghost && !_enabled ? 0.5 : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            elevation: _variant == _ButtonVariant.outline ? 2 : 0,
            shadowColor: AppShadows.raisedColor,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadii.pill),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              IconTheme(
                                data: IconThemeData(
                                  color: foreground,
                                  size: 22,
                                ),
                                child: icon!,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                style: textTheme.labelLarge?.copyWith(
                                  color: foreground,
                                ),
                                textAlign: TextAlign.center,
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
    );
  }
}

enum _ButtonVariant { primary, secondary, outline, ghost }
