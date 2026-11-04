import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// One patient the doctor may order for, on the visit the order hangs off.
typedef OrderablePatient = ({
  String patientId,
  String patientName,
  AppointmentModel appointment,
});

/// The doctor's orderable patients from visits already on the device: one
/// row per `patientId` with an Accepted or Completed visit of this doctor's.
/// Each row hangs off the visit under way where there is one, else the
/// latest; rows sort most recent first. Pure, so the screen owns no query.
List<OrderablePatient> patientsForOrdering({
  required List<AppointmentModel> appointments,
  required String doctorUid,
  required DateTime now,
}) {
  final byPatient = <String, List<AppointmentModel>>{};
  for (final appointment in appointments) {
    if (appointment.uid.isEmpty ||
        appointment.patientId.isEmpty ||
        appointment.doctorUid != doctorUid) {
      continue;
    }
    if (appointment.statusValue != .accepted &&
        appointment.statusValue != .completed) {
      continue;
    }
    (byPatient[appointment.patientId] ??= []).add(appointment);
  }
  DateTime? startOf(AppointmentModel a) => DateTime.tryParse(a.scheduledStart);
  bool underWay(AppointmentModel a) {
    final start = startOf(a);
    final end = DateTime.tryParse(a.scheduledEnd);
    if (start == null || end == null || start.isAfter(now)) return false;
    return !end.isBefore(now);
  }

  int byStartDesc(AppointmentModel a, AppointmentModel b) {
    final sa = startOf(a);
    final sb = startOf(b);
    if (sa == null) return sb == null ? 0 : 1;
    if (sb == null) return -1;
    return sb.compareTo(sa);
  }

  final rows = <OrderablePatient>[];
  for (final entry in byPatient.entries) {
    final visits = entry.value..sort(byStartDesc);
    final current = visits.where(underWay).toList()
      ..sort((a, b) => startOf(a)!.compareTo(startOf(b)!));
    final chosen = current.isNotEmpty ? current.first : visits.first;
    rows.add((
      patientId: entry.key,
      patientName: chosen.patientName,
      appointment: chosen,
    ));
  }
  rows.sort((a, b) {
    final byDate = byStartDesc(a.appointment, b.appointment);
    return byDate != 0 ? byDate : a.patientName.compareTo(b.patientName);
  });
  return rows;
}

/// The wizard's first step on the home "+" path: pick which patient the
/// order is for. The visits come from the screen; nothing here reads a
/// cache or the cloud.
class OrderPatientStep extends StatefulWidget {
  const OrderPatientStep({
    required this.appointments,
    required this.doctorUid,
    required this.now,
    required this.selectedAppointmentUid,
    required this.onPick,
    super.key,
  });

  final List<AppointmentModel> appointments;
  final String doctorUid;
  final DateTime now;
  final String selectedAppointmentUid;
  final ValueChanged<AppointmentModel> onPick;

  @override
  State<OrderPatientStep> createState() => _OrderPatientStepState();
}

class _OrderPatientStepState extends State<OrderPatientStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final all = patientsForOrdering(
      appointments: widget.appointments,
      doctorUid: widget.doctorUid,
      now: widget.now,
    );
    final needle = foldForSearch(_query.trim());
    final rows = needle.isEmpty
        ? all
        : all
              .where((row) => foldForSearch(row.patientName).contains(needle))
              .toList();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      keyboardDismissBehavior: .onDrag,
      children: [
        SectionHeader(title: l10n.orderPatientTitle),
        const SizedBox(height: AppSpacing.xs),
        SearchField(
          hint: l10n.orderPatientSearchHint,
          clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (all.isEmpty)
          EmptyState(
            title: l10n.orderPatientEmptyTitle,
            body: l10n.orderPatientEmptyBody,
          )
        else
          for (final row in rows) ...[
            OptionCard(
              key: ValueKey(row.patientId),
              title: row.patientName,
              supporting: _visitDate(row.appointment, language),
              leading: Avatar(name: row.patientName, radius: 22),
              selected: widget.selectedAppointmentUid == row.appointment.uid,
              onTap: () => widget.onPick(row.appointment),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }

  String? _visitDate(AppointmentModel appointment, String language) {
    final at = nairobiTimeOf(appointment.scheduledStart);
    if (at == null) return null;
    return DateFormat('EEE d MMM', language).format(at);
  }
}
