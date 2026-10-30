import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';

/// A role's middle tab: its title for now; the body comes with its screens.
class TitleTabScreen extends StatelessWidget {
  const TitleTabScreen({required this.role, required this.title, super.key});

  final Role role;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ShellTabPage(
      role: role,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.displaySmall),
        ),
      ],
    );
  }
}
