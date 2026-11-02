import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The price line for a test: "About" when the lab's price is an estimate.
String testPriceLabel(LabTestModel test, AppLocalizations l10n) =>
    test.isPriceEstimate
    ? l10n.orderPriceEstimate(test.testPriceKes)
    : l10n.orderPrice(test.testPriceKes);

/// Step 1 (F-12): the active catalogue, searched and filtered by type, up
/// to ten tests on one order.
class OrderTestsStep extends StatefulWidget {
  const OrderTestsStep({required this.state, required this.onNext, super.key});

  final OrderState state;
  final VoidCallback onNext;

  @override
  State<OrderTestsStep> createState() => _OrderTestsStepState();
}

class _OrderTestsStepState extends State<OrderTestsStep> {
  String _query = '';
  String _typeId = '';

  List<LabTestModel> _visible() {
    final needle = foldForSearch(_query.trim());
    return [
      for (final test in widget.state.tests)
        if ((_typeId.isEmpty || test.testTypeId == _typeId) &&
            (needle.isEmpty ||
                foldForSearch(test.name).contains(needle) ||
                foldForSearch(test.testTypeName).contains(needle)))
          test,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final draft = widget.state.draft;
    final chosen = draft.testIds.toSet();
    final visible = _visible();
    final full = chosen.length >= OrderDraft.maxTests;
    final types = [
      for (final type in widget.state.testTypes)
        if (widget.state.tests.any((t) => t.testTypeId == type.testTypeId))
          type,
    ];

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    Text(l10n.orderTestsTitle, style: textTheme.headlineSmall),
                    Text(
                      l10n.orderForPatient(draft.patientName),
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SearchField(
                      hint: l10n.orderSearchTests,
                      clearLabel: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: .horizontal,
                      child: Row(
                        children: [
                          TabibuFilterChip(
                            label: l10n.orderAllTypes,
                            selected: _typeId.isEmpty,
                            onTap: () => setState(() => _typeId = ''),
                          ),
                          for (final type in types) ...[
                            const SizedBox(width: AppSpacing.xs),
                            TabibuFilterChip(
                              label: type.name,
                              selected: _typeId == type.testTypeId,
                              onTap: () =>
                                  setState(() => _typeId = type.testTypeId),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      visible.isEmpty && _query.trim().isNotEmpty
                          ? l10n.orderNoTestsFound(_query.trim())
                          : l10n.orderTestCount(visible.length),
                      style: textTheme.titleSmall,
                    ),
                    if (full) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.orderMaxTests, style: textTheme.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMargin,
                ),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final test = visible[i];
                    final selected = chosen.contains(test.labTestId);
                    return OptionCard(
                      key: ValueKey(test.labTestId),
                      title: test.name,
                      supporting: [
                        test.testTypeName,
                        testPriceLabel(test, l10n),
                      ].join(' · '),
                      icon: Assets.icons.testTubeIcon,
                      tone: .lavender,
                      selected: selected,
                      onTap: selected || !full
                          ? () => context.read<OrderBloc>().add(
                              OrderTestToggled(labTestId: test.labTestId),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
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
            label: l10n.orderContinueTests(chosen.length),
            onTap: chosen.isEmpty ? null : widget.onNext,
          ),
        ),
      ],
    );
  }
}
