import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart' hide LockState;
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_router.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/presentation/widgets/pin_pad.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Covers every route while the app is locked. Opaque so content behind it
/// never flashes (rule 2). Biometrics is offered when enabled; the PIN is
/// always available.
class UnlockOverlay extends StatefulWidget {
  const UnlockOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<UnlockOverlay> createState() => _UnlockOverlayState();
}

class _UnlockOverlayState extends State<UnlockOverlay> {
  var _usePin = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LockBloc, LockState>(
      listenWhen: (previous, current) =>
          current.signOutRequired && !previous.signOutRequired,
      listener: (context, state) {
        // Five wrong PINs: wipe the session (rule 4 / Muse 46).
        context.read<AuthBloc>().add(const SignOutRequested());
      },
      builder: (context, state) {
        final locked = state.locked || state is LockLoadInProgress;
        return Stack(
          fit: .expand,
          children: [
            widget.child,
            if (locked)
              Positioned.fill(
                child: Material(
                  // Solid cover: no transparency, no peek at the app.
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    child: _UnlockBody(
                      state: state,
                      usePin: _usePin || !state.biometricsEnabled,
                      onUsePin: () => setState(() => _usePin = true),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UnlockBody extends StatelessWidget {
  const _UnlockBody({
    required this.state,
    required this.usePin,
    required this.onUsePin,
  });

  final LockState state;
  final bool usePin;
  final VoidCallback onUsePin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tooMany = state.signOutRequired || state is LockSignOutRequired;
    final wrong = state is LockPinWrong ? state.attemptsRemaining : null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xlg),
          AssetIcon(Assets.icons.shieldIcon, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text(
            tooMany
                ? l10n.appLockTooMany
                : state is LockLoadFailure
                ? l10n.appLockLoadFailed
                : l10n.appLockToOpen,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: .center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tooMany
                ? l10n.appLockWait
                : state is LockLoadFailure
                ? l10n.appLockLoadFailedBody
                : l10n.appLockEnterPin,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: .center,
          ),
          const Spacer(),
          if (tooMany)
            TabibuButton.primary(
              label: l10n.appLockSignInAgain,
              onTap: () =>
                  context.read<AuthBloc>().add(const SignOutRequested()),
            )
          else if (state is LockLoadFailure) ...[
            TabibuButton.primary(
              label: l10n.commonRetry,
              onTap: () =>
                  context.read<LockBloc>().add(const LockStatusRequested()),
            ),
            const SizedBox(height: AppSpacing.sm),
            TabibuButton.secondary(
              label: l10n.appLockSignInAgain,
              onTap: () =>
                  context.read<AuthBloc>().add(const SignOutRequested()),
            ),
          ] else if (!usePin && state.biometricsEnabled) ...[
            TabibuButton.primary(
              label: l10n.appLockUnlockFinger,
              onTap: () => context.read<LockBloc>().add(
                LockBiometricUnlockRequested(reason: l10n.appLockToOpen),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TabibuButton.secondary(label: l10n.appLockUsePin, onTap: onUsePin),
          ] else
            PinEntry(
              enabled: state is! LockWriteInProgress && state is! LockOutActive,
              hasError: wrong != null || state is LockPinWrong,
              errorLabel: wrong == null ? null : l10n.appLockWrongPin(wrong),
              onComplete: (pin) => context.read<LockBloc>().add(
                LockPinVerifyRequested(pin: pin),
              ),
            ),
          if (!tooMany && state is! LockLoadFailure) ...[
            const SizedBox(height: AppSpacing.md),
            Tappable(
              onTap: () => unawaited(_forgot(context)),
              semanticLabel: l10n.appLockForgot,
              child: Text(
                l10n.appLockForgot,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _forgot(BuildContext context) async {
    final l10n = context.l10n;
    // The overlay sits in MaterialApp.builder, above the navigator. Prefer
    // the router's navigator context (same as notification taps in App).
    final navContext = TabibuRouter.navigatorKey.currentContext ?? context;
    final go = await TabibuBottomSheet.show<bool>(
      navContext,
      title: l10n.appLockForgotTitle,
      subtitle: l10n.appLockForgotBody,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          0,
          AppSpacing.screenMargin,
          AppSpacing.md,
        ),
        child: TabibuButton.primary(
          label: l10n.appLockSignInAgain,
          onTap: () => Navigator.of(sheet).pop(true),
        ),
      ),
    );
    if (go == true && context.mounted) {
      context.read<AuthBloc>().add(const SignOutRequested());
    }
  }
}
