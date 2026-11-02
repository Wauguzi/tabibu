import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-07. The booking confirmation: a terminal success screen, so system back
/// goes home and never returns to the submitted form.
class BookedScreen extends StatefulWidget {
  const BookedScreen({required this.appointmentUid, super.key});

  final String appointmentUid;

  @override
  State<BookedScreen> createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  late final String _firstName;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _firstName = switch (session) {
      PatientSession(:final patient) => patient.firstName,
      _ => '',
    };
    final appointments = context.read<AppointmentsBloc>().state.appointments;
    if (appointments.firstWhereOrNull((a) => a.uid == widget.appointmentUid) ==
        null) {
      final uid = switch (session) {
        PatientSession(:final patient) => patient.uid,
        _ => '',
      };
      context.read<AppointmentsBloc>().add(
        AppointmentsRequested(uid: uid, role: .patient),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = context
        .watch<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == widget.appointmentUid);
    final body = SafeArea(
      child: appointment == null
          ? Center(
              child: LoadingView(
                semanticLabel: context.l10n.bookedLoadingLabel,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.xxlg,
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                  ),
                  sliver: SliverList.list(children: _confirmation(appointment)),
                ),
              ],
            ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) const PatientHomeRoute().go(context);
      },
      child: Scaffold(body: RoleBackground.patient(child: body)),
    );
  }

  List<Widget> _confirmation(AppointmentModel appointment) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final language = Localizations.localeOf(context).languageCode;
    final start = nairobiTimeOf(appointment.scheduledStart) ?? nairobiNow();
    return [
      Center(
        child: IconTile(icon: Assets.icons.calendarIcon, tone: .mint, size: .l),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        l10n.bookedTitle(_firstName),
        style: textTheme.displaySmall,
        textAlign: .center,
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        l10n.bookedBody,
        style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        textAlign: .center,
      ),
      const SizedBox(height: AppSpacing.lg),
      Container(
        padding: AppStyles.cardPadding,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.card(),
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Avatar(name: appointment.doctorName, radius: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: textTheme.titleMedium,
                      ),
                      _specialtyOf(appointment),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const DashedDivider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              DateFormat('EEE d MMM', language).format(start),
              style: textTheme.titleLarge?.copyWith(fontWeight: .w600),
            ),
            Text(
              DateFormat('h:mm a', language).format(start),
              style: AppStyles.numericLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                AssetIcon(
                  Assets.icons.locationIcon,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    appointment.facilityName,
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            NoticeCard(
              variant: .neutral,
              icon: Assets.icons.infoIcon,
              body: l10n.bookedBring,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      TabibuButton.primary(
        label: l10n.bookedViewAppointment,
        onTap: () => PatientAppointmentRoute(
          appointmentUid: appointment.uid,
        ).pushReplacement(context),
      ),
      const SizedBox(height: AppSpacing.xs),
      TabibuButton.ghost(
        label: l10n.bookedBackHome,
        onTap: () => const PatientHomeRoute().go(context),
      ),
    ];
  }

  /// The booked doctor's specialty from the directory, or nothing when the
  /// directory doesn't have them.
  Widget _specialtyOf(AppointmentModel appointment) {
    final directory = context.watch<DirectoryBloc>().state;
    final raw = directory.all
        .firstWhereOrNull((d) => d.uid == appointment.doctorUid)
        ?.specialties
        .firstOrNull;
    if (raw == null || raw.isEmpty) return const SizedBox.shrink();
    return Text(
      Specialty.fromValue(raw)?.description(context.l10n) ?? raw,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
