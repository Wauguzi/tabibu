import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The server's limit for one edited segment.
const explanationSegmentMaxLength = 8000;

/// Opens the edit sheet on a draft's [segments] and returns them as the
/// doctor left them, or null when they close it. An unchanged result is the
/// caller's business: the reader turns it into a plain approval.
Future<Map<String, String>?> showExplanationEditSheet(
  BuildContext context, {
  required String language,
  required Map<String, String> segments,
}) {
  final l10n = context.l10n;
  return showSettledSheet<Map<String, String>>(
    context,
    title: l10n.explanationEditTitle,
    cancelLabel: l10n.commonCancel,
    builder: (sheet) => ExplanationEditForm(
      language: language,
      segments: segments,
      onSave: (edited) => Navigator.of(sheet).pop(edited),
    ),
  );
}

/// One field per segment, prefilled. Save and approve stays off while any
/// segment is blank: the server refuses an empty one.
class ExplanationEditForm extends StatefulWidget {
  const ExplanationEditForm({
    required this.language,
    required this.segments,
    required this.onSave,
    super.key,
  });

  final String language;
  final Map<String, String> segments;
  final ValueChanged<Map<String, String>> onSave;

  @override
  State<ExplanationEditForm> createState() => _ExplanationEditFormState();
}

class _ExplanationEditFormState extends State<ExplanationEditForm> {
  late final Map<String, TextEditingController> _controllers = {
    for (final entry in widget.segments.entries)
      entry.key: TextEditingController(text: entry.value),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canSave =>
      _controllers.values.every((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .min,
      children: [
        for (final entry in _controllers.entries) ...[
          TabibuTextField(
            label: widget.language,
            controller: entry.value,
            maxLines: 8,
            maxLength: explanationSegmentMaxLength,
            keyboardType: .multiline,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TabibuButton.primary(
          label: l10n.explanationSaveAndApprove,
          onTap: _canSave
              ? () => widget.onSave({
                  for (final entry in _controllers.entries)
                    entry.key: entry.value.text,
                })
              : null,
        ),
      ],
    );
  }
}
