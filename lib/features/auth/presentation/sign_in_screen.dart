import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_nav.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// B1, and B2 as its wrong-password state. A [SignInFailure] shows its
/// message in the error notice (and under the password field when the
/// password is the problem); a dismissed Google dialog shows nothing. Any
/// signed-in session leaves through [goToSession].
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AppError? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  void _submit() {
    if (!isValidEmail(_emailController.text)) {
      setState(() => _localError = AppError.invalidEmail);
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
      SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case SignInSuccess(:final session):
            goToSession(context, session);
          case SignInCancelled():
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        final busy = state is SignInInProgress;
        final failure = state is SignInFailure ? state.error : _localError;
        final passwordError =
            failure == AppError.wrongPassword ||
                failure == AppError.invalidCredential
            ? failure?.description(l10n)
            : null;
        final emailError = failure == AppError.userNotFound
            ? failure?.description(l10n)
            : null;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleIconButton(
                      icon: Assets.icons.backIcon,
                      semanticLabel: l10n.commonBack,
                      onTap: busy
                          ? null
                          : () => stepBack(context, const GetStartedRoute()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.signInTitle,
                              style: textTheme.displaySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.signInSubtitle,
                              style: textTheme.bodyLarge,
                            ),
                            if (failure != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              NoticeCard(
                                variant: NoticeVariant.error,
                                icon: Assets.icons.cancelIcon,
                                body: failure.description(l10n),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            IgnorePointer(
                              ignoring: busy,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabibuTextField(
                                    label: l10n.signInEmailLabel,
                                    hint: l10n.signInEmailHint,
                                    controller: _emailController,
                                    leading: FieldIcon(Assets.icons.emailIcon),
                                    errorText: emailError,
                                    required: true,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    onChanged: (_) => setState(() {
                                      _localError = null;
                                    }),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  PasswordField(
                                    label: l10n.signInPasswordLabel,
                                    showLabel: l10n.signInShowPassword,
                                    hideLabel: l10n.signInHidePassword,
                                    controller: _passwordController,
                                    errorText: passwordError,
                                    required: true,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onChanged: (_) => setState(() {
                                      _localError = null;
                                    }),
                                    onSubmitted: (_) => _submit(),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TabibuButton.ghost(
                                label: l10n.signInForgot,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onTap: busy
                                    ? null
                                    : () => const ResetPasswordRoute()
                                          .push<void>(context),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TabibuButton.primary(
                              label: l10n.signInButton,
                              isLoading: busy,
                              onTap: busy || !_canSubmit ? null : _submit,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _OrDivider(text: l10n.signInOr),
                            const SizedBox(height: AppSpacing.md),
                            TabibuButton.outline(
                              label: l10n.signInGoogle,
                              icon: Assets.icons.google.image(
                                width: 20,
                                height: 20,
                              ),
                              onTap: busy
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      const GoogleSignInRequested(),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.signInNewTo,
                                  style: textTheme.bodyMedium,
                                ),
                                TabibuButton.ghost(
                                  label: l10n.signUpAction,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  onTap: busy
                                      ? null
                                      : () =>
                                            const SignUpRoleRoute().go(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The line-or-line divider the shared library does not have.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
