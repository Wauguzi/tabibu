import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/features/notifications/presentation/notification_target.dart';

void main() {
  final patient = RoleHelper.fromClaims(const {'role': 'patient'});
  final doctor = RoleHelper.fromClaims(const {'role': 'doctor'});
  final approver = RoleHelper.fromClaims(const {
    'role': 'doctor',
    'admin': true,
    'alertApprover': true,
  });
  final pathologist = RoleHelper.fromClaims(const {'role': 'pathologist'});
  final none = RoleHelper.fromClaims(const {});

  String? target(String link, RoleHelper roles) =>
      notificationTarget(link, roles)?.location;

  group('notificationTarget', () {
    test('appointments open each role its own appointment screen', () {
      expect(target('/appointments/a1', patient), '/patient/appointment/a1');
      expect(target('/appointments/a1', doctor), '/doctor/appointment/a1');
      expect(target('/appointments/a1', pathologist), isNull);
    });

    test('a case and everything under it open the reader view of it', () {
      for (final link in [
        '/cases/c1',
        '/cases/c1/reports/r1',
        '/cases/c1/texts/t1',
        '/cases/c1/book-discussion',
      ]) {
        expect(target(link, patient), '/patient/result/c1', reason: link);
        expect(target(link, pathologist), '/pathologist/case/c1', reason: link);
      }
      expect(target('/cases/c1', doctor), '/doctor/case/c1');
      expect(target('/cases/c1/reports/r1', doctor), '/doctor/case/c1/report');
      expect(target('/cases/c1/texts/t1', doctor), '/doctor/case/c1/report');
    });

    test('a patient alert opens the health notice', () {
      expect(target('/alerts/a1', patient), '/patient/notice/a1');
      expect(target('/alerts/a1', doctor), isNull);
    });

    test('an alert review opens only for an approver (F-7)', () {
      expect(target('/alerts/a1/review', approver), '/doctor/alert/a1');
      expect(target('/alerts/a1/review', doctor), isNull);
      expect(target('/alerts/a1/review', patient), isNull);
    });

    test('Tier 2 and unknown links open nothing', () {
      expect(target('/conversations/x1', doctor), isNull);
      expect(target('/cases/c1/unknown/z', patient), isNull);
      expect(target('/cases/c1/reports/r1/extra', doctor), isNull);
      expect(target('', patient), isNull);
      expect(target('/', patient), isNull);
      expect(target('/appointments/a1', none), isNull);
    });

    test('returns typed routes', () {
      expect(notificationTarget('/cases/c1', doctor), isA<GoRouteData>());
    });

    test('a push with no Tier 1 target opens the role inbox', () {
      expect(
        notificationTapRoute('/conversations/x1', doctor)?.location,
        '/doctor/notifications',
      );
      expect(
        notificationTapRoute('', patient)?.location,
        '/patient/notifications',
      );
      expect(
        notificationTapRoute('/alerts/a1/review', doctor)?.location,
        '/doctor/notifications',
      );
      expect(
        notificationTapRoute('/alerts/a1/review', approver)?.location,
        '/doctor/alert/a1',
      );
      expect(notificationTapRoute('/cases/c1', none), isNull);
    });

    test('each role has its own notifications home', () {
      expect(notificationsHome(patient)?.location, '/patient/notifications');
      expect(notificationsHome(doctor)?.location, '/doctor/notifications');
      expect(
        notificationsHome(pathologist)?.location,
        '/pathologist/notifications',
      );
      expect(notificationsHome(none), isNull);
    });

    test('a path payload is a deep link; a uid is not', () {
      expect(isNotificationDeepLinkPayload('/cases/c1'), isTrue);
      expect(isNotificationDeepLinkPayload('resultReleased:c1:p1'), isFalse);
    });
  });

  group('notificationRowTarget', () {
    NotificationModel row(
      String uid, {
      String deepLink = '/cases/c1',
      String code = '4821',
    }) => NotificationModel(
      uid: uid,
      metadata: NotificationMetadataModel(deepLink: deepLink, shareCode: code),
    );

    String? targetOf(NotificationModel n, RoleHelper roles) =>
        notificationRowTarget(n, roles)?.location;

    test('reportSigned with an unredeemed code opens code entry', () {
      expect(
        targetOf(row('reportSigned:c1_r1:doc-1'), doctor),
        '/doctor/share/unlock_c1_r1',
      );
    });

    test('reportSigned with no code opens the case deep link', () {
      expect(
        targetOf(row('reportSigned:c1_r1:doc-1', code: ''), doctor),
        '/doctor/case/c1',
      );
    });

    test('caseShared opens code entry before the case', () {
      expect(targetOf(row('caseShared:s1:doc-1'), doctor), '/doctor/share/s1');
      expect(
        targetOf(row('caseShared:s1:pa-1'), pathologist),
        '/pathologist/share/s1',
      );
    });

    test('a Tier-1 row with no share code still opens its deep link', () {
      expect(
        targetOf(row('resultReleased:c1:pat-1', code: ''), patient),
        '/patient/result/c1',
      );
    });

    test('a deep link with no screen and no share has no target', () {
      // The inbox then only marks the row read; a push or banner tap falls
      // back to the inbox itself (app.dart).
      expect(
        targetOf(
          row('x:y:doc-1', deepLink: '/conversations/x1', code: ''),
          doctor,
        ),
        isNull,
      );
    });
  });

  group('shareCodeTarget', () {
    NotificationModel shareRow(String uid, {String code = '4821'}) =>
        NotificationModel(
          uid: uid,
          metadata: NotificationMetadataModel(
            deepLink: '/cases/c1',
            shareCode: code,
          ),
        );

    String? share(NotificationModel row, RoleHelper roles) =>
        shareCodeTarget(row, roles)?.location;

    test('a caseShared row opens the enter-code screen for its share', () {
      final row = shareRow('caseShared:s1:doc-1');
      expect(share(row, doctor), '/doctor/share/s1');
      expect(share(row, pathologist), '/pathologist/share/s1');
    });

    test('a reissue strips its -r suffix back to the share id', () {
      expect(
        share(shareRow('shareCodeReissued:s1-r2:doc-1'), doctor),
        '/doctor/share/s1',
      );
    });

    test('a signed or updated report opens its unlock share', () {
      expect(
        share(shareRow('reportSigned:c1_r1:doc-1'), doctor),
        '/doctor/share/unlock_c1_r1',
      );
      expect(
        share(shareRow('reportUpdated:c1_r2:doc-1'), doctor),
        '/doctor/share/unlock_c1_r2',
      );
    });

    test('T-18: the route never carries the code', () {
      final location = share(shareRow('caseShared:s1:doc-1'), doctor)!;
      expect(location, isNot(contains('4821')));
    });

    test('a row without a code, or a patient, gets no share screen', () {
      expect(share(shareRow('caseShared:s1:doc-1', code: ''), doctor), isNull);
      expect(share(shareRow('caseShared:s1:pat-1'), patient), isNull);
      expect(share(shareRow('caseShared:s1:pat-1'), none), isNull);
    });

    test('an unknown template or a malformed id opens nothing', () {
      expect(share(shareRow('resultReleased:c1:doc-1'), doctor), isNull);
      expect(share(shareRow('caseShared:s1'), doctor), isNull);
      expect(share(shareRow('caseShared::doc-1'), doctor), isNull);
      expect(share(shareRow(''), doctor), isNull);
    });
  });
}
