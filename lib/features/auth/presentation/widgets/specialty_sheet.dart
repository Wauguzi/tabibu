import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E2's specialty and F2's area picker: a searchable multi-select sheet with
/// a Done button. Doctors stop at five; pathologists may take all five
/// areas. Dismissing pops null and keeps the old selection.
Future<List<Specialty>?> showSpecialtySheet({
  required BuildContext context,
  required String title,
  required String Function(int count) subtitle,
  required String searchHint,
  required String Function(int count) doneLabel,
  required List<Specialty> initial,
  required List<Specialty> allowed,
}) => TabibuBottomSheet.show<List<Specialty>>(
  context,
  title: title,
  builder: (context) => _SpecialtyBody(
    subtitle: subtitle,
    searchHint: searchHint,
    doneLabel: doneLabel,
    initial: initial,
    allowed: allowed,
  ),
);

class _SpecialtyBody extends StatefulWidget {
  const _SpecialtyBody({
    required this.subtitle,
    required this.searchHint,
    required this.doneLabel,
    required this.initial,
    required this.allowed,
  });

  final String Function(int count) subtitle;
  final String searchHint;
  final String Function(int count) doneLabel;
  final List<Specialty> initial;
  final List<Specialty> allowed;

  @override
  State<_SpecialtyBody> createState() => _SpecialtyBodyState();
}

class _SpecialtyBodyState extends State<_SpecialtyBody> {
  final _searchController = TextEditingController();
  late final List<Specialty> _selected = List.of(widget.initial);
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(Specialty specialty) {
    setState(() {
      if (_selected.contains(specialty)) {
        _selected.remove(specialty);
      } else if (_selected.length < Specialty.maxSelected) {
        _selected.add(specialty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final material = MaterialLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final matches = [
      for (final specialty in widget.allowed)
        if (q.isEmpty || specialty.description(l10n).toLowerCase().contains(q))
          specialty,
    ];

    final capped = _selected.length >= Specialty.maxSelected;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.subtitle(_selected.length), style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          SearchField(
            hint: widget.searchHint,
            clearLabel: material.deleteButtonTooltip,
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: matches.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final specialty = matches[index];
                final selected = _selected.contains(specialty);
                return OptionCard(
                  onSheet: true,
                  title: specialty.description(l10n),
                  supporting: specialty.hint(l10n),
                  selected: selected,
                  markLeading: true,
                  onTap: !selected && capped ? null : () => _toggle(specialty),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TabibuButton.primary(
            label: widget.doneLabel(_selected.length),
            onTap: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
    );
  }
}
