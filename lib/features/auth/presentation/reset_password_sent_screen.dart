import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// B5. The link is on its way; the copy names no address, because success
/// also covers addresses with no account.
class ResetPasswordSentScreen extends StatelessWidget {
  const ResetPasswordSentScreen({super.key});

  Future<void> _openMail(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final opened = await launchUrl(Uri(scheme: 'mailto', path: ''));
      if (!opened && context.mounted) _mailFailed(context, l10n);
    } on Object catch (_) {
      if (!context.mounted) return;
      _mailFailed(context, l10n);
    }
  }

  void _mailFailed(BuildContext context, AppLocalizations l10n) {
    unawaited(
      showTabibuNotification(
        context,
        message: l10n.resetSentMailFailed,
        isError: true,
        dismissLabel: l10n.commonDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: AppShadows.card(),
                              ),
                              child: Center(
                                child: AssetIcon(
                                  Assets.icons.emailIcon,
                                  size: 56,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: AssetIcon(
                                Assets.icons.checkSelectedIcon,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.resetSentTitle,
                        style: textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.resetSentBody,
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NoticeCard(
                        variant: NoticeVariant.info,
                        icon: Assets.icons.infoIcon,
                        body: l10n.resetSentHint,
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.md),
                      TabibuButton.primary(
                        label: l10n.resetSentOpenApp,
                        onTap: () => _openMail(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TabibuButton.ghost(
                        label: l10n.resetSentBackToSignIn,
                        foregroundColor: scheme.primary,
                        onTap: () => const SignInRoute().go(context),
                      ),
                    ],
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
