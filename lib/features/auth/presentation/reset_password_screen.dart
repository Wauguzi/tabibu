import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The reset request: an email to [PasswordResetRequested], then B5. Success
/// also covers addresses with no account, so the screen says nothing about
/// which addresses are registered.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  AppError? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!isValidEmail(_emailController.text)) {
      setState(() => _localError = AppError.invalidEmail);
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
      PasswordResetRequested(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          unawaited(const ResetPasswordSentRoute().push<void>(context));
        }
      },
      builder: (context, state) {
        final busy = state is PasswordResetInProgress;
        final failure = state is PasswordResetFailure
            ? state.error
            : _localError;

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
                      onTap: busy ? null : () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.resetTitle, style: textTheme.displaySmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.resetSubtitle, style: textTheme.bodyLarge),
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
                            child: TabibuTextField(
                              label: l10n.resetEmailLabel,
                              hint: l10n.resetEmailHint,
                              controller: _emailController,
                              leading: FieldIcon(Assets.icons.emailIcon),
                              required: true,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onChanged: (_) =>
                                  setState(() => _localError = null),
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TabibuButton.primary(
                    label: l10n.resetSend,
                    isLoading: busy,
                    onTap: busy || _emailController.text.trim().isEmpty
                        ? null
                        : _submit,
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
