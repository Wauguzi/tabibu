import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class ShareEvent extends Equatable {
  const ShareEvent();

  @override
  List<Object?> get props => [];
}

/// Load share codes (creator or recipient) and the case's viewers.
final class ShareRequested extends ShareEvent {
  const ShareRequested({
    required this.uid,
    required this.role,
    required this.caseUid,
    this.asCreator = true,
  });

  final String uid;
  final Role role;
  final String caseUid;
  final bool asCreator;

  @override
  List<Object?> get props => [uid, role, caseUid, asCreator];
}

/// Pull-to-refresh: sync first.
final class ShareRefreshed extends ShareEvent {
  const ShareRefreshed({
    required this.uid,
    required this.role,
    required this.caseUid,
    this.asCreator = true,
  });

  final String uid;
  final Role role;
  final String caseUid;
  final bool asCreator;

  @override
  List<Object?> get props => [uid, role, caseUid, asCreator];
}

/// Create a Join share for [recipientUid]. Needs the network.
final class ShareCreateRequested extends ShareEvent {
  const ShareCreateRequested({
    required this.uid,
    required this.role,
    required this.caseUid,
    required this.recipientUid,
  });

  final String uid;
  final Role role;
  final String caseUid;
  final String recipientUid;

  @override
  List<Object?> get props => [uid, role, caseUid, recipientUid];
}

/// Reissue a ReportUnlock share. Needs the network.
final class ShareReissueRequested extends ShareEvent {
  const ShareReissueRequested({required this.uid, required this.shareUid});

  final String uid;
  final String shareUid;

  @override
  List<Object?> get props => [uid, shareUid];
}

/// Revoke a pending Join share. Needs the network.
final class ShareRevokeRequested extends ShareEvent {
  const ShareRevokeRequested({required this.uid, required this.shareUid});

  final String uid;
  final String shareUid;

  @override
  List<Object?> get props => [uid, shareUid];
}

/// Remove a viewer who is not the treating doctor or pathologist.
final class ShareRemoveViewerRequested extends ShareEvent {
  const ShareRemoveViewerRequested({
    required this.uid,
    required this.caseUid,
    required this.viewerUid,
  });

  final String uid;
  final String caseUid;
  final String viewerUid;

  @override
  List<Object?> get props => [uid, caseUid, viewerUid];
}

/// Redeem a 4-digit code. The field is never prefilled by this bloc.
final class ShareRedeemRequested extends ShareEvent {
  const ShareRedeemRequested({
    required this.uid,
    required this.shareUid,
    required this.code,
  });

  final String uid;
  final String shareUid;

  /// Raw code from the field only — never from a route or cache.
  final String code;

  @override
  List<Object?> get props => [uid, shareUid, code];
}

/// Drop the one-shot revealed code after the person leaves the screen (T-18).
final class ShareCodeDismissed extends ShareEvent {
  const ShareCodeDismissed();
}

final class ShareReset extends ShareEvent {
  const ShareReset();
}
