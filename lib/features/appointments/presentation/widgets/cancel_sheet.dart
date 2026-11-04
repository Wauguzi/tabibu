import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// What the canceller chose on the cancel sheet: a quick reason, a note,
/// or both. The server takes one free-text note; the bloc joins them.
typedef CancelChoice = ({String reason, String note});

/// The cancel sheet: the appointment, quick reasons, an optional note. The
/// reasons are the client's own — the server takes only the composed note.
/// A slot that already started shows why it can't be cancelled instead.
abstract final class CancelSheet {
  static Future<CancelChoice?> show(
    BuildContext context, {
    required AppointmentModel appointment,
    required bool isDoctor,
  }) => TabibuBottomSheet.show<CancelChoice>(
    context,
    title: isDoctor
        ? context.l10n.cancelAppointmentTitleDoctor(
            appointment.patientName.split(' ').first,
          )
        : context.l10n.cancelAppointmentTitle,
    builder: (_) => _CancelForm(appointment: appointment, isDoctor: isDoctor),
  );
}

class _CancelForm extends StatefulWidget {
  const _CancelForm({required this.appointment, required this.isDoctor});

  final AppointmentModel appointment;
  final bool isDoctor;

  @override
  State<_CancelForm> createState() => _CancelFormState();
}

class _CancelFormState extends State<_CancelForm> {
  final _note = TextEditingController();
  String? _reason;
  bool _showNeedReason = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _send() {
    if (widget.isDoctor && _reason == null && _note.text.trim().isEmpty) {
      setState(() => _showNeedReason = true);
      return;
    }
    Navigator.of(
      context,
    ).pop<CancelChoice>((reason: _reason ?? '', note: _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final start =
        nairobiTimeOf(widget.appointment.scheduledStart) ?? nairobiNow();
    if (!start.isAfter(nairobiNow())) {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(l10n.cancelAppointmentTooLate),
          const SizedBox(height: AppSpacing.md),
          TabibuButton.primary(
            label: l10n.commonBack,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    final reasons = widget.isDoctor
        ? [
            l10n.cancelAppointmentReasonEmergency,
            l10n.cancelAppointmentReasonSpecialist,
          ]
        : [
            l10n.cancelAppointmentReasonDay,
            l10n.cancelAppointmentReasonBetter,
            l10n.cancelAppointmentReasonElsewhere,
          ];
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          widget.isDoctor
              ? l10n.cancelAppointmentBodyDoctor(
                  _when(language, start),
                  widget.appointment.patientName.split(' ').first,
                )
              : widget.appointment.typeValue == .caseDiscussion
              ? l10n.cancelAppointmentBodyResults(
                  _when(language, start),
                  widget.appointment.doctorName,
                )
              : l10n.cancelAppointmentBody(
                  _when(language, start),
                  widget.appointment.doctorName,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.cancelAppointmentWhy),
        const SizedBox(height: AppSpacing.sm),
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
          // The composed note is reason + '\n' + note; lengths are UTF-16
          // units, which overcount the server's code points, so this cap
          // always fits.
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
        TabibuButton.primary(
          label: l10n.cancelAppointmentConfirm,
          onTap: _send,
        ),
      ],
    );
  }

  String _when(String language, DateTime start) =>
      '${DateFormat('EEE d MMM', language).format(start)} · '
      '${DateFormat('h:mm a', language).format(start)}';
}
