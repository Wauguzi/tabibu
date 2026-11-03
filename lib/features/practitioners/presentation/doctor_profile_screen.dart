import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-04. A doctor's profile with the day and slot pickers and booking. The
/// strip carries the planner's whole horizon, so there is no pick-a-date
/// sheet.
class DoctorProfileScreen extends StatefulWidget {
  /// [now] pins the planner's clock; tests pass a fixed morning.
  const DoctorProfileScreen({required this.doctorUid, this.now, super.key});

  final String doctorUid;
  final DateTime? now;

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final String _patientUid;
  late final TextEditingController _symptoms = TextEditingController();
  int _dayIndex = 0;
  int? _slotIndex;
  bool _bioExpanded = false;

  @override
  void initState() {
    super.initState();
    _patientUid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    final directory = context.read<DirectoryBloc>().state;
    if (directory.all.firstWhereOrNull((d) => d.uid == widget.doctorUid) ==
        null) {
      context.read<DirectoryBloc>().add(const DirectoryRequested());
    }
  }

  @override
  void dispose() {
    _symptoms.dispose();
    super.dispose();
  }

  /// The patient's earliest accepted future appointment with this doctor.
  ({AppointmentModel appointment, DateTime start})? _bookedWith(
    List<AppointmentModel> rows,
    DateTime now,
  ) {
    AppointmentModel? booked;
    DateTime? start;
    for (final row in rows) {
      if (row.doctorUid != widget.doctorUid) continue;
      if (row.statusValue != AppointmentStatus.accepted) continue;
      final at = nairobiTimeOf(row.scheduledStart);
      if (at == null || !at.isAfter(now)) continue;
      if (start == null || at.isBefore(start)) {
        booked = row;
        start = at;
      }
    }
    return booked == null || start == null
        ? null
        : (appointment: booked, start: start);
  }

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<DirectoryBloc>().state;
    final doctor = directory.all.firstWhereOrNull(
      (d) => d.uid == widget.doctorUid,
    );
    final body = SafeArea(
      child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          switch (state) {
            case AppointmentBookSuccess(:final appointment):
              BookedRoute(
                appointmentUid: appointment.uid,
              ).pushReplacement(context);
            case AppointmentWriteFailure(:final error):
              unawaited(
                showTabibuNotification(
                  context,
                  message: error.description(context.l10n),
                  isError: true,
                  dismissLabel: context.l10n.commonDismiss,
                ),
              );
            default:
              break;
          }
        },
        builder: (context, appointments) {
          if (doctor == null) {
            return _doctorMissing(directory);
          }
          return CustomScrollView(
            slivers: _slivers(doctor, directory, appointments),
          );
        },
      ),
    );
    return Scaffold(body: RoleBackground.patient(child: body));
  }

  /// Loading until the directory answers, then the not-found empty state.
  Widget _doctorMissing(DirectoryState directory) {
    final loaded =
        directory is DirectoryLoadSuccess || directory is DirectoryLoadFailure;
    if (!loaded) {
      return CustomScrollView(
        slivers: [
          _topBarSliver(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: LoadingView(
                  semanticLabel: context.l10n.doctorProfileLoadingLabel,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        _topBarSliver(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: EmptyState(
              title: context.l10n.doctorProfileNotFoundTitle,
              icon: Assets.icons.searchRoundedIcon,
              body: context.l10n.doctorProfileNotFoundBody,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _slivers(
    PractitionerModel doctor,
    DirectoryState directory,
    AppointmentsState appointments,
  ) {
    const sides = EdgeInsets.fromLTRB(
      AppSpacing.screenMargin,
      AppSpacing.md,
      AppSpacing.screenMargin,
      0,
    );
    final language = Localizations.localeOf(context).languageCode;
    final days = const SlotPlanner().days(doctor, widget.now ?? DateTime.now());
    final dayIndex = _dayIndex.clamp(0, days.length - 1);
    final slots = days[dayIndex].slots;
    final free = slots.where((s) => !s.taken).length;
    final slotIndex = _slotIndex;
    final chosen = slotIndex != null && slotIndex < slots.length
        ? slots[slotIndex]
        : null;
    final offline = directory.offline || appointments.offline;
    final booking = appointments is AppointmentWriteInProgress;
    final now = nairobiNow();
    final booked = _bookedWith(appointments.appointments, now);
    final l10n = context.l10n;

    String dayLabel(PlannedDay day) =>
        DateFormat('EEE d MMM', language).format(day.date);
    String timeLabel(DateTime start) =>
        DateFormat('h:mm a', language).format(nairobiNow(start));

    return [
      _topBarSliver(),
      if (booked != null)
        SliverPadding(
          padding: sides,
          sliver: SliverToBoxAdapter(
            child: NoticeCard(
              variant: .signed,
              title: l10n.doctorProfileBookedTitle(
                [
                  doctor.title,
                  doctor.lastName,
                ].where((part) => part.isNotEmpty).join(' '),
              ),
              body: l10n.doctorProfileBookedBody(
                DateFormat('EEE d MMM', language).format(booked.start),
                DateFormat('h:mm a', language).format(booked.start),
              ),
              action: TabibuButton.ghost(
                label: l10n.doctorProfileViewAppointment,
                onTap: () => PatientAppointmentRoute(
                  appointmentUid: booked.appointment.uid,
                ).push<void>(context),
              ),
            ),
          ),
        ),
      SliverPadding(
        padding: sides,
        sliver: SliverToBoxAdapter(child: _header(doctor)),
      ),
      if (doctor.bio.isNotEmpty)
        SliverPadding(
          padding: sides,
          sliver: SliverToBoxAdapter(child: _about(doctor)),
        ),
      if (doctor.facilityName.isNotEmpty || doctor.subCounty.isNotEmpty)
        SliverPadding(
          padding: sides,
          sliver: SliverToBoxAdapter(child: _hospitalCard(doctor)),
        ),
      SliverPadding(
        padding: sides,
        sliver: SliverToBoxAdapter(
          child: SectionHeader(title: l10n.doctorProfilePickDay),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.sm,
          0,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: DayStrip(
            days: [
              for (final day in days)
                DayOption(
                  weekday: DateFormat('EEE', language).format(day.date),
                  day: DateFormat('d', language).format(day.date),
                  available: day.available,
                ),
            ],
            selected: dayIndex,
            onSelected: (index) => setState(() {
              _dayIndex = index;
              _slotIndex = null;
            }),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.sm,
          AppSpacing.screenMargin,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              AssetIcon(
                Assets.icons.calendarIcon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.doctorProfileTimesFree(
                    DateFormat('EEEE', language).format(days[dayIndex].date),
                    free,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.sm,
          0,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: SlotChipRow(
            slots: [
              for (final slot in slots)
                SlotOption(
                  label: timeLabel(slot.start),
                  taken: slot.taken,
                  semanticLabel: slot.taken
                      ? l10n.pickTimeSlotTaken(timeLabel(slot.start))
                      : null,
                ),
            ],
            selected: slotIndex != null && slotIndex < slots.length
                ? slotIndex
                : null,
            onSelected: (index) => setState(() => _slotIndex = index),
          ),
        ),
      ),
      SliverPadding(
        padding: sides,
        sliver: SliverToBoxAdapter(
          child: TabibuTextField(
            label: l10n.doctorProfileSymptomsLabel,
            hint: l10n.doctorProfileSymptomsHint,
            controller: _symptoms,
            maxLines: 5,
            maxLength: 500,
            keyboardType: .multiline,
          ),
        ),
      ),
      if (offline)
        SliverPadding(
          padding: sides,
          sliver: SliverToBoxAdapter(
            child: ConnectivityBanner(
              state: .offline,
              title: l10n.pickTimeOfflineTitle,
              body: l10n.pickTimeOfflineBody,
              retryLabel: l10n.pickTimeRetry,
              onRetry: () {
                context.read<DirectoryBloc>().add(const DirectoryRefreshed());
                context.read<AppointmentsBloc>().add(
                  AppointmentsRefreshed(uid: _patientUid, role: .patient),
                );
              },
            ),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.md,
          AppSpacing.screenMargin,
          AppSpacing.md,
        ),
        sliver: SliverToBoxAdapter(
          child: TabibuButton.primary(
            label: chosen == null
                ? l10n.doctorProfileChooseTime
                : l10n.doctorProfileBook(
                    dayLabel(days[dayIndex]),
                    timeLabel(chosen.start),
                  ),
            onTap: chosen == null || offline || booking
                ? null
                : () => context.read<AppointmentsBloc>().add(
                    AppointmentBookRequested(
                      uid: _patientUid,
                      doctorUid: doctor.uid,
                      type: AppointmentType.consultation.value,
                      start: chosen.start,
                      symptomText: _symptoms.text,
                    ),
                  ),
            isLoading: booking,
          ),
        ),
      ),
    ];
  }

  Widget _topBarSliver() => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screenMargin,
      AppSpacing.md,
      AppSpacing.screenMargin,
      0,
    ),
    sliver: SliverToBoxAdapter(
      child: TopBar(
        title: context.l10n.roleDoctor,
        backLabel: context.l10n.commonBack,
        onBack: context.pop,
      ),
    ),
  );

  /// Name, specialty and facility on the left, the portrait on the right.
  Widget _header(PractitionerModel doctor) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final l10n = context.l10n;
    final raw = doctor.specialties.firstOrNull ?? '';
    final image = doctor.profilePictureUrl;
    // The chip sits above the columns: beside the portrait it would clip in
    // Kiswahili and at large text.
    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              AssetIcon(
                Assets.icons.verificationBadge,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  l10n.doctorProfileVerified,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: .w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(doctor.fullName, style: textTheme.displaySmall),
                  if (raw.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      Specialty.fromValue(raw)?.description(l10n) ?? raw,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: .w400,
                      ),
                    ),
                  ],
                  if (doctor.facilityName.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        AssetIcon(
                          Assets.icons.facilityIcon,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            doctor.facilityName,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                color: isDark ? AppColors.skyDark : AppColors.skyLight,
                borderRadius: BorderRadius.circular(AppRadii.tile),
              ),
              alignment: .center,
              child: image.isEmpty
                  ? Avatar.tile(name: doctor.fullName, radius: 36)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.tile),
                      child: Image(
                        image: NetworkImage(image),
                        width: 140,
                        height: 180,
                        fit: .cover,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _about(PractitionerModel doctor) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final expanded = _bioExpanded;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.doctorProfileAbout, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          doctor.bio,
          style: textTheme.bodyLarge,
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : .ellipsis,
        ),
        if (!expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          Tappable(
            onTap: () => setState(() => _bioExpanded = true),
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(
                  l10n.doctorProfileReadMore,
                  style: textTheme.labelLarge?.copyWith(color: scheme.primary),
                ),
                AssetIcon(
                  Assets.icons.dropDownIcon,
                  size: 20,
                  scaleUp: false,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _hospitalCard(PractitionerModel doctor) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == .dark;
    return Container(
      width: double.infinity,
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.mintToSkyDark : AppGradients.mintToSky,
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (doctor.facilityName.isNotEmpty)
            Text(doctor.facilityName, style: textTheme.titleLarge),
          if (doctor.subCounty.isNotEmpty) ...[
            if (doctor.facilityName.isNotEmpty)
              const SizedBox(height: AppSpacing.xxs),
            Text(doctor.subCounty, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
