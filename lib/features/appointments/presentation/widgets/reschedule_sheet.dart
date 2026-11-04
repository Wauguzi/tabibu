import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_picker.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The new start the patient chose on the reschedule sheet.
typedef RescheduleChoice = ({DateTime start});

/// The patient's move: the booking flow's own picker prefilled with the same
/// doctor. Nothing is sent from here — the caller books first and cancels
/// only after the new time is held — but the sheet says plainly that moving
/// cancels the current time.
abstract final class RescheduleSheet {
  /// [now] pins the planner's clock; tests pass a fixed morning, the app
  /// leaves it to the open instant, captured once so rebuilds agree.
  static Future<RescheduleChoice?> show(
    BuildContext context, {
    required AppointmentModel appointment,
    DateTime? now,
  }) {
    // The sheet lives on the root navigator, below the screen's providers.
    final directory = context.read<DirectoryBloc>();
    final pinned = now ?? DateTime.now();
    return TabibuBottomSheet.show<RescheduleChoice>(
      context,
      title: context.l10n.rescheduleTitle,
      builder: (_) => BlocProvider<DirectoryBloc>.value(
        value: directory,
        child: _RescheduleForm(appointment: appointment, now: pinned),
      ),
    );
  }
}

class _RescheduleForm extends StatefulWidget {
  const _RescheduleForm({required this.appointment, required this.now});

  final AppointmentModel appointment;
  final DateTime now;

  @override
  State<_RescheduleForm> createState() => _RescheduleFormState();
}

class _RescheduleFormState extends State<_RescheduleForm> {
  PlannedSlot? _slot;

  @override
  void initState() {
    super.initState();
    if (context.read<DirectoryBloc>().state is DirectoryInitial) {
      context.read<DirectoryBloc>().add(const DirectoryRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final start =
        nairobiTimeOf(widget.appointment.scheduledStart) ?? nairobiNow();
    final doctor = context.watch<DirectoryBloc>().state.all.firstWhereOrNull(
      (d) => d.uid == widget.appointment.doctorUid,
    );
    final days = doctor == null
        ? const <PlannedDay>[]
        : const SlotPlanner().days(doctor, widget.now);
    final slot = _slot;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          l10n.rescheduleNow(
            _when(language, start),
            widget.appointment.doctorName,
          ),
        ),
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
            timeLabel: l10n.rescheduleNewTime,
            onPick: (picked) => setState(() => _slot = picked),
          ),
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .info,
          icon: Assets.icons.infoIcon,
          title: l10n.rescheduleCancelsCurrent,
          body: l10n.rescheduleNote,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: slot == null
              ? l10n.rescheduleButton
              : l10n.rescheduleMoveTo(_when(language, nairobiNow(slot.start))),
          onTap: slot == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop<RescheduleChoice>((start: slot.start)),
        ),
      ],
    );
  }

  String _when(String language, DateTime start) =>
      '${DateFormat('EEE d MMM', language).format(start)} · '
      '${DateFormat('h:mm a', language).format(start)}';
}
