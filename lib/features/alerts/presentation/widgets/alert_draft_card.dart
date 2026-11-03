import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The languages an alert is drafted in, in the order they are shown.
const alertDraftLanguages = ['en', 'sw'];

/// The draft key of one audience and language (`clinician_en`,
/// `patient_sw`). The server refuses an edit that lacks any of the four.
String alertDraftKey({required bool clinician, required String language}) =>
    '${clinician ? 'clinician' : 'patient'}_$language';

/// Every draft key, doctors before patients within each language.
final List<String> alertDraftKeys = [
  for (final language in alertDraftLanguages)
    for (final clinician in [true, false])
      alertDraftKey(clinician: clinician, language: language),
];

/// "English" or "Kiswahili" for a draft language code.
String alertDraftLanguageName(AppLocalizations l10n, String language) =>
    language == 'sw' ? l10n.languageSw : l10n.languageEn;

/// Who a draft is for, named with [area].
String alertDraftAudience(AppLocalizations l10n, String key, String area) =>
    key.startsWith('clinician')
    ? l10n.alertReviewForDoctors(area)
    : l10n.alertReviewForPatients(area);

/// One language's AI drafts, waiting for the approver: the doctors' and the
/// patients' text verbatim inside [AiDraftFrame], then Edit. The approval is
/// one decision for the whole alert, so it is not on the card.
class AlertDraftCard extends StatelessWidget {
  const AlertDraftCard({
    required this.language,
    required this.drafts,
    required this.area,
    required this.busy,
    required this.onEdit,
    super.key,
  });

  /// `en` or `sw`.
  final String language;

  /// The alert's whole draft map; this card shows its own language's keys.
  final Map<String, AlertTextModel> drafts;
  final String area;
  final bool busy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final keys = [
      for (final clinician in [true, false])
        if (drafts.containsKey(
          alertDraftKey(clinician: clinician, language: language),
        ))
          alertDraftKey(clinician: clinician, language: language),
    ];
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        AiDraftFrame(
          label: l10n.alertReviewAiDraftNotSent,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(
                alertDraftLanguageName(l10n, language),
                style: textTheme.titleMedium,
              ),
              for (final key in keys) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  alertDraftAudience(l10n, key, area),
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(drafts[key]!.headline, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(drafts[key]!.body, style: textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Outside the frame: its semantics merge everything inside it.
        TabibuButton.secondary(
          label: l10n.reviewEdit,
          onTap: busy ? null : onEdit,
        ),
      ],
    );
  }
}
