import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_demo_banner.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_draft_card.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-ALERT-SENT. What the approver approved: the approved text, the area
/// and when. It replaces the review (F-1), so system back goes to the
/// doctor home. The text is approved, not a draft, so it sits in no AI
/// frame; a demo alert says so (H-10).
class AlertSentScreen extends StatefulWidget {
  const AlertSentScreen({required this.alertUid, super.key});

  final String alertUid;

  @override
  State<AlertSentScreen> createState() => _AlertSentScreenState();
}

class _AlertSentScreenState extends State<AlertSentScreen> {
  late final bool _canApprove;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _canApprove =
        session is PractitionerSession && session.roles.canApproveAlerts;
    final bloc = context.read<AlertReviewBloc>();
    if (_canApprove && bloc.state.current?.uid != widget.alertUid) {
      bloc.add(AlertReviewOpened(alertUid: widget.alertUid));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canApprove) return const SizedBox.shrink();
    final l10n = context.l10n;
    final state = context.watch<AlertReviewBloc>().state;
    final alert = state.current?.uid == widget.alertUid ? state.current : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) const DoctorHomeRoute().go(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: alert == null
              ? LoadingView(semanticLabel: l10n.alertReviewSentTitle)
              : Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Expanded(child: _Sent(alert: alert)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenMargin,
                        AppSpacing.sm,
                        AppSpacing.screenMargin,
                        AppSpacing.md,
                      ),
                      child: TabibuButton.primary(
                        label: l10n.alertReviewBackToToday,
                        onTap: () => const DoctorHomeRoute().go(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Sent extends StatelessWidget {
  const _Sent({required this.alert});

  final AlertModel alert;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final language = Localizations.localeOf(context).languageCode;
    final decidedAt = nairobiTimeOf(alert.decidedAt);
    final when = decidedAt == null
        ? ''
        : DateFormat('d MMM, h:mm a', language).format(decidedAt);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.xxlg,
        AppSpacing.screenMargin,
        AppSpacing.md,
      ),
      children: [
        Center(
          child: IconTile(icon: Assets.icons.shieldIcon, tone: .mint, size: .l),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.alertReviewApprovedSent,
          style: textTheme.displaySmall,
          textAlign: .center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.alertReviewSentBody,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: .center,
        ),
        if (alert.synthetic) ...[
          const SizedBox(height: AppSpacing.lg),
          const AlertDemoBanner(),
        ],
        const SizedBox(height: AppSpacing.lg),
        _SentText(alert: alert, language: language, when: when),
      ],
    );
  }
}

/// The approved text of each audience, in the approver's language, with the
/// area and the time it went out.
class _SentText extends StatelessWidget {
  const _SentText({
    required this.alert,
    required this.language,
    required this.when,
  });

  final AlertModel alert;
  final String language;
  final String when;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final prefix = l10n.alertReviewDemoPrefix;
    final shown = alert.approvedText.containsKey('patient_$language')
        ? language
        : 'en';
    final keys = [
      for (final clinician in [true, false])
        if (alert.approvedText.containsKey(
          alertDraftKey(clinician: clinician, language: shown),
        ))
          alertDraftKey(clinician: clinician, language: shown),
    ];
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.alertReviewSentTitle, style: textTheme.titleMedium),
          if (when.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.healthNoticePublished(when, alert.countyName),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          for (final key in keys) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              alertDraftAudience(l10n, key, alert.countyName),
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              // The server prefixes a demo alert's text itself; add the
              // prefix only where an edit has removed it.
              alert.synthetic &&
                      !alert.approvedText[key]!.headline.startsWith(prefix)
                  ? '$prefix ${alert.approvedText[key]!.headline}'
                  : alert.approvedText[key]!.headline,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(alert.approvedText[key]!.body, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
