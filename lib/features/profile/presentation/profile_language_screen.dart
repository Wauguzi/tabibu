import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P/D/PA-LANG in one screen: two radio options and Save, over the existing
/// language change. Patients read what follows the choice on top;
/// clinicians read their note under the options.
class ProfileLanguageScreen extends StatefulWidget {
  const ProfileLanguageScreen({required this.role, super.key});

  final Role role;

  @override
  State<ProfileLanguageScreen> createState() => _ProfileLanguageScreenState();
}

class _ProfileLanguageScreenState extends State<ProfileLanguageScreen> {
  AppLanguage? _choice;
  bool _saving = false;

  void _save() {
    final choice = _choice;
    if (choice == null || _saving) return;
    setState(() => _saving = true);
    context.read<AuthBloc>().add(LanguageChangeRequested(language: choice));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final background = switch (widget.role) {
      .patient => RoleBackground.patient,
      .doctor => RoleBackground.doctor,
      .pathologist => RoleBackground.pathologist,
    };
    final note = switch (widget.role) {
      .patient => null,
      .doctor => l10n.languageSettingsDoctorNote,
      .pathologist => l10n.languageSettingsPathologistNote,
    };
    final body = SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            sliver: SliverList.list(
              children: [
                TopBar(
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.languageSettingsTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                BlocListener<AuthBloc, AuthState>(
                  listenWhen: (_, _) => _saving,
                  listener: (context, state) {
                    switch (state) {
                      case LanguageChangeSuccess():
                        context.pop();
                      case LanguageChangeFailure(:final error):
                        setState(() => _saving = false);
                        unawaited(
                          showTabibuNotification(
                            context,
                            message: error.description(l10n),
                            isError: true,
                            dismissLabel: l10n.commonDismiss,
                          ),
                        );
                      default:
                        break;
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      final current =
                          Localizations.localeOf(context).languageCode == 'sw'
                          ? AppLanguage.sw
                          : AppLanguage.en;
                      final choice = _choice ?? current;
                      return Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          if (note == null) ...[
                            Text(
                              l10n.languageSettingsPatientBody,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          OptionCard(
                            icon: Assets.icons.languageIcon,
                            tone: .sky,
                            title: l10n.languageEn,
                            supporting: l10n.languageSettingsUseEnglish,
                            selected: choice == .en,
                            onTap: () => setState(() => _choice = .en),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OptionCard(
                            icon: Assets.icons.languageIcon,
                            tone: .sky,
                            title: l10n.languageSw,
                            supporting: l10n.languageSettingsUseSwahili,
                            selected: choice == .sw,
                            onTap: () => setState(() => _choice = .sw),
                          ),
                          if (note != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              note,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          TabibuButton.primary(
                            label: l10n.languageSettingsSave,
                            isLoading: _saving,
                            onTap: _saving ? null : _save,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(body: background(child: body));
  }
}
