import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/title_tab_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-CASES. Shows the shell's current tab until its bundle builds the screen.
class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TitleTabScreen(role: .doctor, title: context.l10n.casesTitle);
}
