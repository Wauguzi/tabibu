import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_bloc.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_event.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P/D/PA-THEME in one screen: three radio options and Save, over the
/// existing theme bloc. The change applies instantly and cannot fail, so
/// Save dispatches and leaves.
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({required this.role, super.key});

  final Role role;

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemePreference? _choice;

  void _save(ThemePreference choice) {
    context.read<ThemeBloc>().add(ThemeChangeRequested(preference: choice));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final background = switch (widget.role) {
      .patient => RoleBackground.patient,
      .doctor => RoleBackground.doctor,
      .pathologist => RoleBackground.pathologist,
    };
    final clinician = widget.role != .patient;
    final choice = _choice ?? context.watch<ThemeBloc>().state.preference;
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
                  title: l10n.themeSettingsTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                OptionCard(
                  icon: Assets.icons.themeIcon,
                  tone: .sky,
                  title: l10n.themeLight,
                  supporting: clinician
                      ? l10n.themeSettingsLightClinician
                      : l10n.themeSettingsLightPatient,
                  selected: choice == .light,
                  onTap: () => setState(() => _choice = .light),
                ),
                const SizedBox(height: AppSpacing.md),
                OptionCard(
                  icon: Assets.icons.themeIcon,
                  tone: .sky,
                  title: l10n.themeDark,
                  supporting: clinician
                      ? l10n.themeSettingsDarkClinician
                      : l10n.themeSettingsDarkPatient,
                  selected: choice == .dark,
                  onTap: () => setState(() => _choice = .dark),
                ),
                const SizedBox(height: AppSpacing.md),
                OptionCard(
                  icon: Assets.icons.themeIcon,
                  tone: .sky,
                  title: l10n.themeSettingsSystem,
                  supporting: l10n.themeSettingsSystemBody,
                  selected: choice == .system,
                  onTap: () => setState(() => _choice = .system),
                ),
                const SizedBox(height: AppSpacing.lg),
                TabibuButton.primary(
                  label: l10n.themeSettingsSave,
                  onTap: () => _save(choice),
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
