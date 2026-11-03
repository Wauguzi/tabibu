import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A search field that only opens the desk's search: it never takes focus, so
/// the keyboard stays down until the person is on the search screen.
class DeskSearchEntry extends StatelessWidget {
  const DeskSearchEntry({required this.hint, required this.onTap, super.key});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: Tappable(
        onTap: onTap,
        child: IgnorePointer(
          child: SearchField(
            hint: hint,
            clearLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
          ),
        ),
      ),
    );
  }
}
