import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/home/presentation/title_tab_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// PA-06. Shows the shell's current tab until its bundle builds the screen.
class SignedScreen extends StatelessWidget {
  const SignedScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TitleTabScreen(role: .pathologist, title: context.l10n.signedTitle);
}
