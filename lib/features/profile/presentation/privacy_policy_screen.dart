import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-/D-/PA-PRIVACY privacy policy. Static sections from the frames; the
/// pathologist's 1st, 4th and 5th titles are the doctor's (bundle 46). The
/// draft date is the policy's, fixed, formatted per locale.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({required this.role, super.key});

  final Role role;

  static final _drafted = DateTime.utc(2026, 10, 27);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d MMM yyyy', language).format(_drafted);
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
                  title: l10n.privacyPolicyTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  role == .patient
                      ? l10n.privacyDraftPatient(date)
                      : l10n.privacyDraftClinician(date),
                  style: _muted(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _PolicyCard(sections: _sections(l10n)),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: switch (role) {
        .patient => RoleBackground.patient(child: body),
        .pathologist => RoleBackground.pathologist(child: body),
        _ => RoleBackground.doctor(child: body),
      },
    );
  }

  TextStyle? _muted(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  List<({String title, String body})> _sections(AppLocalizations l10n) =>
      switch (role) {
        .patient => [
          (title: l10n.privacyP1Title, body: l10n.privacyP1Body),
          (title: l10n.privacyP2Title, body: l10n.privacyP2Body),
          (title: l10n.privacyP3Title, body: l10n.privacyP3Body),
          (title: l10n.privacyP4Title, body: l10n.privacyP4Body),
          (title: l10n.privacyP5Title, body: l10n.privacyP5Body),
          (title: l10n.privacyP6Title, body: l10n.privacyP6Body),
        ],
        .pathologist => [
          (title: l10n.privacyD1Title, body: l10n.privacyA1Body),
          (title: l10n.privacyA2Title, body: l10n.privacyA2Body),
          (title: l10n.privacyA3Title, body: l10n.privacyA3Body),
          (title: l10n.privacyD4Title, body: l10n.privacyA4Body),
          (title: l10n.privacyD5Title, body: l10n.privacyD5Body),
        ],
        _ => [
          (title: l10n.privacyD1Title, body: l10n.privacyD1Body),
          (title: l10n.privacyD2Title, body: l10n.privacyD2Body),
          (title: l10n.privacyD3Title, body: l10n.privacyD3Body),
          (title: l10n.privacyD4Title, body: l10n.privacyD4Body),
          (title: l10n.privacyD5Title, body: l10n.privacyD5Body),
        ],
      };
}

/// The sections on one card, undivided as the frames draw them.
class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.sections});

  final List<({String title, String body})> sections;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.lg),
              Text(
                sections[i].title,
                style: textTheme.titleMedium?.copyWith(fontWeight: .w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                sections[i].body,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
