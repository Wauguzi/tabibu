import 'package:bloc/bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

/// Holds the sign-up draft across the C, D, E and F screens, so going back a
/// step keeps what was entered. Submitting is `AuthBloc`'s.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(const SignUpState()) {
    // Synchronous and order-preserving by default; each event replaces the
    // draft whole, so the last one wins.
    on<SignUpRoleChosen>(
      (event, emit) => emit(
        SignUpState(
          draft: SignUpDraft(role: event.role, language: event.language),
        ),
      ),
    );
    on<SignUpDraftUpdated>(
      (event, emit) => emit(SignUpState(draft: event.draft)),
    );
    on<SignUpDraftCleared>((event, emit) => emit(const SignUpState()));
  }
}
