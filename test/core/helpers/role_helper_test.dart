import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';

RoleHelper claims(Map<String, dynamic>? claims) =>
    RoleHelper.fromClaims(claims);

void main() {
  group('RoleHelper.fromClaims', () {
    test('reads each role', () {
      expect(claims({'role': 'patient'}).isPatient, isTrue);
      expect(claims({'role': 'doctor'}).isDoctor, isTrue);
      expect(claims({'role': 'pathologist'}).isPathologist, isTrue);
    });

    test('grants nothing for a missing, unknown or mistyped claim', () {
      for (final claims in <Map<String, dynamic>?>[
        null,
        {},
        {'role': 'superuser'},
        {'role': 1},
        {'role': 'Doctor'},
      ]) {
        final roles = RoleHelper.fromClaims(claims);
        expect(roles, RoleHelper.none, reason: '$claims');
        expect(roles.hasRole, isFalse);
        expect(roles.canAddPatients, isFalse);
        expect(roles.canApproveAlerts, isFalse);
      }
    });

    test('admin and approver flags need the literal true', () {
      final roles = claims({
        'role': 'doctor',
        'admin': 'true',
        'alertApprover': 1,
      });
      expect(roles.isAdmin, isFalse);
      expect(roles.isAlertApprover, isFalse);
    });
  });

  group('permissions', () {
    test('only doctors add patients', () {
      expect(claims({'role': 'doctor'}).canAddPatients, isTrue);
      expect(claims({'role': 'pathologist'}).canAddPatients, isFalse);
      expect(claims({'role': 'patient'}).canAddPatients, isFalse);
    });

    test('approving alerts needs a doctor with the approver claim', () {
      expect(
        claims({'role': 'doctor', 'alertApprover': true}).canApproveAlerts,
        isTrue,
      );
      expect(claims({'role': 'doctor'}).canApproveAlerts, isFalse);
      expect(
        claims({'role': 'pathologist', 'alertApprover': true}).canApproveAlerts,
        isFalse,
      );
      expect(claims({'alertApprover': true}).canApproveAlerts, isFalse);
    });

    test('verifying practitioners needs the admin claim', () {
      expect(claims({'admin': true}).canVerifyPractitioners, isTrue);
      expect(claims({'role': 'doctor'}).canVerifyPractitioners, isFalse);
    });

    test('practitioner covers doctors and pathologists only', () {
      expect(claims({'role': 'doctor'}).isPractitioner, isTrue);
      expect(claims({'role': 'pathologist'}).isPractitioner, isTrue);
      expect(claims({'role': 'patient'}).isPractitioner, isFalse);
      expect(claims({'role': 'patient'}).role, Role.patient);
    });
  });
}
