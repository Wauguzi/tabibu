import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_grid_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-03. The patient directory: search, specialty chips and the doctor grid,
/// or the empty state when nothing matches.
class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  late final String _area;
  late final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    final patient = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient,
      _ => null,
    };
    _area = patient == null
        ? ''
        : patient.subCounty.isEmpty
        ? patient.county
        : patient.subCounty;
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final directory = context.read<DirectoryBloc>()
      ..add(const DirectoryRefreshed());
    await settleRefresh<DirectoryState>(
      directory.stream,
      (state) => state is DirectoryLoadInProgress,
    );
  }

  void _onQueryChanged(String value) {
    context.read<DirectoryBloc>().add(
      DirectoryQueryChanged(
        query: value,
        specialty: context.read<DirectoryBloc>().state.specialty,
      ),
    );
  }

  void _onChipSelected(Specialty? specialty) {
    context.read<DirectoryBloc>().add(
      DirectoryQueryChanged(query: _query.text, specialty: specialty),
    );
  }

  void _onClear() {
    _query.clear();
    context.read<DirectoryBloc>().add(const DirectoryQueryChanged(query: ''));
  }

  void _onSuggestion(String suggestion) {
    _query.text = suggestion;
    context.read<DirectoryBloc>().add(
      DirectoryQueryChanged(
        query: suggestion,
        specialty: context.read<DirectoryBloc>().state.specialty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<DirectoryBloc>().state;
    final loading =
        state.visible.isEmpty &&
        (state is DirectoryInitial || state is DirectoryLoadInProgress);
    final loaded =
        state is DirectoryLoadSuccess || state is DirectoryLoadFailure;
    final showEmpty = loaded && state.visible.isEmpty;

    final body = SafeArea(
      child: RefreshIndicator.adaptive(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: TopBar(
                  title: l10n.findDoctorTitle,
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      l10n.findDoctorTitle,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      l10n.findDoctorSubtitle(_area),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchField(
                  hint: l10n.findDoctorSearchHint,
                  clearLabel: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  controller: _query,
                  onChanged: _onQueryChanged,
                ),
              ),
            ),
            if (!showEmpty && !loading) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: _chips(state)),
              ),
            ],
            if (state.offline)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: ConnectivityBanner(
                    state: .offline,
                    title: l10n.findDoctorOfflineTitle,
                    body: l10n.findDoctorOfflineBody,
                    retryLabel: l10n.findDoctorRetry,
                    onRetry: () => context.read<DirectoryBloc>().add(
                      const DirectoryRefreshed(),
                    ),
                  ),
                ),
              ),
            if (loading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 280,
                    child: LoadingView(
                      semanticLabel: l10n.findDoctorLoadingLabel,
                    ),
                  ),
                ),
              )
            else if (showEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(child: _empty(state)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                ),
                sliver: SliverList.list(children: _gridRows(state.visible)),
              ),
          ],
        ),
      ),
    );
    return Scaffold(body: RoleBackground.patient(child: body));
  }

  Widget _chips(DirectoryState state) {
    final l10n = context.l10n;
    final bySpecialty = <Specialty, String>{};
    for (final doctor in state.all) {
      for (final raw in doctor.specialties) {
        final specialty = Specialty.fromValue(raw);
        if (specialty != null) {
          bySpecialty[specialty] = specialty.description(l10n);
        }
      }
    }
    final ordered = bySpecialty.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          TabibuFilterChip(
            label: l10n.findDoctorAll,
            selected: state.specialty == null,
            onTap: () => _onChipSelected(null),
          ),
          for (final chip in ordered) ...[
            const SizedBox(width: AppSpacing.sm),
            TabibuFilterChip(
              label: chip.value,
              selected: state.specialty == chip.key,
              onTap: () => _onChipSelected(chip.key),
            ),
          ],
        ],
      ),
    );
  }

  Widget _empty(DirectoryState state) {
    final l10n = context.l10n;
    final specialty = state.specialty;
    final query = state.query.isNotEmpty
        ? state.query
        : specialty?.description(l10n) ?? '';
    final suggestion = _suggestion(state.query, state.all, l10n);
    return EmptyState(
      title: l10n.findDoctorNoResultsTitle(query),
      icon: Assets.icons.searchRoundedIcon,
      body: l10n.findDoctorNoResultsBody,
      actions: [
        if (suggestion != null)
          SuggestionPill(
            label: suggestion,
            onTap: () => _onSuggestion(suggestion),
          ),
        SuggestionPill(label: l10n.findDoctorClearSearch, onTap: _onClear),
      ],
      tips: TipsCard(
        title: l10n.findDoctorTipsTitle,
        tips: [
          l10n.findDoctorTipSpecialty,
          l10n.findDoctorTipHospital,
          l10n.findDoctorTipArea(_area),
        ],
      ),
    );
  }

  List<Widget> _gridRows(List<PractitionerModel> visible) {
    final rows = <Widget>[];
    for (var i = 0; i < visible.length; i += 2) {
      if (i > 0) {
        rows.add(const SizedBox(height: AppSpacing.bentoGap));
      }
      final pair = visible.skip(i).take(2).toList();
      rows.add(
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(child: _card(pair[0])),
            if (pair.length == 2) ...[
              const SizedBox(width: AppSpacing.bentoGap),
              Expanded(child: _card(pair[1])),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    }
    return rows;
  }

  Widget _card(PractitionerModel doctor) {
    final l10n = context.l10n;
    final raw = doctor.specialties.firstOrNull ?? '';
    return DoctorGridCard(
      name: doctor.fullName,
      specialty: raw.isEmpty
          ? ''
          : Specialty.fromValue(raw)?.description(l10n) ?? raw,
      onTap: () =>
          PractitionerProfileRoute(doctorUid: doctor.uid).push<void>(context),
      image: doctor.profilePictureUrl.isEmpty
          ? null
          : NetworkImage(doctor.profilePictureUrl),
    );
  }
}

/// The closest doctor name or specialty label to a failing query, or null
/// when nothing is near enough to suggest.
String? _suggestion(
  String query,
  List<PractitionerModel> all,
  AppLocalizations l10n,
) {
  final needle = query.trim().toLowerCase();
  if (needle.length < 3) return null;
  final labels = <String>{
    for (final doctor in all) ...[
      doctor.fullName,
      for (final raw in doctor.specialties)
        Specialty.fromValue(raw)?.description(l10n) ?? raw,
    ],
  }..removeWhere((label) => label.trim().isEmpty);
  final allowance = (needle.length / 3).ceil().clamp(2, 4);
  String? best;
  var bestDistance = allowance + 1;
  for (final label in labels.toList()..sort()) {
    final words = [label.toLowerCase(), ...label.toLowerCase().split(' ')];
    final distance = words.map((w) => _editDistance(needle, w)).reduce(min);
    if (distance > 0 && distance < bestDistance) {
      best = label;
      bestDistance = distance;
    }
  }
  return bestDistance <= allowance ? best : null;
}

int _editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final current = [i, ...List.filled(b.length, 0)];
    for (var j = 1; j <= b.length; j++) {
      current[j] = min(
        min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + (a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1),
      );
    }
    previous = current;
  }
  return previous[b.length];
}
