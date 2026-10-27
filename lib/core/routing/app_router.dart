import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';

/// The one router (architecture §8). Built once with the [AuthBloc] above
/// it; the guard runs again whenever the session changes, so signing out
/// moves anyone on a role route back through the decision route.
abstract final class TabibuRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey(
    debugLabel: 'root',
  );

  static GoRouter create(AuthBloc authBloc) => GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: const DecisionRoute().location,
    routes: $appRoutes,
    refreshListenable: _SessionChanges(authBloc),
    redirect: (context, state) => guardLocation(
      location: state.uri.toString(),
      session: authBloc.state.session,
    ),
    errorBuilder: (context, state) =>
        const DecisionRoute().build(context, state),
  );
}

class _SessionChanges extends ChangeNotifier {
  _SessionChanges(AuthBloc bloc) {
    _subscription = bloc.stream
        .map((state) => state.session)
        .distinct()
        .listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthSession> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
