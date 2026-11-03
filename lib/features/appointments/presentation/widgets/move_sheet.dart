import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_picker.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// What the doctor chose on the move sheet: a proposed new start, a reason,
/// a note. A doctor cannot hold a booking, so the caller cancels with the
/// proposal as the note's first line and the patient rebooks.
typedef MoveChoice = ({DateTime start, String reason, String note});

/// The doctor's move: their own free times, move reasons, a note. Days come
/// from the signed-in doctor's own hours; busy times from their live
/// appointments.
abstract final class MoveSheet {
  /// [now] pins the planner's clock; tests pass a fixed morning, the app
  /// leaves it to the open instant, captured once so rebuilds agree.
  static Future<MoveChoice?> show(
    BuildContext context, {
    required AppointmentModel appointment,
    DateTime? now,
  }) {
    // The sheet lives on the root navigator, below the screen's providers.
    final auth = context.read<AuthBloc>();
    final appointments = context.read<AppointmentsBloc>();
    final pinned = now ?? DateTime.now();
    return TabibuBottomSheet.show<MoveChoice>(
      context,
      title: context.l10n.rescheduleTitle,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: auth),
          BlocProvider<AppointmentsBloc>.value(value: appointments),
        ],
        child: _MoveForm(appointment: appointment, now: pinned),
      ),
    );
  }
}

class _MoveForm extends StatefulWidget {
  const _MoveForm({required this.appointment, required this.now});

  final AppointmentModel appointment;
  final DateTime now;

  @override
  State<_MoveForm> createState() => _MoveFormState();
}

class _MoveFormState extends State<_MoveForm> {
  final _note = TextEditingController();
  PlannedSlot? _slot;
  String? _reason;
  bool _showNeedReason = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _send() {
    final slot = _slot;
    if (slot == null) return;
    if (_reason == null && _note.text.trim().isEmpty) {
      setState(() => _showNeedReason = true);
      return;
    }
    Navigator.of(context).pop<MoveChoice>((
      start: slot.start,
      reason: _reason ?? '',
      note: _note.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final start =
        nairobiTimeOf(widget.appointment.scheduledStart) ?? nairobiNow();
    final session = context.watch<AuthBloc>().state.session;
    final doctor = switch (session) {
      PractitionerSession(:final doctor) => doctor,
      _ => null,
    };
    final appointments = context
        .watch<AppointmentsBloc>()
        .state
        .appointments
        .where(
          (a) =>
              a.uid != widget.appointment.uid &&
              (a.statusValue == AppointmentStatus.accepted ||
                  a.statusValue == AppointmentStatus.requested),
        )
        .map((a) => a.scheduledStart)
        .toList();
    final days = doctor == null
        ? const <PlannedDay>[]
        : const SlotPlanner().days(
            PractitionerModel.empty().copyWith(
              workingDays: doctor.workingDays,
              dayStartMinute: doctor.dayStartMinute,
              dayEndMinute: doctor.dayEndMinute,
              busySlots: appointments,
            ),
            widget.now,
          );
    final reasons = [
      l10n.rescheduleReasonTheatre,
      l10n.rescheduleReasonAsked,
      l10n.rescheduleReasonClosed,
    ];
    final firstName =
        widget.appointment.patientName.split(' ').firstOrNull ?? '';
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(l10n.rescheduleNowDoctor(_when(language, start))),
        const SizedBox(height: AppSpacing.md),
        if (doctor == null)
          SizedBox(
            height: 200,
            child: LoadingView(
              semanticLabel: l10n.appointmentDetailLoadingLabel,
            ),
          )
        else
          SlotPicker(
            days: days,
            dayLabel: l10n.rescheduleNewDay,
            timeLabel: l10n.rescheduleFreeTimes,
            onPick: (picked) => setState(() => _slot = picked),
          ),
        const SizedBox(height: AppSpacing.md),
        for (final reason in reasons) ...[
          OptionCard(
            title: reason,
            selected: _reason == reason,
            onSheet: true,
            onTap: () => setState(() {
              _reason = _reason == reason ? null : reason;
              _showNeedReason = false;
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        OptionCard(
          title: l10n.cancelAppointmentReasonOther,
          selected: false,
          onSheet: true,
          onTap: () => setState(() => _reason = null),
        ),
        Text(l10n.cancelAppointmentOtherHint),
        const SizedBox(height: AppSpacing.sm),
        TabibuTextField(
          label: l10n.cancelAppointmentNote,
          hint: l10n.cancelAppointmentNoteHint,
          controller: _note,
          maxLines: 3,
          // As the cancel sheet: the composed note is reason + '\n' + note.
          maxLength: _reason == null
              ? cancelNoteMaxLength
              : cancelNoteMaxLength - _reason!.length - 1,
          keyboardType: .multiline,
          onChanged: (_) {
            if (_showNeedReason) setState(() => _showNeedReason = false);
          },
        ),
        if (_showNeedReason) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.cancelAppointmentNeedReason),
        ],
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .info,
          icon: Assets.icons.infoIcon,
          title: l10n.rescheduleCancelsCurrent,
          body: l10n.rescheduleNote,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.rescheduleMoveAndTell(firstName),
          onTap: _slot == null ? null : _send,
        ),
      ],
    );
  }

  String _when(String language, DateTime start) =>
      '${DateFormat('EEE d MMM', language).format(start)} · '
      '${DateFormat('h:mm a', language).format(start)}';
}
