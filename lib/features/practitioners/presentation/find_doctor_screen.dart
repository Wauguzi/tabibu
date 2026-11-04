import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/closest_match.dart';
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
          keyboardDismissBehavior: .onDrag,
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
                sliver: SliverList.builder(
                  itemCount: (state.visible.length + 1) ~/ 2,
                  itemBuilder: (context, index) =>
                      _gridRow(state.visible, index),
                ),
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

  /// One two-up row at [index]; built only when the list asks for it.
  Widget _gridRow(List<PractitionerModel> visible, int index) {
    final i = index * 2;
    final left = visible[i];
    final right = i + 1 < visible.length ? visible[i + 1] : null;
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.bentoGap),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(child: _card(left)),
          if (right != null) ...[
            const SizedBox(width: AppSpacing.bentoGap),
            Expanded(child: _card(right)),
          ] else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
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
) => closestMatch(query, [
  for (final doctor in all) ...[
    doctor.fullName,
    for (final raw in doctor.specialties)
      Specialty.fromValue(raw)?.description(l10n) ?? raw,
  ],
]);
