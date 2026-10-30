import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/landing.dart';
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
import 'package:tabibu/features/auth/presentation/verify_email_screen.dart';
import 'package:tabibu/features/home/presentation/home_shell.dart';
import 'package:tabibu/features/home/presentation/home_tab_screen.dart';
import 'package:tabibu/features/home/presentation/title_tab_screen.dart';
import 'package:tabibu/features/onboarding/presentation/get_started_screen.dart';
import 'package:tabibu/features/onboarding/presentation/intro_screen.dart';
import 'package:tabibu/features/onboarding/presentation/language_screen.dart';
import 'package:tabibu/features/onboarding/presentation/update_required_screen.dart';
import 'package:tabibu/features/profile/presentation/profile_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

part 'app_routes.g.dart';

// Screen ids follow the designs (A1 to F5).

/// The route for each [Landing], shared by the decision route and every
/// screen that finishes a sign-in or sign-up step.
GoRouteData routeForLanding(Landing landing) => switch (landing) {
  .update => const UpdateRoute(),
  .onboarding => const LanguageRoute(),
  .signIn => const SignInRoute(),
  .verifyEmail => const VerifyEmailRoute(),
  .finishSignUp => const SignUpRoleRoute(),
  .clinicRecord => const ClinicRecordRoute(),
  .pending => const PendingVerificationRoute(),
  .patientHome => const PatientHomeRoute(),
  .doctorHome => const DoctorHomeRoute(),
  .pathologistHome => const PathologistHomeRoute(),
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
/// Between the account step and the next profile step: the address must be
/// confirmed before any profile is created (the callables refuse otherwise).
@TypedGoRoute<VerifyEmailRoute>(path: '${RoutePaths.account}/verify-email')
class VerifyEmailRoute extends GoRouteData with $VerifyEmailRoute {
  const VerifyEmailRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const VerifyEmailScreen();
}

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
// Guarded by role claim. Each role is a StatefulShellRoute of four tabs under
// its home path (architecture §8); a tab keeps its state while another shows.

/// The branch data every role tab shares; a branch carries nothing of its own.
class RoleTabBranch extends StatefulShellBranchData {
  const RoleTabBranch();
}

@TypedStatefulShellRoute<PatientShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<PatientHomeRoute>(path: RoutePaths.patient)],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientAppointmentsRoute>(
          path: '${RoutePaths.patient}/appointments',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientResultsRoute>(
          path: '${RoutePaths.patient}/results',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PatientProfileRoute>(
          path: '${RoutePaths.patient}/profile',
        ),
      ],
    ),
  ],
)
class PatientShellRoute extends StatefulShellRouteData {
  const PatientShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .patient, navigationShell: navigationShell);
}

class PatientHomeRoute extends GoRouteData with $PatientHomeRoute {
  const PatientHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeTabScreen(role: .patient);
}

class PatientAppointmentsRoute extends GoRouteData
    with $PatientAppointmentsRoute {
  const PatientAppointmentsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .patient, title: context.l10n.appointmentsTitle);
}

class PatientResultsRoute extends GoRouteData with $PatientResultsRoute {
  const PatientResultsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .patient, title: context.l10n.resultsTitle);
}

class PatientProfileRoute extends GoRouteData with $PatientProfileRoute {
  const PatientProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .patient);
}

@TypedStatefulShellRoute<DoctorShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<DoctorHomeRoute>(path: RoutePaths.doctor)],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<DoctorCasesRoute>(path: '${RoutePaths.doctor}/cases'),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [TypedGoRoute<DoctorMdtRoute>(path: '${RoutePaths.doctor}/mdt')],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<DoctorProfileRoute>(path: '${RoutePaths.doctor}/profile'),
      ],
    ),
  ],
)
class DoctorShellRoute extends StatefulShellRouteData {
  const DoctorShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .doctor, navigationShell: navigationShell);
}

class DoctorHomeRoute extends GoRouteData with $DoctorHomeRoute {
  const DoctorHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeTabScreen(role: .doctor);
}

class DoctorCasesRoute extends GoRouteData with $DoctorCasesRoute {
  const DoctorCasesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .doctor, title: context.l10n.casesTitle);
}

class DoctorMdtRoute extends GoRouteData with $DoctorMdtRoute {
  const DoctorMdtRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .doctor, title: context.l10n.mdtTitle);
}

class DoctorProfileRoute extends GoRouteData with $DoctorProfileRoute {
  const DoctorProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .doctor);
}

@TypedStatefulShellRoute<PathologistShellRoute>(
  branches: [
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistHomeRoute>(path: RoutePaths.pathologist),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistSignedRoute>(
          path: '${RoutePaths.pathologist}/signed',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistMdtRoute>(
          path: '${RoutePaths.pathologist}/mdt',
        ),
      ],
    ),
    TypedStatefulShellBranch<RoleTabBranch>(
      routes: [
        TypedGoRoute<PathologistProfileRoute>(
          path: '${RoutePaths.pathologist}/profile',
        ),
      ],
    ),
  ],
)
class PathologistShellRoute extends StatefulShellRouteData {
  const PathologistShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => HomeShell(role: .pathologist, navigationShell: navigationShell);
}

class PathologistHomeRoute extends GoRouteData with $PathologistHomeRoute {
  const PathologistHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeTabScreen(role: .pathologist);
}

class PathologistSignedRoute extends GoRouteData with $PathologistSignedRoute {
  const PathologistSignedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .pathologist, title: context.l10n.signedTitle);
}

class PathologistMdtRoute extends GoRouteData with $PathologistMdtRoute {
  const PathologistMdtRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TitleTabScreen(role: .pathologist, title: context.l10n.mdtTitle);
}

class PathologistProfileRoute extends GoRouteData
    with $PathologistProfileRoute {
  const PathologistProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen(role: .pathologist);
}
