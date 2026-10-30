import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A6. Onboarding is already marked done (the intro did it); both actions
/// push. No popping back into the intro: this is the point of no return.
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          // Full width, however narrow its pills.
                          SizedBox(
                            width: double.infinity,
                            child: PatternCard(
                              // Fixed gaps, not a spacer: the card wraps its
                              // content, so flex has no bound to fill.
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  ExcludeSemantics(
                                    child: Assets.icons.logoTransparentWhite
                                        .svg(width: 148),
                                  ),
                                  const SizedBox(height: 72),
                                  _HeroPill(
                                    icon: Assets.icons.verificationBadge,
                                    label: l10n.getStartedBadge1,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  // The two results pills end on one edge; the
                                  // second starts a step in from the first.
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: AppSpacing.md,
                                    ),
                                    child: IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment: .end,
                                        children: [
                                          _HeroPill(
                                            icon: Assets.icons.languageIcon,
                                            label: l10n.getStartedBadge2,
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          _HeroPill(
                                            icon:
                                                Assets.icons.checkSelectedIcon,
                                            label: l10n.getStartedBadge3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                            onTap: () {
                              // A draft left on a shared phone is not this
                              // person's.
                              context.read<SignUpBloc>().add(
                                const SignUpDraftCleared(),
                              );
                              unawaited(
                                const SignUpRoleRoute().push<void>(context),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TabibuButton.secondary(
                            label: l10n.getStartedSignIn,
                            onTap: () =>
                                const SignInRoute().push<void>(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: Text(
                              l10n.getStartedTerms,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              textAlign: .center,
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
        mainAxisSize: .min,
        children: [
          AssetIcon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(label, style: textTheme.titleSmall)),
        ],
      ),
    );
  }
}
