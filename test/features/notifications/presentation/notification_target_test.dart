import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
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
  });
}
