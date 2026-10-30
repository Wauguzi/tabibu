import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D3. The national digits; the +254 prefix is fixed, because the server
/// accepts Kenyan numbers only.
class PatientPhoneScreen extends StatefulWidget {
  const PatientPhoneScreen({super.key});

  @override
  State<PatientPhoneScreen> createState() => _PatientPhoneScreenState();
}

class _PatientPhoneScreenState extends State<PatientPhoneScreen> {
  late final TextEditingController _phoneController;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    final phone = context.read<SignUpBloc>().state.draft.phoneNumber;
    _phoneController = TextEditingController(text: formatKePhone(phone));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  SignUpDraft _fill(SignUpDraft draft) => draft.copyWith(
    phoneNumber:
        normalizeKePhone(_phoneController.text) ?? _phoneController.text.trim(),
  );

  void _continue() {
    final normalized = normalizeKePhone(_phoneController.text);
    if (normalized == null) {
      setState(() => _error = AppError.invalidPhone);
      return;
    }
    setState(() => _error = null);
    final draft = _fill(context.read<SignUpBloc>().state.draft);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));
    unawaited(const PatientAreaRoute().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;

    return DraftPopScope(
      fill: _fill,
      child: StepScaffold(
        step: 3,
        total: 4,
        backLabel: l10n.commonBack,
        onBack: () => Navigator.of(context).pop(),
        title: l10n.patientPhoneTitle,
        subtitle: l10n.patientPhoneSubtitle,
        error: error != null && fieldFor(error) == null ? error : null,
        role: Role.patient,
        footer: TabibuButton.primary(
          label: l10n.commonContinue,
          onTap: _continue,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                const _PhonePrefix(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TabibuTextField(
                    label: l10n.phoneLabel,
                    hint: l10n.phoneHint,
                    controller: _phoneController,
                    leading: FieldIcon(Assets.icons.phoneIcon),
                    errorText: _error == .invalidPhone
                        ? fieldErrorText(_error!, l10n)
                        : null,
                    required: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational,
                    ],
                    inputFormatters: const [KePhoneFormatter()],
                    onChanged: (_) => setState(
                      () => _error = errorAfterChange(_error, .phone),
                    ),
                    onSubmitted: (_) => _continue(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            NoticeCard(
              variant: NoticeVariant.info,
              icon: Assets.icons.shieldIcon,
              body: l10n.phonePrivacyNotice,
            ),
          ],
        ),
      ),
    );
  }
}

/// D3's +254 prefix: its own small, read-only box beside the number field.
/// Kenya only, so the chevron is decorative.
class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: .min,
        children: [
          // A blank line matching the number field's label, so the boxes
          // align.
          Text(' ', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Text('🇰🇪', style: textTheme.titleLarge),
                const SizedBox(width: AppSpacing.xs),
                Text('+254', style: textTheme.bodyLarge),
                const SizedBox(width: AppSpacing.xs),
                AssetIcon(
                  Assets.icons.dropDownIcon,
                  size: 22,
                  scaleUp: false,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
