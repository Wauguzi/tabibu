import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// C1. A changed role starts a fresh draft; the same role keeps the one in
/// progress. Continue pushes D1 for a patient, E1/F1 for a doctor or
/// pathologist.
class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  Role _role = Role.patient;

  void _continue() {
    // Backed into from a step with the role unchanged: pushing on without a
    // fresh draft keeps the form's contents.
    if (context.read<SignUpBloc>().state.draft.role != _role) {
      final language = AppLanguage.fromValue(
        Localizations.localeOf(context).languageCode,
      );
      context.read<SignUpBloc>().add(
        SignUpRoleChosen(role: _role, language: language),
      );
    }
    switch (_role) {
      case Role.patient:
        unawaited(const PatientNameRoute().push<void>(context));
      case Role.doctor || Role.pathologist:
        unawaited(const PractitionerDetailsRoute().push<void>(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.mintWashDark : AppGradients.mintWash,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: Column(
                children: [
                  // The root when a verified account has no profile yet.
                  if (Navigator.of(context).canPop())
                    Align(
                      alignment: .centerLeft,
                      child: CircleIconButton(
                        icon: Assets.icons.backIcon,
                        semanticLabel: l10n.commonBack,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(l10n.roleTitle, style: textTheme.displaySmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(l10n.roleSubtitle, style: textTheme.bodyLarge),
                          const SizedBox(height: AppSpacing.lg),
                          OptionCard(
                            icon: Assets.icons.heartIcon,
                            tone: .sky,
                            title: l10n.roleCardPatientTitle,
                            supporting: l10n.roleCardPatientBody,
                            selected: _role == Role.patient,
                            onTap: () => setState(() => _role = Role.patient),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OptionCard(
                            icon: Assets.icons.stethoscopeIcon,
                            title: l10n.roleCardDoctorTitle,
                            supporting: l10n.roleCardDoctorBody,
                            selected: _role == Role.doctor,
                            onTap: () => setState(() => _role = Role.doctor),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OptionCard(
                            icon: Assets.icons.testTubeIcon,
                            tone: .lavender,
                            title: l10n.roleCardPathologistTitle,
                            supporting: l10n.roleCardPathologistBody,
                            selected: _role == Role.pathologist,
                            onTap: () =>
                                setState(() => _role = Role.pathologist),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          NoticeCard(
                            variant: NoticeVariant.info,
                            icon: Assets.icons.shieldIcon,
                            body: l10n.roleVerifyNotice,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TabibuButton.primary(
                    label: l10n.commonContinue,
                    onTap: _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
