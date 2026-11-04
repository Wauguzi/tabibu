import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_viewer.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

/// Share codes, who-can-see, and the one-shot revealed code (T-18).
sealed class ShareState extends Equatable {
  const ShareState({
    this.caseModel = const CaseModel(),
    this.shares = const <ShareCodeModel>[],
    this.viewers = const <ShareViewer>[],
    this.revealedCode = '',
    this.revealedShareUid = '',
    this.redeemedCaseUid = '',
    this.offline = false,
  });

  final CaseModel caseModel;
  final List<ShareCodeModel> shares;
  final List<ShareViewer> viewers;

  /// Shown once after create/reissue when the callable returns a code.
  /// Never cached, never put in a route (T-18). Empty after dismiss/reset.
  final String revealedCode;
  final String revealedShareUid;

  /// Set after a successful redeem so the screen can open the case (F-2).
  final String redeemedCaseUid;
  final bool offline;

  @override
  List<Object?> get props => [
    caseModel,
    shares,
    viewers,
    revealedCode,
    revealedShareUid,
    redeemedCaseUid,
    offline,
  ];
}

final class ShareInitial extends ShareState {
  const ShareInitial();
}

final class ShareLoadInProgress extends ShareState {
  const ShareLoadInProgress({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareLoadSuccess extends ShareState {
  const ShareLoadSuccess({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareLoadFailure extends ShareState {
  const ShareLoadFailure({
    required this.error,
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class ShareWriteInProgress extends ShareState {
  const ShareWriteInProgress({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareCreateSuccess extends ShareState {
  const ShareCreateSuccess({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareRevokeSuccess extends ShareState {
  const ShareRevokeSuccess({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareRemoveViewerSuccess extends ShareState {
  const ShareRemoveViewerSuccess({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareRedeemSuccess extends ShareState {
  const ShareRedeemSuccess({
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });
}

final class ShareWriteFailure extends ShareState {
  const ShareWriteFailure({
    required this.error,
    super.caseModel,
    super.shares,
    super.viewers,
    super.revealedCode,
    super.revealedShareUid,
    super.redeemedCaseUid,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
