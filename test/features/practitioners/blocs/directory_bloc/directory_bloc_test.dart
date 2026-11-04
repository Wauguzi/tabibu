import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

class _MockCache extends Mock implements PractitionerCacheHelper {}

PractitionerModel _doc(
  String uid, {
  String title = 'Dr.',
  String firstName = 'Amina',
  String lastName = 'Otieno',
  List<String> specialties = const ['General practice'],
  String facilityName = 'Aga Khan',
  bool isPathologist = false,
  bool isAvailable = true,
}) => PractitionerModel.empty().copyWith(
  uid: uid,
  title: title,
  firstName: firstName,
  lastName: lastName,
  specialties: specialties,
  facilityName: facilityName,
  isPathologist: isPathologist,
  isAvailable: isAvailable,
);

void main() {
  late _MockCache cache;

  DirectoryBloc build() => DirectoryBloc(cache: cache);

  setUp(() {
    cache = _MockCache();
  });

  group('DirectoryBloc', () {
    test('starts empty', () {
      expect(build().state, const DirectoryInitial());
    });

    blocTest<DirectoryBloc, DirectoryState>(
      'drops its data on reset',
      build: build,
      seed: () => const DirectoryLoadSuccess(query: 'otieno'),
      act: (bloc) => bloc.add(const DirectoryReset()),
      expect: () => [const DirectoryInitial()],
    );

    group('DirectoryRequested', () {
      blocTest<DirectoryBloc, DirectoryState>(
        'with a cache emits success, then the synced rows',
        setUp: () {
          when(
            () => cache.getPractitioners(),
          ).thenAnswer((_) async => [_doc('d1')]);
          when(() => cache.syncPractitioners()).thenAnswer(
            (_) async => [_doc('d1'), _doc('d2', lastName: 'Wanjiru')],
          );
        },
        build: build,
        act: (bloc) => bloc.add(const DirectoryRequested()),
        expect: () => [
          const DirectoryLoadInProgress(),
          DirectoryLoadSuccess(all: [_doc('d1')], visible: [_doc('d1')]),
          DirectoryLoadSuccess(
            all: [
              _doc('d1'),
              _doc('d2', lastName: 'Wanjiru'),
            ],
            visible: [
              _doc('d1'),
              _doc('d2', lastName: 'Wanjiru'),
            ],
          ),
        ],
      );

      blocTest<DirectoryBloc, DirectoryState>(
        'with an empty cache skips the first success',
        setUp: () {
          when(() => cache.getPractitioners()).thenAnswer((_) async => []);
          when(
            () => cache.syncPractitioners(),
          ).thenAnswer((_) async => [_doc('d1')]);
        },
        build: build,
        act: (bloc) => bloc.add(const DirectoryRequested()),
        expect: () => [
          const DirectoryLoadInProgress(),
          DirectoryLoadSuccess(all: [_doc('d1')], visible: [_doc('d1')]),
        ],
      );

      blocTest<DirectoryBloc, DirectoryState>(
        'offline with a cache keeps the rows and sets offline',
        setUp: () {
          when(
            () => cache.getPractitioners(),
          ).thenAnswer((_) async => [_doc('d1')]);
          when(() => cache.syncPractitioners()).thenThrow(AppError.noInternet);
        },
        build: build,
        act: (bloc) => bloc.add(const DirectoryRequested()),
        expect: () => [
          const DirectoryLoadInProgress(),
          DirectoryLoadSuccess(all: [_doc('d1')], visible: [_doc('d1')]),
          DirectoryLoadSuccess(
            all: [_doc('d1')],
            visible: [_doc('d1')],
            offline: true,
          ),
        ],
      );

      blocTest<DirectoryBloc, DirectoryState>(
        'offline with an empty cache fails',
        setUp: () {
          when(() => cache.getPractitioners()).thenAnswer((_) async => []);
          when(
            () => cache.syncPractitioners(),
          ).thenThrow(AppError.serviceUnavailable);
        },
        build: build,
        act: (bloc) => bloc.add(const DirectoryRequested()),
        expect: () => [
          const DirectoryLoadInProgress(),
          const DirectoryLoadFailure(error: AppError.serviceUnavailable),
        ],
      );
    });

    group('DirectoryRefreshed', () {
      blocTest<DirectoryBloc, DirectoryState>(
        'syncs and keeps the current query',
        setUp: () {
          when(() => cache.syncPractitioners()).thenAnswer(
            (_) async => [
              _doc('d1'),
              _doc('d2', firstName: 'Brian', lastName: 'Mwangi'),
            ],
          );
        },
        build: build,
        seed: () => DirectoryLoadSuccess(
          all: [_doc('d1')],
          visible: [_doc('d1')],
          query: 'otieno',
        ),
        act: (bloc) => bloc.add(const DirectoryRefreshed()),
        expect: () => [
          DirectoryLoadInProgress(
            all: [_doc('d1')],
            visible: [_doc('d1')],
            query: 'otieno',
          ),
          DirectoryLoadSuccess(
            all: [
              _doc('d1'),
              _doc('d2', firstName: 'Brian', lastName: 'Mwangi'),
            ],
            visible: [_doc('d1')],
            query: 'otieno',
          ),
        ],
      );
    });

    group('DirectoryQueryChanged', () {
      final mixed = [
        _doc('path', isPathologist: true, specialties: ['Histopathology']),
        _doc('busy', isAvailable: false),
        _doc(
          'jose',
          firstName: 'José',
          lastName: 'García',
          specialties: ['Paediatrics'],
          facilityName: 'Kenyatta',
        ),
        _doc(
          'amina',
          specialties: ['General practice'],
          facilityName: 'Nairobi Hospital',
        ),
        _doc(
          'brian',
          firstName: 'Brian',
          lastName: 'Mwangi',
          specialties: ['General surgery'],
        ),
      ];

      blocTest<DirectoryBloc, DirectoryState>(
        'matches name, specialty wire value, facility; folds accents and case',
        build: build,
        seed: () => DirectoryLoadSuccess(
          all: mixed,
          visible: visibleOf(mixed, query: ''),
        ),
        act: (bloc) async {
          bloc.add(const DirectoryQueryChanged(query: '  Otieno '));
          await pumpEventQueue();
          bloc.add(const DirectoryQueryChanged(query: 'jose'));
          await pumpEventQueue();
          bloc.add(const DirectoryQueryChanged(query: 'paediatrics'));
          await pumpEventQueue();
          bloc.add(const DirectoryQueryChanged(query: 'aga khan'));
        },
        expect: () => [
          DirectoryLoadSuccess(
            all: mixed,
            visible: [
              _doc(
                'amina',
                specialties: ['General practice'],
                facilityName: 'Nairobi Hospital',
              ),
            ],
            query: '  Otieno ',
          ),
          DirectoryLoadSuccess(
            all: mixed,
            visible: [
              _doc(
                'jose',
                firstName: 'José',
                lastName: 'García',
                specialties: ['Paediatrics'],
                facilityName: 'Kenyatta',
              ),
            ],
            query: 'jose',
          ),
          DirectoryLoadSuccess(
            all: mixed,
            visible: [
              _doc(
                'jose',
                firstName: 'José',
                lastName: 'García',
                specialties: ['Paediatrics'],
                facilityName: 'Kenyatta',
              ),
            ],
            query: 'paediatrics',
          ),
          DirectoryLoadSuccess(
            all: mixed,
            visible: [
              _doc(
                'brian',
                firstName: 'Brian',
                lastName: 'Mwangi',
                specialties: ['General surgery'],
              ),
            ],
            query: 'aga khan',
          ),
        ],
      );

      blocTest<DirectoryBloc, DirectoryState>(
        'specialty filter excludes other specialties',
        build: build,
        seed: () => DirectoryLoadSuccess(
          all: mixed,
          visible: visibleOf(mixed, query: ''),
        ),
        act: (bloc) => bloc.add(
          const DirectoryQueryChanged(
            query: '',
            specialty: Specialty.generalPractice,
          ),
        ),
        expect: () => [
          DirectoryLoadSuccess(
            all: mixed,
            visible: [
              _doc(
                'amina',
                specialties: ['General practice'],
                facilityName: 'Nairobi Hospital',
              ),
            ],
            specialty: Specialty.generalPractice,
          ),
        ],
      );
    });
  });

  test('visibleOf excludes pathologists and unavailable; sorts by name', () {
    final all = [
      _doc('b', firstName: 'Zane', lastName: 'Wanjiru'),
      _doc('a'),
      _doc('c', firstName: 'Brian'),
      _doc('p', isPathologist: true),
      _doc('u', isAvailable: false),
    ];
    expect(visibleOf(all, query: '').map((d) => d.uid), ['a', 'c', 'b']);
  });

  test(
    'shareRecipientsOf keeps pathologists and unavailable; drops the sender',
    () {
      final all = [
        _doc('b', firstName: 'Zane', lastName: 'Wanjiru'),
        _doc('a'),
        _doc('p', isPathologist: true, firstName: 'Pia', lastName: 'Path'),
        _doc('u', isAvailable: false, firstName: 'Una', lastName: 'Avail'),
        _doc('me', firstName: 'Self', lastName: 'Sender'),
      ];
      expect(
        shareRecipientsOf(all, query: '', excludeUid: 'me').map((d) => d.uid),
        ['u', 'a', 'p', 'b'],
      );
      expect(
        shareRecipientsOf(
          all,
          query: 'path',
          excludeUid: 'me',
        ).map((d) => d.uid),
        ['p'],
      );
    },
  );
}
