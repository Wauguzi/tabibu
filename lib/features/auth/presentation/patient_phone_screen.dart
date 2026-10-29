import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
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
    _phoneController = TextEditingController(
      text: phone.startsWith('+254') ? phone.substring(4) : phone,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final normalized = normalizeKePhone(_phoneController.text);
    if (normalized == null) {
      setState(() => _error = AppError.invalidPhone);
      return;
    }
    setState(() => _error = null);
    final draft = context.read<SignUpBloc>().state.draft.copyWith(
      phoneNumber: normalized,
    );
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));
    unawaited(const PatientAreaRoute().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return StepScaffold(
      step: 3,
      total: 4,
      backLabel: l10n.commonBack,
      onBack: () => Navigator.of(context).pop(),
      title: l10n.patientPhoneTitle,
      subtitle: l10n.patientPhoneSubtitle,
      error: _error,
      role: Role.patient,
      footer: TabibuButton.primary(
        label: l10n.commonContinue,
        onTap: _continue,
      ),
      child: Column(
        children: [
          TabibuTextField(
            label: l10n.phoneLabel,
            hint: l10n.phoneHint,
            controller: _phoneController,
            leading: ExcludeSemantics(
              child: Text('+254', style: textTheme.bodyLarge),
            ),
            errorText: _error?.description(l10n),
            required: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _continue(),
          ),
          const SizedBox(height: AppSpacing.md),
          NoticeCard(
            variant: NoticeVariant.info,
            icon: Assets.icons.shieldIcon,
            body: l10n.phonePrivacyNotice,
          ),
        ],
      ),
    );
  }
}
