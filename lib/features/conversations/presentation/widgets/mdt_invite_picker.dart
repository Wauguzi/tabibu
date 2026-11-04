import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The practitioners an invite can name: the public directory of verified
/// doctors and pathologists, which is the list the server checks every
/// invitee against. Never me, never someone already invited or in.
List<PractitionerModel> mdtInvitable(
  List<PractitionerModel> directory, {
  required String myUid,
  Set<String> excluded = const {},
}) {
  final rows = [
    for (final p in directory)
      if (p.uid.isNotEmpty && p.uid != myUid && !excluded.contains(p.uid)) p,
  ];
  return rows..sort((a, b) {
    final byLast = foldForSearch(
      a.lastName,
    ).compareTo(foldForSearch(b.lastName));
    if (byLast != 0) return byLast;
    return foldForSearch(a.firstName).compareTo(foldForSearch(b.firstName));
  });
}

/// A specialty a consult can be asked in: the practitioner's first one the
/// server knows.
Specialty? mdtSpecialtyOf(PractitionerModel practitioner) {
  for (final raw in practitioner.specialties) {
    final found = Specialty.fromValue(raw);
    if (found != null) return found;
  }
  return null;
}

/// Search and a multi-select list of invitable practitioners.
class MdtInvitePicker extends StatefulWidget {
  const MdtInvitePicker({
    required this.candidates,
    required this.selected,
    required this.onToggle,
    required this.limit,
    super.key,
  });

  final List<PractitionerModel> candidates;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  /// How many people can be chosen: the room the consult has left.
  final int limit;

  @override
  State<MdtInvitePicker> createState() => _MdtInvitePickerState();
}

class _MdtInvitePickerState extends State<MdtInvitePicker> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(PractitionerModel p, String needle) {
    if (needle.isEmpty) return true;
    if (foldForSearch(p.fullName).contains(needle)) return true;
    if (foldForSearch(p.facilityName).contains(needle)) return true;
    return p.specialties.any((s) => foldForSearch(s).contains(needle));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final needle = foldForSearch(_query.text);
    final rows = [
      for (final p in widget.candidates)
        if (_matches(p, needle)) p,
    ];
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SearchField(
          hint: l10n.mdtInviteSearch,
          clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
          controller: _query,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        if (rows.isEmpty && needle.isNotEmpty)
          EmptyState(
            title: l10n.findDoctorNoResultsTitle(_query.text.trim()),
            body: l10n.findDoctorNoResultsBody,
          )
        else
          for (final p in rows) ...[
            _Candidate(
              practitioner: p,
              selected: widget.selected.contains(p.uid),
              // A full list still lets a chosen person be taken off.
              onTap: widget.selected.contains(p.uid)
                  ? () => widget.onToggle(p.uid)
                  : widget.selected.length >= widget.limit
                  ? null
                  : () => widget.onToggle(p.uid),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _Candidate extends StatelessWidget {
  const _Candidate({
    required this.practitioner,
    required this.selected,
    required this.onTap,
  });

  final PractitionerModel practitioner;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final specialty = mdtSpecialtyLabel(
      practitioner.specialties.isEmpty ? '' : practitioner.specialties.first,
      l10n,
    );
    final facility = practitioner.facilityName;
    final supporting = specialty.isNotEmpty && facility.isNotEmpty
        ? l10n.mdtMemberSubtitle(facility, specialty)
        : specialty.isNotEmpty
        ? specialty
        : facility;
    return OptionCard(
      title: practitioner.fullName,
      supporting: supporting.isEmpty ? null : supporting,
      selected: selected,
      markLeading: true,
      onTap: onTap,
    );
  }
}
