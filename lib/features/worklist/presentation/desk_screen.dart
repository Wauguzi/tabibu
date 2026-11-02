import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/home_tab_screen.dart';

/// PA-01. Shows the shell's current tab until its bundle builds the screen.
class DeskScreen extends StatelessWidget {
  const DeskScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeTabScreen(role: .pathologist);
}
