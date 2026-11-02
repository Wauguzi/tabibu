import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';

void main() {
  group('DirectoryBloc', () {
    test('starts empty', () {
      expect(DirectoryBloc().state, const DirectoryInitial());
    });

    blocTest<DirectoryBloc, DirectoryState>(
      'drops its data on reset',
      build: DirectoryBloc.new,
      seed: () => const DirectoryLoadSuccess(query: 'otieno'),
      act: (bloc) => bloc.add(const DirectoryReset()),
      expect: () => [const DirectoryInitial()],
    );
  });
}
