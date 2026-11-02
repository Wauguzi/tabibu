import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// CS-01..CS-08. A back button only, until its bundle builds the screen.
class CaseWorkspaceScreen extends StatelessWidget {
  const CaseWorkspaceScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TopBar(backLabel: context.l10n.commonBack, onBack: context.pop),
      ),
    ),
  );
}
