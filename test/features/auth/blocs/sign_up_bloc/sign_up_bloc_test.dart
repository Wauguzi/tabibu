import 'package:bloc_test/bloc_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

void main() {
  blocTest<SignUpBloc, SignUpState>(
    'choosing a role starts a fresh draft',
    build: SignUpBloc.new,
    seed: () => const SignUpState(
      draft: SignUpDraft(role: Role.doctor, kmpdcNumber: 'A1234'),
    ),
    act: (bloc) => bloc.add(
      const SignUpRoleChosen(role: Role.patient, language: AppLanguage.sw),
    ),
    expect: () => [
      const SignUpState(
        draft: SignUpDraft(role: Role.patient, language: AppLanguage.sw),
      ),
    ],
  );

  blocTest<SignUpBloc, SignUpState>(
    'a step updates the draft, and clearing empties it',
    build: SignUpBloc.new,
    act: (bloc) => bloc
      ..add(const SignUpDraftUpdated(draft: SignUpDraft(firstName: 'Amina')))
      ..add(const SignUpDraftCleared()),
    expect: () => [
      const SignUpState(draft: SignUpDraft(firstName: 'Amina')),
      const SignUpState(),
    ],
  );
}
