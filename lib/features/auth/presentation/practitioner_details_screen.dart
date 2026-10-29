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
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/photo_row.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/single_select_sheet.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E1 and F1. Title, names, work email, phone, password and the required
/// photo. The account is created as in D2, skipped when one is already
/// signed in. Opened from E4's Edit links, the draft reopens filled in;
/// Continue pushes E2.
class PractitionerDetailsScreen extends StatefulWidget {
  const PractitionerDetailsScreen({super.key});

  @override
  State<PractitionerDetailsScreen> createState() =>
      _PractitionerDetailsScreenState();
}

class _PractitionerDetailsScreenState extends State<PractitionerDetailsScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  PractitionerTitle? _title;
  UploadFile? _picture;
  AppError? _localError;
  bool _photoReading = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _firstNameController = TextEditingController(text: draft.firstName);
    _lastNameController = TextEditingController(text: draft.lastName);
    final session = context.read<AuthBloc>().state.session;
    _emailController = TextEditingController(
      text: session is SignUpIncompleteSession ? session.email : draft.email,
    );
    _phoneController = TextEditingController(
      text: formatKePhone(draft.phoneNumber, withPrefix: true),
    );
    _passwordController = TextEditingController();
    _title = draft.title;
    _picture = draft.picture;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _avatarName {
    final name =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    return name;
  }

  // An unconfirmed address is confirmed before E2; the server refuses a
  // profile without it.
  void _forward() {
    final session = context.read<AuthBloc>().state.session;
    final confirmed =
        session is! SignUpIncompleteSession || session.emailVerified;
    unawaited(
      confirmed
          ? const PractitionerLicenceRoute().push<void>(context)
          : const VerifyEmailRoute().push<void>(context),
    );
  }

  Future<void> _pickTitle() async {
    final l10n = context.l10n;
    final picked = await showSingleSelectSheet<PractitionerTitle>(
      context: context,
      title: l10n.titleSheetTitle,
      searchHint: l10n.titleSheetTitle,
      items: PractitionerTitle.values,
      label: (title) => title.value,
      selected: _title,
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _title = picked;
      _localError = errorAfterChange(_localError, .title);
    });
  }

  SignUpDraft _fill(SignUpDraft draft) => draft.copyWith(
    title: _title,
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(),
    phoneNumber:
        normalizeKePhone(_phoneController.text) ?? _phoneController.text.trim(),
    picture: _picture,
  );

  void _submit() {
    final session = context.read<AuthBloc>().state.session;
    final accountExists = session is! SignedOutSession;
    final email = _emailController.text.trim();
    final phone = normalizeKePhone(_phoneController.text);
    final AppError? error;
    if (_title == null) {
      error = AppError.invalidTitle;
    } else if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      error = AppError.invalidName;
    } else if (!accountExists && !isValidEmail(email)) {
      error = AppError.invalidEmail;
    } else if (phone == null) {
      error = AppError.invalidPhone;
    } else if (_picture == null) {
      error = AppError.invalidPicture;
    } else {
      error = null;
    }
    setState(() => _localError = error);
    if (error != null) return;

    final draft = _fill(context.read<SignUpBloc>().state.draft);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));

    if (!accountExists) {
      context.read<AuthBloc>().add(
        CreateAccountRequested(
          email: email,
          password: _passwordController.text,
        ),
      );
    } else {
      _forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.watch<SignUpBloc>().state.draft.role;
    final isPathologist = role == Role.pathologist;

    return BlocConsumer<AuthBloc, AuthState>(
      // From the listener, not the builder: a stale failure must not
      // reappear when the screen is revisited.
      listener: (context, state) {
        if (state is CreateAccountSuccess) _forward();
        if (state is CreateAccountFailure) {
          setState(() => _localError = state.error);
        }
      },
      builder: (context, state) {
        final busy = state is CreateAccountInProgress;
        final failure = _localError;
        final signedIn = state.session is! SignedOutSession;
        final strongEnough = isPasswordStrong(_passwordController.text);
        final firstEmpty = _firstNameController.text.trim().isEmpty;
        final lastEmpty = _lastNameController.text.trim().isEmpty;

        return DraftPopScope(
          fill: _fill,
          canPop: !busy,
          child: StepScaffold(
            step: 1,
            total: 4,
            backLabel: l10n.commonBack,
            onBack: busy ? null : () => Navigator.of(context).pop(),
            title: l10n.practitionerDetailsTitle,
            subtitle: l10n.practitionerDetailsSubtitle,
            error: failure != null && fieldFor(failure) == null
                ? failure
                : null,
            role: role,
            footer: TabibuButton.primary(
              label: l10n.commonContinue,
              isLoading: busy,
              // An Edit return passes through: the password is never stored,
              // so the empty field must not block saving the edits.
              onTap: busy || _photoReading || (!signedIn && !strongEnough)
                  ? null
                  : _submit,
            ),
            child: AutofillGroup(
              child: Column(
                children: [
                  PhotoRow(
                    name: _avatarName,
                    title: l10n.photoTitle,
                    body: isPathologist
                        ? l10n.practitionerPhotoPathologistBody
                        : l10n.practitionerPhotoDoctorBody,
                    picture: _picture,
                    required: true,
                    errorText: failure == .invalidPicture
                        ? fieldErrorText(failure!, l10n)
                        : null,
                    onPicked: (file) => setState(() {
                      _picture = file;
                      _localError = errorAfterChange(_localError, .picture);
                    }),
                    onReading: (reading) =>
                        setState(() => _photoReading = reading),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  IgnorePointer(
                    ignoring: busy,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: .start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: PickerField(
                                label: l10n.titleLabel,
                                required: true,
                                hint: l10n.titleSheetTitle,
                                value: _title?.value,
                                errorText: failure == .invalidTitle
                                    ? fieldErrorText(failure!, l10n)
                                    : null,
                                onTap: _pickTitle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 3,
                              child: TabibuTextField(
                                label: l10n.firstNameLabel,
                                controller: _firstNameController,
                                leading: FieldIcon(Assets.icons.personIcon),
                                errorText: failure == .invalidName && firstEmpty
                                    ? fieldErrorText(failure!, l10n)
                                    : null,
                                required: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                                onChanged: (_) => setState(
                                  () => _localError = errorAfterChange(
                                    _localError,
                                    .name,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.lastNameLabel,
                          controller: _lastNameController,
                          leading: FieldIcon(Assets.icons.personIcon),
                          errorText:
                              failure == .invalidName &&
                                  !firstEmpty &&
                                  lastEmpty
                              ? fieldErrorText(failure!, l10n)
                              : null,
                          required: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          onChanged: (_) => setState(
                            () => _localError = errorAfterChange(
                              _localError,
                              .name,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.workEmailLabel,
                          hint: l10n.workEmailHint,
                          controller: _emailController,
                          leading: FieldIcon(Assets.icons.emailIcon),
                          errorText:
                              failure != null && fieldFor(failure) == .email
                              ? fieldErrorText(failure, l10n)
                              : null,
                          required: true,
                          // The account exists: Continue moves on, so an
                          // edit here would change nothing.
                          readOnly: signedIn,
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
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.phoneLabel,
                          hint: l10n.practitionerPhoneHint,
                          controller: _phoneController,
                          leading: FieldIcon(Assets.icons.phoneIcon),
                          errorText: failure == .invalidPhone
                              ? fieldErrorText(failure!, l10n)
                              : null,
                          required: true,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: const [
                            KePhoneFormatter(withPrefix: true),
                          ],
                          onChanged: (_) => setState(
                            () => _localError = errorAfterChange(
                              _localError,
                              .phone,
                            ),
                          ),
                        ),
                        if (!signedIn) ...[
                          const SizedBox(height: AppSpacing.md),
                          PasswordField(
                            label: l10n.passwordLabel,
                            showLabel: l10n.passwordShow,
                            hideLabel: l10n.passwordHide,
                            controller: _passwordController,
                            errorText: failure == .weakPassword
                                ? fieldErrorText(failure!, l10n)
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
                              if (strongEnough) _submit();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (signedIn)
                    NoticeCard(
                      variant: .info,
                      icon: Assets.icons.infoIcon,
                      body: l10n.accountCreatedNotice,
                    )
                  else
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
          ),
        );
      },
    );
  }
}
