import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The case pinned under a consult's header. It carries the signed report's
/// de-identified finding, or "Report in progress" until there is one. It
/// never shows an unsigned draft or any AI text, whoever is reading (H-6,
/// H-7): the summary holds none, and a pending status reads only as
/// progress.
class MdtPinnedCard extends StatelessWidget {
  const MdtPinnedCard({
    required this.consult,
    required this.reportInProgress,
    this.openLabel,
    this.onOpen,
    super.key,
  });

  final ConversationModel consult;
  final bool reportInProgress;

  /// The link's label, or null when this person cannot open the case.
  final String? openLabel;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final language = Localizations.localeOf(context).languageCode;
    final summary = consult.caseSummary;
    final test = mdtFirstTest(consult);
    final title = l10n.mdtPinned(
      test.isEmpty ? l10n.reportPdfSignedReport : test,
    );
    final subtitle = reportInProgress
        ? l10n.mdtReportInProgress
        : l10n.mdtPinnedSigned(
            summary.signedDiagnosisExcerpt,
            mdtClockLabel(summary.signedAt, language),
          );
    final label = openLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.signedContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          IconTile(icon: Assets.icons.documentIcon, tone: .white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall,
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
          if (label != null)
            TabibuButton.ghost(
              label: label,
              onTap: onOpen,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
