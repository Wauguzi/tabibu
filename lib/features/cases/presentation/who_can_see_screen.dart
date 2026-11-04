import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_viewer.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_confirms.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_dates.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-SHARE · Who can see my results. The care team (never removable here)
/// and the people the patient shared with, as the server holds them. Both
/// ways of taking access away ask first and name who loses it (rule 2).
class WhoCanSeeScreen extends StatefulWidget {
  const WhoCanSeeScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  State<WhoCanSeeScreen> createState() => _WhoCanSeeScreenState();
}

class _WhoCanSeeScreenState extends State<WhoCanSeeScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    context.read<ShareBloc>().add(
      ShareRequested(uid: _uid, role: .patient, caseUid: widget.caseUid),
    );
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  Future<void> _refresh() async {
    final share = context.read<ShareBloc>()
      ..add(ShareRefreshed(uid: _uid, role: .patient, caseUid: widget.caseUid));
    await settleRefresh<ShareState>(
      share.stream,
      (state) => state is ShareLoadInProgress,
    );
  }

  Future<void> _remove(ShareViewer viewer) async {
    final name = _nameOf(context.l10n, viewer);
    if (!await confirmRemoveViewer(context, name: name)) return;
    if (!mounted) return;
    context.read<ShareBloc>().add(
      ShareRemoveViewerRequested(
        uid: _uid,
        caseUid: widget.caseUid,
        viewerUid: viewer.uid,
      ),
    );
  }

  Future<void> _stop(ShareCodeModel share, String name) async {
    if (!await confirmStopSharing(context, name: name)) return;
    if (!mounted) return;
    context.read<ShareBloc>().add(
      ShareRevokeRequested(uid: _uid, shareUid: share.uid),
    );
  }

  void _onShareState(BuildContext context, ShareState state) {
    final error = switch (state) {
      ShareWriteFailure(:final error) => error,
      ShareLoadFailure(:final error) => error,
      _ => null,
    };
    if (error == null) return;
    unawaited(
      showTabibuNotification(
        context,
        message: error.description(context.l10n),
        isError: true,
        dismissLabel: context.l10n.commonDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<ShareBloc>().state;
    final directory = context.watch<DirectoryBloc>().state.all;
    final loading =
        state.viewers.isEmpty &&
        (state is ShareInitial || state is ShareLoadInProgress);
    final writing = state is ShareWriteInProgress;
    final careTeam = state.viewers.where((v) => !v.removable).toList();
    final sharedViewers = state.viewers.where((v) => v.removable).toList();
    // A pending share has no access yet; it can still be called back.
    final pending = state.shares
        .where((s) => s.statusValue == .pending)
        .map((s) => (share: s, practitioner: _find(directory, s.recipientUid)))
        .where((e) => e.practitioner != null)
        .toList();

    return BlocListener<ShareBloc, ShareState>(
      listenWhen: (_, current) =>
          current is ShareWriteFailure || current is ShareLoadFailure,
      listener: _onShareState,
      child: Scaffold(
        body: RoleBackground.patient(
          child: SafeArea(
            child: RefreshIndicator.adaptive(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                children: [
                  TopBar(
                    title: l10n.shareWhoCanSeeTitle,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.shareWhoCanSeeBody, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sectionGap),
                  if (loading)
                    SizedBox(
                      height: 240,
                      child: LoadingView(
                        semanticLabel: l10n.resultsLoadingLabel,
                      ),
                    )
                  else ...[
                    if (careTeam.isNotEmpty) ...[
                      SectionHeader(title: l10n.shareCareTeam),
                      const SizedBox(height: AppSpacing.sm),
                      for (final viewer in careTeam) ...[
                        _careTeamRow(context, viewer, directory),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                    if (sharedViewers.isNotEmpty || pending.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SectionHeader(title: l10n.shareSharedPeople),
                      const SizedBox(height: AppSpacing.sm),
                      for (final viewer in sharedViewers) ...[
                        _SharedRow(
                          title: _nameOf(l10n, viewer),
                          subtitle: _roleLabel(l10n, viewer.role),
                          untilLabel: null,
                          busy: writing,
                          onStop: () => unawaited(_remove(viewer)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      for (final entry in pending) ...[
                        _SharedRow(
                          title: entry.practitioner!.fullName,
                          subtitle: _roleLabel(
                            l10n,
                            entry.practitioner!.isPathologist
                                ? .pathologist
                                : .doctor,
                          ),
                          untilLabel: _until(context, entry.share.expiresAt),
                          busy: writing,
                          onStop: () => unawaited(
                            _stop(entry.share, entry.practitioner!.fullName),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PractitionerModel? _find(List<PractitionerModel> all, String uid) =>
      all.firstWhereOrNull((p) => p.uid == uid);

  String _roleLabel(AppLocalizations l10n, ActorRole role) => switch (role) {
    .pathologist => l10n.rolePathologist,
    _ => l10n.roleDoctor,
  };

  String _nameOf(AppLocalizations l10n, ShareViewer viewer) =>
      viewer.displayName.isEmpty
      ? _roleLabel(l10n, viewer.role)
      : viewer.displayName;

  String? _until(BuildContext context, String expiresAt) {
    final date = shareDateLabel(
      expiresAt,
      Localizations.localeOf(context).languageCode,
    );
    return date.isEmpty ? null : context.l10n.shareUntil(date);
  }

  Widget _careTeamRow(
    BuildContext context,
    ShareViewer viewer,
    List<PractitionerModel> directory,
  ) {
    final l10n = context.l10n;
    final subtitle = switch (viewer.role) {
      .pathologist => l10n.shareReviewedBy,
      _ => l10n.shareOrderedBy(
        _specialtyOf(l10n, _find(directory, viewer.uid)),
      ),
    };
    return ListRowCard(
      leading: IconTile(
        icon: viewer.role == .pathologist
            ? Assets.icons.testTubeIcon
            : Assets.icons.stethoscopeIcon,
        tone: viewer.role == .pathologist ? .lavender : .mint,
      ),
      title: _nameOf(l10n, viewer),
      subtitle: subtitle,
      chip: StatusChip(label: l10n.shareFullAccess, tone: .signed),
      chevron: false,
    );
  }

  String _specialtyOf(AppLocalizations l10n, PractitionerModel? doctor) {
    final raw = doctor?.specialties.firstOrNull ?? '';
    if (raw.isEmpty) return l10n.roleDoctor.toLowerCase();
    return Specialty.fromValue(raw)?.description(l10n) ?? raw;
  }
}

class _SharedRow extends StatelessWidget {
  const _SharedRow({
    required this.title,
    required this.subtitle,
    required this.untilLabel,
    required this.busy,
    required this.onStop,
  });

  final String title;
  final String subtitle;
  final String? untilLabel;
  final bool busy;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ListRowCard(
          leading: IconTile(icon: Assets.icons.personIcon, tone: .sky),
          title: title,
          subtitle: [subtitle, ?untilLabel].join(' · '),
          chip: StatusChip(label: l10n.shareThisReportOnly, tone: .info),
          chevron: false,
        ),
        Align(
          alignment: .centerRight,
          child: TabibuButton.ghost(
            label: l10n.shareStopSharing,
            onTap: busy ? null : onStop,
          ),
        ),
      ],
    );
  }
}
