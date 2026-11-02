import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/presentation/case_steps.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_bloc.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-ORDER-SENT (F-1, F-12): replaces the wizard, so back returns to the
/// appointment. The summary comes from the draft just sent; the case
/// number arrives with the doctor's cases, refreshed on arrival.
class OrderSentScreen extends StatefulWidget {
  const OrderSentScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<OrderSentScreen> createState() => _OrderSentScreenState();
}

class _OrderSentScreenState extends State<OrderSentScreen> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = context.watch<OrderBloc>().state;
    final sent = order.draft.caseUid == widget.caseUid ? order : null;
    final caseModel = context
        .select<CasesBloc, CasesState>((b) => b.state)
        .cases
        .firstWhereOrNull((c) => c.uid == widget.caseUid);
    final pathologist = sent?.pathologists.firstWhereOrNull(
      (p) => p.uid == sent.draft.pathologistUid,
    );
    final orderNumber = caseModel?.orderNumber ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                children: [
                  TopBar(
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                    title: l10n.orderSentTitle,
                    subtitle: orderNumber.isEmpty ? null : orderNumber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NoticeCard(
                    variant: .info,
                    icon: Assets.icons.tickIcon,
                    title: pathologist == null
                        ? l10n.orderSentTitle
                        : l10n.orderSentHero(
                            '${pathologist.title} ${pathologist.lastName}'
                                .trim(),
                          ),
                    body: l10n.orderSentHeroBody,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StepperCard(current: caseModel?.doctorStep ?? 2),
                  if (sent != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _Summary(state: sent),
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
                  label: l10n.orderViewCase,
                  onTap: () => DoctorCaseRoute(
                    caseUid: widget.caseUid,
                  ).pushReplacement(context),
                ),
                primary: TabibuButton.primary(
                  label: l10n.orderBackToAppointment,
                  onTap: context.pop,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: scheme.brightness == .dark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: CaseStepper(
        labels: doctorCaseStepLabels(l10n),
        current: current,
        semanticLabel: doctorCaseStepSemantics(l10n, current),
      ),
    );
  }
}

/// What was sent: tests, specimen, pathologist, priority, payment and how
/// the risk check ended.
class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final OrderState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = state.draft;
    final tests = [
      for (final id in draft.testIds)
        ?state.tests.firstWhereOrNull((t) => t.labTestId == id)?.name,
    ];
    final pathologist = state.pathologists.firstWhereOrNull(
      (p) => p.uid == draft.pathologistUid,
    );
    final insurer = state.insurers.firstWhereOrNull(
      (i) => i.insurerId == draft.insurerId,
    );
    final check = state.riskCheck;
    final risk = check?.statusValue != JobStatus.ready
        ? l10n.orderSummaryRiskPending
        : check!.advisoryKey.isEmpty
        ? l10n.orderRiskClear
        : l10n.orderSummaryProtocol;
    final payment = !draft.insured
        ? l10n.orderPaymentCash
        : [
            l10n.orderPaymentInsurance,
            if (draft.insurerId == OrderDraft.otherInsurer)
              draft.insurerName
            else if (insurer != null)
              insurer.name,
          ].join(' · ');

    return KeyValueCard(
      title: l10n.orderSummary,
      rows: [
        (l10n.orderTestsLabel, tests.join(', ')),
        if (draft.specimen.trim().isNotEmpty)
          (l10n.orderSpecimenLabel, draft.specimen.trim()),
        if (pathologist != null)
          (l10n.orderPathologistLabel, pathologist.fullName),
        (l10n.orderPriorityLabel, draft.priority.description(l10n)),
        (l10n.orderPaymentLabel, payment),
        (l10n.orderSummaryRisk, risk),
      ],
    );
  }
}
