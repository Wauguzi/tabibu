import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoDatePicker,
        CupertinoTheme,
        CupertinoThemeData,
        showCupertinoModalPopup;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/presentation/widgets/order_tests_step.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Step 2 (F-12): the tests, when the sample was collected, priority,
/// specimen, notes and payment, then "Create order". Problems show once
/// the doctor has tried to create, not while they type.
class OrderDetailsStep extends StatefulWidget {
  const OrderDetailsStep({required this.state, super.key});

  final OrderState state;

  @override
  State<OrderDetailsStep> createState() => _OrderDetailsStepState();
}

class _OrderDetailsStepState extends State<OrderDetailsStep> {
  late final _specimen = TextEditingController(
    text: widget.state.draft.specimen,
  );
  late final _notes = TextEditingController(
    text: widget.state.draft.clinicalNotes,
  );
  late final _insurerName = TextEditingController(
    text: widget.state.draft.insurerName,
  );
  late final _policy = TextEditingController(
    text: widget.state.draft.policyNumber,
  );
  bool _tried = false;

  @override
  void dispose() {
    _specimen.dispose();
    _notes.dispose();
    _insurerName.dispose();
    _policy.dispose();
    super.dispose();
  }

  void _add(OrderEvent event) => context.read<OrderBloc>().add(event);

  void _create() {
    setState(() => _tried = true);
    if (widget.state.draft.issues(DateTime.now()).isNotEmpty) return;
    _add(const OrderCreateRequested());
  }

  /// The picker shows Nairobi wall-clock time whatever the device's zone;
  /// the draft keeps the instant.
  Future<void> _pickCollectedAt() async {
    final now = DateTime.now();
    DateTime wall(DateTime instant) {
      final w = nairobiNow(instant);
      return DateTime(w.year, w.month, w.day, w.hour, w.minute);
    }

    DateTime instant(DateTime picked) => DateTime.utc(
      picked.year,
      picked.month,
      picked.day,
      picked.hour,
      picked.minute,
    ).subtract(nairobiOffset);

    final brightness = Theme.of(context).brightness;
    final surface = Theme.of(context).colorScheme.surfaceContainerLowest;
    final opening = wall(widget.state.draft.collectedAt ?? now);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadii.tile),
            topRight: Radius.circular(AppRadii.tile),
          ),
        ),
        child: SafeArea(
          top: false,
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: brightness),
            child: CupertinoDatePicker(
              backgroundColor: AppColors.transparent,
              initialDateTime: opening,
              minimumDate: wall(now.subtract(OrderDraft.collectionWindow)),
              maximumDate: wall(now),
              onDateTimeChanged: (picked) =>
                  _add(OrderDetailsChanged(collectedAt: instant(picked))),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickInsurer() async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.orderInsurerLabel,
      actions: [
        for (final insurer in widget.state.insurers)
          OptionsAction(
            value: insurer.insurerId,
            icon: Assets.icons.shieldIcon,
            label: insurer.name,
          ),
      ],
    );
    if (picked != null) _add(OrderPaymentChanged(insurerId: picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final state = widget.state;
    final draft = state.draft;
    final busy = state is OrderWriteInProgress;
    final issues = _tried
        ? draft.issues(DateTime.now()).toSet()
        : const <OrderDraftIssue>{};
    final collectedAt = draft.collectedAt;
    final tests = [
      for (final id in draft.testIds)
        ?state.tests.firstWhereOrNull((t) => t.labTestId == id),
    ];
    final offline =
        state.offline ||
        (state is OrderWriteFailure && state.error == AppError.noInternet);

    String? collectedError() {
      if (issues.contains(OrderDraftIssue.collectedAtMissing)) {
        return l10n.orderCollectedMissing;
      }
      if (issues.contains(OrderDraftIssue.collectedAtInFuture)) {
        return l10n.orderCollectedFuture;
      }
      if (issues.contains(OrderDraftIssue.collectedAtTooOld)) {
        return l10n.orderCollectedOld;
      }
      return null;
    }

    final collectedErrorText = collectedError();
    final insurer = state.insurers.firstWhereOrNull(
      (i) => i.insurerId == draft.insurerId,
    );

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.lg,
            ),
            children: [
              Text(l10n.orderDetailsTitle, style: textTheme.headlineSmall),
              Text(
                l10n.orderForPatient(draft.patientName),
                style: textTheme.bodyMedium,
              ),
              if (offline) ...[
                const SizedBox(height: AppSpacing.md),
                NoticeCard(
                  variant: .neutral,
                  icon: Assets.icons.cloudOffIcon,
                  body: l10n.orderOffline,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: l10n.orderTestsLabel),
              const SizedBox(height: AppSpacing.xs),
              GroupedRowsCard(
                children: [
                  for (final test in tests)
                    _TestRow(
                      name: test.name,
                      supporting: testPriceLabel(test, l10n),
                      removeLabel: l10n.orderRemoveTest(test.name),
                      onRemove: busy || tests.length == 1
                          ? null
                          : () => _add(
                              OrderTestToggled(labTestId: test.labTestId),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ListRowCard(
                title: l10n.orderCollectedLabel,
                subtitle: collectedAt == null
                    ? null
                    : DateFormat(
                        'd MMM yyyy, h:mm a',
                        language,
                      ).format(nairobiNow(collectedAt)),
                leading: IconTile(icon: Assets.icons.calendarIcon, tone: .sky),
                onTap: busy ? null : _pickCollectedAt,
              ),
              if (collectedErrorText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    left: AppSpacing.md,
                  ),
                  child: Text(
                    collectedErrorText,
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: l10n.orderPriorityLabel),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final urgency in Urgency.values)
                    TabibuFilterChip(
                      label: urgency.description(l10n),
                      selected: draft.priority == urgency,
                      onTap: () => _add(OrderDetailsChanged(priority: urgency)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TabibuTextField(
                label: l10n.orderSpecimenLabel,
                hint: l10n.orderSpecimenHint,
                controller: _specimen,
                maxLines: 3,
                readOnly: busy,
                errorText: issues.contains(OrderDraftIssue.specimenTooLong)
                    ? l10n.orderTooLong(OrderDraft.maxSpecimen)
                    : null,
                onChanged: (value) =>
                    _add(OrderDetailsChanged(specimen: value)),
              ),
              const SizedBox(height: AppSpacing.md),
              TabibuTextField(
                label: l10n.orderNotesLabel,
                hint: l10n.orderNotesHint,
                controller: _notes,
                maxLines: 6,
                readOnly: busy,
                errorText: issues.contains(OrderDraftIssue.notesTooLong)
                    ? l10n.orderTooLong(OrderDraft.maxNotes)
                    : null,
                onChanged: (value) =>
                    _add(OrderDetailsChanged(clinicalNotes: value)),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: l10n.orderPaymentLabel),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  TabibuFilterChip(
                    label: l10n.orderPaymentCash,
                    selected: !draft.insured,
                    onTap: () =>
                        _add(const OrderPaymentChanged(insured: false)),
                  ),
                  TabibuFilterChip(
                    label: l10n.orderPaymentInsurance,
                    selected: draft.insured,
                    onTap: () => _add(const OrderPaymentChanged(insured: true)),
                  ),
                ],
              ),
              if (draft.insured) ...[
                const SizedBox(height: AppSpacing.sm),
                ListRowCard(
                  title: l10n.orderInsurerLabel,
                  subtitle: insurer?.name,
                  leading: IconTile(icon: Assets.icons.shieldIcon, tone: .mint),
                  onTap: busy ? null : _pickInsurer,
                ),
                if (issues.contains(OrderDraftIssue.insurerMissing))
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      left: AppSpacing.md,
                    ),
                    child: Text(
                      l10n.orderInsurerMissing,
                      style: textTheme.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
                if (draft.insurerId == OrderDraft.otherInsurer) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TabibuTextField(
                    label: l10n.orderInsurerNameLabel,
                    controller: _insurerName,
                    required: true,
                    readOnly: busy,
                    errorText:
                        issues.contains(OrderDraftIssue.insurerNameInvalid)
                        ? l10n.orderInsurerNameInvalid
                        : null,
                    onChanged: (value) =>
                        _add(OrderPaymentChanged(insurerName: value)),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TabibuTextField(
                  label: l10n.orderPolicyLabel,
                  controller: _policy,
                  required: true,
                  readOnly: busy,
                  errorText: issues.contains(OrderDraftIssue.policyInvalid)
                      ? l10n.orderPolicyInvalid
                      : null,
                  onChanged: (value) =>
                      _add(OrderPaymentChanged(policyNumber: value)),
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
          child: TabibuButton.primary(
            label: l10n.orderCreate,
            isLoading: busy,
            onTap: busy ? null : _create,
          ),
        ),
      ],
    );
  }
}

/// A chosen test with its price and a remove button; the last test can't be
/// removed (an order needs one).
class _TestRow extends StatelessWidget {
  const _TestRow({
    required this.name,
    required this.supporting,
    required this.removeLabel,
    required this.onRemove,
  });

  final String name;
  final String supporting;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onRemove = this.onRemove;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconTile(icon: Assets.icons.testTubeIcon, tone: .lavender),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(name, style: textTheme.titleSmall),
                Text(supporting, style: textTheme.bodySmall),
              ],
            ),
          ),
          if (onRemove != null)
            CircleIconButton(
              icon: Assets.icons.cancelIcon,
              semanticLabel: removeLabel,
              onTap: onRemove,
              onCard: true,
              diameter: 40,
            ),
        ],
      ),
    );
  }
}
