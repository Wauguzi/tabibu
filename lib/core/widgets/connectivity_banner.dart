import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Connectivity states: offline and slow carry a retry action; waiting and
/// back-online are informational.
enum ConnectivityState { offline, slow, waitingToSend, backOnline }

/// A connectivity banner: icon, title and body on the state's container,
/// with a retry pill where retrying makes sense.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    required this.state,
    required this.title,
    required this.body,
    this.retryLabel,
    this.onRetry,
    super.key,
  });

  final ConnectivityState state;
  final String title;
  final String body;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground, icon) = switch (state) {
      ConnectivityState.offline => (
        status.neutralContainer,
        status.neutralText,
        Assets.icons.infoIcon,
      ),
      ConnectivityState.slow => (
        status.attentionContainer,
        status.attentionText,
        Assets.icons.inProgressIcon,
      ),
      ConnectivityState.waitingToSend => (
        status.infoContainer,
        status.infoText,
        Assets.icons.uploadIcon,
      ),
      ConnectivityState.backOnline => (
        status.signedContainer,
        status.signed,
        Assets.icons.checkSelectedIcon,
      ),
    };

    final retryLabel = this.retryLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.notice),
      ),
      child: Row(
        children: [
          AssetIcon(icon, size: 22, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(color: foreground),
                ),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          if (retryLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _RetryPill(
              label: retryLabel,
              onTap: onRetry,
              foreground: foreground,
            ),
          ],
        ],
      ),
    );
  }
}

class _RetryPill extends StatelessWidget {
  const _RetryPill({
    required this.label,
    required this.onTap,
    required this.foreground,
  });

  final String label;
  final VoidCallback? onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final onTap = this.onTap;
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: GestureDetector(
          onTap: onTap,
          behavior: .opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                child: Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
