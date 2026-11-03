import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A case this pathologist has taken whose sample is not recorded yet. The
/// report cannot start until the lab's accession number is, so it is asked
/// for here; the order stays in view above.
class SampleReceivedView extends StatefulWidget {
  const SampleReceivedView({
    required this.caseModel,
    required this.busy,
    required this.onRecord,
    this.suggested = '',
    super.key,
  });

  final CaseModel caseModel;
  final bool busy;
  final ValueChanged<String> onRecord;

  /// A made-up accession number to start from; the person may replace it.
  final String suggested;

  @override
  State<SampleReceivedView> createState() => _SampleReceivedViewState();
}

class _SampleReceivedViewState extends State<SampleReceivedView> {
  static final _shape = RegExp(r'^[A-Za-z0-9/-]{1,30}$');

  /// Keyboards swap a hyphen for a typographic dash and add spaces; both are
  /// put right as they are typed, and anything else the lab does not use is
  /// not accepted at all.
  static final _typing = TextInputFormatter.withFunction((old, value) {
    final text = value.text
        .replaceAll(RegExp('[\u2010-\u2015\u2212]'), '-')
        .replaceAll(RegExp('[^A-Za-z0-9/-]'), '');
    if (text == value.text) return value;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length.clamp(0, value.selection.end.clamp(0, text.length)),
      ),
    );
  });

  late final _accession = TextEditingController(text: widget.suggested);
  bool _invalid = false;

  @override
  void dispose() {
    _accession.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _accession.text.trim();
    if (!_shape.hasMatch(text)) {
      setState(() => _invalid = true);
      return;
    }
    widget.onRecord(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tests = widget.caseModel.tests
        .map((t) => t.name)
        .where((name) => name.isNotEmpty)
        .join(', ');

    return ListView(
      keyboardDismissBehavior: .onDrag,
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      children: [
        NoticeCard(
          variant: .info,
          icon: Assets.icons.testTubeIcon,
          title: l10n.workspaceSampleTitle,
          body: l10n.workspaceSampleBody,
        ),
        const SizedBox(height: AppSpacing.md),
        if (tests.isNotEmpty) ...[
          KeyValueCard(
            title: l10n.doctorCaseOrder,
            rows: [(l10n.doctorCaseTest, tests)],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TabibuTextField(
          label: l10n.workspaceSampleLabel,
          hint: l10n.workspaceSampleHint,
          helperText: widget.suggested.isEmpty
              ? null
              : l10n.workspaceSampleSuggested,
          controller: _accession,
          required: true,
          bordered: true,
          readOnly: widget.busy,
          maxLength: 30,
          inputFormatters: [_typing],
          errorText: _invalid ? l10n.workspaceSampleInvalid : null,
          onChanged: (_) {
            if (_invalid) setState(() => _invalid = false);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.doctorCaseSampleReceived,
          isLoading: widget.busy,
          onTap: widget.busy ? null : _submit,
        ),
      ],
    );
  }
}
