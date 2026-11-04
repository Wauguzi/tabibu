import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// Case progress as a titled card around [VerificationTimeline].
class CaseTimelineCard extends StatelessWidget {
  const CaseTimelineCard({
    required this.title,
    required this.steps,
    this.trailing,
    super.key,
  });

  final String title;
  final List<VerificationStep> steps;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return VerificationTimeline(
      title: title,
      progressLabel: trailing ?? '',
      steps: steps,
    );
  }
}
