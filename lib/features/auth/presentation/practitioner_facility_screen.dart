import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/facility_group.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E3 and F3. The facility comes from the bundled Nairobi list only, with
/// "All" plus the types and KEPH levels in the data as filters.
/// Non-operational rows show greyed and cannot be chosen.
class PractitionerFacilityScreen extends StatefulWidget {
  const PractitionerFacilityScreen({super.key});

  @override
  State<PractitionerFacilityScreen> createState() =>
      _PractitionerFacilityScreenState();
}

class _PractitionerFacilityScreenState
    extends State<PractitionerFacilityScreen> {
  late final TextEditingController _bioController;
  List<FacilityModel>? _results;
  List<String> _levels = [];
  FacilityGroup? _typeFilter;
  String? _levelFilter;
  String _query = '';
  String _facilityId = '';
  bool _isAvailable = true;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _bioController = TextEditingController(text: draft.bio);
    _facilityId = draft.facilityId;
    _isAvailable = draft.isAvailable;
    context.read<FacilitiesBloc>().add(const FacilitiesSearchRequested(''));
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _onSearch(FacilitiesState state) {
    if (state is FacilitiesSearchSuccess) {
      setState(() {
        _results = state.results;
        // The level chips come from the first success, which answers the
        // empty query sent at init (the whole list), so typing never
        // reshuffles them.
        if (_levels.isEmpty) {
          final levels = <String>{};
          for (final facility in state.results) {
            levels.add(facility.kephLevel);
          }
          _levels = levels.toList()..sort();
        }
      });
    } else if (state is FacilitiesSearchFailure) {
      setState(() => _error = state.error);
    } else if (state is FacilitiesSearchInProgress) {
      setState(() => _results = null);
    }
  }

  /// The F3 list: labs and hospitals only, chips combine, and with no
  /// query the labs come first, then the highest level.
  List<FacilityModel> _pathologistVisible(List<FacilityModel> results) {
    final visible = [
      for (final facility in results)
        if (_labListed(facility)) facility,
    ];
    if (_query.trim().isEmpty) {
      visible.sort((a, b) {
        final aIsLab =
            facilityGroupOf(a.facilityType) == FacilityGroup.laboratory;
        final bIsLab =
            facilityGroupOf(b.facilityType) == FacilityGroup.laboratory;
        if (aIsLab != bIsLab) return aIsLab ? -1 : 1;
        final byLevel = _levelNumber(
          b.kephLevel,
        ).compareTo(_levelNumber(a.kephLevel));
        if (byLevel != 0) return byLevel;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    return visible;
  }

  bool _labListed(FacilityModel facility) {
    final group = facilityGroupOf(facility.facilityType);
    if (group != FacilityGroup.laboratory && group != FacilityGroup.hospital) {
      return false;
    }
    if (_typeFilter != null && group != _typeFilter) return false;
    if (_levelFilter != null && facility.kephLevel != _levelFilter) {
      return false;
    }
    return true;
  }

  /// Only state-run owners read as public; faith-based, NGO and company
  /// facilities report as private.
  bool _isPublicOwner(String owner) {
    final normalized = owner.toLowerCase();
    return normalized.startsWith('ministry of health') ||
        normalized.startsWith('public institution') ||
        normalized.startsWith('local authority') ||
        normalized == 'armed forces' ||
        normalized == 'community';
  }

  /// The E3 list: ungrouped types and labs excluded, chips combine, and with
  /// no query the highest-level facilities come first.
  List<FacilityModel> _doctorVisible(List<FacilityModel> results) {
    final visible = [
      for (final facility in results)
        if (_doctorListed(facility)) facility,
    ];
    if (_query.trim().isEmpty) {
      visible.sort((a, b) {
        final byLevel = _levelNumber(
          b.kephLevel,
        ).compareTo(_levelNumber(a.kephLevel));
        if (byLevel != 0) return byLevel;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    return visible;
  }

  bool _doctorListed(FacilityModel facility) {
    final group = facilityGroupOf(facility.facilityType);
    if (group == null || group == FacilityGroup.laboratory) return false;
    if (_typeFilter != null && group != _typeFilter) return false;
    if (_levelFilter != null && facility.kephLevel != _levelFilter) {
      return false;
    }
    return true;
  }

  int _levelNumber(String level) =>
      int.tryParse(level.replaceAll('Level ', '')) ?? 0;

  SignUpDraft _fill(SignUpDraft draft) => draft.copyWith(
    facilityId: _facilityId,
    bio: _bioController.text.trim(),
    isAvailable: _isAvailable,
  );

  void _continue() {
    if (_facilityId.isEmpty) {
      setState(() => _error = AppError.invalidFacility);
      return;
    }
    setState(() => _error = null);
    final draft = _fill(context.read<SignUpBloc>().state.draft);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));
    unawaited(const PractitionerReviewRoute().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final role = context.watch<SignUpBloc>().state.draft.role;
    final isPathologist = role == Role.pathologist;
    final results = _results;
    final visible = results == null
        ? null
        : isPathologist
        ? _pathologistVisible(results)
        : _doctorVisible(results);
    final groupChips = isPathologist
        ? [
            (FacilityGroup.laboratory, l10n.filterLabs),
            (FacilityGroup.hospital, l10n.filterHospitals),
          ]
        : [
            (FacilityGroup.hospital, l10n.filterHospital),
            (FacilityGroup.healthCentre, l10n.filterHealthCentre),
            (FacilityGroup.clinic, l10n.filterClinic),
            (FacilityGroup.dispensary, l10n.filterDispensary),
          ];

    return BlocListener<FacilitiesBloc, FacilitiesState>(
      listener: (context, state) => _onSearch(state),
      child: DraftPopScope(
        fill: _fill,
        child: StepScaffold(
          step: 3,
          total: 4,
          backLabel: l10n.commonBack,
          onBack: () => Navigator.of(context).pop(),
          title: isPathologist ? l10n.labTitle : l10n.facilityTitle,
          subtitle: isPathologist
              ? l10n.labSubtitle
              : l10n.facilityDoctorSubtitle,
          error: _error,
          role: role,
          footer: TabibuButton.primary(
            label: l10n.commonContinue,
            onTap: _continue,
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  SearchField(
                    hint: isPathologist
                        ? l10n.labSearchHint
                        : l10n.facilitySearchHint,
                    clearLabel: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    onChanged: (query) {
                      setState(() {
                        _error = null;
                        _query = query;
                      });
                      context.read<FacilitiesBloc>().add(
                        FacilitiesSearchRequested(query),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Row(
                      children: [
                        TabibuFilterChip(
                          label: l10n.filterAll,
                          selected: _typeFilter == null && _levelFilter == null,
                          onTap: () => setState(() {
                            _typeFilter = null;
                            _levelFilter = null;
                          }),
                        ),
                        for (final (group, label) in groupChips) ...[
                          const SizedBox(width: AppSpacing.xs),
                          TabibuFilterChip(
                            label: label,
                            selected: _typeFilter == group,
                            onTap: () => setState(
                              () => _typeFilter = _typeFilter == group
                                  ? null
                                  : group,
                            ),
                          ),
                        ],
                        for (final level in _levels) ...[
                          const SizedBox(width: AppSpacing.xs),
                          TabibuFilterChip(
                            label: level,
                            selected: _levelFilter == level,
                            onTap: () => setState(
                              () => _levelFilter = _levelFilter == level
                                  ? null
                                  : level,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (visible == null && _error == null)
                    Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    )
                  else if (visible == null)
                    const SizedBox.shrink()
                  else if (visible.isEmpty)
                    _EmptyResults(),
                ],
              ),
            ),
            if (visible != null && visible.isNotEmpty)
              SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final facility = visible[index];
                  final ownership = _isPublicOwner(facility.owner)
                      ? l10n.ownerPublic
                      : l10n.ownerPrivate;
                  final supporting = isPathologist
                      ? '$ownership · ${facility.kephLevel} · '
                            '${facility.subCounty}'
                      : '${facility.kephLevel} · ${facility.ward}, '
                            '${facility.subCounty} · '
                            '${l10n.facilityMfl(facility.mflCode)}';
                  final card = OptionCard(
                    icon: isPathologist
                        ? Assets.icons.testTubeIcon
                        : Assets.icons.facilityIcon,
                    tone: isPathologist ? .lavender : .mint,
                    title: facility.name,
                    supporting: supporting,
                    selected: _facilityId == facility.facilityId,
                    onTap: facility.isOperational
                        ? () => setState(() {
                            _facilityId = facility.facilityId;
                            _error = null;
                          })
                        : null,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: facility.isOperational
                        ? card
                        : Opacity(opacity: 0.5, child: card),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  NoticeCard(
                    variant: NoticeVariant.info,
                    icon: Assets.icons.infoIcon,
                    body: l10n.facilityPilotNotice,
                  ),
                  if (isPathologist) ...[
                    const SizedBox(height: AppSpacing.sm),
                    NoticeCard(
                      variant: NoticeVariant.info,
                      icon: Assets.icons.infoIcon,
                      body: l10n.multiLabNotice,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.profileSectionTitle, style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  TabibuTextField(
                    label: l10n.bioLabel,
                    hint: l10n.bioHint,
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 300,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingToggleCard(
                    icon: Assets.icons.calendarIcon,
                    tone: .mint,
                    title: isPathologist
                        ? l10n.availabilityPathologistTitle
                        : l10n.availabilityDoctorTitle,
                    supporting: isPathologist
                        ? l10n.availabilityPathologistBody
                        : l10n.availabilityDoctorBody,
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// E3/F3's no-matches placeholder.
class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          IconTile(
            icon: Assets.icons.searchRoundedIcon,
            tone: .sky,
            size: IconTileSize.l,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.facilityEmptyTitle, style: textTheme.titleMedium),
          Text(
            l10n.facilityEmptyBody,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
