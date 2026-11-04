import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/mdt_routes.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_confirms.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_consult_row.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-MDT and PA-MDT. A role's MDT tab: invites to answer, the consults that
/// are open, and the ones that closed. A person sees an invite only as an
/// invite until they accept (rule 1).
class MdtScreen extends StatefulWidget {
  const MdtScreen({required this.role, super.key});

  final Role role;

  @override
  State<MdtScreen> createState() => _MdtScreenState();
}

class _MdtScreenState extends State<MdtScreen> {
  late final String _uid;

  /// The consult being accepted; the person goes in once it is confirmed.
  String _accepting = '';

  /// The inviter's name while a decline is in flight, for the toast.
  String _declinedInviter = '';

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    context.read<MdtBloc>().add(MdtRequested(uid: _uid, role: widget.role));
  }

  void _load() =>
      context.read<MdtBloc>().add(MdtRequested(uid: _uid, role: widget.role));

  Future<void> _refresh() async {
    final bloc = context.read<MdtBloc>()
      ..add(MdtRefreshed(uid: _uid, role: widget.role));
    await settleRefresh<MdtState>(
      bloc.stream,
      (state) => state is MdtLoadInProgress,
    );
  }

  void _accept(ConversationModel consult) {
    _accepting = consult.uid;
    context.read<MdtBloc>().add(
      MdtRespondRequested(
        uid: _uid,
        conversationUid: consult.uid,
        accept: true,
      ),
    );
  }

  Future<void> _decline(ConversationModel consult) async {
    final l10n = context.l10n;
    final name = mdtMemberName(mdtInviterOf(consult, _uid));
    final confirmed = await confirmDeclineInvite(
      context,
      inviter: name,
      caseNumber: mdtRef(consult),
      test: mdtInviteAbout(consult, l10n),
    );
    if (!confirmed || !mounted) return;
    _declinedInviter = name;
    context.read<MdtBloc>().add(
      MdtRespondRequested(
        uid: _uid,
        conversationUid: consult.uid,
        accept: false,
      ),
    );
  }

  void _notify(String message, {required bool isError}) {
    unawaited(
      showTabibuNotification(
        context,
        message: message,
        isError: isError,
        dismissLabel: context.l10n.commonDismiss,
      ),
    );
  }

  void _onState(BuildContext context, MdtState state) {
    final l10n = context.l10n;
    switch (state) {
      case MdtWriteSuccess():
        if (_accepting.isNotEmpty) {
          final id = _accepting;
          _accepting = '';
          unawaited(mdtConsultRoute(widget.role, id).push<void>(context));
        } else if (_declinedInviter.isNotEmpty) {
          final name = _declinedInviter;
          _declinedInviter = '';
          _notify(l10n.mdtInviteDeclinedToast(name), isError: false);
        }
      case MdtWriteFailure(:final error):
        _accepting = '';
        _declinedInviter = '';
        _notify(error.description(l10n), isError: true);
      default:
        break;
    }
  }

  void _open(ConversationModel consult) =>
      unawaited(mdtConsultRoute(widget.role, consult.uid).push<void>(context));

  /// Newest activity first.
  List<ConversationModel> _newestFirst(Iterable<ConversationModel> rows) {
    String stamp(ConversationModel c) =>
        c.lastMessageAt.isNotEmpty ? c.lastMessageAt : c.createdAt;
    return rows.toList()..sort((a, b) => stamp(b).compareTo(stamp(a)));
  }

  MemberStatus? _mine(ConversationModel c) => c.members[_uid]?.statusValue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<MdtBloc>().state;
    final writing = state is MdtWriteInProgress;

    final invites = _newestFirst(
      state.invites.where(
        (c) => _mine(c) == .invited && c.statusValue == .open,
      ),
    );
    final active = _newestFirst(
      state.conversations.where(
        (c) => _mine(c) == .accepted && c.statusValue == .open,
      ),
    );
    final closed = _newestFirst(
      state.conversations.where(
        (c) => _mine(c) == .accepted && c.statusValue == .closed,
      ),
    );
    final loading =
        (state is MdtInitial || state is MdtLoadInProgress) &&
        state.conversations.isEmpty;
    final empty = invites.isEmpty && active.isEmpty && closed.isEmpty;
    final failure = state is MdtLoadFailure && empty ? state : null;
    final subtitle = widget.role == .pathologist
        ? l10n.mdtSubtitlePathologist
        : l10n.mdtSubtitleDoctor;
    final canStart = widget.role == .doctor;
    final background = widget.role == .pathologist
        ? RoleBackground.pathologist
        : RoleBackground.doctor;

    return BlocListener<MdtBloc, MdtState>(
      listenWhen: (_, current) =>
          current is MdtWriteSuccess || current is MdtWriteFailure,
      listener: _onState,
      child: Scaffold(
        floatingActionButton: canStart && !empty && !loading
            ? Padding(
                // Clears the shell's floating tab bar.
                padding: const EdgeInsets.only(bottom: 96),
                child: Fab(
                  icon: Assets.icons.addIcon,
                  semanticLabel: l10n.mdtStartConsult,
                  onTap: () =>
                      unawaited(mdtNewRoute(widget.role).push<void>(context)),
                ),
              )
            : null,
        body: background(
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator.adaptive(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenMargin,
                      AppSpacing.md,
                      AppSpacing.screenMargin,
                      MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.mdtTitle,
                            style: textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(subtitle, style: textTheme.bodyMedium),
                        if (state.offline) ...[
                          const SizedBox(height: AppSpacing.md),
                          ConnectivityBanner(
                            state: .offline,
                            title: l10n.notificationsOfflineTitle,
                            body: subtitle,
                            retryLabel: l10n.commonRetry,
                            onRetry: _load,
                          ),
                        ],
                        if (loading) ...[
                          const SizedBox(height: AppSpacing.sectionGap),
                          LoadingView(semanticLabel: l10n.mdtTitle),
                        ] else if (failure != null) ...[
                          const SizedBox(height: AppSpacing.sectionGap),
                          EmptyState(
                            title: failure.error.description(l10n),
                            icon: Assets.icons.mdtIcon,
                            actions: [
                              TabibuButton.primary(
                                label: l10n.commonRetry,
                                onTap: _load,
                              ),
                            ],
                          ),
                        ] else if (empty)
                          ..._emptyState()
                        else ...[
                          for (final c in invites) ...[
                            const SizedBox(height: AppSpacing.md),
                            MdtInviteCard(
                              consult: c,
                              inviter: mdtInviterOf(c, _uid),
                              busy: writing,
                              onAccept: () => _accept(c),
                              onDecline: () => unawaited(_decline(c)),
                            ),
                          ],
                          if (active.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(l10n.mdtActive, style: textTheme.titleLarge),
                            for (final c in active) ...[
                              const SizedBox(height: AppSpacing.sm),
                              MdtConsultRow(
                                consult: c,
                                myUid: _uid,
                                onTap: () => _open(c),
                              ),
                            ],
                          ],
                          if (closed.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(l10n.mdtClosed, style: textTheme.titleLarge),
                            for (final c in closed) ...[
                              const SizedBox(height: AppSpacing.sm),
                              MdtConsultRow(
                                consult: c,
                                myUid: _uid,
                                onTap: () => _open(c),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            NoticeCard(
                              variant: .neutral,
                              icon: Assets.icons.infoIcon,
                              body: l10n.mdtClosedNote,
                            ),
                          ],
                        ],
                      ],
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

  List<Widget> _emptyState() {
    final l10n = context.l10n;
    final doctor = widget.role == .doctor;
    return [
      const SizedBox(height: AppSpacing.sectionGap),
      EmptyState(
        title: l10n.mdtEmptyTitle,
        body: doctor ? l10n.mdtEmptyDoctor : l10n.mdtEmptyPathologist,
        icon: Assets.icons.mdtIcon,
        actions: [
          TabibuButton.primary(
            label: doctor ? l10n.mdtStartConsult : l10n.mdtGoToDesk,
            onTap: doctor
                ? () => unawaited(mdtNewRoute(widget.role).push<void>(context))
                : () => const PathologistHomeRoute().go(context),
          ),
        ],
      ),
    ];
  }
}
