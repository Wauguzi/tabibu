import 'package:equatable/equatable.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

final class SignUpState extends Equatable {
  const SignUpState({this.draft = const SignUpDraft()});

  final SignUpDraft draft;

  @override
  List<Object?> get props => [draft];
}
