import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_state.dart';
import 'package:tabibu/features/onboarding/presentation/book_slide.dart';
import 'package:tabibu/features/onboarding/presentation/case_slide.dart';
import 'package:tabibu/features/onboarding/presentation/results_slide.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A3–A5. Three swipeable slides, each with its wash; finishing (Skip or the
/// last slide's Get started) marks onboarding done first, then goes to A6 as
/// the new root.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == .dark;
    final isLast = _index == 2;
    final wash = switch (_index) {
      0 => isDark ? AppGradients.skyWashDark : AppGradients.skyWash,
      1 => isDark ? AppGradients.mintWashDark : AppGradients.mintWash,
      _ => isDark ? AppGradients.lavenderWashDark : AppGradients.lavenderWash,
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? .dark : .light,
        statusBarIconBrightness: isDark ? .light : .dark,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(gradient: wash),
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            switch (state) {
              case OnboardingComplete():
                const GetStartedRoute().go(context);
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
          builder: (context, state) {
            final busy = state is OnboardingInProgress;
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (index) =>
                              setState(() => _index = index),
                          children: const [
                            BookSlide(),
                            CaseSlide(),
                            ResultsSlide(),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PageDots(count: 3, index: _index),
                      const SizedBox(height: AppSpacing.md),
                      TabibuButton.primary(
                        label: isLast ? l10n.introGetStarted : l10n.commonNext,
                        isLoading: busy && isLast,
                        onTap: busy
                            ? null
                            : () {
                                if (isLast) {
                                  context.read<OnboardingBloc>().add(
                                    const OnboardingCompleted(),
                                  );
                                } else {
                                  _goTo(_index + 1);
                                }
                              },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TabibuButton.ghost(
                        label: isLast ? l10n.commonBack : l10n.commonSkip,
                        onTap: busy
                            ? null
                            : () {
                                if (isLast) {
                                  _goTo(_index - 1);
                                } else {
                                  context.read<OnboardingBloc>().add(
                                    const OnboardingCompleted(),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
