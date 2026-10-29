import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A role tab's page: the role's wash behind a scrolling column. The shell
/// extends its body under the floating menu and adds the menu's height to
/// the bottom padding, so the last row scrolls clear of it.
class ShellTabPage extends StatelessWidget {
  const ShellTabPage({required this.role, required this.children, super.key});

  final Role role;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.md,
          AppSpacing.screenMargin,
          MediaQuery.paddingOf(context).bottom + AppSpacing.md,
        ),
        children: children,
      ),
    );
    return Scaffold(
      body: switch (role) {
        .patient => RoleBackground.patient(child: content),
        .doctor => RoleBackground.doctor(child: content),
        .pathologist => RoleBackground.pathologist(child: content),
      },
    );
  }
}
