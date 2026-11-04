import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/voice_send_outcome.dart';

sealed class MdtEvent extends Equatable {
  const MdtEvent();

  @override
  List<Object?> get props => [];
}

/// Load the group consults [uid] takes part in.
final class MdtRequested extends MdtEvent {
  const MdtRequested({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

/// Pull-to-refresh: sync the list first.
final class MdtRefreshed extends MdtEvent {
  const MdtRefreshed({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

/// Open one consult. An invited-only member gets the invite, no thread.
final class MdtOpened extends MdtEvent {
  const MdtOpened({required this.uid, required this.conversationUid});

  final String uid;
  final String conversationUid;

  @override
  List<Object?> get props => [uid, conversationUid];
}

/// Start a consult on a case. Needs the network.
final class MdtOpenRequested extends MdtEvent {
  const MdtOpenRequested({
    required this.uid,
    required this.caseUid,
    required this.specialty,
    required this.description,
    required this.inviteeUids,
  });

  final String uid;
  final String caseUid;
  final String specialty;
  final String description;
  final List<String> inviteeUids;

  @override
  List<Object?> get props => [
    uid,
    caseUid,
    specialty,
    description,
    inviteeUids,
  ];
}

/// Invite more doctors. Needs the network.
final class MdtInviteRequested extends MdtEvent {
  const MdtInviteRequested({
    required this.uid,
    required this.conversationUid,
    required this.inviteeUids,
  });

  final String uid;
  final String conversationUid;
  final List<String> inviteeUids;

  @override
  List<Object?> get props => [uid, conversationUid, inviteeUids];
}

/// Accept or decline an invite. Needs the network.
final class MdtRespondRequested extends MdtEvent {
  const MdtRespondRequested({
    required this.uid,
    required this.conversationUid,
    required this.accept,
  });

  final String uid;
  final String conversationUid;
  final bool accept;

  @override
  List<Object?> get props => [uid, conversationUid, accept];
}

/// Leave a consult. Needs the network.
final class MdtLeaveRequested extends MdtEvent {
  const MdtLeaveRequested({required this.uid, required this.conversationUid});

  final String uid;
  final String conversationUid;

  @override
  List<Object?> get props => [uid, conversationUid];
}

/// Remove another member. Needs the network.
final class MdtRemoveRequested extends MdtEvent {
  const MdtRemoveRequested({
    required this.uid,
    required this.conversationUid,
    required this.memberUid,
  });

  final String uid;
  final String conversationUid;
  final String memberUid;

  @override
  List<Object?> get props => [uid, conversationUid, memberUid];
}

/// Send a text message. Queued, so it works offline.
final class MdtMessageSendRequested extends MdtEvent {
  const MdtMessageSendRequested({
    required this.uid,
    required this.conversationUid,
    required this.text,
  });

  final String uid;
  final String conversationUid;
  final String text;

  @override
  List<Object?> get props => [uid, conversationUid, text];
}

/// Send a voice note from a local AAC file.
/// Sequential so a retry while the first is in flight cannot mint a second id.
final class MdtVoiceNoteSendRequested extends MdtEvent {
  MdtVoiceNoteSendRequested({
    required this.uid,
    required this.conversationUid,
    required this.localPath,
    required this.durationMs,
    required this.voicePeaks,
    this.contentType = 'audio/mp4',
    Completer<VoiceSendOutcome>? result,
  }) : result = result ?? Completer<VoiceSendOutcome>();

  final String uid;
  final String conversationUid;
  final String localPath;
  final int durationMs;
  final List<int> voicePeaks;
  final String contentType;

  /// Completed by the bloc so a concurrent text write cannot clear the preview.
  final Completer<VoiceSendOutcome> result;

  @override
  List<Object?> get props => [
    uid,
    conversationUid,
    localPath,
    durationMs,
    voicePeaks,
    contentType,
  ];
}

final class MdtReset extends MdtEvent {
  const MdtReset();
}
