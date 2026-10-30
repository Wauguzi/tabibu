// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $decisionRoute,
  $updateRoute,
  $languageRoute,
  $introRoute,
  $getStartedRoute,
  $signInRoute,
  $resetPasswordRoute,
  $signUpRoleRoute,
  $patientAllSetRoute,
  $clinicRecordRoute,
  $verifyEmailRoute,
  $pendingVerificationRoute,
  $verifiedRoute,
  $patientShellRoute,
  $doctorShellRoute,
  $pathologistShellRoute,
];

RouteBase get $decisionRoute => GoRouteData.$route(
  path: '/decision',
  hasOverriddenOnExit: false,
  factory: $DecisionRoute._fromState,
);

mixin $DecisionRoute on GoRouteData {
  static DecisionRoute _fromState(GoRouterState state) =>
      DecisionRoute(from: state.uri.queryParameters['from']);

  DecisionRoute get _self => this as DecisionRoute;

  @override
  String get location => GoRouteData.$location(
    '/decision',
    queryParams: {if (_self.from != null) 'from': _self.from},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $updateRoute => GoRouteData.$route(
  path: '/update',
  hasOverriddenOnExit: false,
  factory: $UpdateRoute._fromState,
);

mixin $UpdateRoute on GoRouteData {
  static UpdateRoute _fromState(GoRouterState state) => const UpdateRoute();

  @override
  String get location => GoRouteData.$location('/update');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $languageRoute => GoRouteData.$route(
  path: '/language',
  hasOverriddenOnExit: false,
  factory: $LanguageRoute._fromState,
);

mixin $LanguageRoute on GoRouteData {
  static LanguageRoute _fromState(GoRouterState state) => const LanguageRoute();

  @override
  String get location => GoRouteData.$location('/language');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $introRoute => GoRouteData.$route(
  path: '/intro',
  hasOverriddenOnExit: false,
  factory: $IntroRoute._fromState,
);

mixin $IntroRoute on GoRouteData {
  static IntroRoute _fromState(GoRouterState state) => const IntroRoute();

  @override
  String get location => GoRouteData.$location('/intro');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $getStartedRoute => GoRouteData.$route(
  path: '/get-started',
  hasOverriddenOnExit: false,
  factory: $GetStartedRoute._fromState,
);

mixin $GetStartedRoute on GoRouteData {
  static GetStartedRoute _fromState(GoRouterState state) =>
      const GetStartedRoute();

  @override
  String get location => GoRouteData.$location('/get-started');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetPasswordRoute => GoRouteData.$route(
  path: '/reset-password',
  hasOverriddenOnExit: false,
  factory: $ResetPasswordRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'sent',
      hasOverriddenOnExit: false,
      factory: $ResetPasswordSentRoute._fromState,
    ),
  ],
);

mixin $ResetPasswordRoute on GoRouteData {
  static ResetPasswordRoute _fromState(GoRouterState state) =>
      const ResetPasswordRoute();

  @override
  String get location => GoRouteData.$location('/reset-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ResetPasswordSentRoute on GoRouteData {
  static ResetPasswordSentRoute _fromState(GoRouterState state) =>
      const ResetPasswordSentRoute();

  @override
  String get location => GoRouteData.$location('/reset-password/sent');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoleRoute => GoRouteData.$route(
  path: '/sign-up',
  hasOverriddenOnExit: false,
  factory: $SignUpRoleRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'patient/name',
      hasOverriddenOnExit: false,
      factory: $PatientNameRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/account',
      hasOverriddenOnExit: false,
      factory: $PatientAccountRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/phone',
      hasOverriddenOnExit: false,
      factory: $PatientPhoneRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'patient/area',
      hasOverriddenOnExit: false,
      factory: $PatientAreaRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/details',
      hasOverriddenOnExit: false,
      factory: $PractitionerDetailsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/licence',
      hasOverriddenOnExit: false,
      factory: $PractitionerLicenceRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/facility',
      hasOverriddenOnExit: false,
      factory: $PractitionerFacilityRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'practitioner/review',
      hasOverriddenOnExit: false,
      factory: $PractitionerReviewRoute._fromState,
    ),
  ],
);

mixin $SignUpRoleRoute on GoRouteData {
  static SignUpRoleRoute _fromState(GoRouterState state) =>
      const SignUpRoleRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientNameRoute on GoRouteData {
  static PatientNameRoute _fromState(GoRouterState state) =>
      const PatientNameRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/name');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAccountRoute on GoRouteData {
  static PatientAccountRoute _fromState(GoRouterState state) =>
      const PatientAccountRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/account');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientPhoneRoute on GoRouteData {
  static PatientPhoneRoute _fromState(GoRouterState state) =>
      const PatientPhoneRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/phone');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAreaRoute on GoRouteData {
  static PatientAreaRoute _fromState(GoRouterState state) =>
      const PatientAreaRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/patient/area');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerDetailsRoute on GoRouteData {
  static PractitionerDetailsRoute _fromState(GoRouterState state) =>
      const PractitionerDetailsRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerLicenceRoute on GoRouteData {
  static PractitionerLicenceRoute _fromState(GoRouterState state) =>
      const PractitionerLicenceRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/licence');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerFacilityRoute on GoRouteData {
  static PractitionerFacilityRoute _fromState(GoRouterState state) =>
      const PractitionerFacilityRoute();

  @override
  String get location =>
      GoRouteData.$location('/sign-up/practitioner/facility');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PractitionerReviewRoute on GoRouteData {
  static PractitionerReviewRoute _fromState(GoRouterState state) =>
      const PractitionerReviewRoute();

  @override
  String get location => GoRouteData.$location('/sign-up/practitioner/review');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientAllSetRoute => GoRouteData.$route(
  path: '/account/all-set',
  hasOverriddenOnExit: false,
  factory: $PatientAllSetRoute._fromState,
);

mixin $PatientAllSetRoute on GoRouteData {
  static PatientAllSetRoute _fromState(GoRouterState state) =>
      const PatientAllSetRoute();

  @override
  String get location => GoRouteData.$location('/account/all-set');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clinicRecordRoute => GoRouteData.$route(
  path: '/account/clinic-record',
  hasOverriddenOnExit: false,
  factory: $ClinicRecordRoute._fromState,
);

mixin $ClinicRecordRoute on GoRouteData {
  static ClinicRecordRoute _fromState(GoRouterState state) =>
      const ClinicRecordRoute();

  @override
  String get location => GoRouteData.$location('/account/clinic-record');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyEmailRoute => GoRouteData.$route(
  path: '/account/verify-email',
  hasOverriddenOnExit: false,
  factory: $VerifyEmailRoute._fromState,
);

mixin $VerifyEmailRoute on GoRouteData {
  static VerifyEmailRoute _fromState(GoRouterState state) =>
      const VerifyEmailRoute();

  @override
  String get location => GoRouteData.$location('/account/verify-email');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pendingVerificationRoute => GoRouteData.$route(
  path: '/account/pending',
  hasOverriddenOnExit: false,
  factory: $PendingVerificationRoute._fromState,
);

mixin $PendingVerificationRoute on GoRouteData {
  static PendingVerificationRoute _fromState(GoRouterState state) =>
      const PendingVerificationRoute();

  @override
  String get location => GoRouteData.$location('/account/pending');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifiedRoute => GoRouteData.$route(
  path: '/account/verified',
  hasOverriddenOnExit: false,
  factory: $VerifiedRoute._fromState,
);

mixin $VerifiedRoute on GoRouteData {
  static VerifiedRoute _fromState(GoRouterState state) => const VerifiedRoute();

  @override
  String get location => GoRouteData.$location('/account/verified');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $patientShellRoute => StatefulShellRouteData.$route(
  factory: $PatientShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient',
          hasOverriddenOnExit: false,
          factory: $PatientHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/appointments',
          hasOverriddenOnExit: false,
          factory: $PatientAppointmentsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/results',
          hasOverriddenOnExit: false,
          factory: $PatientResultsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/patient/profile',
          hasOverriddenOnExit: false,
          factory: $PatientProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $PatientShellRouteExtension on PatientShellRoute {
  static PatientShellRoute _fromState(GoRouterState state) =>
      const PatientShellRoute();
}

mixin $PatientHomeRoute on GoRouteData {
  static PatientHomeRoute _fromState(GoRouterState state) =>
      const PatientHomeRoute();

  @override
  String get location => GoRouteData.$location('/patient');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientAppointmentsRoute on GoRouteData {
  static PatientAppointmentsRoute _fromState(GoRouterState state) =>
      const PatientAppointmentsRoute();

  @override
  String get location => GoRouteData.$location('/patient/appointments');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientResultsRoute on GoRouteData {
  static PatientResultsRoute _fromState(GoRouterState state) =>
      const PatientResultsRoute();

  @override
  String get location => GoRouteData.$location('/patient/results');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PatientProfileRoute on GoRouteData {
  static PatientProfileRoute _fromState(GoRouterState state) =>
      const PatientProfileRoute();

  @override
  String get location => GoRouteData.$location('/patient/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorShellRoute => StatefulShellRouteData.$route(
  factory: $DoctorShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor',
          hasOverriddenOnExit: false,
          factory: $DoctorHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/cases',
          hasOverriddenOnExit: false,
          factory: $DoctorCasesRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/mdt',
          hasOverriddenOnExit: false,
          factory: $DoctorMdtRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/doctor/profile',
          hasOverriddenOnExit: false,
          factory: $DoctorProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $DoctorShellRouteExtension on DoctorShellRoute {
  static DoctorShellRoute _fromState(GoRouterState state) =>
      const DoctorShellRoute();
}

mixin $DoctorHomeRoute on GoRouteData {
  static DoctorHomeRoute _fromState(GoRouterState state) =>
      const DoctorHomeRoute();

  @override
  String get location => GoRouteData.$location('/doctor');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorCasesRoute on GoRouteData {
  static DoctorCasesRoute _fromState(GoRouterState state) =>
      const DoctorCasesRoute();

  @override
  String get location => GoRouteData.$location('/doctor/cases');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorMdtRoute on GoRouteData {
  static DoctorMdtRoute _fromState(GoRouterState state) =>
      const DoctorMdtRoute();

  @override
  String get location => GoRouteData.$location('/doctor/mdt');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DoctorProfileRoute on GoRouteData {
  static DoctorProfileRoute _fromState(GoRouterState state) =>
      const DoctorProfileRoute();

  @override
  String get location => GoRouteData.$location('/doctor/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $pathologistShellRoute => StatefulShellRouteData.$route(
  factory: $PathologistShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist',
          hasOverriddenOnExit: false,
          factory: $PathologistHomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/signed',
          hasOverriddenOnExit: false,
          factory: $PathologistSignedRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/mdt',
          hasOverriddenOnExit: false,
          factory: $PathologistMdtRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/pathologist/profile',
          hasOverriddenOnExit: false,
          factory: $PathologistProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $PathologistShellRouteExtension on PathologistShellRoute {
  static PathologistShellRoute _fromState(GoRouterState state) =>
      const PathologistShellRoute();
}

mixin $PathologistHomeRoute on GoRouteData {
  static PathologistHomeRoute _fromState(GoRouterState state) =>
      const PathologistHomeRoute();

  @override
  String get location => GoRouteData.$location('/pathologist');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistSignedRoute on GoRouteData {
  static PathologistSignedRoute _fromState(GoRouterState state) =>
      const PathologistSignedRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/signed');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistMdtRoute on GoRouteData {
  static PathologistMdtRoute _fromState(GoRouterState state) =>
      const PathologistMdtRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/mdt');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PathologistProfileRoute on GoRouteData {
  static PathologistProfileRoute _fromState(GoRouterState state) =>
      const PathologistProfileRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
