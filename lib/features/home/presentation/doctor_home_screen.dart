import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/home_tab_screen.dart';

/// D-HOME. Shows the shell's current tab until its bundle builds the screen.
class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeTabScreen(role: .doctor);
}
