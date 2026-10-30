import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E4 and F4. The draft read back as summary cards with Edit links, the
/// terms box, and Submit. Edit pops back to its step; the draft is in the
/// bloc, so the steps after it reopen filled in.
class PractitionerReviewScreen extends StatefulWidget {
  const PractitionerReviewScreen({super.key});

  @override
  State<PractitionerReviewScreen> createState() =>
      _PractitionerReviewScreenState();
}

class _PractitionerReviewScreenState extends State<PractitionerReviewScreen> {
  FacilityModel? _facility;
  bool _terms = false;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _terms = draft.termsAccepted;
    // A return trip: the bloc already holds this facility, so no new state
    // arrives and the name reads from what is cached.
    final cached = context.read<FacilitiesBloc>().state;
    if (cached is FacilityLoadSuccess &&
        cached.facility?.facilityId == draft.facilityId) {
      _facility = cached.facility;
    }
    context.read<FacilitiesBloc>().add(
      FacilitiesFacilityRequested(draft.facilityId),
    );
  }

  // Steps 1 to 3 sit below this one on the stack, in order.
  void _edit(int step) {
    final navigator = Navigator.of(context);
    for (var i = step; i < 4 && navigator.canPop(); i++) {
      navigator.pop();
    }
  }

  void _toggleTerms(bool value) {
    setState(() => _terms = value);
    final draft = context.read<SignUpBloc>().state.draft.copyWith(
      termsAccepted: value,
    );
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));
  }

  void _submit(SignUpDraft draft) {
    final submitted = draft.copyWith(termsAccepted: _terms);
    try {
      submitted.checkPractitioner();
    } on AppError catch (error) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: submitted));
    context.read<AuthBloc>().add(PractitionerSignUpRequested(draft: submitted));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = context.watch<SignUpBloc>().state.draft;
    final role = draft.role;
    final isPathologist = role == Role.pathologist;
    final session = context.watch<AuthBloc>().state.session;
    final email = session is SignUpIncompleteSession ? session.email : '';

    return BlocListener<FacilitiesBloc, FacilitiesState>(
      listener: (context, state) {
        if (state is FacilityLoadSuccess) {
          setState(() => _facility = state.facility);
        } else if (state is FacilityLoadFailure) {
          setState(() => _error = state.error);
        }
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        // From the listener, not the builder: a stale failure must not
        // reappear when the screen is revisited.
        listener: (context, state) {
          if (state is SignUpSuccess) {
            goToSession(context, state.session);
          }
          if (state is SignUpFailure) {
            setState(() => _error = state.error);
          }
        },
        builder: (context, authState) {
          final busy = authState is SignUpInProgress;
          final failure = _error;
          final facility = _facility;

          return DraftPopScope(
            fill: (draft) => draft.copyWith(termsAccepted: _terms),
            canPop: !busy,
            child: StepScaffold(
              step: 4,
              total: 4,
              backLabel: l10n.commonBack,
              onBack: busy ? null : () => Navigator.of(context).pop(),
              title: l10n.reviewTitle,
              error: failure,
              role: role,
              footer: TabibuButton.primary(
                label: l10n.reviewSubmit,
                isLoading: busy,
                onTap: busy || !_terms ? null : () => _submit(draft),
              ),
              child: Column(
                children: [
                  SummaryCard(
                    title: l10n.reviewYouTitle,
                    rows: [
                      (
                        l10n.reviewNameRow,
                        [draft.title?.value, draft.firstName, draft.lastName]
                            .whereType<String>()
                            .where((part) => part.isNotEmpty)
                            .join(' '),
                      ),
                      if (email.isNotEmpty) (l10n.reviewEmailRow, email),
                      (
                        l10n.reviewPhoneRow,
                        formatKePhone(draft.phoneNumber, withPrefix: true),
                      ),
                    ],
                    editLabel: l10n.reviewEdit,
                    onEdit: busy ? null : () => _edit(1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SummaryCard(
                    title: isPathologist
                        ? l10n.reviewLicenceAreasTitle
                        : l10n.reviewLicenceTitle,
                    rows: [
                      (l10n.reviewKmpdcRow, draft.kmpdcNumber),
                      if (isPathologist)
                        (
                          l10n.reviewAreasRow,
                          draft.specialties
                              .map((s) => s.description(l10n))
                              .join(', '),
                        )
                      else
                        (
                          l10n.specialtyLabel,
                          draft.specialties
                              .map((s) => s.description(l10n))
                              .join(' · '),
                        ),
                      (
                        l10n.reviewDocumentsRow,
                        l10n.documentsCount(draft.licenses.length),
                      ),
                    ],
                    editLabel: l10n.reviewEdit,
                    onEdit: busy ? null : () => _edit(2),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SummaryCard(
                    title: isPathologist
                        ? l10n.reviewLabTitle
                        : l10n.reviewFacilityTitle,
                    rows: [
                      (
                        isPathologist
                            ? l10n.reviewLabTitle
                            : l10n.reviewFacilityTitle,
                        facility?.name ?? draft.facilityId,
                      ),
                      if (!isPathologist && facility != null)
                        (
                          l10n.reviewAreaRow,
                          '${facility.ward}, ${facility.subCounty}',
                        ),
                      (
                        l10n.reviewAvailabilityRow,
                        draft.isAvailable
                            ? (isPathologist
                                  ? l10n.availabilityPathologistTitle
                                  : l10n.availabilityDoctorTitle)
                            : (isPathologist
                                  ? l10n.availabilityOffPathologist
                                  : l10n.availabilityOffDoctor),
                      ),
                    ],
                    editLabel: l10n.reviewEdit,
                    onEdit: busy ? null : () => _edit(3),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TermsBox(
                    label: isPathologist
                        ? l10n.reviewTermsPathologist
                        : l10n.reviewTerms,
                    value: _terms,
                    onChanged: busy ? null : _toggleTerms,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// E4/F4's terms checkbox, in the shared library's absence.
class _TermsBox extends StatelessWidget {
  const _TermsBox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Tappable(
          onTap: onChanged == null ? null : () => onChanged(!value),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  ExcludeFocus(
                    child: Checkbox(
                      value: value,
                      onChanged: onChanged == null
                          ? null
                          : (checked) => onChanged(checked ?? false),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(label, style: textTheme.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
