import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/facilities_helper.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/alerts/data/cache/alert_cache_helper.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';

class _MockCache extends Mock implements AlertCacheHelper {}

class _MockFacilities extends Mock implements FacilitiesHelper {}

PublicAlertModel _alert(
  String uid, {
  String issuedAt = '2026-11-02T10:00:00.000Z',
}) => PublicAlertModel.empty().copyWith(uid: uid, issuedAt: issuedAt);

AlertClinicianBriefModel _brief(String alertUid) =>
    AlertClinicianBriefModel.empty().copyWith(alertUid: alertUid);

void main() {
  late _MockCache cache;
  late _MockFacilities facilities;

  PublicAlertsBloc build() =>
      PublicAlertsBloc(cache: cache, facilities: facilities);

  setUp(() {
    facilities = _MockFacilities();
    when(facilities.counties).thenAnswer(
      (_) async => const [
        CountyModel(id: 1, name: 'Mombasa'),
        CountyModel(id: 2, name: 'Kwale'),
        CountyModel(id: 47, name: 'Nairobi'),
      ],
    );
    cache = _MockCache();
  });

  group('PublicAlertsBloc', () {
    test('starts empty', () {
      expect(build().state, const PublicAlertsInitial());
    });

    blocTest<PublicAlertsBloc, PublicAlertsState>(
      'drops its data on reset',
      build: build,
      seed: () => const PublicAlertsLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const PublicAlertsReset()),
      expect: () => [const PublicAlertsInitial()],
    );

    blocTest<PublicAlertsBloc, PublicAlertsState>(
      'an unknown county shows no alerts and reads nothing',
      build: build,
      act: (bloc) => bloc.add(
        const PublicAlertsRequested(
          county: 'Atlantis',
          demo: false,
          clinician: false,
        ),
      ),
      expect: () => [
        const PublicAlertsLoadInProgress(),
        const PublicAlertsLoadSuccess(),
      ],
      verify: (_) => verifyNever(
        () => cache.publicAlertsForCounty(
          countyId: any(named: 'countyId'),
          demo: any(named: 'demo'),
        ),
      ),
    );

    group('PublicAlertsRequested', () {
      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'patient path loads the county list',
        setUp: () {
          when(
            () => cache.publicAlertsForCounty(countyId: 47, demo: false),
          ).thenAnswer((_) async => [_alert('a2'), _alert('a1')]);
        },
        build: build,
        act: (bloc) => bloc.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: false,
            clinician: false,
          ),
        ),
        expect: () => [
          const PublicAlertsLoadInProgress(),
          PublicAlertsLoadSuccess(alerts: [_alert('a2'), _alert('a1')]),
        ],
        verify: (_) {
          verifyNever(() => cache.briefFor(alertUid: any(named: 'alertUid')));
        },
      );

      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'clinician path loads briefs keyed by alert',
        setUp: () {
          when(
            () => cache.publicAlertsForClinician(countyId: 47, demo: true),
          ).thenAnswer((_) async => [_alert('a1'), _alert('a2')]);
          when(
            () => cache.briefFor(alertUid: 'a1'),
          ).thenAnswer((_) async => _brief('a1'));
          when(
            () => cache.briefFor(alertUid: 'a2'),
          ).thenAnswer((_) async => _brief('a2'));
        },
        build: build,
        act: (bloc) => bloc.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: true,
            clinician: true,
          ),
        ),
        expect: () => [
          const PublicAlertsLoadInProgress(),
          PublicAlertsLoadSuccess(
            alerts: [_alert('a1'), _alert('a2')],
            briefs: {'a1': _brief('a1'), 'a2': _brief('a2')},
          ),
        ],
      );

      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'offline with a cache keeps the rows',
        setUp: () {
          when(
            () => cache.publicAlertsForCounty(countyId: 47, demo: false),
          ).thenThrow(AppError.noInternet);
        },
        build: build,
        seed: () => PublicAlertsLoadSuccess(alerts: [_alert('a1')]),
        act: (bloc) => bloc.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: false,
            clinician: false,
          ),
        ),
        expect: () => [
          PublicAlertsLoadInProgress(alerts: [_alert('a1')]),
          PublicAlertsLoadSuccess(alerts: [_alert('a1')], offline: true),
        ],
      );

      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'offline with an empty cache fails',
        setUp: () {
          when(
            () => cache.publicAlertsForCounty(countyId: 47, demo: false),
          ).thenThrow(AppError.serviceUnavailable);
        },
        build: build,
        act: (bloc) => bloc.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: false,
            clinician: false,
          ),
        ),
        expect: () => [
          const PublicAlertsLoadInProgress(),
          const PublicAlertsLoadFailure(error: AppError.serviceUnavailable),
        ],
      );

      test('a county change restarts the load', () async {
        when(
          () => cache.publicAlertsForCounty(countyId: 1, demo: false),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return [_alert('old')];
        });
        when(
          () => cache.publicAlertsForCounty(countyId: 2, demo: false),
        ).thenAnswer((_) async => [_alert('new')]);

        final bloc = build()
          ..add(
            const PublicAlertsRequested(
              county: 'Mombasa',
              demo: false,
              clinician: false,
            ),
          );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(
          const PublicAlertsRequested(
            county: 'Kwale',
            demo: false,
            clinician: false,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsThrough(PublicAlertsLoadSuccess(alerts: [_alert('new')])),
        );
        expect(
          bloc.state,
          isNot(PublicAlertsLoadSuccess(alerts: [_alert('old')])),
        );
        await bloc.close();
      });
    });

    group('PublicAlertReadRequested', () {
      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'records a receipt without changing state',
        setUp: () {
          when(() => cache.markRead(alertUid: 'a1')).thenAnswer(
            (_) async => const AlertReceiptModel(
              alertUid: 'a1',
              readAt: '2026-11-02T12:00:00.000Z',
              lastUpdatedAt: '2026-11-02T12:00:00.000Z',
            ),
          );
        },
        build: build,
        seed: () => PublicAlertsLoadSuccess(alerts: [_alert('a1')]),
        act: (bloc) => bloc.add(const PublicAlertReadRequested(alertUid: 'a1')),
        expect: () => <PublicAlertsState>[],
        verify: (_) {
          verify(() => cache.markRead(alertUid: 'a1')).called(1);
        },
      );

      blocTest<PublicAlertsBloc, PublicAlertsState>(
        'swallows a receipt failure',
        setUp: () {
          when(
            () => cache.markRead(alertUid: 'a1'),
          ).thenThrow(AppError.unknown);
        },
        build: build,
        seed: () => PublicAlertsLoadSuccess(alerts: [_alert('a1')]),
        act: (bloc) => bloc.add(const PublicAlertReadRequested(alertUid: 'a1')),
        expect: () => <PublicAlertsState>[],
      );
    });
  });
}
