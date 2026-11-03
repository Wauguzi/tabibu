import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/presentation/widgets/signature_pad.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_score_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Opens CS-07. Returns true after a successful sign once the sheet has
/// finished closing (lesson 12).
Future<bool> showWorkspaceSignSheet(
  BuildContext context, {
  required String signedBy,
  required String goesTo,
  required String notifiableDisease,
  required WorkspaceScoreCard? scoreCard,
}) async {
  ModalRoute<bool>? sheetRoute;
  final result = await TabibuBottomSheet.show<bool>(
    context,
    title: context.l10n.signSheetTitle,
    cancelLabel: context.l10n.commonCancel,
    builder: (sheet) {
      sheetRoute = ModalRoute.of(sheet) as ModalRoute<bool>?;
      return _WorkspaceSignBody(
        sheetContext: sheet,
        signedBy: signedBy,
        goesTo: goesTo,
        notifiableDisease: notifiableDisease,
        scoreCard: scoreCard,
      );
    },
  );
  if (result != true) return false;
  await _closed(sheetRoute?.animation);
  return true;
}

Future<void> _closed(Animation<double>? animation) {
  if (animation == null || animation.isDismissed) return Future.value();
  final done = Completer<void>();
  void listener(AnimationStatus status) {
    if (status != .dismissed) return;
    animation.removeStatusListener(listener);
    done.complete();
  }

  animation.addStatusListener(listener);
  return done.future;
}

class _WorkspaceSignBody extends StatefulWidget {
  const _WorkspaceSignBody({
    required this.sheetContext,
    required this.signedBy,
    required this.goesTo,
    required this.notifiableDisease,
    required this.scoreCard,
  });

  final BuildContext sheetContext;
  final String signedBy;
  final String goesTo;
  final String notifiableDisease;
  final WorkspaceScoreCard? scoreCard;

  @override
  State<_WorkspaceSignBody> createState() => _WorkspaceSignBodyState();
}

class _WorkspaceSignBodyState extends State<_WorkspaceSignBody> {
  // Unticked every open (H-3).
  bool _attested = false;
  late final SignaturePadController _pad = SignaturePadController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _pad.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pad.dispose();
    super.dispose();
  }

  Future<void> _sign() async {
    final png = await _pad.toPngBase64();
    if (png == null || !mounted) return;
    context.read<CaseWorkspaceBloc>().add(
      CaseSignRequested(signaturePng: png, attested: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scoreCard = widget.scoreCard;

    return BlocConsumer<CaseWorkspaceBloc, CaseWorkspaceState>(
      listenWhen: (previous, current) =>
          current is CaseSignSuccess || current is CaseWorkspaceWriteFailure,
      listener: (context, state) {
        if (state is CaseSignSuccess) {
          Navigator.of(widget.sheetContext).pop(true);
          return;
        }
        if (state is CaseWorkspaceWriteFailure) {
          setState(() => _error = state.error.description(l10n));
        }
      },
      builder: (context, state) {
        final busy = state is CaseWorkspaceWriteInProgress;
        final offline = state.offline;
        final needsScore = state.needsScore;

        if (needsScore && scoreCard != null) {
          return scoreCard;
        }

        final canSign = _attested && !_pad.isEmpty && !offline && !busy;

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            _SummaryRow(label: l10n.signSheetSignedBy, value: widget.signedBy),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: l10n.signSheetGoesTo, value: widget.goesTo),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: l10n.signSheetPatientSees,
              value: l10n.signSheetPatientSeesValue,
            ),
            if (widget.notifiableDisease.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              NoticeCard(
                variant: .attention,
                icon: Assets.icons.alertIcon,
                body: l10n.signSheetNotifiableNotice(widget.notifiableDisease),
              ),
            ],
            if (offline) ...[
              const SizedBox(height: AppSpacing.md),
              ConnectivityBanner(
                state: .offline,
                title: l10n.signSheetOfflineTitle,
                body: l10n.signSheetOfflineBody,
                retryLabel: l10n.findDoctorRetry,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            CheckRow(
              label: l10n.signSheetAttestation,
              value: _attested,
              onChanged: busy
                  ? null
                  : (value) => setState(() => _attested = value),
            ),
            const SizedBox(height: AppSpacing.md),
            SignaturePad(
              controller: _pad,
              hint: l10n.signSheetSignHere,
              clearLabel: l10n.signSheetClear,
              semanticLabel: l10n.signSheetSignatureLabel,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              NoticeCard(
                variant: .error,
                icon: Assets.icons.alertIcon,
                body: _error!,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TabibuButton.primary(
              label: offline
                  ? l10n.signSheetSignWhenOnline
                  : l10n.signSheetSignAndSend,
              isLoading: busy,
              onTap: canSign ? _sign : null,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: textTheme.bodyLarge),
      ],
    );
  }
}
