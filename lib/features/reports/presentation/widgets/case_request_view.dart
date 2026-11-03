import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A case the doctor has asked this pathologist to take: what was ordered,
/// then Accept or Decline. Nothing else of the case is readable until it is
/// accepted, so this is all the screen shows.
class CaseRequestView extends StatelessWidget {
  const CaseRequestView({
    required this.caseModel,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final CaseModel caseModel;
  final bool busy;
  final VoidCallback onAccept;
  final ValueChanged<String> onDecline;

  Future<void> _decline(BuildContext context) async {
    final reason = await TabibuBottomSheet.show<String>(
      context,
      title: context.l10n.workspaceRequestDeclineTitle,
      builder: (sheet) => const _DeclineForm(),
    );
    if (reason != null) onDecline(reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;
    final tests = caseModel.tests
        .map((t) => t.name)
        .where((name) => name.isNotEmpty)
        .join(', ');
    final expires = nairobiTimeOf(caseModel.pathologistRequestExpiresAt);
    final priority = switch (caseModel.priorityValue) {
      .routine => l10n.doctorCaseRoutine,
      .priority => l10n.urgencyPriority,
      .urgent => l10n.doctorCaseUrgent,
    };

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            children: [
              NoticeCard(
                variant: .info,
                icon: Assets.icons.documentIcon,
                title: l10n.workspaceRequestTitle,
                body: l10n.workspaceRequestBody,
              ),
              const SizedBox(height: AppSpacing.md),
              KeyValueCard(
                title: l10n.doctorCaseOrder,
                rows: [
                  if (tests.isNotEmpty) (l10n.doctorCaseTest, tests),
                  (l10n.doctorCasePriority, priority),
                  if (caseModel.sampleNotes.trim().isNotEmpty)
                    (l10n.doctorCaseSpecimen, caseModel.sampleNotes.trim()),
                  if (caseModel.clinicalNotes.trim().isNotEmpty)
                    (l10n.orderNotesLabel, caseModel.clinicalNotes.trim()),
                  if (caseModel.requiresSlides)
                    (
                      l10n.orderSlidesTitle,
                      l10n.workspaceRequestSlides(caseModel.slideImages.length),
                    ),
                ],
              ),
              if (expires != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.workspaceRequestReplyBy(
                    DateFormat('EEE d MMM, h:mm a', language).format(expires),
                  ),
                  style: textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.sm,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          child: BottomActionBar(
            secondary: TabibuButton.secondary(
              label: l10n.workspaceRequestDecline,
              onTap: busy ? null : () => unawaited(_decline(context)),
            ),
            primary: TabibuButton.primary(
              label: l10n.workspaceRequestAccept,
              isLoading: busy,
              onTap: busy ? null : onAccept,
            ),
          ),
        ),
      ],
    );
  }
}

/// The reason for declining: required, as the server's limit allows.
class _DeclineForm extends StatefulWidget {
  const _DeclineForm();

  @override
  State<_DeclineForm> createState() => _DeclineFormState();
}

class _DeclineFormState extends State<_DeclineForm> {
  static const _maxReason = 500;

  final _reason = TextEditingController();
  bool _empty = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _reason.text.trim();
    if (text.isEmpty) {
      setState(() => _empty = true);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        TabibuTextField(
          label: l10n.workspaceRequestReasonLabel,
          controller: _reason,
          required: true,
          bordered: true,
          maxLines: 4,
          maxLength: _maxReason,
          keyboardType: .multiline,
          errorText: _empty ? l10n.workspaceRequestReasonRequired : null,
          onChanged: (_) {
            if (_empty) setState(() => _empty = false);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(
          label: l10n.workspaceRequestDecline,
          onTap: _submit,
        ),
      ],
    );
  }
}
