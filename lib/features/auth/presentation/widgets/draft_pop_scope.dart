import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

/// Commits a step's fields to the draft on back, because the next Continue
/// pushes a fresh copy of the step that reads only the draft.
class DraftPopScope extends StatelessWidget {
  const DraftPopScope({
    required this.fill,
    required this.child,
    this.canPop = true,
    super.key,
  });

  final SignUpDraft Function(SignUpDraft draft) fill;
  final bool canPop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        final bloc = context.read<SignUpBloc>();
        // Cleared after sign-up or sign-out: the steps leaving the stack
        // must not write it back.
        if (bloc.state.draft.role == null) return;
        bloc.add(SignUpDraftUpdated(draft: fill(bloc.state.draft)));
      },
      child: child,
    );
  }
}
