import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/core/routing/route_placeholder.dart';
import 'package:tabibu/features/auth/presentation/decision_screen.dart';

part 'app_routes.g.dart';

// Screen ids follow the designs (A1 to F5). A route whose screen is not
// built yet renders a RoutePlaceholder.

@TypedGoRoute<DecisionRoute>(path: RoutePaths.decision)
class DecisionRoute extends GoRouteData with $DecisionRoute {
  const DecisionRoute({this.from});

  /// A deep link the guard held back, followed once the session is known.
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DecisionScreen(from: from);
}

@TypedGoRoute<UpdateRoute>(path: RoutePaths.update)
class UpdateRoute extends GoRouteData with $UpdateRoute {
  const UpdateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Update required');
}

// ── Onboarding (A2 to A6) ──────────────────────────────────────────────────

@TypedGoRoute<LanguageRoute>(path: '/language')
class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'A2 Language');
}

/// A3 to A5, one paged screen.
@TypedGoRoute<IntroRoute>(path: '/intro')
class IntroRoute extends GoRouteData with $IntroRoute {
  const IntroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'A3–A5 Intro');
}

@TypedGoRoute<GetStartedRoute>(path: '/get-started')
class GetStartedRoute extends GoRouteData with $GetStartedRoute {
  const GetStartedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'A6 Get started');
}

// ── Sign-in (B) ────────────────────────────────────────────────────────────

/// B1, and B2 as its wrong-password state.
@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'B1 Sign in');
}

@TypedGoRoute<ResetPasswordRoute>(
  path: '/reset-password',
  routes: [TypedGoRoute<ResetPasswordSentRoute>(path: 'sent')],
)
class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Reset password');
}

class ResetPasswordSentRoute extends GoRouteData with $ResetPasswordSentRoute {
  const ResetPasswordSentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'B5 Check your email');
}

// ── Sign-up (C, D, E, F) ───────────────────────────────────────────────────
// The draft lives in SignUpBloc, so these routes take no parameters. The
// practitioner steps serve doctors (E) and pathologists (F); the draft's role
// decides the copy.

@TypedGoRoute<SignUpRoleRoute>(
  path: RoutePaths.signUp,
  routes: [
    TypedGoRoute<PatientNameRoute>(path: 'patient/name'),
    TypedGoRoute<PatientAccountRoute>(path: 'patient/account'),
    TypedGoRoute<PatientPhoneRoute>(path: 'patient/phone'),
    TypedGoRoute<PatientAreaRoute>(path: 'patient/area'),
    TypedGoRoute<PractitionerDetailsRoute>(path: 'practitioner/details'),
    TypedGoRoute<PractitionerLicenceRoute>(path: 'practitioner/licence'),
    TypedGoRoute<PractitionerFacilityRoute>(path: 'practitioner/facility'),
    TypedGoRoute<PractitionerReviewRoute>(path: 'practitioner/review'),
  ],
)
class SignUpRoleRoute extends GoRouteData with $SignUpRoleRoute {
  const SignUpRoleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'C1 Choose your role');
}

class PatientNameRoute extends GoRouteData with $PatientNameRoute {
  const PatientNameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'D1 Name');
}

/// Creates the Auth account.
class PatientAccountRoute extends GoRouteData with $PatientAccountRoute {
  const PatientAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'D2 Email and password');
}

class PatientPhoneRoute extends GoRouteData with $PatientPhoneRoute {
  const PatientPhoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'D3 Phone');
}

/// Submits the patient sign-up.
class PatientAreaRoute extends GoRouteData with $PatientAreaRoute {
  const PatientAreaRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'D4 Your area');
}

/// E1 and F1; creates the Auth account, or skips that when one is signed in.
class PractitionerDetailsRoute extends GoRouteData
    with $PractitionerDetailsRoute {
  const PractitionerDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E1/F1 Your details');
}

class PractitionerLicenceRoute extends GoRouteData
    with $PractitionerLicenceRoute {
  const PractitionerLicenceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E2/F2 Licence');
}

class PractitionerFacilityRoute extends GoRouteData
    with $PractitionerFacilityRoute {
  const PractitionerFacilityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E3/F3 Facility');
}

/// Uploads the files and submits.
class PractitionerReviewRoute extends GoRouteData
    with $PractitionerReviewRoute {
  const PractitionerReviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E4/F4 Review');
}

// ── Account states after sign-up ───────────────────────────────────────────

// Under RoutePaths.account, which the guard holds for signed-in accounts.

@TypedGoRoute<PatientAllSetRoute>(path: '${RoutePaths.account}/all-set')
class PatientAllSetRoute extends GoRouteData with $PatientAllSetRoute {
  const PatientAllSetRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'D5 All set');
}

/// A clinic already holds this phone and birth date; the doctor links the
/// account in person (T-15).
@TypedGoRoute<ClinicRecordRoute>(path: '${RoutePaths.account}/clinic-record')
class ClinicRecordRoute extends GoRouteData with $ClinicRecordRoute {
  const ClinicRecordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Clinic record exists');
}

/// E5, and the rejected state.
@TypedGoRoute<PendingVerificationRoute>(path: '${RoutePaths.account}/pending')
class PendingVerificationRoute extends GoRouteData
    with $PendingVerificationRoute {
  const PendingVerificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E5 Verification pending');
}

/// E6 and F5, shown once after verification.
@TypedGoRoute<VerifiedRoute>(path: '${RoutePaths.account}/verified')
class VerifiedRoute extends GoRouteData with $VerifiedRoute {
  const VerifiedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'E6/F5 Verified');
}

// ── Role homes ─────────────────────────────────────────────────────────────
// Guarded by role claim. Each becomes its role's StatefulShellRoute when its
// tabs are designed (architecture §8).

@TypedGoRoute<PatientHomeRoute>(path: RoutePaths.patient)
class PatientHomeRoute extends GoRouteData with $PatientHomeRoute {
  const PatientHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Patient home');
}

@TypedGoRoute<DoctorHomeRoute>(path: RoutePaths.doctor)
class DoctorHomeRoute extends GoRouteData with $DoctorHomeRoute {
  const DoctorHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Doctor home');
}

@TypedGoRoute<PathologistHomeRoute>(path: RoutePaths.pathologist)
class PathologistHomeRoute extends GoRouteData with $PathologistHomeRoute {
  const PathologistHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutePlaceholder(name: 'Pathologist home');
}
