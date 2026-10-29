import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// The forced-update blocker: no back, no dismiss. Title and message come
/// from Remote Config when set, otherwise from ARB. The store button hides
/// when no store URL is configured, and on the web, where there is no store.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  Future<void> _openStore(BuildContext context) async {
    final l10n = context.l10n;
    // defaultTargetPlatform, not Platform: dart:io throws on the web.
    final url = getIt<AppUpdateService>().storeUrl(
      isIos: defaultTargetPlatform == .iOS,
    );
    if (url == null) return;
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _storeFailed(context, l10n);
      }
    } on Object catch (_) {
      if (!context.mounted) return;
      _storeFailed(context, l10n);
    }
  }

  void _storeFailed(BuildContext context, AppLocalizations l10n) {
    unawaited(
      showTabibuNotification(
        context,
        message: l10n.updateStoreUnavailable,
        isError: true,
        dismissLabel: l10n.commonDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final updates = getIt<AppUpdateService>();
    final title = updates.remoteText('update_title', l10n.updateTitle);
    final message = updates.remoteText('update_message', l10n.updateMessage);
    final storeUrl = kIsWeb
        ? null
        : updates.storeUrl(isIos: defaultTargetPlatform == .iOS);

    return PopScope(
      canPop: false,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconTile(
                          icon: Assets.icons.shieldIcon,
                          tone: IconTone.sky,
                          size: IconTileSize.l,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          title,
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          message,
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (storeUrl != null)
                          TabibuButton.primary(
                            label: l10n.updateButton,
                            onTap: () => _openStore(context),
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
