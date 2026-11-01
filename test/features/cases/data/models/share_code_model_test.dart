import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

Map<String, dynamic> shareCodeJson() => {
  'uid': 'uid-share-1',
  'caseUid': 'uid-case-1',
  'reportUid': 'uid-report-1',
  'purpose': 'ReportUnlock',
  'createdByUid': 'uid-doctor-1',
  'createdByRole': 'doctor',
  'recipientUid': 'uid-pathologist-1',
  'status': 'Redeemed',
  'attempts': 2,
  'reissueCount': 1,
  'expiresAt': '2030-05-08T10:00:00.000Z',
  'redeemedAt': '2030-05-02T10:00:00.000Z',
  'notificationUid': 'uid-notification-1',
  'createdAt': '2030-05-01T10:00:00.000Z',
  'lastUpdatedAt': '2030-05-02T10:00:00.000Z',
};

void main() {
  group('ShareCodeModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = shareCodeJson();
      final model = ShareCodeModel.fromJson(json);
      expect(model.purpose, 'ReportUnlock');
      expect(model.attempts, 2);
      expect(model.reissueCount, 1);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = ShareCodeModel.fromJson({});
      expect(model, ShareCodeModel.empty());
      expect(model.purpose, 'Join');
      expect(model.status, 'Pending');
    });

    test('toJson never contains synced', () {
      final model = ShareCodeModel.fromJson(shareCodeJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = ShareCodeModel.fromJson(shareCodeJson());
      expect(model.purposeValue, SharePurpose.reportUnlock);
      expect(model.statusValue, ShareStatus.redeemed);
      expect(ShareCodeModel.fromJson({}).purposeValue, SharePurpose.join);
      expect(
        ShareCodeModel.fromJson({'status': 'Bogus'}).statusValue,
        ShareStatus.revoked,
      );
    });

    test('maxShareAttempts is 5', () {
      expect(ShareCodeModel.maxShareAttempts, 5);
    });
  });

  group('ShareCodeHive', () {
    test('fromModel maps every field', () {
      final hive = ShareCodeHive.fromModel(
        ShareCodeModel.fromJson(shareCodeJson()),
      );
      expect(hive.uid, 'uid-share-1');
      expect(hive.caseUid, 'uid-case-1');
      expect(hive.reportUid, 'uid-report-1');
      expect(hive.purpose, 'ReportUnlock');
      expect(hive.createdByUid, 'uid-doctor-1');
      expect(hive.createdByRole, 'doctor');
      expect(hive.recipientUid, 'uid-pathologist-1');
      expect(hive.status, 'Redeemed');
      expect(hive.attempts, 2);
      expect(hive.reissueCount, 1);
      expect(hive.expiresAt, '2030-05-08T10:00:00.000Z');
      expect(hive.redeemedAt, '2030-05-02T10:00:00.000Z');
      expect(hive.notificationUid, 'uid-notification-1');
      expect(hive.createdAt, '2030-05-01T10:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-02T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = ShareCodeModel.fromJson(shareCodeJson());
      expect(ShareCodeHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = ShareCodeModel.fromJson(
        shareCodeJson(),
      ).copyWith(synced: false);
      expect(ShareCodeHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
