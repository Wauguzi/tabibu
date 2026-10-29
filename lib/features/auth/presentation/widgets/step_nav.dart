import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Steps move with `go`, so the stack holds one entry; E4's Edit links
/// `push`, so the step below is the review. Back pops in the pushed case and
/// otherwise goes to the previous step explicitly.
void stepBack(BuildContext context, GoRouteData previous) {
  if (context.canPop()) {
    context.pop();
  } else {
    previous.go(context);
  }
}

/// After committing, a pushed step (opened from Edit) pops back to the
/// review; a stepped-to screen moves forward.
bool shouldPopAfterCommit(BuildContext context) => context.canPop();
