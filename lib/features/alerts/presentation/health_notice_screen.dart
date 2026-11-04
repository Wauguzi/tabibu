import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/source_link.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// P-12. A released health notice: the approved headline, the Ministry
/// guidance verbatim, and the O-1 attribution. Hotline numbers come only
/// from the guidance asset, inside verbatim bullets.
class HealthNoticeScreen extends StatefulWidget {
  const HealthNoticeScreen({required this.alertUid, super.key});

  final String alertUid;

  @override
  State<HealthNoticeScreen> createState() => _HealthNoticeScreenState();
}

class _HealthNoticeScreenState extends State<HealthNoticeScreen> {
  late final Future<List<PublicHealthGuidanceModel>> _guidance =
      getIt<ReferenceDataHelper>().publicHealthGuidance();
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    _markIfShown(context.read<PublicAlertsBloc>().state);
  }

  void _markIfShown(PublicAlertsState state) {
    if (_marked) return;
    if (state.alerts.any((a) => a.uid == widget.alertUid)) {
      _marked = true;
      context.read<PublicAlertsBloc>().add(
        PublicAlertReadRequested(alertUid: widget.alertUid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PublicAlertsBloc, PublicAlertsState>(
          listenWhen: (_, next) =>
              next.alerts.any((a) => a.uid == widget.alertUid),
          listener: (context, state) => _markIfShown(state),
          child: _Body(alertUid: widget.alertUid, guidance: _guidance),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.alertUid, required this.guidance});

  final String alertUid;
  final Future<List<PublicHealthGuidanceModel>> guidance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PublicAlertsBloc>().state;
    final alert = state.alerts.firstWhereOrNull((a) => a.uid == alertUid);
    final loading =
        (state is PublicAlertsInitial || state is PublicAlertsLoadInProgress) &&
        state.alerts.isEmpty;

    if (loading || alert == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TopBar(backLabel: l10n.commonBack, onBack: context.pop),
          ),
          if (loading)
            Expanded(
              child: LoadingView(semanticLabel: l10n.notificationsLoadingLabel),
            )
          else
            Expanded(child: EmptyState(title: l10n.errorDataNotFound)),
        ],
      );
    }

    final language = Localizations.localeOf(context).languageCode;
    final text = alert.patientText[language] ?? alert.patientText['en'];
    final headline = text?.headline ?? '';
    final issued = nairobiTimeOf(alert.issuedAt);
    final date = issued == null
        ? ''
        : DateFormat('d MMM', language).format(issued);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TopBar(backLabel: l10n.commonBack, onBack: context.pop),
        if (alert.synthetic) ...[
          const SizedBox(height: AppSpacing.md),
          _DemoBanner(),
        ],
        const SizedBox(height: AppSpacing.md),
        _NoticeChip(county: alert.countyName),
        const SizedBox(height: AppSpacing.sm),
        Text(
          alert.synthetic
              ? '${l10n.alertReviewDemoPrefix} $headline'
              : headline,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.healthNoticePublished(date, alert.countyName),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Guidance(alert: alert, guidance: guidance, date: date),
      ],
    );
  }
}

class _Guidance extends StatelessWidget {
  const _Guidance({
    required this.alert,
    required this.guidance,
    required this.date,
  });

  final PublicAlertModel alert;
  final Future<List<PublicHealthGuidanceModel>> guidance;
  final String date;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final swahili = language == 'sw';
    return FutureBuilder<List<PublicHealthGuidanceModel>>(
      future: guidance,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <PublicHealthGuidanceModel>[];
        final row = rows.firstWhereOrNull(
          (r) => r.diseaseId == alert.diseaseId,
        );
        final assetBullets =
            row?.bullets.where((b) => b.audienceValue == .patient).toList() ??
            const <GuidanceBulletModel>[];
        // The asset's patient bullets; the alert's own when the asset has
        // no row for a new disease. Either way verbatim, patient-only.
        final useAsset = assetBullets.isNotEmpty;
        final bullets = useAsset
            ? assetBullets
            : alert.patientGuidance
                  .where((b) => b.audienceValue == .patient)
                  .toList();
        final pool = useAsset
            ? row?.sources ?? const <GuidanceSourceModel>[]
            : alert.sources;
        final byId = {for (final s in pool) s.sourceId: s};
        final sources = [
          for (final id in {...bullets.map((b) => b.sourceId)})
            if (byId[id] != null) byId[id]!,
        ];
        final first = sources.firstOrNull;
        final readUri = first == null ? null : Uri.tryParse(first.url);
        final l10n = context.l10n;

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            if (bullets.isNotEmpty) ...[
              ChecklistCard(
                title: l10n.healthNoticeMohAdvises,
                items: [
                  for (final b in bullets)
                    if (swahili) b.textSw else b.textEn,
                ],
              ),
              if (swahili && bullets.any((b) => !b.swIsOfficial)) ...[
                const SizedBox(height: AppSpacing.md),
                AttributionLine(
                  text: l10n.mohTranslatedByTabibu,
                  icon: Assets.icons.languageIcon,
                ),
              ],
              for (final source in sources) ...[
                const SizedBox(height: AppSpacing.xs),
                SourceLink(source: source),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            _ApprovalCard(publisher: first?.publisher ?? '', date: date),
            const SizedBox(height: AppSpacing.md),
            AttributionLine(
              text: l10n.healthNoticeLocationLine,
              icon: Assets.icons.locationIcon,
            ),
            const SizedBox(height: AppSpacing.sm),
            AttributionLine(
              text: l10n.healthNoticeAttribution(first?.title ?? ''),
            ),
            if (readUri != null) ...[
              const SizedBox(height: AppSpacing.md),
              TabibuButton.secondary(
                label: l10n.healthNoticeReadGuidance,
                onTap: () => unawaited(launchUrl(readUri)),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TabibuButton.primary(
              label: l10n.healthNoticeFindDoctor,
              onTap: () => const FindDoctorRoute().push<void>(context),
            ),
          ],
        );
      },
    );
  }
}

/// The notice's chip in the alertNotice tone (H-10).
class _NoticeChip extends StatelessWidget {
  const _NoticeChip({required this.county});

  final String county;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: .centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: status.alertNotice,
                shape: .circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                context.l10n.patientHomeNoticeLabel(county),
                style: textTheme.bodySmall?.copyWith(
                  color: status.alertNotice,
                  fontWeight: .w600,
                ),
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The demo banner in the alertNotice tone (H-10).
class _DemoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: status.alertNotice),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Text(
        context.l10n.alertReviewDemoBanner,
        style: textTheme.bodyMedium?.copyWith(
          color: status.alertNotice,
          fontWeight: .w600,
        ),
      ),
    );
  }
}

/// Who approved the guidance and when. No names anywhere (O-1): the
/// authority is the guidance source's publisher.
class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.publisher, required this.date});

  final String publisher;
  final String date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final l10n = context.l10n;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Row(
        children: [
          IconTile(icon: Assets.icons.verificationBadge, tone: .sky),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  l10n.healthNoticeApprovedBy,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(publisher, style: textTheme.titleMedium),
                Text(
                  l10n.healthNoticeSentBy(publisher, date),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
