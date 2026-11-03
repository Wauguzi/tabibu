import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_draft_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The server's limits for one edited headline and body.
const alertHeadlineMaxLength = 90;
const alertBodyMaxLength = 600;

/// Opens the edit sheet on one language's [segments] and returns them as the
/// approver left them, or null when they close it. An unchanged result is
/// the bloc's business: it turns it into a plain approval.
Future<Map<String, AlertTextModel>?> showAlertEditSheet(
  BuildContext context, {
  required String language,
  required String area,
  required Map<String, AlertTextModel> segments,
}) {
  final l10n = context.l10n;
  return showSettledSheet<Map<String, AlertTextModel>>(
    context,
    title: l10n.reviewEdit,
    subtitle: alertDraftLanguageName(l10n, language),
    cancelLabel: l10n.commonCancel,
    builder: (sheet) => AlertEditForm(
      area: area,
      segments: segments,
      onSave: (edited) => Navigator.of(sheet).pop(edited),
    ),
  );
}

/// A headline and a body per audience, prefilled. Save stays off while any
/// is blank: the server refuses an empty one.
class AlertEditForm extends StatefulWidget {
  const AlertEditForm({
    required this.area,
    required this.segments,
    required this.onSave,
    super.key,
  });

  final String area;
  final Map<String, AlertTextModel> segments;
  final ValueChanged<Map<String, AlertTextModel>> onSave;

  @override
  State<AlertEditForm> createState() => _AlertEditFormState();
}

class _AlertEditFormState extends State<AlertEditForm> {
  late final Map<String, (TextEditingController, TextEditingController)>
  _controllers = {
    for (final entry in widget.segments.entries)
      entry.key: (
        TextEditingController(text: entry.value.headline),
        TextEditingController(text: entry.value.body),
      ),
  };

  @override
  void dispose() {
    for (final (headline, body) in _controllers.values) {
      headline.dispose();
      body.dispose();
    }
    super.dispose();
  }

  bool get _canSave => _controllers.values.every(
    (c) => c.$1.text.trim().isNotEmpty && c.$2.text.trim().isNotEmpty,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .min,
      children: [
        for (final entry in _controllers.entries) ...[
          TabibuTextField(
            label: alertDraftAudience(l10n, entry.key, widget.area),
            controller: entry.value.$1,
            maxLines: 2,
            maxLength: alertHeadlineMaxLength,
            keyboardType: .multiline,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xs),
          TabibuTextField(
            label: alertDraftAudience(l10n, entry.key, widget.area),
            controller: entry.value.$2,
            maxLines: 8,
            maxLength: alertBodyMaxLength,
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
                    entry.key: AlertTextModel(
                      headline: entry.value.$1.text,
                      body: entry.value.$2.text,
                    ),
                })
              : null,
        ),
      ],
    );
  }
}
