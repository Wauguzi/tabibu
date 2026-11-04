import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/services/recording_cue_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/voice_pending_store.dart';
import 'package:tabibu/features/conversations/data/voice_send_outcome.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/mdt_routes.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_confirms.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_invite_card.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_members_sheet.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_message_bubble.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_pinned_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-MDT and PA-MDT · A consult. A member reads the thread, sends text or a
/// voice note and sees the case pinned; a person who is only invited sees the
/// invite and nothing else (rule 1). The pinned case never carries an unsigned
/// draft (rule 2).
class MdtConsultScreen extends StatefulWidget {
  /// [recorder], [player] and [cues] are injected in tests so getIt need not
  /// be configured for the composer.
  const MdtConsultScreen({
    required this.role,
    required this.conversationUid,
    this.recorder,
    this.player,
    this.cues,
    super.key,
  });

  final Role role;
  final String conversationUid;
  final AudioRecorderService? recorder;
  final AudioPlayerService? player;
  final RecordingCueService? cues;

  @override
  State<MdtConsultScreen> createState() => _MdtConsultScreenState();
}

class _MdtConsultScreenState extends State<MdtConsultScreen> {
  late final String _uid;
  final _voiceStore = VoicePendingStore();
  var _leaving = false;
  var _accepting = false;

  /// The inviter's name while a decline is in flight, for the toast.
  String _declinedInviter = '';

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    _open();
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: _uid, role: widget.role));
    }
  }

  void _open() => context.read<MdtBloc>().add(
    MdtOpened(uid: _uid, conversationUid: widget.conversationUid),
  );

  void _notify(BuildContext context, String message, {required bool isError}) {
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
        if (_leaving) {
          _leaving = false;
          context.pop();
        } else if (_accepting) {
          _accepting = false;
          // Accepting makes me a member; the thread is read only now.
          _open();
        } else if (_declinedInviter.isNotEmpty) {
          final name = _declinedInviter;
          _declinedInviter = '';
          final root = Navigator.of(context, rootNavigator: true).context;
          context.pop();
          _notify(root, l10n.mdtInviteDeclinedToast(name), isError: false);
        }
      case MdtWriteFailure(:final error):
        _leaving = false;
        _accepting = false;
        _declinedInviter = '';
        _notify(context, error.description(l10n), isError: true);
      default:
        break;
    }
  }

  void _accept() {
    _accepting = true;
    context.read<MdtBloc>().add(
      MdtRespondRequested(
        uid: _uid,
        conversationUid: widget.conversationUid,
        accept: true,
      ),
    );
  }

  Future<void> _decline(ConversationModel consult) async {
    final name = mdtMemberName(mdtInviterOf(consult, _uid));
    final confirmed = await confirmDeclineInvite(
      context,
      inviter: name,
      caseNumber: mdtRef(consult),
      test: mdtInviteAbout(consult, context.l10n),
    );
    if (!confirmed || !mounted) return;
    _declinedInviter = name;
    context.read<MdtBloc>().add(
      MdtRespondRequested(
        uid: _uid,
        conversationUid: widget.conversationUid,
        accept: false,
      ),
    );
  }

  Future<void> _openMembers(ConversationModel consult) async {
    final choice = await showMdtMembersSheet(
      context,
      consult: consult,
      myUid: _uid,
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case MdtChoseInvite():
        unawaited(
          mdtInviteRoute(
            widget.role,
            widget.conversationUid,
          ).push<void>(context),
        );
      case MdtChoseLeave():
        if (!await confirmLeaveConsult(context) || !mounted) return;
        _leaving = true;
        context.read<MdtBloc>().add(
          MdtLeaveRequested(uid: _uid, conversationUid: widget.conversationUid),
        );
      case MdtChoseRemove(:final memberUid):
        final name = mdtMemberName(
          consult.members[memberUid] ?? const ConversationMemberModel(),
        );
        if (!await confirmRemoveMember(context, name: name) || !mounted) {
          return;
        }
        context.read<MdtBloc>().add(
          MdtRemoveRequested(
            uid: _uid,
            conversationUid: widget.conversationUid,
            memberUid: memberUid,
          ),
        );
    }
  }

  void _send(String text) {
    context.read<MdtBloc>().add(
      MdtMessageSendRequested(
        uid: _uid,
        conversationUid: widget.conversationUid,
        text: text,
      ),
    );
  }

  Future<bool> _sendVoice(RecordedAudio audio) async {
    final bloc = context.read<MdtBloc>();
    final path = await _voiceStore.write(audio.bytes);
    if (!mounted) {
      await _voiceStore.delete(path);
      return false;
    }
    final event = MdtVoiceNoteSendRequested(
      uid: _uid,
      conversationUid: widget.conversationUid,
      localPath: path,
      durationMs: audio.durationMs,
      voicePeaks: audio.peaks,
      contentType: audio.contentType,
    );
    bloc.add(event);
    return await settleVoiceSend(
      result: event.result,
      path: path,
      delete: _voiceStore.delete,
    );
  }

  Future<Uint8List> _loadVoice(MessageModel message) =>
      getIt<ConversationCacheHelper>().voiceNoteBytes(message);

  /// The case link, only for someone who is on the case: the server answers
  /// a colleague's request for it with a refusal, so it is not offered.
  ({String label, VoidCallback onTap})? _caseLink(
    ConversationModel consult,
    bool inProgress,
  ) {
    final l10n = context.l10n;
    final caseUid = consult.linkedResourceUid;
    final onCase = context.watch<CasesBloc>().state.cases.any(
      (c) => c.uid == caseUid,
    );
    if (caseUid.isEmpty || !onCase) return null;
    final signed = !inProgress;
    return switch (widget.role) {
      .pathologist => (
        label: signed ? l10n.mdtOpenReport : l10n.mdtOpenCase,
        onTap: () =>
            unawaited(CaseWorkspaceRoute(caseUid: caseUid).push<void>(context)),
      ),
      _ when signed => (
        label: l10n.mdtOpenReport,
        onTap: () =>
            unawaited(DoctorReportRoute(caseUid: caseUid).push<void>(context)),
      ),
      _ => (
        label: l10n.mdtOpenCase,
        onTap: () =>
            unawaited(DoctorCaseRoute(caseUid: caseUid).push<void>(context)),
      ),
    };
  }

  /// The thread top to bottom, with "You joined" where it happened.
  List<Widget> _thread(ConversationModel consult, List<MessageModel> messages) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final joinedAt = consult.members[_uid]?.respondedAt ?? '';
    final showJoined =
        consult.createdByUid != _uid && DateTime.tryParse(joinedAt) != null;
    final joined = showJoined
        ? MdtThreadEvent(
            label: l10n.mdtYouJoined(mdtClockLabel(joinedAt, language)),
          )
        : null;
    final shown = [
      for (final m in messages)
        if ((m.kindValue == .text && m.text.isNotEmpty) ||
            m.kindValue == .voice)
          m,
    ];
    // `messages` is newest first; build oldest first, the pill before the
    // first message sent after I joined.
    final ordered = shown.reversed.toList();
    final widgets = <Widget>[];
    var placed = joined == null;
    for (final m in ordered) {
      if (!placed && m.sentAt.compareTo(joinedAt) >= 0) {
        widgets.add(joined!);
        placed = true;
      }
      widgets.add(
        MdtMessageBubble(
          key: ValueKey<String>(m.uid),
          message: m,
          mine: m.senderUid == _uid,
          sender:
              consult.members[m.senderUid] ?? const ConversationMemberModel(),
          loadVoiceBytes: _loadVoice,
        ),
      );
    }
    if (!placed) widgets.add(joined!);
    return widgets;
  }

  Widget _frame({required Widget child}) {
    final background = widget.role == .pathologist
        ? RoleBackground.pathologist
        : RoleBackground.doctor;
    return Scaffold(
      body: background(child: SafeArea(bottom: false, child: child)),
    );
  }

  Widget _topBar({String? title, String? subtitle, Widget? trailing}) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.md,
        AppSpacing.screenMargin,
        AppSpacing.xs,
      ),
      child: TopBar(
        title: title,
        subtitle: subtitle,
        backLabel: l10n.commonBack,
        onBack: context.pop,
        trailing: trailing,
      ),
    );
  }

  Widget _message(AppError error, {VoidCallback? onRetry}) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _topBar(title: l10n.mdtTitle),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  title: error.description(l10n),
                  icon: Assets.icons.mdtIcon,
                  actions: [
                    if (onRetry != null)
                      TabibuButton.primary(
                        label: l10n.commonRetry,
                        onTap: onRetry,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<MdtBloc>().state;
    final consult = state.active.uid == widget.conversationUid
        ? state.active
        : null;

    final Widget body;
    if (consult == null) {
      body = state is MdtLoadFailure
          ? _message(state.error, onRetry: _open)
          : Column(
              children: [
                _topBar(title: l10n.mdtTitle),
                Expanded(child: LoadingView(semanticLabel: l10n.mdtTitle)),
              ],
            );
    } else if (state.inviteOnly ||
        consult.members[_uid]?.statusValue != .accepted) {
      body = consult.members[_uid]?.statusValue == .invited
          ? _inviteView(consult, writing: state is MdtWriteInProgress)
          : _message(.dataNotFound);
    } else {
      body = _memberView(consult, state);
    }

    return BlocListener<MdtBloc, MdtState>(
      listenWhen: (_, current) =>
          current is MdtWriteSuccess || current is MdtWriteFailure,
      listener: _onState,
      child: _frame(child: body),
    );
  }

  Widget _inviteView(ConversationModel consult, {required bool writing}) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _topBar(title: context.l10n.mdtTitle),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: MdtInviteCard(
            consult: consult,
            inviter: mdtInviterOf(consult, _uid),
            busy: writing,
            onAccept: _accept,
            onDecline: () => unawaited(_decline(consult)),
          ),
        ),
      ],
    );
  }

  Widget _memberView(ConversationModel consult, MdtState state) {
    final l10n = context.l10n;
    final closed = consult.statusValue == .closed;
    final members = mdtAcceptedMembers(consult);
    final names = [
      for (final m in members)
        if (m.uid == _uid) l10n.mdtYou else mdtMemberShortName(m),
    ].join(', ');
    final inProgress = state.reportInProgress;
    final link = _caseLink(consult, inProgress);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _topBar(
          title: mdtConsultTitle(consult, l10n),
          subtitle: closed ? l10n.mdtMembersClosed(names) : names,
          trailing: CircleIconButton(
            icon: Assets.icons.mdtIcon,
            semanticLabel: l10n.mdtMemberCount(
              members.length,
              mdtDateLabel(
                consult.createdAt,
                Localizations.localeOf(context).languageCode,
              ),
            ),
            onTap: () => unawaited(_openMembers(consult)),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              // Starts at the newest message.
              reverse: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    if (state.offline) ...[
                      ConnectivityBanner(
                        state: .offline,
                        title: l10n.notificationsOfflineTitle,
                        body: l10n.mdtOnlyTeam,
                        retryLabel: l10n.commonRetry,
                        onRetry: _open,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    NoticeCard(
                      variant: .attention,
                      icon: Assets.icons.shieldIcon,
                      body: l10n.mdtOnlyTeam,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MdtPinnedCard(
                      consult: consult,
                      reportInProgress: inProgress,
                      openLabel: link?.label,
                      onOpen: link?.onTap,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._thread(consult, state.messages),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (closed)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.xs,
              AppSpacing.screenMargin,
              MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
            ),
            child: NoticeCard(
              variant: .neutral,
              icon: Assets.icons.infoIcon,
              title: l10n.mdtClosedSubtitle,
              body: l10n.mdtClosedBody,
            ),
          )
        else
          MdtComposer(
            hint: l10n.mdtComposer,
            sendLabel: l10n.mdtComposer,
            onSend: _send,
            onVoiceSend: _sendVoice,
            recorder: widget.recorder,
            player: widget.player,
            cues: widget.cues,
          ),
      ],
    );
  }
}
