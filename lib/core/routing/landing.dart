import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';

/// Where a cold start lands, in precedence order (architecture §8).
enum Landing {
  /// The build is older than Remote Config allows; nothing else is checked.
  update,

  /// First run: the language and intro screens (A2 to A6).
  onboarding,
  signIn,

  /// Signed in, but the email address is not confirmed yet.
  verifyEmail,

  /// Signed in with no role and no profile: back to the role choice (C1).
  finishSignUp,

  /// A clinic record holds this phone and birth date (T-15).
  clinicRecord,

  /// Pending or rejected practitioner (E5).
  pending,
  patientHome,
  doctorHome,
  pathologistHome,
}

/// Pure, so every rung is unit-tested; the decision route only maps the
/// answer to a route.
Landing resolveLanding({
  required AuthSession session,
  required bool updateRequired,
  required bool isOnboarded,
}) {
  if (updateRequired) return Landing.update;
  return switch (session) {
    SignedOutSession() => isOnboarded ? Landing.signIn : Landing.onboarding,
    SignUpIncompleteSession(:final emailVerified) =>
      emailVerified ? Landing.finishSignUp : Landing.verifyEmail,
    ClinicRecordExistsSession() => Landing.clinicRecord,
    PendingVerificationSession() => Landing.pending,
    PatientSession() => Landing.patientHome,
    PractitionerSession(:final roles) =>
      roles.isPathologist ? Landing.pathologistHome : Landing.doctorHome,
  };
}

/// Path prefixes, shared by the routes and the guard so the two cannot
/// drift apart.
abstract final class RoutePaths {
  static const decision = '/decision';
  static const update = '/update';
  static const patient = '/patient';
  static const doctor = '/doctor';
  static const pathologist = '/pathologist';
  static const signUp = '/sign-up';
  static const account = '/account';
}

/// Sign-up steps that need an account to exist (they upload or call a
/// callable as the user), relative to [RoutePaths.signUp].
const accountSignUpSteps = {
  'patient/phone',
  'patient/area',
  'practitioner/licence',
  'practitioner/facility',
  'practitioner/review',
};

/// The redirect, by role claim (architecture §8): null lets [location]
/// through; anything else is where to go instead. A refused deep link goes
/// to the decision route, which sends the person on once they are known.
String? guardLocation({
  required String location,
  required AuthSession session,
}) {
  final path = Uri.parse(location).path;
  final roles = switch (session) {
    PatientSession(:final roles) || PractitionerSession(:final roles) => roles,
    _ => null,
  };

  bool under(String prefix) => path == prefix || path.startsWith('$prefix/');

  final required = under(RoutePaths.patient)
      ? Role.patient
      : under(RoutePaths.doctor)
      ? Role.doctor
      : under(RoutePaths.pathologist)
      ? Role.pathologist
      : null;
  if (required != null) {
    return roles?.role == required ? null : _decision(location);
  }

  const signUpPrefix = '${RoutePaths.signUp}/';
  final needsAccount =
      under(RoutePaths.account) ||
      (path.startsWith(signUpPrefix) &&
          accountSignUpSteps.contains(path.substring(signUpPrefix.length)));
  if (needsAccount && session is SignedOutSession) return _decision(location);
  return null;
}

String _decision(String from) =>
    Uri(path: RoutePaths.decision, queryParameters: {'from': from}).toString();
