import 'package:equatable/equatable.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

/// Where a cold start or sign-in lands (architecture §8). The decision route
/// reads this; a screen never infers it.
sealed class AuthSession extends Equatable {
  const AuthSession();

  @override
  List<Object?> get props => [];
}

final class SignedOutSession extends AuthSession {
  const SignedOutSession();
}

/// Signed in, with no role and no profile: sign-up is not finished. An
/// address not yet confirmed must be verified before any profile step; a
/// Google account arrives confirmed.
final class SignUpIncompleteSession extends AuthSession {
  const SignUpIncompleteSession({
    required this.email,
    this.emailVerified = false,
  });

  final String email;
  final bool emailVerified;

  @override
  List<Object?> get props => [email, emailVerified];
}

/// Signed up as a patient, but a clinic record already holds this phone and
/// birth date; the doctor must link the account in person (T-15).
final class ClinicRecordExistsSession extends AuthSession {
  const ClinicRecordExistsSession();
}

/// A practitioner whose profile is not verified: no role, no clinical route
/// (T-14).
final class PendingVerificationSession extends AuthSession {
  const PendingVerificationSession({required this.doctor});

  final DoctorModel doctor;

  @override
  List<Object?> get props => [doctor];
}

final class PatientSession extends AuthSession {
  const PatientSession({required this.patient, required this.roles});

  final PatientModel patient;
  final RoleHelper roles;

  @override
  List<Object?> get props => [patient, roles];
}

final class PractitionerSession extends AuthSession {
  const PractitionerSession({required this.doctor, required this.roles});

  final DoctorModel doctor;
  final RoleHelper roles;

  @override
  List<Object?> get props => [doctor, roles];
}
