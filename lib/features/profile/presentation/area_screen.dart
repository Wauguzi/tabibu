import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/single_select_sheet.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-AREA: the patient's county and sub-county over the `updatePatientArea`
/// callable. The county list and the Nairobi sub-county list come from the
/// facilities bloc (D4's pattern); the current area prefills by name, and a
/// save without changes leaves without writing.
class AreaScreen extends StatefulWidget {
  const AreaScreen({super.key});

  @override
  State<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  List<CountyModel>? _counties;
  List<SubCountyModel>? _subCounties;
  int? _countyId;
  String? _countyName;
  int? _subCountyId;
  String? _subCountyName;
  int? _origCountyId;
  int? _origSubCountyId;
  bool _countyPrefilled = false;
  bool _subPrefilled = false;
  String? _countyError;
  String? _subCountyError;
  bool _saving = false;

  /// A county or sub-county list failed and is still missing; the notice
  /// offers its requests again.
  bool _listsFailed = false;

  @override
  void initState() {
    super.initState();
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

  /// The session's area names resolve to ids once the lists arrive; a name
  /// the lists no longer carry stays unpicked.
  void _prefill(String county, String subCounty) {
    final counties = _counties;
    if (counties != null && !_countyPrefilled) {
      _countyPrefilled = true;
      final match = counties.where((c) => c.name == county).firstOrNull;
      if (match != null) {
        _countyId = match.id;
        _countyName = match.name;
        _origCountyId = match.id;
      }
    }
    final subCounties = _subCounties;
    if (subCounties != null && !_subPrefilled) {
      _subPrefilled = true;
      final match = subCounties.where((s) => s.name == subCounty).firstOrNull;
      if (match != null) {
        _subCountyId = match.id;
        _subCountyName = match.name;
        _origSubCountyId = match.id;
      }
    }
  }

  void _onFacilities(FacilitiesState state) {
    if (state is CountiesLoadSuccess) {
      setState(() {
        _counties = state.counties;
        if (_counties != null && _subCounties != null) _listsFailed = false;
      });
    } else if (state is SubCountiesLoadSuccess) {
      setState(() {
        _subCounties = state.subCounties;
        if (_counties != null && _subCounties != null) _listsFailed = false;
      });
    } else if (state is CountiesLoadFailure ||
        state is SubCountiesLoadFailure) {
      setState(() => _listsFailed = true);
    }
  }

  /// Resends the lists that never arrived.
  void _retryLists() {
    final retryCounties = _counties == null;
    final retrySubCounties = _subCounties == null;
    setState(() => _listsFailed = false);
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
      title: l10n.areaCounty,
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
      _subCountyName = null;
      _countyError = null;
    });
  }

  Future<void> _pickSubCounty() async {
    final subCounties = _subCounties;
    if (subCounties == null) return;
    final l10n = context.l10n;
    final picked = await showSingleSelectSheet<SubCountyModel>(
      context: context,
      title: l10n.areaSubCounty,
      searchHint: l10n.subCountySearchHint(_countyName ?? ''),
      items: subCounties,
      label: (sub) => sub.name,
      selected: subCounties.where((s) => s.id == _subCountyId).firstOrNull,
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _subCountyId = picked.id;
      _subCountyName = picked.name;
      _subCountyError = null;
    });
  }

  void _save() {
    final l10n = context.l10n;
    final countyId = _countyId;
    if (countyId == null) {
      setState(() => _countyError = l10n.areaCountyRequired);
      return;
    }
    // The server refuses Nairobi without one of its sub-counties.
    if (_nairobiChosen && _subCountyId == null) {
      setState(() => _subCountyError = l10n.areaSubCountyRequired);
      return;
    }
    if (countyId == _origCountyId && _subCountyId == _origSubCountyId) {
      context.pop();
      return;
    }
    setState(() => _saving = true);
    context.read<AuthBloc>().add(
      PatientAreaChanged(
        countyId: countyId,
        subCountyId: _nairobiChosen ? _subCountyId : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = SafeArea(
      child: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          sliver: SliverList.list(
            children: [
              TopBar(
                backLabel: l10n.commonBack,
                onBack: context.pop,
                title: l10n.areaTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.areaBody, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.md),
              BlocListener<FacilitiesBloc, FacilitiesState>(
                listener: (context, state) => _onFacilities(state),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (_, _) => _saving,
                  listener: (context, state) {
                    switch (state) {
                      case ProfileSaveSuccess():
                        context.pop();
                      case ProfileSaveFailure(:final error):
                        setState(() => _saving = false);
                        unawaited(
                          showTabibuNotification(
                            context,
                            message: error.description(l10n),
                            isError: true,
                            dismissLabel: l10n.commonDismiss,
                          ),
                        );
                      default:
                        break;
                    }
                  },
                  builder: (context, state) {
                    final patient = switch (state.session) {
                      PatientSession(:final patient) => patient,
                      _ => null,
                    };
                    // The router bounces the signed-out off role paths; this is
                    // the frame between a sign-out and its redirect.
                    if (patient == null) return const SizedBox.shrink();
                    _prefill(patient.county, patient.subCounty);
                    return Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        if (_listsFailed) ...[
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
                          label: l10n.areaCounty,
                          required: true,
                          hint: l10n.countyHint,
                          value: _countyName,
                          leading: Assets.icons.locationIcon,
                          errorText: _countyError,
                          onTap: _counties == null ? null : _pickCounty,
                        ),
                        if (_countyId != null && _nairobiChosen) ...[
                          const SizedBox(height: AppSpacing.md),
                          PickerField(
                            label: l10n.areaSubCounty,
                            required: true,
                            hint: l10n.subCountyLabel,
                            value: _subCountyName,
                            leading: Assets.icons.locationIcon,
                            errorText: _subCountyError,
                            onTap: _pickSubCounty,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        TabibuButton.primary(
                          label: l10n.areaSave,
                          isLoading: _saving,
                          // Both lists decide the payload: Nairobi without a
                          // sub-county is refused, so Save waits for them.
                          onTap:
                              _counties == null ||
                                  _subCounties == null ||
                                  _saving
                              ? null
                              : _save,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
    return Scaffold(body: RoleBackground.patient(child: body));
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
