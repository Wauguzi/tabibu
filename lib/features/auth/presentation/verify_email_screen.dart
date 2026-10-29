import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/email_address.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The address must be confirmed before any profile is written. "Verified"
/// asks the server; once it agrees, a sign-up in progress moves to its next
/// step, and anyone else (a cold start or a sign-in) to role selection.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const resendCooldown = 60;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _cooldown;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _cooldown?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    setState(() => _secondsLeft = VerifyEmailScreen.resendCooldown);
    _cooldown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _notify(String message, {required bool isError}) {
    unawaited(
      showTabibuNotification(
        context,
        message: message,
        isError: isError,
        dismissLabel: context.l10n.commonDismiss,
      ),
    );
  }

  void _onVerified(AuthSession session) {
    // Replaced, not pushed: back from the next step returns to the step
    // that created the account, never to this screen.
    switch (context.read<SignUpBloc>().state.draft.role) {
      case Role.patient:
        const PatientPhoneRoute().pushReplacement(context);
      case Role.doctor || Role.pathologist:
        const PractitionerLicenceRoute().pushReplacement(context);
      case null:
        goToSession(context, session);
    }
  }

  void _listen(BuildContext context, AuthState state) {
    final l10n = context.l10n;
    switch (state) {
      case EmailVerificationCheckSuccess(:final isVerified, :final session):
        if (isVerified) {
          _onVerified(session);
        } else {
          _notify(l10n.verifyEmailNotYet, isError: true);
        }
      case VerificationEmailResendSuccess():
        _startCooldown();
        _notify(l10n.verifyEmailResent, isError: false);
      case EmailVerificationCheckFailure(:final error) ||
          VerificationEmailResendFailure(:final error) ||
          SignOutFailure(:final error):
        _notify(error.description(l10n), isError: true);
      case SignOutSuccess():
        const SignInRoute().go(context);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: _listen,
      builder: (context, state) {
        final session = state.session;
        final email = session is SignUpIncompleteSession ? session.email : '';
        final checking = state is EmailVerificationCheckInProgress;
        final busy =
            checking ||
            state is VerificationEmailResendInProgress ||
            state is SignOutInProgress;
        final canResend = !busy && _secondsLeft == 0;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          const Spacer(),
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.tile,
                                ),
                                boxShadow: AppShadows.card(),
                              ),
                              child: Center(
                                child: AssetIcon(
                                  Assets.icons.emailIcon,
                                  size: 56,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.verifyEmailTitle,
                            style: textTheme.displaySmall,
                            textAlign: .center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.verifyEmailBody(maskEmail(email)),
                            style: textTheme.bodyLarge,
                            textAlign: .center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          NoticeCard(
                            variant: .info,
                            icon: Assets.icons.infoIcon,
                            body: l10n.verifyEmailHint,
                            action: _ResendLink(
                              label: _secondsLeft > 0
                                  ? l10n.verifyEmailResendIn(_secondsLeft)
                                  : l10n.verifyEmailResend,
                              onTap: canResend
                                  ? () => context.read<AuthBloc>().add(
                                      const VerificationEmailResendRequested(),
                                    )
                                  : null,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: AppSpacing.md),
                          TabibuButton.primary(
                            label: l10n.verifyEmailVerified,
                            isLoading: checking,
                            onTap: busy
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    const EmailVerificationCheckRequested(),
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TabibuButton.ghost(
                            label: l10n.verifyEmailBackToSignIn,
                            foregroundColor: scheme.primary,
                            onTap: busy
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    const SignOutRequested(),
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
      },
    );
  }
}

/// The resend link inside the notice: underlined while it can be tapped,
/// muted during the cooldown.
class _ResendLink extends StatelessWidget {
  const _ResendLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        // The 48 dp floor wraps the hit area; the drawn link keeps its
        // size, centered in the taller row.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            mainAxisSize: .min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Opacity(
                    opacity: enabled ? 1 : 0.6,
                    child: Text(
                      label,
                      style: style?.copyWith(
                        decoration: enabled ? .underline : null,
                        color: DefaultTextStyle.of(context).style.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
