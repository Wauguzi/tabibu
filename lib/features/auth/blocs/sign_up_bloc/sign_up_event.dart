import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

/// C1. Starts a fresh draft, so nothing from another role carries over.
final class SignUpRoleChosen extends SignUpEvent {
  const SignUpRoleChosen({required this.role, required this.language});

  final Role role;
  final AppLanguage language;

  @override
  List<Object?> get props => [role, language];
}

/// A step's fields, as `state.draft.copyWith(...)`.
final class SignUpDraftUpdated extends SignUpEvent {
  const SignUpDraftUpdated({required this.draft});

  final SignUpDraft draft;

  @override
  List<Object?> get props => [draft];
}

/// After sign-up or sign-out: photos and license scans leave memory.
final class SignUpDraftCleared extends SignUpEvent {
  const SignUpDraftCleared();
}
