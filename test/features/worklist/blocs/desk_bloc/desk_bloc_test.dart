import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';

void main() {
  group('DeskBloc', () {
    test('starts empty', () {
      expect(DeskBloc().state, const DeskInitial());
    });

    blocTest<DeskBloc, DeskState>(
      'drops its data on reset',
      build: DeskBloc.new,
      seed: () => const DeskLoadSuccess(query: 'TB-0231'),
      act: (bloc) => bloc.add(const DeskReset()),
      expect: () => [const DeskInitial()],
    );
  });
}
