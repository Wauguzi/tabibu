import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A searchable single-select list in a bottom sheet (county, title). Tapping
/// a row pops with it; dismissing pops null.
Future<T?> showSingleSelectSheet<T extends Object>({
  required BuildContext context,
  required String title,
  required String searchHint,
  required List<T> items,
  required String Function(T item) label,
  required T? selected,
}) => TabibuBottomSheet.show<T>(
  context,
  title: title,
  builder: (context) => _SingleSelectBody<T>(
    searchHint: searchHint,
    items: items,
    label: label,
    selected: selected,
  ),
);

class _SingleSelectBody<T extends Object> extends StatefulWidget {
  const _SingleSelectBody({
    required this.searchHint,
    required this.items,
    required this.label,
    required this.selected,
  });

  final String searchHint;
  final List<T> items;
  final String Function(T item) label;
  final T? selected;

  @override
  State<_SingleSelectBody<T>> createState() => _SingleSelectBodyState<T>();
}

class _SingleSelectBodyState<T extends Object>
    extends State<_SingleSelectBody<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final matches = [
      for (final item in widget.items)
        if (q.isEmpty || widget.label(item).toLowerCase().contains(q)) item,
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchField(
            hint: widget.searchHint,
            clearLabel: l10n.deleteButtonTooltip,
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
                final item = matches[index];
                return OptionCard(
                  title: widget.label(item),
                  selected: item == widget.selected,
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
