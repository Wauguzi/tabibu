import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/home_tab_screen.dart';

/// P-01. Shows the shell's current tab until its bundle builds the screen.
class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeTabScreen(role: .patient);
}
