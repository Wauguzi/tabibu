import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_bloc.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/advisory_protocol.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_slides_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Step 3 (F-12): the AI risk check on the created case, then the
/// pathologist. The check's own words sit in [AiDraftFrame] (H-11); the
/// Ministry of Health card, the doctor's confirmation and the choice of
/// pathologist are the doctor's and stay outside it.
class OrderSendStep extends StatefulWidget {
  const OrderSendStep({required this.state, super.key});

  final OrderState state;

  @override
  State<OrderSendStep> createState() => _OrderSendStepState();
}

class _OrderSendStepState extends State<OrderSendStep> {
  String _query = '';

  /// Slides are uploading ahead of the send.
  bool _uploading = false;

  /// The slide rows that belong to this order's case and are not yet on the
  /// server; rows from another case are not ours.
  List<SlideItem> _pending(String caseUid) {
    final upload = context.read<SlideUploadBloc>().state;
    if (upload.caseUid.isNotEmpty && upload.caseUid != caseUid) return const [];
    return [
      for (final slide in upload.slides)
        if (slide.status != .uploaded) slide,
    ];
  }

  /// Uploads any slides still waiting, then sends. Nothing to upload sends
  /// at once; a failed upload stops here, and its rows say why.
  Future<void> _send() async {
    final draft = widget.state.draft;
    final pending = _pending(draft.caseUid);
    if (pending.isEmpty) {
      _add(const OrderSendRequested());
      return;
    }
    final slides = context.read<SlideUploadBloc>();
    setState(() => _uploading = true);
    final settled = slides.stream.firstWhere(
      (state) => state is! SlideUploadInProgress,
    );
    slides.add(
      SlideUploadRequested(uid: draft.doctorUid, caseUid: draft.caseUid),
    );
    final result = await settled;
    if (!mounted) return;
    setState(() => _uploading = false);
    if (result.slides.every((slide) => slide.status == .uploaded)) {
      _add(const OrderSendRequested());
    }
  }

  // The case is created on the way here; the list must learn of it for the
  // slides card to know the order needs slides.
  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    if (session is PractitionerSession) {
      context.read<CasesBloc>().add(
        CasesRefreshed(uid: session.doctor.uid, role: .doctor),
      );
    }
  }

  void _add(OrderEvent event) => context.read<OrderBloc>().add(event);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = widget.state;
    final draft = state.draft;
    final busy = state is OrderWriteInProgress;
    final check = state.riskCheck;
    final advisoryKey = check?.advisoryKey ?? '';
    final protocol = AdvisoryProtocol.fromKey(advisoryKey);
    final needle = foldForSearch(_query.trim());
    // The slides card reads the case: the upload bloc's synced copy when it
    // is this case, else the cases list. It stays hidden while another
    // case's upload runs.
    final upload = context.watch<SlideUploadBloc>().state;
    final foreignBusy =
        upload is SlideUploadInProgress &&
        upload.caseUid.isNotEmpty &&
        upload.caseUid != draft.caseUid;
    final synced = upload.caseModel;
    final requiresSlides =
        !foreignBusy &&
        (synced != null && synced.uid == draft.caseUid
            ? synced.requiresSlides
            : context
                      .watch<CasesBloc>()
                      .state
                      .cases
                      .firstWhereOrNull((c) => c.uid == draft.caseUid)
                      ?.requiresSlides ??
                  false);
    // A row with no valid size cannot upload, so it cannot go with the send.
    final unsized = _pending(
      draft.caseUid,
    ).any((slide) => !slide.hasValidPixelSize);
    final pathologists = [
      for (final p in state.pathologists)
        if (needle.isEmpty ||
            foldForSearch(p.fullName).contains(needle) ||
            foldForSearch(p.facilityName).contains(needle))
          p,
    ];

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: .onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.lg,
            ),
            children: [
              Text(l10n.orderSendTitle, style: textTheme.headlineSmall),
              Text(
                l10n.orderForPatient(draft.patientName),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _RiskCheck(check: check, settled: state.riskCheckSettled),
              if (state.flagged) ...[
                const SizedBox(height: AppSpacing.md),
                NoticeCard(
                  variant: .attention,
                  icon: Assets.icons.alertIcon,
                  title: l10n.orderProtocolTitle,
                  body: protocol?.body(l10n) ?? l10n.orderProtocolTitle,
                  action: protocol == null
                      ? null
                      : TabibuButton.outline(
                          label: l10n.orderProtocolRead,
                          onTap: () => MohProtocolRoute(
                            protocolId: protocol.key,
                          ).push<void>(context),
                        ),
                ),
                const SizedBox(height: AppSpacing.xs),
                CheckRow(
                  label: l10n.orderProtocolConfirm,
                  value: draft.protocolConfirmed,
                  // Outline tick / empty circle from assets, tinted to the
                  // theme (not the Material filled checkbox).
                  circle: true,
                  onChanged: busy
                      ? null
                      : (value) =>
                            _add(OrderProtocolConfirmed(confirmed: value)),
                ),
              ],
              if (requiresSlides) ...[
                const SizedBox(height: AppSpacing.md),
                OrderSlidesCard(
                  caseUid: draft.caseUid,
                  doctorUid: draft.doctorUid,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: l10n.orderPathologistLabel),
              const SizedBox(height: AppSpacing.xs),
              SearchField(
                hint: l10n.orderSearchPathologists,
                clearLabel: MaterialLocalizations.of(
                  context,
                ).deleteButtonTooltip,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.pathologists.isEmpty)
                Text(l10n.orderNoPathologists, style: textTheme.bodyMedium)
              else
                for (final p in pathologists) ...[
                  OptionCard(
                    key: ValueKey(p.uid),
                    title: p.fullName,
                    supporting: p.facilityName,
                    leading: Avatar(
                      name: p.fullName,
                      radius: 22,
                      image: p.profilePictureUrl.isEmpty
                          ? null
                          : NetworkImage(p.profilePictureUrl),
                    ),
                    selected: draft.pathologistUid == p.uid,
                    onTap: busy
                        ? null
                        : () => _add(
                            OrderPathologistSelected(pathologistUid: p.uid),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              const SizedBox(height: AppSpacing.xs),
              AttributionLine(
                text: l10n.orderPathologistAiNote,
                icon: Assets.icons.sparkleIcon,
              ),
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
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              if (!state.riskCheckSettled) ...[
                Text(
                  l10n.orderWaitRisk,
                  style: textTheme.bodySmall,
                  textAlign: .center,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (unsized) ...[
                Text(
                  l10n.orderSlidesSizeBeforeSend,
                  style: textTheme.bodySmall,
                  textAlign: .center,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              TabibuButton.primary(
                label: l10n.orderSend,
                isLoading: busy || _uploading,
                onTap: state.canSend && !busy && !_uploading && !unsized
                    ? () => unawaited(_send())
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The risk check as it stands. Only a Ready result is AI output and wears
/// the frame; running, failed or overdue are statuses, said plainly.
class _RiskCheck extends StatelessWidget {
  const _RiskCheck({required this.check, required this.settled});

  final RiskCheckModel? check;
  final bool settled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final check = this.check;
    final status = check?.statusValue;

    if (status == JobStatus.failed) {
      return NoticeCard(
        variant: .neutral,
        icon: Assets.icons.infoIcon,
        body: l10n.orderRiskFailed,
      );
    }
    if (check == null || status != JobStatus.ready) {
      return NoticeCard(
        variant: .neutral,
        icon: Assets.icons.hourglassIcon,
        body: settled ? l10n.orderRiskTimedOut : l10n.orderRiskRunning,
      );
    }

    final swahili = Localizations.localeOf(context).languageCode == 'sw';
    final advisory = swahili ? check.advisorySw : check.advisoryEn;
    final suggested = context
        .read<OrderBloc>()
        .state
        .tests
        .where((t) => check.suggestedLabTestIds.contains(t.labTestId))
        .map((t) => t.name)
        .toList();
    final models = check.models.values.whereNot((m) => m.isEmpty).join(', ');

    return AiDraftFrame(
      label: l10n.orderRiskAiLabel,
      detail: models.isEmpty ? null : models,
      footer: Text(l10n.orderRiskDisclaimer, style: textTheme.bodySmall),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (check.advisoryKey.isEmpty) ...[
            Text(l10n.orderRiskClear, style: textTheme.titleSmall),
            Text(l10n.orderRiskClearBody, style: textTheme.bodyMedium),
          ] else
            // The server's fixed template, verbatim (S-7).
            Text(advisory, style: textTheme.bodyMedium),
          if (suggested.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.orderRiskSuggested, style: textTheme.titleSmall),
            for (final name in suggested)
              Text('• $name', style: textTheme.bodyMedium),
            Text(l10n.orderRiskSuggestedBody, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
