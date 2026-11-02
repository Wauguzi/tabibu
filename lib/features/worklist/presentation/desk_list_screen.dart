import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/l10n/l10n.dart';

/// PA-02. A back button only, until its bundle builds the screen.
class DeskListScreen extends StatelessWidget {
  const DeskListScreen({required this.filter, super.key});

  final DeskFilter filter;

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
