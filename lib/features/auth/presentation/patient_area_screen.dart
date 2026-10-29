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
      });
    } else if (state is SubCountiesLoadSuccess) {
      setState(() => _subCounties = state.subCounties);
    } else if (state is CountiesLoadFailure ||
        state is SubCountiesLoadFailure) {
      setState(() => _error = AppError.dataNotFound);
    }
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
    if (picked == null) return;
    setState(() {
      _countyId = picked.id;
      _countyName = picked.name;
      _subCountyId = null;
      _error = null;
    });
  }

  SignUpDraft _fill(SignUpDraft draft) =>
      draft.copyWith(countyId: _countyId, subCountyId: _subCountyId);

  void _finish(SignUpDraft draft) {
    final countyId = _countyId;
    if (countyId == null) {
      setState(() => _error = AppError.invalidCounty);
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
        listener: (context, state) {
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
          final failure = authState is SignUpFailure ? authState.error : _error;
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
              error: failure,
              role: Role.patient,
              footer: TabibuButton.primary(
                label: l10n.patientFinish,
                isLoading: busy,
                onTap: busy ? null : () => _finish(draft),
              ),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  PickerField(
                    label: l10n.countyLabel,
                    required: true,
                    hint: l10n.countyHint,
                    value: _countyName,
                    leading: Assets.icons.locationIcon,
                    onTap: _counties == null ? null : _pickCounty,
                  ),
                  if (_countyId != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (_nairobiChosen)
                      _SubCountyPicker(
                        countyName: _countyName ?? '',
                        subCounties: _subCounties!,
                        selectedId: _subCountyId,
                        onSelected: (id) => setState(() {
                          _subCountyId = id;
                          _error = null;
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

/// D4's inline Nairobi sub-county search and cards.
class _SubCountyPicker extends StatefulWidget {
  const _SubCountyPicker({
    required this.countyName,
    required this.subCounties,
    required this.selectedId,
    required this.onSelected,
  });

  final String countyName;
  final List<SubCountyModel> subCounties;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  State<_SubCountyPicker> createState() => _SubCountyPickerState();
}

class _SubCountyPickerState extends State<_SubCountyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final material = MaterialLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final matches = [
      for (final sub in widget.subCounties)
        if (q.isEmpty || sub.name.toLowerCase().contains(q)) sub,
    ];

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(l10n.subCountyLabel, style: textTheme.titleMedium),
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
      ],
    );
  }
}
