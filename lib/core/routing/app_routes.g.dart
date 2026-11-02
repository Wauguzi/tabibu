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
  $patientNotificationsRoute,
  $findDoctorRoute,
  $practitionerProfileRoute,
  $patientAppointmentRoute,
  $bookedRoute,
  $patientResultRoute,
  $explainedResultRoute,
  $healthNoticeRoute,
  $doctorNotificationsRoute,
  $reportsReadyRoute,
  $bookingRequestsRoute,
  $doctorAppointmentRoute,
  $orderRoute,
  $orderSentRoute,
  $mohProtocolRoute,
  $doctorCaseRoute,
  $doctorReportRoute,
  $fullReportRoute,
  $alertReviewRoute,
  $alertSentRoute,
  $pathologistNotificationsRoute,
  $deskListRoute,
  $deskSearchRoute,
  $caseWorkspaceRoute,
  $tilesRoute,
  $compareRoute,
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

RouteBase get $patientNotificationsRoute => GoRouteData.$route(
  path: '/patient/notifications',
  hasOverriddenOnExit: false,
  factory: $PatientNotificationsRoute._fromState,
);

mixin $PatientNotificationsRoute on GoRouteData {
  static PatientNotificationsRoute _fromState(GoRouterState state) =>
      const PatientNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/patient/notifications');

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

RouteBase get $findDoctorRoute => GoRouteData.$route(
  path: '/patient/doctors',
  hasOverriddenOnExit: false,
  factory: $FindDoctorRoute._fromState,
);

mixin $FindDoctorRoute on GoRouteData {
  static FindDoctorRoute _fromState(GoRouterState state) =>
      const FindDoctorRoute();

  @override
  String get location => GoRouteData.$location('/patient/doctors');

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

RouteBase get $practitionerProfileRoute => GoRouteData.$route(
  path: '/patient/doctors/:doctorUid',
  hasOverriddenOnExit: false,
  factory: $PractitionerProfileRoute._fromState,
);

mixin $PractitionerProfileRoute on GoRouteData {
  static PractitionerProfileRoute _fromState(GoRouterState state) =>
      PractitionerProfileRoute(doctorUid: state.pathParameters['doctorUid']!);

  PractitionerProfileRoute get _self => this as PractitionerProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/doctors/${Uri.encodeComponent(_self.doctorUid)}',
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

RouteBase get $patientAppointmentRoute => GoRouteData.$route(
  path: '/patient/appointment/:appointmentUid',
  hasOverriddenOnExit: false,
  factory: $PatientAppointmentRoute._fromState,
);

mixin $PatientAppointmentRoute on GoRouteData {
  static PatientAppointmentRoute _fromState(GoRouterState state) =>
      PatientAppointmentRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  PatientAppointmentRoute get _self => this as PatientAppointmentRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/appointment/${Uri.encodeComponent(_self.appointmentUid)}',
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

RouteBase get $bookedRoute => GoRouteData.$route(
  path: '/patient/appointment/:appointmentUid/booked',
  hasOverriddenOnExit: false,
  factory: $BookedRoute._fromState,
);

mixin $BookedRoute on GoRouteData {
  static BookedRoute _fromState(GoRouterState state) =>
      BookedRoute(appointmentUid: state.pathParameters['appointmentUid']!);

  BookedRoute get _self => this as BookedRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/appointment/${Uri.encodeComponent(_self.appointmentUid)}/booked',
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

RouteBase get $patientResultRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid',
  hasOverriddenOnExit: false,
  factory: $PatientResultRoute._fromState,
);

mixin $PatientResultRoute on GoRouteData {
  static PatientResultRoute _fromState(GoRouterState state) =>
      PatientResultRoute(caseUid: state.pathParameters['caseUid']!);

  PatientResultRoute get _self => this as PatientResultRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}',
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

RouteBase get $explainedResultRoute => GoRouteData.$route(
  path: '/patient/result/:caseUid/explained',
  hasOverriddenOnExit: false,
  factory: $ExplainedResultRoute._fromState,
);

mixin $ExplainedResultRoute on GoRouteData {
  static ExplainedResultRoute _fromState(GoRouterState state) =>
      ExplainedResultRoute(caseUid: state.pathParameters['caseUid']!);

  ExplainedResultRoute get _self => this as ExplainedResultRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/result/${Uri.encodeComponent(_self.caseUid)}/explained',
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

RouteBase get $healthNoticeRoute => GoRouteData.$route(
  path: '/patient/notice/:alertUid',
  hasOverriddenOnExit: false,
  factory: $HealthNoticeRoute._fromState,
);

mixin $HealthNoticeRoute on GoRouteData {
  static HealthNoticeRoute _fromState(GoRouterState state) =>
      HealthNoticeRoute(alertUid: state.pathParameters['alertUid']!);

  HealthNoticeRoute get _self => this as HealthNoticeRoute;

  @override
  String get location => GoRouteData.$location(
    '/patient/notice/${Uri.encodeComponent(_self.alertUid)}',
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

RouteBase get $doctorNotificationsRoute => GoRouteData.$route(
  path: '/doctor/notifications',
  hasOverriddenOnExit: false,
  factory: $DoctorNotificationsRoute._fromState,
);

mixin $DoctorNotificationsRoute on GoRouteData {
  static DoctorNotificationsRoute _fromState(GoRouterState state) =>
      const DoctorNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/notifications');

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

RouteBase get $reportsReadyRoute => GoRouteData.$route(
  path: '/doctor/reports-ready',
  hasOverriddenOnExit: false,
  factory: $ReportsReadyRoute._fromState,
);

mixin $ReportsReadyRoute on GoRouteData {
  static ReportsReadyRoute _fromState(GoRouterState state) =>
      const ReportsReadyRoute();

  @override
  String get location => GoRouteData.$location('/doctor/reports-ready');

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

RouteBase get $bookingRequestsRoute => GoRouteData.$route(
  path: '/doctor/booking-requests',
  hasOverriddenOnExit: false,
  factory: $BookingRequestsRoute._fromState,
);

mixin $BookingRequestsRoute on GoRouteData {
  static BookingRequestsRoute _fromState(GoRouterState state) =>
      const BookingRequestsRoute();

  @override
  String get location => GoRouteData.$location('/doctor/booking-requests');

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

RouteBase get $doctorAppointmentRoute => GoRouteData.$route(
  path: '/doctor/appointment/:appointmentUid',
  hasOverriddenOnExit: false,
  factory: $DoctorAppointmentRoute._fromState,
);

mixin $DoctorAppointmentRoute on GoRouteData {
  static DoctorAppointmentRoute _fromState(GoRouterState state) =>
      DoctorAppointmentRoute(
        appointmentUid: state.pathParameters['appointmentUid']!,
      );

  DoctorAppointmentRoute get _self => this as DoctorAppointmentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/appointment/${Uri.encodeComponent(_self.appointmentUid)}',
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

RouteBase get $orderRoute => GoRouteData.$route(
  path: '/doctor/appointment/:appointmentUid/order',
  hasOverriddenOnExit: false,
  factory: $OrderRoute._fromState,
);

mixin $OrderRoute on GoRouteData {
  static OrderRoute _fromState(GoRouterState state) =>
      OrderRoute(appointmentUid: state.pathParameters['appointmentUid']!);

  OrderRoute get _self => this as OrderRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/appointment/${Uri.encodeComponent(_self.appointmentUid)}/order',
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

RouteBase get $orderSentRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/sent',
  hasOverriddenOnExit: false,
  factory: $OrderSentRoute._fromState,
);

mixin $OrderSentRoute on GoRouteData {
  static OrderSentRoute _fromState(GoRouterState state) =>
      OrderSentRoute(caseUid: state.pathParameters['caseUid']!);

  OrderSentRoute get _self => this as OrderSentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/sent',
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

RouteBase get $mohProtocolRoute => GoRouteData.$route(
  path: '/doctor/protocol/:protocolId',
  hasOverriddenOnExit: false,
  factory: $MohProtocolRoute._fromState,
);

mixin $MohProtocolRoute on GoRouteData {
  static MohProtocolRoute _fromState(GoRouterState state) =>
      MohProtocolRoute(protocolId: state.pathParameters['protocolId']!);

  MohProtocolRoute get _self => this as MohProtocolRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/protocol/${Uri.encodeComponent(_self.protocolId)}',
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

RouteBase get $doctorCaseRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid',
  hasOverriddenOnExit: false,
  factory: $DoctorCaseRoute._fromState,
);

mixin $DoctorCaseRoute on GoRouteData {
  static DoctorCaseRoute _fromState(GoRouterState state) =>
      DoctorCaseRoute(caseUid: state.pathParameters['caseUid']!);

  DoctorCaseRoute get _self => this as DoctorCaseRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}',
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

RouteBase get $doctorReportRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/report',
  hasOverriddenOnExit: false,
  factory: $DoctorReportRoute._fromState,
);

mixin $DoctorReportRoute on GoRouteData {
  static DoctorReportRoute _fromState(GoRouterState state) =>
      DoctorReportRoute(caseUid: state.pathParameters['caseUid']!);

  DoctorReportRoute get _self => this as DoctorReportRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/report',
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

RouteBase get $fullReportRoute => GoRouteData.$route(
  path: '/doctor/case/:caseUid/report/full',
  hasOverriddenOnExit: false,
  factory: $FullReportRoute._fromState,
);

mixin $FullReportRoute on GoRouteData {
  static FullReportRoute _fromState(GoRouterState state) =>
      FullReportRoute(caseUid: state.pathParameters['caseUid']!);

  FullReportRoute get _self => this as FullReportRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/case/${Uri.encodeComponent(_self.caseUid)}/report/full',
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

RouteBase get $alertReviewRoute => GoRouteData.$route(
  path: '/doctor/alert/:alertUid',
  hasOverriddenOnExit: false,
  factory: $AlertReviewRoute._fromState,
);

mixin $AlertReviewRoute on GoRouteData {
  static AlertReviewRoute _fromState(GoRouterState state) =>
      AlertReviewRoute(alertUid: state.pathParameters['alertUid']!);

  AlertReviewRoute get _self => this as AlertReviewRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/alert/${Uri.encodeComponent(_self.alertUid)}',
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

RouteBase get $alertSentRoute => GoRouteData.$route(
  path: '/doctor/alert/:alertUid/sent',
  hasOverriddenOnExit: false,
  factory: $AlertSentRoute._fromState,
);

mixin $AlertSentRoute on GoRouteData {
  static AlertSentRoute _fromState(GoRouterState state) =>
      AlertSentRoute(alertUid: state.pathParameters['alertUid']!);

  AlertSentRoute get _self => this as AlertSentRoute;

  @override
  String get location => GoRouteData.$location(
    '/doctor/alert/${Uri.encodeComponent(_self.alertUid)}/sent',
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

RouteBase get $pathologistNotificationsRoute => GoRouteData.$route(
  path: '/pathologist/notifications',
  hasOverriddenOnExit: false,
  factory: $PathologistNotificationsRoute._fromState,
);

mixin $PathologistNotificationsRoute on GoRouteData {
  static PathologistNotificationsRoute _fromState(GoRouterState state) =>
      const PathologistNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/notifications');

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

RouteBase get $deskListRoute => GoRouteData.$route(
  path: '/pathologist/cases',
  hasOverriddenOnExit: false,
  factory: $DeskListRoute._fromState,
);

mixin $DeskListRoute on GoRouteData {
  static DeskListRoute _fromState(GoRouterState state) =>
      DeskListRoute(filter: state.uri.queryParameters['filter'] ?? 'all');

  DeskListRoute get _self => this as DeskListRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/cases',
    queryParams: {if (_self.filter != 'all') 'filter': _self.filter},
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

RouteBase get $deskSearchRoute => GoRouteData.$route(
  path: '/pathologist/search',
  hasOverriddenOnExit: false,
  factory: $DeskSearchRoute._fromState,
);

mixin $DeskSearchRoute on GoRouteData {
  static DeskSearchRoute _fromState(GoRouterState state) =>
      const DeskSearchRoute();

  @override
  String get location => GoRouteData.$location('/pathologist/search');

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

RouteBase get $caseWorkspaceRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid',
  hasOverriddenOnExit: false,
  factory: $CaseWorkspaceRoute._fromState,
);

mixin $CaseWorkspaceRoute on GoRouteData {
  static CaseWorkspaceRoute _fromState(GoRouterState state) =>
      CaseWorkspaceRoute(caseUid: state.pathParameters['caseUid']!);

  CaseWorkspaceRoute get _self => this as CaseWorkspaceRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}',
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

RouteBase get $tilesRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid/tiles',
  hasOverriddenOnExit: false,
  factory: $TilesRoute._fromState,
);

mixin $TilesRoute on GoRouteData {
  static TilesRoute _fromState(GoRouterState state) =>
      TilesRoute(caseUid: state.pathParameters['caseUid']!);

  TilesRoute get _self => this as TilesRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}/tiles',
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

RouteBase get $compareRoute => GoRouteData.$route(
  path: '/pathologist/case/:caseUid/compare',
  hasOverriddenOnExit: false,
  factory: $CompareRoute._fromState,
);

mixin $CompareRoute on GoRouteData {
  static CompareRoute _fromState(GoRouterState state) =>
      CompareRoute(caseUid: state.pathParameters['caseUid']!);

  CompareRoute get _self => this as CompareRoute;

  @override
  String get location => GoRouteData.$location(
    '/pathologist/case/${Uri.encodeComponent(_self.caseUid)}/compare',
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
