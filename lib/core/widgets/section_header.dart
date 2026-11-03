import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

/// A section title with its action link: "Your day" plus "Calendar".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final actionLabel = this.actionLabel;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        if (actionLabel != null)
          // The ghost button pads its label; shifting it by that padding puts
          // the label's end on the content edge, under the cards' own.
          Transform.translate(
            offset: const Offset(AppSpacing.xlg, 0),
            child: TabibuButton.ghost(
              label: actionLabel,
              onTap: onAction,
              foregroundColor: scheme.primary,
            ),
          ),
      ],
    );
  }
}
