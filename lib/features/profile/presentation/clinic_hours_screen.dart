import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/hours_sheet.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_form.dart';
import 'package:tabibu/features/profile/presentation/widgets/settings_group.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-HOURS: the working-day groups, the fixed appointment length, and the
/// accepting switch. The groups share the one range the backend keeps; the
/// length sheet from the frame stays out (slots are fixed at 30 minutes),
/// and the accepting switch flips at once through the profile-setting path.
class ClinicHoursScreen extends StatefulWidget {
  const ClinicHoursScreen({super.key});

  @override
  State<ClinicHoursScreen> createState() => _ClinicHoursScreenState();
}

enum _DayGroup {
  weekdays,
  saturday,
  sunday;

  Set<int> get days => switch (this) {
    .weekdays => const {1, 2, 3, 4, 5},
    .saturday => const {6},
    .sunday => const {7},
  };
}

class _ClinicHoursScreenState extends State<ClinicHoursScreen> {
  Set<int> _days = {};
  int _start = 480;
  int _end = 1020;
  bool _filled = false;
  bool _saving = false;
  bool _needDay = false;

  /// The session's hours fill the draft once; a rebuild mid-edit must not
  /// clobber it.
  void _fillOnce(DoctorModel doctor) {
    if (_filled) return;
    _filled = true;
    _days = doctor.workingDays.toSet();
    _start = doctor.dayStartMinute;
    _end = doctor.dayEndMinute;
  }

  String _groupTitle(_DayGroup group, AppLocalizations l10n) {
    final language = Localizations.localeOf(context).languageCode;
    return switch (group) {
      // 31 Oct 2026 is a Saturday, 1 Nov a Sunday.
      .weekdays => l10n.clinicHoursWeekdays,
      .saturday => DateFormat(
        'EEEE',
        language,
      ).format(DateTime.utc(2026, 10, 31)),
      .sunday => DateFormat('EEEE', language).format(DateTime.utc(2026, 11)),
    };
  }

  Future<void> _edit(_DayGroup group) async {
    final l10n = context.l10n;
    final draft = await showHoursSheet(
      context: context,
      title: _groupTitle(group, l10n),
      open: _days.any(group.days.contains),
      startMinute: _start,
      endMinute: _end,
    );
    if (draft == null || !mounted) return;
    setState(() {
      if (draft.open) {
        _days.addAll(group.days);
      } else {
        _days.removeAll(group.days);
      }
      _start = draft.startMinute;
      _end = draft.endMinute;
      _needDay = false;
    });
  }

  void _save() {
    if (_days.isEmpty) {
      setState(() => _needDay = true);
      return;
    }
    setState(() => _saving = true);
    final days = _days.toList()..sort();
    context.read<AuthBloc>().add(
      ClinicHoursChanged(
        workingDays: days,
        dayStartMinute: _start,
        dayEndMinute: _end,
      ),
    );
  }

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
                  title: l10n.clinicHoursTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    switch (state) {
                      case ProfileSaveSuccess() when _saving:
                        context.pop();
                      case ProfileSaveFailure(:final error) when _saving:
                        setState(() => _saving = false);
                        unawaited(
                          showTabibuNotification(
                            context,
                            message: error.description(l10n),
                            isError: true,
                            dismissLabel: l10n.commonDismiss,
                          ),
                        );
                      case ProfileSettingChangeFailure(:final error):
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
                  builder: (context, state) {
                    final doctor = switch (state.session) {
                      PractitionerSession(:final doctor) => doctor,
                      _ => null,
                    };
                    // The router bounces the signed-out off role paths; this is
                    // the frame between a sign-out and its redirect.
                    if (doctor == null) return const SizedBox.shrink();
                    _fillOnce(doctor);
                    final flipping = state is ProfileSettingChangeInProgress;
                    final range = hoursRangeText(context, _start, _end);
                    String supporting(_DayGroup group) =>
                        _days.any(group.days.contains)
                        ? range
                        : l10n.clinicHoursClosed;
                    return Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        SettingsCard(
                          children: [
                            for (final group in _DayGroup.values)
                              SettingsRow(
                                icon: Assets.icons.calendarIcon,
                                title: _groupTitle(group, l10n),
                                supporting: supporting(group),
                                onTap: () => _edit(group),
                              ),
                            SettingsRow(
                              icon: Assets.icons.clockIcon,
                              title: l10n.clinicHoursLength,
                              supporting: l10n.clinicHoursThirtyMin,
                              chevron: false,
                            ),
                            SettingsSwitchRow(
                              icon: Assets.icons.testTubeIcon,
                              title: l10n.clinicHoursAccepting,
                              supporting: doctor.isAvailable
                                  ? l10n.clinicHoursAcceptingOn
                                  : l10n.clinicHoursAcceptingOff,
                              value: doctor.isAvailable,
                              onChanged: flipping
                                  ? null
                                  : (value) => context.read<AuthBloc>().add(
                                      ProfileSettingChanged(
                                        setting: .acceptCases,
                                        value: value,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        if (_needDay) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.clinicHoursNeedDay,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        TabibuButton.primary(
                          label: l10n.clinicHoursSave,
                          isLoading: _saving,
                          onTap: _saving ? null : _save,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(body: RoleBackground.doctor(child: body));
  }
}
