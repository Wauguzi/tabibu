import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A6. Both actions first mark onboarding done, then move on: creating an
/// account goes to role choice, signing in goes to B1.
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  GoRouteData? _destination;

  void _proceed(GoRouteData destination) {
    setState(() => _destination = destination);
    context.read<OnboardingBloc>().add(const OnboardingCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (_, state) =>
          state is OnboardingComplete || state is OnboardingFailure,
      listener: (context, state) {
        switch (state) {
          case OnboardingComplete():
            _destination?.go(context);
          case OnboardingFailure(:final error):
            unawaited(
              showTabibuNotification(
                context,
                message: error.description(l10n),
                isError: true,
                dismissLabel: l10n.commonDismiss,
              ),
            );
          default:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatternCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Assets.icons.logoTransparentWhite.svg(
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    l10n.appTitle.toLowerCase(),
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _HeroPill(
                                icon: Assets.icons.verificationBadge,
                                label: l10n.getStartedBadge1,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _HeroPill(
                                  icon: Assets.icons.languageIcon,
                                  label: l10n.getStartedBadge2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              _HeroPill(
                                icon: Assets.icons.checkSelectedIcon,
                                label: l10n.getStartedBadge3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.getStartedTitle,
                          style: textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.getStartedBody, style: textTheme.bodyLarge),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.md),
                        TabibuButton.primary(
                          label: l10n.getStartedCreateAccount,
                          onTap: () => _proceed(const SignUpRoleRoute()),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TabibuButton.secondary(
                          label: l10n.getStartedSignIn,
                          onTap: () => _proceed(const SignInRoute()),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: Text(
                            l10n.getStartedTerms,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final SvgGenImage icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetIcon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(label, style: textTheme.titleSmall)),
        ],
      ),
    );
  }
}
