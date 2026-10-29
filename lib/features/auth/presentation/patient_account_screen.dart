import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/email_address.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D2. Creates the Auth account; the password never enters the draft.
/// Continue enables once the password meets the meter's three rules.
class PatientAccountScreen extends StatefulWidget {
  const PatientAccountScreen({super.key});

  @override
  State<PatientAccountScreen> createState() => _PatientAccountScreenState();
}

class _PatientAccountScreenState extends State<PatientAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AppError? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // An unconfirmed address is confirmed before D3; the server refuses a
  // profile without it.
  void _next(AuthSession session) {
    final confirmed =
        session is! SignUpIncompleteSession || session.emailVerified;
    unawaited(
      confirmed
          ? const PatientPhoneRoute().push<void>(context)
          : const VerifyEmailRoute().push<void>(context),
    );
  }

  void _submit(bool signedIn) {
    // Backed into from D3: the account already exists.
    if (signedIn) {
      _next(context.read<AuthBloc>().state.session);
      return;
    }
    if (!isValidEmail(_emailController.text)) {
      setState(() => _localError = .invalidEmail);
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
      CreateAccountRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      // From the listener, not the builder: a stale failure must not
      // reappear when the screen is revisited.
      listener: (context, state) {
        if (state is CreateAccountSuccess) _next(state.session);
        if (state is CreateAccountFailure) {
          setState(() => _localError = state.error);
        }
      },
      builder: (context, state) {
        final busy = state is CreateAccountInProgress;
        final failure = _localError;
        final signedIn = state.session is SignUpIncompleteSession;
        final strongEnough = isPasswordStrong(_passwordController.text);

        return StepScaffold(
          step: 2,
          total: 4,
          backLabel: l10n.commonBack,
          onBack: busy ? null : () => Navigator.of(context).pop(),
          title: l10n.patientAccountTitle,
          subtitle: l10n.patientAccountSubtitle,
          error: failure != null && fieldFor(failure) == null ? failure : null,
          role: Role.patient,
          footer: TabibuButton.primary(
            label: l10n.commonContinue,
            isLoading: busy,
            onTap: busy || (!signedIn && !strongEnough)
                ? null
                : () => _submit(signedIn),
          ),
          child: AutofillGroup(
            child: Column(
              children: [
                IgnorePointer(
                  ignoring: busy,
                  child: Column(
                    children: [
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus &&
                              _emailController.text.trim().isNotEmpty &&
                              !isValidEmail(_emailController.text)) {
                            setState(() => _localError = .invalidEmail);
                          }
                        },
                        child: TabibuTextField(
                          label: l10n.accountEmailLabel,
                          hint: l10n.accountEmailHint,
                          controller: _emailController,
                          leading: FieldIcon(Assets.icons.emailIcon),
                          errorText:
                              failure != null && fieldFor(failure) == .email
                              ? fieldErrorText(failure, l10n)
                              : null,
                          required: true,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (_) => setState(
                            () => _localError = errorAfterChange(
                              _localError,
                              .email,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PasswordField(
                        label: l10n.passwordLabel,
                        showLabel: l10n.passwordShow,
                        hideLabel: l10n.passwordHide,
                        controller: _passwordController,
                        errorText:
                            failure != null && fieldFor(failure) == .password
                            ? fieldErrorText(failure, l10n)
                            : null,
                        required: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (_) => setState(
                          () => _localError = errorAfterChange(
                            _localError,
                            .password,
                          ),
                        ),
                        onSubmitted: (_) {
                          if (signedIn || strongEnough) _submit(signedIn);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordStrengthMeter(
                  password: _passwordController.text,
                  strengthWord: passwordStrengthWord(
                    _passwordController.text,
                    l10n,
                  ),
                  lengthLabel: l10n.passwordRuleLength,
                  numberLabel: l10n.passwordRuleNumber,
                  symbolLabel: l10n.passwordRuleSymbol,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
