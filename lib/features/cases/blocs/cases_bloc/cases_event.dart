import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class CasesEvent extends Equatable {
  const CasesEvent();

  @override
  List<Object?> get props => [];
}

/// Cache first, then a silent sync.
final class CasesRequested extends CasesEvent {
  const CasesRequested({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

/// Sync first: pull-to-refresh.
final class CasesRefreshed extends CasesEvent {
  const CasesRefreshed({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

final class CaseLogRequested extends CasesEvent {
  const CaseLogRequested({required this.caseUid, required this.role});

  final String caseUid;
  final Role role;

  @override
  List<Object?> get props => [caseUid, role];
}

/// Back to the initial state on sign-out.
final class CasesReset extends CasesEvent {
  const CasesReset();
}
