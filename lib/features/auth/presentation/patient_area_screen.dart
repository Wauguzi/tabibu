import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/single_select_sheet.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D4. The county is required; the bundled sub-county list covers Nairobi
/// only, so anywhere else sends `subCountyId: null`. Finish submits the
/// patient sign-up: a [PatientSession] goes to D5, a
/// [ClinicRecordExistsSession] to [goToSession].
class PatientAreaScreen extends StatefulWidget {
  const PatientAreaScreen({super.key});

  @override
  State<PatientAreaScreen> createState() => _PatientAreaScreenState();
}

class _PatientAreaScreenState extends State<PatientAreaScreen> {
  List<CountyModel>? _counties;
  List<SubCountyModel>? _subCounties;
  int? _countyId;
  String? _countyName;
  int? _subCountyId;
  AppError? _error;

  /// A county or sub-county list failed and is still missing; the notice
  /// offers its requests again.
  bool _listsFailed = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _countyId = draft.countyId;
    _subCountyId = draft.subCountyId;
    context.read<FacilitiesBloc>()
      ..add(const FacilitiesCountiesRequested())
      ..add(const FacilitiesSubCountiesRequested());
  }

  /// The sub-county list belongs to one county (Nairobi); it shows only
  /// when the chosen county is that one. No hardcoded id.
  bool get _nairobiChosen {
    final subCounties = _subCounties;
    final countyId = _countyId;
    return subCounties != null &&
        subCounties.isNotEmpty &&
        countyId != null &&
        subCounties.first.countyId == countyId;
  }

  void _onFacilities(FacilitiesState state) {
    if (state is CountiesLoadSuccess) {
      setState(() {
        _counties = state.counties;
        final countyId = _countyId;
        if (countyId != null) {
          _countyName = state.counties
              .where((c) => c.id == countyId)
              .map((c) => c.name)
              .firstOrNull;
        }
        _clearListFailure();
      });
    } else if (state is SubCountiesLoadSuccess) {
      setState(() {
        _subCounties = state.subCounties;
        _clearListFailure();
      });
    } else if (state is CountiesLoadFailure ||
        state is SubCountiesLoadFailure) {
      setState(() {
        _error = AppError.dataNotFound;
        _listsFailed = true;
      });
    }
  }

  /// A recovered list clears the retry notice once both lists are in.
  void _clearListFailure() {
    if (_counties != null && _subCounties != null) {
      _listsFailed = false;
      if (_error == AppError.dataNotFound) _error = null;
    }
  }

  /// Resends the lists that never arrived.
  void _retryLists() {
    final retryCounties = _counties == null;
    final retrySubCounties = _subCounties == null;
    setState(() {
      _listsFailed = false;
      if (_error == AppError.dataNotFound) _error = null;
    });
    final bloc = context.read<FacilitiesBloc>();
    if (retryCounties) bloc.add(const FacilitiesCountiesRequested());
    if (retrySubCounties) bloc.add(const FacilitiesSubCountiesRequested());
  }

  Future<void> _pickCounty() async {
    final counties = _counties;
    if (counties == null) return;
    final l10n = context.l10n;
    final picked = await showSingleSelectSheet<CountyModel>(
      context: context,
      title: l10n.countyHint,
      searchHint: l10n.countySearchHint,
      items: counties,
      label: (county) => county.name,
      selected: counties.where((c) => c.id == _countyId).firstOrNull,
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _countyId = picked.id;
      _countyName = picked.name;
      _subCountyId = null;
      _error = errorAfterChange(_error, .county);
    });
  }

  SignUpDraft _fill(SignUpDraft draft) =>
      draft.copyWith(countyId: _countyId, subCountyId: _subCountyId);

  void _finish(SignUpDraft draft) {
    final countyId = _countyId;
    if (countyId == null) {
      setState(() => _error = .invalidCounty);
      return;
    }
    // The server refuses Nairobi without one of its sub-counties.
    if (_nairobiChosen && _subCountyId == null) {
      setState(() => _error = .invalidSubCounty);
      return;
    }
    final submitted = draft.copyWith(
      countyId: countyId,
      subCountyId: _nairobiChosen ? _subCountyId : null,
    );
    try {
      submitted.toPatientRequest();
    } on AppError catch (error) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: submitted));
    context.read<AuthBloc>().add(PatientSignUpRequested(draft: submitted));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<FacilitiesBloc, FacilitiesState>(
      listener: (context, state) => _onFacilities(state),
      child: BlocConsumer<AuthBloc, AuthState>(
        // A refusal is taken here, not in the builder, so the field that
        // caused it clears on its change and an old one does not return.
        listener: (context, state) {
          if (state is SignUpFailure) setState(() => _error = state.error);
          if (state is SignUpSuccess) {
            if (state.session is PatientSession) {
              // Replaces the stack: there is no back into a submitted form.
              const PatientAllSetRoute().go(context);
            } else {
              goToSession(context, state.session);
            }
          }
        },
        builder: (context, authState) {
          final busy = authState is SignUpInProgress;
          final failure = _error;
          final listsFailed = _listsFailed;
          final draft = context.watch<SignUpBloc>().state.draft;

          return DraftPopScope(
            fill: _fill,
            canPop: !busy,
            child: StepScaffold(
              step: 4,
              total: 4,
              backLabel: l10n.commonBack,
              onBack: busy ? null : () => Navigator.of(context).pop(),
              title: l10n.patientAreaTitle,
              subtitle: l10n.patientAreaSubtitle,
              error:
                  failure != null && fieldFor(failure) == null && !listsFailed
                  ? failure
                  : null,
              role: Role.patient,
              footer: TabibuButton.primary(
                label: l10n.patientFinish,
                isLoading: busy,
                onTap: busy ? null : () => _finish(draft),
              ),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  if (listsFailed) ...[
                    NoticeCard(
                      variant: .error,
                      icon: Assets.icons.cancelIcon,
                      body: AppError.dataNotFound.description(l10n),
                      action: _RetryLink(
                        label: l10n.commonRetry,
                        onTap: _retryLists,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  PickerField(
                    label: l10n.countyLabel,
                    required: true,
                    hint: l10n.countyHint,
                    value: _countyName,
                    leading: Assets.icons.locationIcon,
                    errorText: failure == .invalidCounty
                        ? fieldErrorText(failure!, l10n)
                        : null,
                    onTap: _counties == null ? null : _pickCounty,
                  ),
                  if (_countyId != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (_nairobiChosen)
                      _SubCountyPicker(
                        countyName: _countyName ?? '',
                        subCounties: _subCounties!,
                        selectedId: _subCountyId,
                        errorText: failure == .invalidSubCounty
                            ? fieldErrorText(failure!, l10n)
                            : null,
                        onSelected: (id) => setState(() {
                          _subCountyId = id;
                          _error = errorAfterChange(_error, .subCounty);
                        }),
                      )
                    else if (_subCounties == null && failure == null)
                      Center(
                        child: SpinKitCircle(
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  NoticeCard(
                    variant: NoticeVariant.info,
                    icon: Assets.icons.shieldIcon,
                    body: l10n.areaPrivacyNotice,
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

/// The retry notice's Try again link.
class _RetryLink extends StatelessWidget {
  const _RetryLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Semantics(
      button: true,
      child: Tappable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Text(
            label,
            style: style?.copyWith(
              decoration: .underline,
              color: DefaultTextStyle.of(context).style.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// D4's inline Nairobi sub-county search and cards.
class _SubCountyPicker extends StatefulWidget {
  const _SubCountyPicker({
    required this.countyName,
    required this.subCounties,
    required this.selectedId,
    required this.onSelected,
    this.errorText,
  });

  final String countyName;
  final List<SubCountyModel> subCounties;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  final String? errorText;

  @override
  State<_SubCountyPicker> createState() => _SubCountyPickerState();
}

class _SubCountyPickerState extends State<_SubCountyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final material = MaterialLocalizations.of(context);
    final errorText = widget.errorText;
    final q = _query.trim().toLowerCase();
    final matches = [
      for (final sub in widget.subCounties)
        if (q.isEmpty || sub.name.toLowerCase().contains(q)) sub,
    ];

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text.rich(
          TextSpan(
            text: l10n.subCountyLabel,
            style: textTheme.titleMedium,
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: scheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SearchField(
          hint: l10n.subCountySearchHint(widget.countyName),
          clearLabel: material.deleteButtonTooltip,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final sub in matches) ...[
          OptionCard(
            icon: Assets.icons.locationIcon,
            tone: .sky,
            title: sub.name,
            supporting: l10n.countyNoun(widget.countyName),
            selected: widget.selectedId == sub.id,
            onTap: () => widget.onSelected(sub.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (errorText != null)
          Text(
            errorText,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
            maxLines: 3,
          ),
      ],
    );
  }
}
