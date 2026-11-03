import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-PROFILE-EDIT details. The hero, the pencil into the edit screen, and
/// the About-me rows. Names, phone and the area come from the session; date
/// of birth, sex and email are shown read-only (the rules let no client
/// write them), and the frame's care-team, emergency and cover sections
/// stay out: the data model has no fields for them (F-3).
class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  title: l10n.editProfileTitle,
                  trailing: CircleIconButton(
                    icon: Assets.icons.editIcon,
                    semanticLabel: l10n.editProfileEditTitle,
                    onTap: () =>
                        const PatientEditProfileRoute().push<void>(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final patient = switch (state.session) {
                      PatientSession(:final patient) => patient,
                      _ => null,
                    };
                    // The router bounces the signed-out off role paths; this is
                    // the frame between a sign-out and its redirect.
                    if (patient == null) return const SizedBox.shrink();
                    return _Details(patient: patient);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(body: RoleBackground.patient(child: body));
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final birth = DateTime.tryParse(patient.dateOfBirth);
    // The rules do not pin the format down, so a bad value degrades to
    // dateless text instead of failing the screen (the server's ageYears
    // answers -1 the same way).
    final age = birth == null ? null : patient.ageOn(nairobiNow());
    final birthText = birth == null
        ? ''
        : DateFormat('d MMM y', language).format(birth);
    final area = [
      patient.subCounty,
      patient.county,
    ].where((p) => p.isNotEmpty).join(', ');
    final nearby = patient.subCounty.isNotEmpty
        ? patient.subCounty
        : patient.county;
    final sex = Sex.fromValue(patient.sex)?.description(l10n) ?? patient.sex;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PatternCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Avatar.tile(
                  name: '${patient.firstName} ${patient.lastName}',
                  image: patient.profilePictureUrl.isEmpty
                      ? null
                      : NetworkImage(patient.profilePictureUrl),
                  radius: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        PatientIdentityCard.shortName(
                          patient.firstName,
                          patient.lastName,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        age == null
                            ? nearby
                            : l10n.editProfileSubtitle(age, nearby),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.editProfileAboutMe, style: _section(context)),
        const SizedBox(height: AppSpacing.sm),
        GroupedRowsCard(
          children: [
            _DetailRow(
              icon: Assets.icons.calendarIcon,
              title: l10n.editProfileDob,
              value: age == null
                  ? (patient.dateOfBirth.isEmpty ? '–' : patient.dateOfBirth)
                  : l10n.editProfileDobValue(age, birthText),
            ),
            _DetailRow(
              icon: Assets.icons.personIcon,
              title: l10n.editProfileSex,
              value: sex,
            ),
            _DetailRow(
              icon: Assets.icons.phoneIcon,
              title: l10n.editProfilePhone,
              value: PatientIdentityCard.maskPhone(patient.phoneNumber),
            ),
            _DetailRow(
              icon: Assets.icons.emailIcon,
              title: l10n.editProfileEmail,
              value: patient.email,
            ),
            _DetailRow(
              icon: Assets.icons.locationIcon,
              title: l10n.editProfileArea,
              value: area,
            ),
          ],
        ),
      ],
    );
  }

  TextStyle? _section(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;
}

/// An icon with a bold title and a muted value, no chevron: detail rows
/// navigate nowhere. No core row fits (GroupedRow is one line, SettingsRow
/// always chevrons), so it lives here.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final SvgGenImage icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        IconTile(icon: icon, tone: .neutral),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(title, style: textTheme.titleMedium),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
