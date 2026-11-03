import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_bloc.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_viewer.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

class _MockCache extends Mock implements CaseCacheHelper {}

class _MockShares extends Mock implements ShareCodeFirebase {}

class _MockCases extends Mock implements CaseFirebase {}

class _MockInternet extends Mock implements InternetService {}

class _MockPractitioners extends Mock implements PractitionerCacheHelper {}

class _MockAnalytics extends Mock implements AnalyticsService {}

PractitionerModel _practitioner({
  required String uid,
  required String firstName,
  required String lastName,
  required bool isPathologist,
}) => PractitionerModel(
  uid: uid,
  title: 'Dr.',
  firstName: firstName,
  lastName: lastName,
  profilePictureUrl: '',
  isPathologist: isPathologist,
  specialties: const [],
  bio: '',
  facilityId: '',
  facilityMflCode: '',
  facilityName: '',
  county: '',
  subCounty: '',
  geohash: '',
  isAvailable: true,
  appointmentsHandled: 0,
  ordersCreated: 0,
  reportsSigned: 0,
  lastUpdatedAt: '',
);

void main() {
  late _MockCache cache;
  late _MockShares shares;
  late _MockCases cases;
  late _MockInternet internet;
  late _MockPractitioners practitioners;
  late _MockAnalytics analytics;

  ShareBloc build() => ShareBloc(
    cache: cache,
    shares: shares,
    cases: cases,
    internet: internet,
    practitioners: practitioners,
    analytics: analytics,
    newShareUid: () => 'share-fixed',
  );

  const careCase = CaseModel(
    uid: 'c1',
    doctorUid: 'doc-1',
    doctorName: 'Dr Doc',
    pathologistUid: 'path-1',
    pathologistName: 'Dr Path',
    viewerUids: ['viewer-1'],
  );

  const pending = ShareCodeModel(
    uid: 'share-fixed',
    caseUid: 'c1',
    recipientUid: 'viewer-1',
  );

  final doctorViewer = _practitioner(
    uid: 'viewer-1',
    firstName: 'Ada',
    lastName: 'Mwangi',
    isPathologist: false,
  );

  final pathologistViewer = _practitioner(
    uid: 'viewer-1',
    firstName: 'Grace',
    lastName: 'Otieno',
    isPathologist: true,
  );

  setUp(() {
    cache = _MockCache();
    shares = _MockShares();
    cases = _MockCases();
    internet = _MockInternet();
    practitioners = _MockPractitioners();
    analytics = _MockAnalytics();
    when(() => internet.check()).thenAnswer((_) async => true);
    when(() => cache.getCases(any())).thenAnswer((_) async => [careCase]);
    when(() => cache.syncCases(any())).thenAnswer((_) async => [careCase]);
    when(
      () => cache.getShareCodes(any(), asCreator: any(named: 'asCreator')),
    ).thenAnswer((_) async => [pending]);
    when(
      () => cache.syncShareCodes(
        uid: any(named: 'uid'),
        asCreator: any(named: 'asCreator'),
      ),
    ).thenAnswer((_) async => [pending]);
    when(
      () => cache.cacheShareCodeMaps(any(), fromCloud: any(named: 'fromCloud')),
    ).thenAnswer((_) async {});
    when(() => cache.evictShareCode(any())).thenAnswer((_) async {});
    when(
      () => practitioners.getPractitioner(any()),
    ).thenAnswer((_) async => doctorViewer);
    when(
      () => analytics.logShareCreated(purpose: any(named: 'purpose')),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logShareReissued(purpose: any(named: 'purpose')),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logShareRevoked(purpose: any(named: 'purpose')),
    ).thenAnswer((_) async {});
    when(() => analytics.logShareViewerRemoved()).thenAnswer((_) async {});
    when(
      () => analytics.logShareRedeemed(purpose: any(named: 'purpose')),
    ).thenAnswer((_) async {});
  });

  group('ShareBloc', () {
    test('starts empty', () {
      expect(build().state, const ShareInitial());
    });

    blocTest<ShareBloc, ShareState>(
      'drops its data on reset',
      build: build,
      seed: () => const ShareLoadSuccess(
        caseModel: careCase,
        revealedCode: '4821',
        revealedShareUid: 'share-fixed',
      ),
      act: (bloc) => bloc.add(const ShareReset()),
      expect: () => [const ShareInitial()],
    );

    blocTest<ShareBloc, ShareState>(
      'who-can-see lists doctor, pathologist and viewers; care team not '
      'removable',
      build: build,
      act: (bloc) => bloc.add(
        const ShareRequested(
          uid: 'patient-1',
          role: Role.patient,
          caseUid: 'c1',
        ),
      ),
      expect: () => [
        const ShareLoadInProgress(),
        isA<ShareLoadSuccess>()
            .having((s) => s.viewers, 'viewers', [
              const ShareViewer(
                uid: 'doc-1',
                displayName: 'Dr Doc',
                role: ActorRole.doctor,
                removable: false,
              ),
              const ShareViewer(
                uid: 'path-1',
                displayName: 'Dr Path',
                role: ActorRole.pathologist,
                removable: false,
              ),
              const ShareViewer(
                uid: 'viewer-1',
                displayName: 'Dr. Ada Mwangi',
                role: ActorRole.doctor,
                removable: true,
              ),
            ])
            .having((s) => s.revealedCode, 'revealedCode', isEmpty),
      ],
    );

    blocTest<ShareBloc, ShareState>(
      'who-can-see names a pathologist viewer with the pathologist role',
      setUp: () {
        when(
          () => practitioners.getPractitioner('viewer-1'),
        ).thenAnswer((_) async => pathologistViewer);
      },
      build: build,
      act: (bloc) => bloc.add(
        const ShareRequested(
          uid: 'patient-1',
          role: Role.patient,
          caseUid: 'c1',
        ),
      ),
      expect: () => [
        const ShareLoadInProgress(),
        isA<ShareLoadSuccess>().having(
          (s) => s.viewers.last,
          'viewer',
          const ShareViewer(
            uid: 'viewer-1',
            displayName: 'Dr. Grace Otieno',
            role: ActorRole.pathologist,
            removable: true,
          ),
        ),
      ],
    );

    blocTest<ShareBloc, ShareState>(
      'create keeps a returned code only in memory and strips it before cache',
      setUp: () {
        when(
          () => shares.createShareCode(
            shareUid: any(named: 'shareUid'),
            caseUid: any(named: 'caseUid'),
            recipientUid: any(named: 'recipientUid'),
          ),
        ).thenAnswer(
          (_) async => {
            'status': 'created',
            'shareUid': 'share-fixed',
            'code': '4821',
            'expiresAt': '2026-11-10T00:00:00.000Z',
          },
        );
      },
      build: build,
      seed: () => const ShareLoadSuccess(caseModel: careCase),
      act: (bloc) => bloc.add(
        const ShareCreateRequested(
          uid: 'patient-1',
          role: Role.patient,
          caseUid: 'c1',
          recipientUid: 'viewer-1',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareCreateSuccess>()
            .having((s) => s.revealedCode, 'code', '4821')
            .having((s) => s.revealedShareUid, 'shareUid', 'share-fixed'),
      ],
      verify: (_) {
        final captured =
            verify(
                  () => cache.cacheShareCodeMaps(
                    captureAny(),
                    fromCloud: any(named: 'fromCloud'),
                  ),
                ).captured.single
                as List<Map<String, dynamic>>;
        expect(captured.single.containsKey('code'), isFalse);
        verify(() => analytics.logShareCreated(purpose: 'Join')).called(1);
      },
    );

    blocTest<ShareBloc, ShareState>(
      'leaving the screen clears the revealed code; a reload never restores it',
      build: build,
      seed: () => const ShareCreateSuccess(
        caseModel: careCase,
        shares: [pending],
        revealedCode: '4821',
        revealedShareUid: 'share-fixed',
      ),
      act: (bloc) async {
        bloc.add(const ShareCodeDismissed());
        await bloc.stream.firstWhere((s) => s.revealedCode.isEmpty);
        bloc.add(
          const ShareRequested(
            uid: 'patient-1',
            role: Role.patient,
            caseUid: 'c1',
          ),
        );
      },
      expect: () => [
        isA<ShareLoadSuccess>().having((s) => s.revealedCode, 'code', isEmpty),
        isA<ShareLoadInProgress>().having(
          (s) => s.revealedCode,
          'code',
          isEmpty,
        ),
        isA<ShareLoadSuccess>().having((s) => s.revealedCode, 'code', isEmpty),
      ],
    );

    blocTest<ShareBloc, ShareState>(
      'patient cannot remove the treating doctor or pathologist',
      build: build,
      seed: () => const ShareLoadSuccess(caseModel: careCase),
      act: (bloc) => bloc.add(
        const ShareRemoveViewerRequested(
          uid: 'patient-1',
          caseUid: 'c1',
          viewerUid: 'doc-1',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareWriteFailure>().having(
          (s) => s.error,
          'error',
          AppError.permissionDenied,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => cases.removeCaseViewer(
            caseUid: any(named: 'caseUid'),
            viewerUid: any(named: 'viewerUid'),
          ),
        );
        verifyNever(() => analytics.logShareViewerRemoved());
      },
    );

    blocTest<ShareBloc, ShareState>(
      'remove viewer logs ids only',
      setUp: () {
        when(
          () => cases.removeCaseViewer(
            caseUid: any(named: 'caseUid'),
            viewerUid: any(named: 'viewerUid'),
          ),
        ).thenAnswer((_) async => <String, dynamic>{'status': 'ok'});
      },
      build: build,
      seed: () => const ShareLoadSuccess(caseModel: careCase),
      act: (bloc) => bloc.add(
        const ShareRemoveViewerRequested(
          uid: 'patient-1',
          caseUid: 'c1',
          viewerUid: 'viewer-1',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareRemoveViewerSuccess>(),
      ],
      verify: (_) {
        verify(() => analytics.logShareViewerRemoved()).called(1);
      },
    );

    blocTest<ShareBloc, ShareState>(
      'reissue logs share uid and purpose',
      setUp: () {
        when(
          () => shares.reissueShareCode(shareUid: any(named: 'shareUid')),
        ).thenAnswer(
          (_) async => {
            'status': 'reissued',
            'code': '9911',
            'expiresAt': '2026-11-10T00:00:00.000Z',
          },
        );
      },
      build: build,
      seed: () => ShareLoadSuccess(
        caseModel: careCase,
        shares: [pending.copyWith(purpose: SharePurpose.reportUnlock.value)],
      ),
      act: (bloc) => bloc.add(
        const ShareReissueRequested(uid: 'patient-1', shareUid: 'share-fixed'),
      ),
      expect: () => [isA<ShareWriteInProgress>(), isA<ShareCreateSuccess>()],
      verify: (_) {
        verify(
          () => analytics.logShareReissued(purpose: 'ReportUnlock'),
        ).called(1);
      },
    );

    blocTest<ShareBloc, ShareState>(
      'revoke logs share uid and purpose',
      setUp: () {
        when(
          () => shares.revokeShareCode(shareUid: any(named: 'shareUid')),
        ).thenAnswer((_) async => <String, dynamic>{'status': 'revoked'});
      },
      build: build,
      seed: () => ShareLoadSuccess(
        caseModel: careCase,
        shares: [pending.copyWith(purpose: SharePurpose.reportUnlock.value)],
      ),
      act: (bloc) => bloc.add(
        const ShareRevokeRequested(uid: 'patient-1', shareUid: 'share-fixed'),
      ),
      expect: () => [isA<ShareWriteInProgress>(), isA<ShareRevokeSuccess>()],
      verify: (_) {
        verify(
          () => analytics.logShareRevoked(purpose: 'ReportUnlock'),
        ).called(1);
      },
    );

    blocTest<ShareBloc, ShareState>(
      'redeem maps wrong, expired and locked to distinct AppErrors',
      setUp: () {
        when(
          () => shares.redeemShareCode(
            shareUid: any(named: 'shareUid'),
            code: any(named: 'code'),
          ),
        ).thenThrow(AppError.wrongShareCode);
      },
      build: build,
      seed: () =>
          const ShareLoadSuccess(caseModel: careCase, shares: [pending]),
      act: (bloc) => bloc.add(
        const ShareRedeemRequested(
          uid: 'doc-1',
          shareUid: 'share-fixed',
          code: '0000',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareWriteFailure>().having(
          (s) => s.error,
          'error',
          AppError.wrongShareCode,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => analytics.logShareRedeemed(purpose: any(named: 'purpose')),
        );
      },
    );

    blocTest<ShareBloc, ShareState>(
      'redeem success opens the case via redeemedCaseUid',
      setUp: () {
        when(
          () => shares.redeemShareCode(
            shareUid: any(named: 'shareUid'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      seed: () =>
          const ShareLoadSuccess(caseModel: careCase, shares: [pending]),
      act: (bloc) => bloc.add(
        const ShareRedeemRequested(
          uid: 'doc-1',
          shareUid: 'share-fixed',
          code: '4821',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareRedeemSuccess>()
            .having((s) => s.redeemedCaseUid, 'caseUid', 'c1')
            .having((s) => s.revealedCode, 'code', isEmpty),
      ],
      verify: (_) {
        verify(() => analytics.logShareRedeemed(purpose: 'Join')).called(1);
      },
    );

    blocTest<ShareBloc, ShareState>(
      'redeem without a loaded share fails with dataNotFound',
      setUp: () {
        when(
          () => shares.redeemShareCode(
            shareUid: any(named: 'shareUid'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => {'status': 'ok'});
      },
      build: build,
      seed: () => const ShareLoadSuccess(caseModel: careCase),
      act: (bloc) => bloc.add(
        const ShareRedeemRequested(
          uid: 'doc-1',
          shareUid: 'share-fixed',
          code: '4821',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareWriteFailure>().having(
          (s) => s.error,
          'error',
          AppError.dataNotFound,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => shares.redeemShareCode(
            shareUid: any(named: 'shareUid'),
            code: any(named: 'code'),
          ),
        );
        verifyNever(
          () => analytics.logShareRedeemed(purpose: any(named: 'purpose')),
        );
      },
    );

    blocTest<ShareBloc, ShareState>(
      'every write fails fast offline with no queued call',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
      },
      build: build,
      seed: () => const ShareLoadSuccess(caseModel: careCase),
      act: (bloc) => bloc.add(
        const ShareCreateRequested(
          uid: 'patient-1',
          role: Role.patient,
          caseUid: 'c1',
          recipientUid: 'viewer-1',
        ),
      ),
      expect: () => [
        isA<ShareWriteInProgress>(),
        isA<ShareWriteFailure>().having(
          (s) => s.error,
          'error',
          AppError.noInternet,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => shares.createShareCode(
            shareUid: any(named: 'shareUid'),
            caseUid: any(named: 'caseUid'),
            recipientUid: any(named: 'recipientUid'),
          ),
        );
        verifyNever(
          () => analytics.logShareCreated(purpose: any(named: 'purpose')),
        );
      },
    );

    test('AppError maps server redeem reasons distinctly', () {
      AppError from(String message) => AppError.fromFunctionsException(
        FirebaseFunctionsException(
          code: 'failed-precondition',
          message: message,
        ),
      );
      expect(from('wrongCode'), AppError.wrongShareCode);
      expect(from('shareExpired'), AppError.shareExpired);
      expect(from('shareLocked'), AppError.shareLocked);
      expect(from('shareClosed'), AppError.shareClosed);
    });
  });
}
