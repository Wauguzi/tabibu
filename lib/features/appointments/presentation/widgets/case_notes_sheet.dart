import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The server's limit on a case's clinical notes.
const caseNotesMaxLength = 2000;

/// The doctor's notes sheet. It stays open while the save runs and pops `true`
/// only when the save landed (synced or queued offline), `false` when nothing
/// changed. A failure shows its notice over the sheet and keeps the text.
abstract final class CaseNotesSheet {
  static Future<bool?> show(
    BuildContext context, {
    required String caseUid,
    required String initialNotes,
  }) {
    // The sheet lives on the root navigator, below the screen's providers.
    final cases = context.read<CasesBloc>();
    return TabibuBottomSheet.show<bool>(
      context,
      title: context.l10n.doctorAppointmentNotes,
      builder: (_) => BlocProvider<CasesBloc>.value(
        value: cases,
        child: _NotesForm(caseUid: caseUid, initialNotes: initialNotes),
      ),
    );
  }
}

class _NotesForm extends StatefulWidget {
  const _NotesForm({required this.caseUid, required this.initialNotes});

  final String caseUid;
  final String initialNotes;

  @override
  State<_NotesForm> createState() => _NotesFormState();
}

class _NotesFormState extends State<_NotesForm> {
  late final TextEditingController _notes = TextEditingController(
    text: widget.initialNotes,
  );

  /// Set when this sheet sent a save, so another screen's write is not ours.
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final text = _notes.text.trim();
    // The bloc emits nothing for unchanged text, so the sheet closes itself.
    if (text == widget.initialNotes.trim()) {
      Navigator.of(context).pop(false);
      return;
    }
    _saving = true;
    context.read<CasesBloc>().add(
      CaseNotesSaveRequested(caseUid: widget.caseUid, clinicalNotes: text),
    );
  }

  void _onState(BuildContext context, CasesState state) {
    if (!_saving) return;
    switch (state) {
      case CaseNotesSaveSuccess():
        _saving = false;
        Navigator.of(context).pop(true);
      case CaseWriteFailure():
        _saving = false;
        unawaited(
          showTabibuNotification(
            context,
            message: context.l10n.doctorAppointmentNotesFailed,
            isError: true,
            dismissLabel: context.l10n.commonDismiss,
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = context.watch<CasesBloc>().state is CaseWriteInProgress;
    return BlocListener<CasesBloc, CasesState>(
      listener: _onState,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          TabibuTextField(
            label: l10n.doctorAppointmentNotesFieldLabel,
            hint: l10n.doctorAppointmentNotesHint,
            controller: _notes,
            maxLines: 8,
            maxLength: caseNotesMaxLength,
            keyboardType: .multiline,
          ),
          const SizedBox(height: AppSpacing.md),
          TabibuButton.primary(
            label: l10n.doctorAppointmentNotesSave,
            isLoading: busy,
            onTap: busy ? null : _save,
          ),
        ],
      ),
    );
  }
}
