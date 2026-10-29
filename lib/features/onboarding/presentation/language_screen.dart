import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A2. The language cards switch the app at once; Continue moves to the
/// intro.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final current = AppLanguage.fromValue(
      Localizations.localeOf(context).languageCode,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) => state is LanguageChangeFailure,
      listener: (context, state) {
        final failure = state as LanguageChangeFailure;
        unawaited(
          showTabibuNotification(
            context,
            message: failure.error.description(l10n),
            isError: true,
            dismissLabel: l10n.commonDismiss,
          ),
        );
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
                        Text(l10n.languageTitle, style: textTheme.displaySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.languageSubtitle, style: textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.xlg),
                        OptionCard(
                          icon: Assets.icons.languageIcon,
                          tone: IconTone.sky,
                          title: l10n.languageEn,
                          supporting: l10n.languageEnglishSupporting,
                          selected: current == AppLanguage.en,
                          onTap: () => context.read<AuthBloc>().add(
                            const LanguageChangeRequested(
                              language: AppLanguage.en,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OptionCard(
                          icon: Assets.icons.languageIcon,
                          title: l10n.languageSw,
                          supporting: l10n.languageSwahiliSupporting,
                          selected: current == AppLanguage.sw,
                          onTap: () => context.read<AuthBloc>().add(
                            const LanguageChangeRequested(
                              language: AppLanguage.sw,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TabibuButton.primary(
                          label: l10n.commonContinue,
                          onTap: () => const IntroRoute().go(context),
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
