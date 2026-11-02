import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/notifications/presentation/inbox_watch.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

void main() {
  group('inboxWatchUid', () {
    test('a signed-in patient or practitioner with a role is watched', () {
      expect(
        inboxWatchUid(
          PatientSession(
            patient: PatientModel.empty().copyWith(uid: 'p1'),
            roles: RoleHelper.fromClaims(const {'role': 'patient'}),
          ),
        ),
        'p1',
      );
      for (final role in ['doctor', 'pathologist']) {
        expect(
          inboxWatchUid(
            PractitionerSession(
              doctor: DoctorModel.empty().copyWith(uid: 'd1'),
              roles: RoleHelper.fromClaims({'role': role}),
            ),
          ),
          'd1',
        );
      }
    });

    test('an empty uid is no watch', () {
      expect(
        inboxWatchUid(
          PractitionerSession(
            doctor: DoctorModel.empty(),
            roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
          ),
        ),
        isNull,
      );
    });

    test('nobody is watched in the background', () {
      expect(
        inboxWatchUid(
          PatientSession(
            patient: PatientModel.empty().copyWith(uid: 'p1'),
            roles: RoleHelper.fromClaims(const {'role': 'patient'}),
          ),
          foreground: false,
        ),
        isNull,
      );
    });

    test('no role, no watch', () {
      expect(inboxWatchUid(const SignedOutSession()), isNull);
      expect(
        inboxWatchUid(PendingVerificationSession(doctor: DoctorModel.empty())),
        isNull,
      );
      expect(
        inboxWatchUid(
          PractitionerSession(
            doctor: DoctorModel.empty().copyWith(uid: 'd1'),
            roles: RoleHelper.none,
          ),
        ),
        isNull,
      );
    });
  });
}
