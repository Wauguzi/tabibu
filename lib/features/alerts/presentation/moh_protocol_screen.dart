import 'dart:async';

import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/public_health_guidance_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/source_link.dart';
import 'package:tabibu/features/alerts/presentation/widgets/steps_card.dart';
import 'package:tabibu/features/orders/data/advisory_protocol.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-MOH-PROTOCOL (F-13): the clinician guidance a risk-check advisory
/// points to, verbatim from the bundled register, each step linked to its
/// source. Sourced guidance, not AI output.
class MohProtocolScreen extends StatefulWidget {
  const MohProtocolScreen({required this.protocolId, super.key});

  final String protocolId;

  @override
  State<MohProtocolScreen> createState() => _MohProtocolScreenState();
}

class _MohProtocolScreenState extends State<MohProtocolScreen> {
  late final AdvisoryProtocol? _protocol = AdvisoryProtocol.fromKey(
    widget.protocolId,
  );
  late final Future<PublicHealthGuidanceModel?> _guidance = _load();

  Future<PublicHealthGuidanceModel?> _load() async {
    final protocol = _protocol;
    if (protocol == null) return null;
    final rows = await getIt<ReferenceDataHelper>().publicHealthGuidance();
    return rows.firstWhereOrNull(
      (row) => row.diseaseId == protocol.guidanceDiseaseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<PublicHealthGuidanceModel?>(
          future: _guidance,
          builder: (context, snapshot) {
            final protocol = _protocol;
            final guidance = snapshot.data;
            final loading =
                snapshot.connectionState != ConnectionState.done &&
                protocol != null;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenMargin),
              children: [
                TopBar(
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.mohTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (loading)
                  LoadingView(semanticLabel: l10n.mohLoadingLabel)
                else if (protocol == null || guidance == null)
                  EmptyState(
                    icon: Assets.icons.alertIcon,
                    title: l10n.mohUnknown,
                  )
                else
                  ..._body(context, protocol, guidance),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    AdvisoryProtocol protocol,
    PublicHealthGuidanceModel guidance,
  ) {
    final l10n = context.l10n;
    final swahili = Localizations.localeOf(context).languageCode == 'sw';
    final steps = [
      for (final bullet in guidance.bullets)
        if (bullet.audienceValue == .clinician) bullet,
    ];
    final sources = {
      for (final source in guidance.sources) source.sourceId: source,
    };
    final usedSources = [
      for (final id in {for (final step in steps) step.sourceId}) ?sources[id],
    ];
    final translated = swahili && steps.any((s) => !s.swIsOfficial);
    return [
      NoticeCard(
        variant: .attention,
        icon: Assets.icons.alertIcon,
        title: protocol.title(l10n),
        body: protocol.body(l10n),
      ),
      const SizedBox(height: AppSpacing.md),
      StepsCard(
        steps: [
          for (final step in steps)
            if (swahili) step.textSw else step.textEn,
        ],
      ),
      if (translated) ...[
        const SizedBox(height: AppSpacing.xs),
        AttributionLine(
          text: l10n.mohTranslatedByTabibu,
          icon: Assets.icons.languageIcon,
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      Text(l10n.mohCaption, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: AppSpacing.sm),
      for (final source in usedSources) SourceLink(source: source),
    ];
  }
}
