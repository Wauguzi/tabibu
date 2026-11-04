import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/services/recording_cue_service.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_bloc.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_event.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/voice_pending_store.dart';
import 'package:tabibu/features/conversations/data/voice_send_outcome.dart';
import 'package:tabibu/features/conversations/presentation/mdt_labels.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_message_bubble.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-CHAT / D-CHAT. The direct thread of one appointment. Text and voice
/// notes (no PDF, no "Last seen"). A closed thread is read-only.
class AppointmentChatScreen extends StatefulWidget {
  /// [recorder], [player] and [cues] are injected in tests so getIt need not
  /// be configured for the composer.
  const AppointmentChatScreen({
    required this.role,
    required this.appointmentUid,
    this.recorder,
    this.player,
    this.cues,
    super.key,
  });

  final Role role;
  final String appointmentUid;
  final AudioRecorderService? recorder;
  final AudioPlayerService? player;
  final RecordingCueService? cues;

  @override
  State<AppointmentChatScreen> createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  late final String _uid;
  final _voiceStore = VoicePendingStore();

  @override
  void initState() {
    super.initState();
    _uid = switch (context.read<AuthBloc>().state.session) {
      PatientSession(:final patient) => patient.uid,
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final appointments = context.read<AppointmentsBloc>();
    if (appointments.state.appointments.none(
      (a) => a.uid == widget.appointmentUid,
    )) {
      appointments.add(AppointmentsRequested(uid: _uid, role: widget.role));
    }
    _open();
  }

  void _open() => context.read<ChatBloc>().add(
    ChatOpened(
      uid: _uid,
      role: widget.role,
      appointmentUid: widget.appointmentUid,
    ),
  );

  void _refresh(String conversationUid) => context.read<ChatBloc>().add(
    ChatRefreshed(uid: _uid, conversationUid: conversationUid),
  );

  void _send(String text) {
    final conversation = context.read<ChatBloc>().state.conversation;
    if (conversation.uid.isEmpty) return;
    context.read<ChatBloc>().add(
      ChatMessageSendRequested(
        uid: _uid,
        conversationUid: conversation.uid,
        text: text,
      ),
    );
  }

  Future<bool> _sendVoice(RecordedAudio audio) async {
    final conversation = context.read<ChatBloc>().state.conversation;
    if (conversation.uid.isEmpty) return false;
    final bloc = context.read<ChatBloc>();
    final path = await _voiceStore.write(audio.bytes);
    if (!mounted) {
      await _voiceStore.delete(path);
      return false;
    }
    final event = ChatVoiceNoteSendRequested(
      uid: _uid,
      conversationUid: conversation.uid,
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

  void _onState(BuildContext context, ChatState state) {
    if (state is ChatWriteFailure) {
      _notify(state.error.description(context.l10n), isError: true);
    }
  }

  /// The other person on the thread: appointment names first, then members.
  String _counterpartName(ConversationModel conversation) {
    final appointment = context
        .watch<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == widget.appointmentUid);
    if (widget.role == .patient) {
      final doctor = appointment?.doctorName.trim() ?? '';
      if (doctor.isNotEmpty) return doctor;
    } else {
      final patient = appointment?.patientName.trim() ?? '';
      if (patient.isNotEmpty) return patient;
    }
    for (final member in conversation.members.values) {
      if (member.uid == _uid) continue;
      final name = mdtMemberShortName(member);
      if (name.isNotEmpty) return name;
    }
    return context.l10n.chatRowTitle;
  }

  String _appointmentDateLabel() {
    final appointment = context
        .read<AppointmentsBloc>()
        .state
        .appointments
        .firstWhereOrNull((a) => a.uid == widget.appointmentUid);
    final start = nairobiTimeOf(appointment?.scheduledStart ?? '');
    if (start == null) return '';
    final language = Localizations.localeOf(context).languageCode;
    return DateFormat('EEE d MMM', language).format(start);
  }

  List<Widget> _thread(
    ConversationModel conversation,
    List<MessageModel> messages,
  ) {
    final shown = [
      for (final m in messages)
        if ((m.kindValue == .text && m.text.isNotEmpty) ||
            m.kindValue == .voice)
          m,
    ];
    return [
      for (final m in shown.reversed)
        MdtMessageBubble(
          key: ValueKey<String>(m.uid),
          message: m,
          mine: m.senderUid == _uid,
          sender:
              conversation.members[m.senderUid] ??
              const ConversationMemberModel(),
          loadVoiceBytes: _loadVoice,
        ),
    ];
  }

  Widget _frame({required Widget child}) {
    final background = switch (widget.role) {
      .patient => RoleBackground.patient,
      .pathologist => RoleBackground.pathologist,
      _ => RoleBackground.doctor,
    };
    return Scaffold(
      body: background(child: SafeArea(bottom: false, child: child)),
    );
  }

  Widget _topBar({String? title, String? subtitle}) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ChatBloc>().state;
    final conversation = state.conversation;
    final held =
        conversation.uid.isNotEmpty &&
        conversation.linkedResourceUid == widget.appointmentUid;

    final Widget body;
    if (!held) {
      if (state is ChatLoadFailure) {
        body = Column(
          crossAxisAlignment: .stretch,
          children: [
            _topBar(title: l10n.chatRowTitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: Center(
                  child: EmptyState(
                    title: state.error.description(l10n),
                    icon: Assets.icons.chatIcon,
                    actions: [
                      TabibuButton.primary(
                        label: l10n.commonRetry,
                        onTap: _open,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        body = Column(
          children: [
            _topBar(title: l10n.chatRowTitle),
            Expanded(child: LoadingView(semanticLabel: l10n.chatRowTitle)),
          ],
        );
      }
    } else {
      body = _threadView(conversation, state);
    }

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (_, current) => current is ChatWriteFailure,
      listener: _onState,
      child: _frame(child: body),
    );
  }

  Widget _threadView(ConversationModel conversation, ChatState state) {
    final l10n = context.l10n;
    final name = _counterpartName(conversation);
    final date = _appointmentDateLabel();
    final closed = state.readOnly;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _topBar(
          title: name,
          subtitle: date.isEmpty
              ? l10n.chatClosesWhen
              : l10n.chatBelongsTo(date),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: () async => _refresh(conversation.uid),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          body: l10n.chatOnlyYou(name),
                          retryLabel: l10n.commonRetry,
                          onRetry: () => _refresh(conversation.uid),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      NoticeCard(
                        variant: .attention,
                        icon: Assets.icons.shieldIcon,
                        body: l10n.chatOnlyYou(name),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (date.isNotEmpty) ...[
                        NoticeCard(
                          variant: .neutral,
                          icon: Assets.icons.calendarIcon,
                          body: closed
                              ? l10n.chatBelongsTo(date)
                              : '${l10n.chatBelongsTo(date)} '
                                    '${l10n.chatClosesWhen}',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      ..._thread(conversation, state.messages),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
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
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                NoticeCard(
                  variant: .neutral,
                  icon: Assets.icons.infoIcon,
                  body: l10n.chatClosesWhen,
                ),
                if (widget.role == .patient) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TabibuButton.primary(
                    label: l10n.chatBookFollowUp,
                    onTap: () =>
                        unawaited(const FindDoctorRoute().push<void>(context)),
                  ),
                ],
              ],
            ),
          )
        else
          MdtComposer(
            hint: l10n.chatComposer,
            sendLabel: l10n.chatComposer,
            onSend: _send,
            onVoiceSend: _sendVoice,
            recorder: widget.recorder,
            player: widget.player,
            cues: widget.cues,
            voiceSurface: 'chat',
          ),
      ],
    );
  }
}
