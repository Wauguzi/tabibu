import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/core/widgets/logo_cells.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A1. Resolves the session, then sends the person on (architecture §8). The
/// order of the checks is [resolveLanding]'s; this only maps it to a route.
///
/// The look is the brand moment the native splash hands off to: the same
/// teal, the same wordmark centered, the tagline beneath it, and the
/// scattered logo cells faint at the bottom. Identical in both themes.
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
    // The native splash launches full screen; every screen after A1 has bars.
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        .manual,
        overlays: SystemUiOverlay.values,
      ),
    );
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
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (_, current) =>
            current is SessionLoadSuccess || current is SessionLoadFailure,
        listener: (context, state) => _land(state),
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                colors: [AppColors.primaryLight, AppColors.tealHeroEndLight],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _SplashScatter()),
                ),
                Center(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      ExcludeSemantics(
                        child: Assets.icons.logoTransparentWhite.svg(
                          width: 180,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenMargin,
                        ),
                        child: Text(
                          l10n.splashTagline,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: .center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A1's bottom scatter: the same logo cells as the hero pattern, hand-placed
/// low and faint so the wordmark keeps the screen.
class _SplashScatter extends CustomPainter {
  const _SplashScatter();

  static final List<Path> _cells = [
    LogoCells.joinedPair(),
    LogoCells.drop(),
    LogoCells.dot(),
  ];

  // Fixed scatter: fraction offsets, width, rotation. Bottom-weighted, like
  // the design.
  static const _scatter = [
    (0.08, 0.66, 56.0, 0.4),
    (0.82, 0.64, 64.0, -0.5),
    (0.30, 0.72, 44.0, 0.9),
    (0.58, 0.70, 72.0, 0.2),
    (0.90, 0.78, 52.0, 1.1),
    (0.16, 0.82, 60.0, -0.3),
    (0.44, 0.84, 84.0, -0.7),
    (0.70, 0.88, 48.0, 0.5),
    (0.06, 0.93, 54.0, -1.0),
    (0.34, 0.94, 66.0, 0.6),
    (0.60, 0.95, 42.0, -0.2),
    (0.86, 0.94, 58.0, 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    for (var i = 0; i < _scatter.length; i++) {
      final (fx, fy, width, rotation) = _scatter[i];
      canvas
        ..save()
        ..translate(fx * size.width, fy * size.height)
        ..rotate(rotation)
        ..scale(width / 530)
        ..translate(-265, -256);
      for (final cell in _cells) {
        canvas.drawPath(cell, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashScatter oldDelegate) => false;
}
