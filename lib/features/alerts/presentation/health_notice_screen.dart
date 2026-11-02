import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-12. A back button only, until its bundle builds the screen.
class HealthNoticeScreen extends StatelessWidget {
  const HealthNoticeScreen({required this.alertUid, super.key});

  final String alertUid;

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
