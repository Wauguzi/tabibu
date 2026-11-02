import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';

void main() {
  group('CasesBloc', () {
    test('starts empty', () {
      expect(CasesBloc().state, const CasesInitial());
    });

    blocTest<CasesBloc, CasesState>(
      'drops its data on reset',
      build: CasesBloc.new,
      seed: () => const CasesLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const CasesReset()),
      expect: () => [const CasesInitial()],
    );
  });
}
