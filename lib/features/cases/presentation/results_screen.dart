import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/title_tab_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-11. Shows the shell's current tab until its bundle builds the screen.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TitleTabScreen(role: .patient, title: context.l10n.resultsTitle);
}
