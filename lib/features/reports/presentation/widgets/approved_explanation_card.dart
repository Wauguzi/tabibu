import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/l10n/l10n.dart';

/// An explanation the doctor approved, as the patient reads it: the text
/// verbatim on the plain card, never inside [AiDraftFrame].
class ApprovedExplanationCard extends StatelessWidget {
  const ApprovedExplanationCard({
    required this.language,
    required this.segments,
    super.key,
  });

  /// The language's name, such as "English".
  final String language;
  final List<String> segments;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(language, style: textTheme.titleSmall)),
            StatusChip(label: context.l10n.explanationApproved, tone: .signed),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ReportTextCard(entries: [for (final text in segments) ('', text)]),
      ],
    );
  }
}
