import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// P-/D-/PA-PRIVACY help and support. The call row dials out; the questions
/// open in place, the first already open as the frames draw it. The frames'
/// WhatsApp and SMS rows stay out: bundle 46 kept the one confirmed number.
class HelpScreen extends StatefulWidget {
  const HelpScreen({required this.role, super.key});

  final Role role;

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _open = 0;

  void _call(String number) {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patient = widget.role == .patient;
    final callTitle = patient ? l10n.helpCallUs : l10n.helpCallClinician;
    final callBody = patient ? l10n.helpCallUsBody : l10n.helpCallClinicianBody;
    final guides = _guides(l10n);
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
                  title: l10n.helpTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionTitle(
                  title: patient
                      ? l10n.helpTalkToUs
                      : l10n.helpClinicianSupport,
                ),
                const SizedBox(height: AppSpacing.xs),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Assets.icons.phoneIcon,
                      title: callTitle,
                      supporting: callBody,
                      chevron: false,
                      onTap: () => _call(callBody),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionTitle(
                  title: patient ? l10n.helpQuestions : l10n.helpGuides,
                ),
                const SizedBox(height: AppSpacing.xs),
                SettingsCard(
                  children: [
                    for (var i = 0; i < guides.length; i++)
                      _GuideRow(
                        icon: guides[i].icon,
                        title: guides[i].title,
                        body: guides[i].body,
                        expanded: _open == i,
                        onTap: () => setState(() => _open = i),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: switch (widget.role) {
        .patient => RoleBackground.patient(child: body),
        .pathologist => RoleBackground.pathologist(child: body),
        _ => RoleBackground.doctor(child: body),
      },
    );
  }

  List<({SvgGenImage icon, String title, String body})> _guides(
    AppLocalizations l10n,
  ) => switch (widget.role) {
    .patient => [
      (
        icon: Assets.icons.calendarIcon,
        title: l10n.helpChangeAppointment,
        body: l10n.helpChangeAppointmentBody,
      ),
      (
        icon: Assets.icons.documentIcon,
        title: l10n.helpWhenResults,
        body: l10n.helpWhenResultsBody,
      ),
      (
        icon: Assets.icons.languageIcon,
        title: l10n.helpKiswahili,
        body: l10n.helpKiswahiliBody,
      ),
      (
        icon: Assets.icons.shieldIcon,
        title: l10n.helpSafe,
        body: l10n.helpSafeBody,
      ),
    ],
    .pathologist => [
      (
        icon: Assets.icons.sparkleIcon,
        title: l10n.helpPreread,
        body: l10n.helpPrereadBody,
      ),
      (
        icon: Assets.icons.signedIcon,
        title: l10n.helpSigning,
        body: l10n.helpSigningBody,
      ),
    ],
    _ => [
      (
        icon: Assets.icons.testTubeIcon,
        title: l10n.helpOrderingTest,
        body: l10n.helpOrderingTestBody,
      ),
      (
        icon: Assets.icons.alertIcon,
        title: l10n.helpApprovingAlerts,
        body: l10n.helpApprovingAlertsBody,
      ),
      (
        icon: Assets.icons.mdtIcon,
        title: l10n.helpMdtConsult,
        body: l10n.helpMdtConsultBody,
      ),
    ],
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

/// One question: the answer opens under the title. Tapping the open row
/// keeps it open; another row takes its place.
class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.expanded,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String title;
  final String body;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      expanded: expanded,
      onTap: onTap,
      child: Tappable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              IconTile(icon: icon, tone: .neutral),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    const SizedBox(height: AppSpacing.xxs),
                    Text(title, style: textTheme.titleSmall),
                    if (expanded) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        body,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: AssetIcon(
                    Assets.icons.dropDownIcon,
                    size: 22,
                    scaleUp: false,
                    color: scheme.onSurfaceVariant,
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
