import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/landing.dart';
import 'package:tabibu/core/routing/route_placeholder.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/clinic_record_screen.dart';
import 'package:tabibu/features/auth/presentation/decision_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_account_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_all_set_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_area_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_name_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_phone_screen.dart';
import 'package:tabibu/features/auth/presentation/pending_verification_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_details_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_facility_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_licence_screen.dart';
import 'package:tabibu/features/auth/presentation/practitioner_review_screen.dart';
import 'package:tabibu/features/auth/presentation/reset_password_screen.dart';
import 'package:tabibu/features/auth/presentation/reset_password_sent_screen.dart';
import 'package:tabibu/features/auth/presentation/role_screen.dart';
import 'package:tabibu/features/auth/presentation/sign_in_screen.dart';
import 'package:tabibu/features/auth/presentation/verified_screen.dart';
import 'package:tabibu/features/onboarding/presentation/get_started_screen.dart';
import 'package:tabibu/features/onboarding/presentation/intro_screen.dart';
import 'package:tabibu/features/onboarding/presentation/language_screen.dart';
import 'package:tabibu/features/onboarding/presentation/update_required_screen.dart';

part 'app_routes.g.dart';

// Screen ids follow the designs (A1 to F5). A route whose screen is not
// built yet renders a RoutePlaceholder.

/// The route for each [Landing], shared by the decision route and every
/// screen that finishes a sign-in or sign-up step.
GoRouteData routeForLanding(Landing landing) => switch (landing) {
  Landing.update => const UpdateRoute(),
  Landing.onboarding => const LanguageRoute(),
  Landing.signIn => const SignInRoute(),
  Landing.finishSignUp => const SignUpRoleRoute(),
  Landing.clinicRecord => const ClinicRecordRoute(),
  Landing.pending => const PendingVerificationRoute(),
  Landing.patientHome => const PatientHomeRoute(),
  Landing.doctorHome => const DoctorHomeRoute(),
  Landing.pathologistHome => const PathologistHomeRoute(),
};

/// Sends a person who has just signed in or signed up where [session]
/// belongs, by the same order as a cold start.
void goToSession(BuildContext context, AuthSession session) => routeForLanding(
  resolveLanding(session: session, updateRequired: false, isOnboarded: true),
).go(context);

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
      const UpdateRequiredScreen();
}

// ── Onboarding (A2 to A6) ──────────────────────────────────────────────────

@TypedGoRoute<LanguageRoute>(path: '/language')
class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LanguageScreen();
}

/// A3 to A5, one paged screen.
@TypedGoRoute<IntroRoute>(path: '/intro')
class IntroRoute extends GoRouteData with $IntroRoute {
  const IntroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const IntroScreen();
}

@TypedGoRoute<GetStartedRoute>(path: '/get-started')
class GetStartedRoute extends GoRouteData with $GetStartedRoute {
  const GetStartedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GetStartedScreen();
}

// ── Sign-in (B) ────────────────────────────────────────────────────────────

/// B1, and B2 as its wrong-password state.
@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedGoRoute<ResetPasswordRoute>(
  path: '/reset-password',
  routes: [TypedGoRoute<ResetPasswordSentRoute>(path: 'sent')],
)
class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResetPasswordScreen();
}

class ResetPasswordSentRoute extends GoRouteData with $ResetPasswordSentRoute {
  const ResetPasswordSentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResetPasswordSentScreen();
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
  Widget build(BuildContext context, GoRouterState state) => const RoleScreen();
}

class PatientNameRoute extends GoRouteData with $PatientNameRoute {
  const PatientNameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientNameScreen();
}

/// Creates the Auth account.
class PatientAccountRoute extends GoRouteData with $PatientAccountRoute {
  const PatientAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAccountScreen();
}

class PatientPhoneRoute extends GoRouteData with $PatientPhoneRoute {
  const PatientPhoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientPhoneScreen();
}

/// Submits the patient sign-up.
class PatientAreaRoute extends GoRouteData with $PatientAreaRoute {
  const PatientAreaRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAreaScreen();
}

/// E1 and F1; creates the Auth account, or skips that when one is signed in.
class PractitionerDetailsRoute extends GoRouteData
    with $PractitionerDetailsRoute {
  const PractitionerDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerDetailsScreen();
}

class PractitionerLicenceRoute extends GoRouteData
    with $PractitionerLicenceRoute {
  const PractitionerLicenceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerLicenceScreen();
}

class PractitionerFacilityRoute extends GoRouteData
    with $PractitionerFacilityRoute {
  const PractitionerFacilityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerFacilityScreen();
}

/// Uploads the files and submits.
class PractitionerReviewRoute extends GoRouteData
    with $PractitionerReviewRoute {
  const PractitionerReviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PractitionerReviewScreen();
}

// ── Account states after sign-up ───────────────────────────────────────────

// Under RoutePaths.account, which the guard holds for signed-in accounts.

@TypedGoRoute<PatientAllSetRoute>(path: '${RoutePaths.account}/all-set')
class PatientAllSetRoute extends GoRouteData with $PatientAllSetRoute {
  const PatientAllSetRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PatientAllSetScreen();
}

/// A clinic already holds this phone and birth date; the doctor links the
/// account in person (T-15).
@TypedGoRoute<ClinicRecordRoute>(path: '${RoutePaths.account}/clinic-record')
class ClinicRecordRoute extends GoRouteData with $ClinicRecordRoute {
  const ClinicRecordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ClinicRecordScreen();
}

/// E5, and the rejected state.
@TypedGoRoute<PendingVerificationRoute>(path: '${RoutePaths.account}/pending')
class PendingVerificationRoute extends GoRouteData
    with $PendingVerificationRoute {
  const PendingVerificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PendingVerificationScreen();
}

/// E6 and F5, shown once after verification.
@TypedGoRoute<VerifiedRoute>(path: '${RoutePaths.account}/verified')
class VerifiedRoute extends GoRouteData with $VerifiedRoute {
  const VerifiedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const VerifiedScreen();
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
