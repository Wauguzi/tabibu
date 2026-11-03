import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/widgets/sign_out_sheet.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_form.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Every role's last tab: who is signed in, their settings, and sign-out.
/// The rows lead to the profile screens (S-3); biometrics, delete account
/// and the facility change stay hidden (Tier 3 and group D), and privacy
/// and help lead in bundle 52.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.role, super.key});

  final Role role;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  String _languageName(AppLocalizations l10n) =>
      Localizations.localeOf(context).languageCode == 'sw'
      ? l10n.languageSw
      : l10n.languageEn;

  void _push(GoRouteData route) => unawaited(route.push<void>(context));

  void _openDetails() => _push(switch (widget.role) {
    .patient => const PatientProfileDetailsRoute(),
    .doctor => const DoctorProfileDetailsRoute(),
    .pathologist => const PathologistProfileDetailsRoute(),
  });

  void _openLanguage() => _push(switch (widget.role) {
    .patient => const PatientProfileLanguageRoute(),
    .doctor => const DoctorProfileLanguageRoute(),
    .pathologist => const PathologistProfileLanguageRoute(),
  });

  void _openTheme() => _push(switch (widget.role) {
    .patient => const PatientProfileThemeRoute(),
    .doctor => const DoctorProfileThemeRoute(),
    .pathologist => const PathologistProfileThemeRoute(),
  });

  void _openNotifications() => _push(switch (widget.role) {
    .patient => const PatientProfileNotificationsRoute(),
    .doctor => const DoctorProfileNotificationsRoute(),
    .pathologist => const PathologistProfileNotificationsRoute(),
  });

  /// "Mon–Fri · 9:00 AM–4:00 PM" under the clinic-hours row, from the
  /// stored days and range.
  String _hoursSummary(AppLocalizations l10n, DoctorModel doctor) {
    final days = doctor.workingDays.toSet();
    if (days.isEmpty) return l10n.clinicHoursClosed;
    final language = Localizations.localeOf(context).languageCode;
    final range = hoursRangeText(
      context,
      doctor.dayStartMinute,
      doctor.dayEndMinute,
    );
    return '${workingDaysSummary(language, days)} · $range';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.watch<AuthBloc>().state;
    final signingOut = authState is SignOutInProgress;

    final title = Semantics(
      header: true,
      child: Text(switch (widget.role) {
        .patient => l10n.profileTitlePatient,
        .doctor => l10n.profileTitleDoctor,
        .pathologist => l10n.profileTitlePathologist,
      }, style: Theme.of(context).textTheme.displaySmall),
    );
    final help = SettingsGroup(
      title: l10n.profileSectionHelp,
      children: [
        SettingsRow(icon: Assets.icons.shieldIcon, title: l10n.profilePrivacy),
        SettingsRow(icon: Assets.icons.heartIcon, title: l10n.profileHelp),
        SettingsRow(
          icon: Assets.icons.signOutIcon,
          title: l10n.profileSignOut,
          destructive: true,
          onTap: signingOut
              ? null
              : () => unawaited(
                  confirmSignOut(context, isPatient: widget.role == .patient),
                ),
        ),
        SettingsRow(
          icon: Assets.icons.deleteIcon,
          title: l10n.profileDeleteAccount,
          destructive: true,
        ),
      ],
    );
    final language = SettingsRow(
      icon: Assets.icons.languageIcon,
      title: l10n.profileLanguage,
      supporting: _languageName(l10n),
      onTap: _openLanguage,
    );
    final theme = SettingsRow(
      icon: Assets.icons.themeIcon,
      title: l10n.profileTheme,
      supporting: l10n.profileThemeSupporting,
      onTap: _openTheme,
    );
    final notifications = SettingsRow(
      icon: Assets.icons.notificationBellIcon,
      title: l10n.notificationSettingsTitle,
      onTap: _openNotifications,
    );
    // Bundle 53: app lock settings (S-3). Supporting mirrors the lock state.
    final lockOn = context.watch<LockBloc>().state.enabled;
    final appLock = SettingsRow(
      icon: Assets.icons.shieldIcon,
      title: l10n.appLockTitle,
      supporting: lockOn ? l10n.appLockPin : l10n.appLockOff,
      onTap: () => unawaited(switch (widget.role) {
        .patient => const PatientAppLockRoute().push<void>(context),
        .pathologist => const PathologistAppLockRoute().push<void>(context),
        _ => const DoctorAppLockRoute().push<void>(context),
      }),
    );
    final saving = authState is ProfileSettingChangeInProgress;
    void flip({required ProfileSetting setting, required bool value}) => context
        .read<AuthBloc>()
        .add(ProfileSettingChanged(setting: setting, value: value));

    final body = switch (authState.session) {
      PatientSession(:final patient) => _patient(
        l10n,
        patient,
        language: language,
        theme: theme,
        appLock: appLock,
        notifications: notifications,
        saving: saving,
        onFlip: flip,
      ),
      PractitionerSession(:final doctor, :final roles) => _practitioner(
        l10n,
        doctor,
        isAlertApprover: roles.isAlertApprover,
        language: language,
        theme: theme,
        appLock: appLock,
        notifications: notifications,
        saving: saving,
        onFlip: flip,
      ),
      // Signing out: the guard is about to leave this route.
      _ => const <Widget>[],
    };

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) =>
          state is SignOutFailure || state is ProfileSettingChangeFailure,
      listener: (context, state) {
        final error = switch (state) {
          SignOutFailure(:final error) => error,
          ProfileSettingChangeFailure(:final error) => error,
          _ => null,
        };
        if (error == null) return;
        unawaited(
          showTabibuNotification(
            context,
            message: error.description(l10n),
            isError: true,
            dismissLabel: l10n.commonDismiss,
          ),
        );
      },
      child: ShellTabPage(
        role: widget.role,
        children: [
          title,
          const SizedBox(height: AppSpacing.md),
          for (final (i, child) in body.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sectionGap),
            child,
          ],
          if (body.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            help,
            const SizedBox(height: AppSpacing.lg),
            _Version(packageInfo: _packageInfo),
          ],
        ],
      ),
    );
  }

  List<Widget> _patient(
    AppLocalizations l10n,
    PatientModel patient, {
    required Widget language,
    required Widget theme,
    required Widget appLock,
    required Widget notifications,
    required bool saving,
    required void Function({
      required ProfileSetting setting,
      required bool value,
    })
    onFlip,
  }) {
    final area = [
      patient.subCounty,
      patient.county,
    ].where((part) => part.isNotEmpty).join(', ');
    return [
      PatientIdentityCard(
        firstName: patient.firstName,
        lastName: patient.lastName,
        phoneNumber: patient.phoneNumber,
        photoUrl: patient.profilePictureUrl,
        editLabel: l10n.profileEdit,
        onEdit: _openDetails,
      ),
      SettingsGroup(
        title: l10n.profileSectionPreferences,
        children: [
          language,
          SettingsRow(
            icon: Assets.icons.locationIcon,
            title: l10n.profileMyArea,
            supporting: area.isEmpty ? null : area,
            onTap: () => _push(const PatientProfileAreaRoute()),
          ),
          theme,
          appLock,
        ],
      ),
      SettingsGroup(
        title: l10n.profileSectionAlerts,
        children: [
          notifications,
          _healthNoticesRow(
            l10n,
            patient.receiveNotifications,
            saving: saving,
            onFlip: onFlip,
          ),
        ],
      ),
    ];
  }

  List<Widget> _practitioner(
    AppLocalizations l10n,
    DoctorModel doctor, {
    required bool isAlertApprover,
    required Widget language,
    required Widget theme,
    required Widget appLock,
    required Widget notifications,
    required bool saving,
    required void Function({
      required ProfileSetting setting,
      required bool value,
    })
    onFlip,
  }) {
    final specialties = [
      for (final value in doctor.specialties)
        Specialty.fromValue(value)?.description(l10n) ?? value,
    ];
    final role = doctor.isPathologist
        ? l10n.profilePathologist
        : specialties.firstOrNull;
    return [
      PractitionerIdentityCard(
        name: '${doctor.title} ${doctor.firstName} ${doctor.lastName}'.trim(),
        subtitle: role == null
            ? doctor.facilityName
            : l10n.profileRoleAtFacility(role, doctor.facilityName),
        verifiedLabel: l10n.profileKmpdcVerified(doctor.kmpdcNumber),
        photoUrl: doctor.profilePictureUrl,
        onEdit: _openDetails,
        editLabel: l10n.profileEdit,
      ),
      if (!doctor.isPathologist && isAlertApprover && doctor.county.isNotEmpty)
        NoticeCard(
          variant: .attention,
          icon: Assets.icons.infoIcon,
          body: l10n.profileAlertApprover(doctor.county),
        ),
      if (doctor.isPathologist && specialties.isNotEmpty)
        _Areas(title: l10n.profileAreas, areas: specialties),
      SettingsGroup(
        title: l10n.profileSectionPractice,
        children: [
          SettingsRow(
            icon: Assets.icons.facilityIcon,
            title: doctor.isPathologist
                ? l10n.profileLab
                : l10n.profileFacility,
            supporting: doctor.facilityName,
          ),
          if (!doctor.isPathologist)
            SettingsRow(
              icon: Assets.icons.clockIcon,
              title: l10n.clinicHoursTitle,
              supporting: _hoursSummary(l10n, doctor),
              onTap: () => _push(const DoctorClinicHoursRoute()),
            ),
          if (doctor.isPathologist)
            SettingsSwitchRow(
              icon: Assets.icons.testTubeIcon,
              title: l10n.profileAcceptCases,
              value: doctor.isAvailable,
              onChanged: saving
                  ? null
                  : (value) => onFlip(
                      setting: ProfileSetting.acceptCases,
                      value: value,
                    ),
            ),
          language,
          theme,
          appLock,
        ],
      ),
      SettingsGroup(
        title: l10n.profileSectionAlerts,
        children: [
          notifications,
          _healthNoticesRow(
            l10n,
            doctor.receiveNotifications,
            saving: saving,
            onFlip: onFlip,
          ),
        ],
      ),
    ];
  }

  Widget _healthNoticesRow(
    AppLocalizations l10n,
    bool initial, {
    required bool saving,
    required void Function({
      required ProfileSetting setting,
      required bool value,
    })
    onFlip,
  }) => SettingsSwitchRow(
    icon: Assets.icons.infoIcon,
    title: l10n.profileHealthNotices,
    value: initial,
    onChanged: saving
        ? null
        : (value) =>
              onFlip(setting: ProfileSetting.healthNotices, value: value),
  );
}

/// The pathologist's report areas as mint pills.
class _Areas extends StatelessWidget {
  const _Areas({required this.title, required this.areas});

  final String title;
  final List<String> areas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // One row that scrolls, as designed; unclipped, so the pills run on
        // to the screen's edge.
        SingleChildScrollView(
          scrollDirection: .horizontal,
          clipBehavior: .none,
          child: Row(
            spacing: AppSpacing.xs,
            children: [
              for (final area in areas)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: status.signedContainer,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      area,
                      style: textTheme.labelLarge?.copyWith(
                        color: status.signed,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({required this.packageInfo});

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: packageInfo,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Text(
          context.l10n.profileVersion(info.version),
          textAlign: .center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
