import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A1. Resolves the session, then sends the person on (architecture §8). The
/// order of the checks is [resolveLanding]'s; this only maps it to a route.
class DecisionScreen extends StatefulWidget {
  const DecisionScreen({this.from, super.key});

  final String? from;

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  /// Started once, and awaited on every path, so an outdated build never
  /// races past the gate. A failed check lets the build through.
  late final Future<bool> _updateRequired = getIt<AppUpdateService>()
      .isUpdateRequired()
      .catchError((Object _) => false);

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const SessionRequested());
  }

  Future<void> _land(AuthState state) async {
    final updateRequired = await _updateRequired;
    final onboarding = await getIt<HiveHelper>().getCachedOnboarding();
    if (!mounted) return;
    final landing = resolveLanding(
      session: state.session,
      updateRequired: updateRequired,
      isOnboarded: onboarding?.isOnboarded ?? false,
    );
    final from = widget.from;
    if (landing != Landing.update &&
        from != null &&
        !from.startsWith(RoutePaths.decision) &&
        guardLocation(location: from, session: state.session) == null) {
      context.go(from);
      return;
    }
    routeForLanding(landing).go(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is SessionLoadSuccess || current is SessionLoadFailure,
      listener: (context, state) => _land(state),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.tabibuLogo.image(width: 96, height: 96),
              const SizedBox(height: 24),
              SpinKitPulse(color: scheme.onSurface, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
