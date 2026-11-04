import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_confirms.dart';
import 'package:tabibu/features/cases/presentation/widgets/share_dates.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-SHARE · Shared reports. Every share the patient made: pending ones
/// first, with a way to stop them, then the ones that ended. A row never
/// shows a code; the app holds none after the screen it was made on (T-18).
class SharedReportsScreen extends StatefulWidget {
  const SharedReportsScreen({super.key});

  @override
  State<SharedReportsScreen> createState() => _SharedReportsScreenState();
}

class _SharedReportsScreenState extends State<SharedReportsScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      _ => '',
    };
    context.read<ShareBloc>().add(
      ShareRequested(uid: _uid, role: .patient, caseUid: ''),
    );
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: _uid, role: .patient));
    }
    context.read<DirectoryBloc>().add(const DirectoryRequested());
  }

  Future<void> _refresh() async {
    final share = context.read<ShareBloc>()
      ..add(ShareRefreshed(uid: _uid, role: .patient, caseUid: ''));
    await settleRefresh<ShareState>(
      share.stream,
      (state) => state is ShareLoadInProgress,
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
    final state = context.watch<ShareBloc>().state;
    final cases = context.watch<CasesBloc>().state.cases;
    final directory = context.watch<DirectoryBloc>().state.all;
    final language = Localizations.localeOf(context).languageCode;
    final loading =
        state.shares.isEmpty &&
        (state is ShareInitial || state is ShareLoadInProgress);
    final writing = state is ShareWriteInProgress;
    // Newest first; a Join share is open only while it is Pending.
    final shares = state.shares.sortedBy((s) => s.createdAt).reversed.toList();
    final active = shares.where((s) => s.statusValue == .pending).toList();
    final ended = shares.where((s) => s.statusValue != .pending).toList();

    String nameOf(ShareCodeModel share) {
      final found = directory.firstWhereOrNull(
        (p) => p.uid == share.recipientUid,
      );
      return found == null || found.fullName.isEmpty
          ? l10n.roleDoctor
          : found.fullName;
    }

    Widget row(ShareCodeModel share, {required bool open}) {
      final caseModel =
          cases.firstWhereOrNull((c) => c.uid == share.caseUid) ??
          const CaseModel();
      final name = nameOf(share);
      final endedOn = shareDateLabel(
        share.redeemedAt.isNotEmpty ? share.redeemedAt : share.expiresAt,
        language,
      );
      final openedOn = shareDateLabel(share.redeemedAt, language);
      final ends = shareDateLabel(share.expiresAt, language);
      final subtitle = open
          ? l10n.shareListShared(
              shareDateLabel(share.createdAt, language),
              name,
            )
          : [
              l10n.shareListWasEnded(endedOn, name),
              if (openedOn.isNotEmpty) l10n.shareListOpened(openedOn),
            ].join('\n');
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            ListRowCard(
              leading: IconTile(
                icon: Assets.icons.documentIcon,
                tone: open ? .mint : .neutral,
              ),
              title: l10n.shareListReport(
                caseModel.orderNumber,
                caseModel.tests.firstOrNull?.name ?? '',
              ),
              subtitle: subtitle,
              chip: open && ends.isNotEmpty
                  ? StatusChip(label: l10n.shareListEnds(ends), tone: .info)
                  : null,
              chevron: false,
            ),
            if (open)
              Align(
                alignment: .centerRight,
                child: TabibuButton.ghost(
                  label: l10n.shareStopSharing,
                  onTap: writing ? null : () => unawaited(_stop(share, name)),
                ),
              ),
          ],
        ),
      );
    }

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
                    title: l10n.shareListTitle,
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (loading)
                    SizedBox(
                      height: 240,
                      child: LoadingView(
                        semanticLabel: l10n.resultsLoadingLabel,
                      ),
                    )
                  else if (shares.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxlg),
                      child: EmptyState(
                        title: l10n.shareListEmpty,
                        icon: Assets.icons.shareIcon,
                      ),
                    )
                  else ...[
                    if (active.isNotEmpty) ...[
                      SectionHeader(title: l10n.shareListActive),
                      const SizedBox(height: AppSpacing.sm),
                      for (final share in active) row(share, open: true),
                    ],
                    if (ended.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SectionHeader(title: l10n.shareListEnded),
                      const SizedBox(height: AppSpacing.sm),
                      for (final share in ended) row(share, open: false),
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
}
