import 'package:go_router/go_router.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';

/// The consult route for [role]. Only the id travels (F-2).
GoRouteData mdtConsultRoute(Role role, String conversationUid) =>
    switch (role) {
      .pathologist => PathologistMdtConsultRoute(
        conversationUid: conversationUid,
      ),
      _ => DoctorMdtConsultRoute(conversationUid: conversationUid),
    };

/// The new-consult route for [role], optionally on one case.
GoRouteData mdtNewRoute(Role role, {String caseUid = ''}) {
  final id = caseUid.isEmpty ? null : caseUid;
  return switch (role) {
    .pathologist => PathologistMdtNewRoute(caseUid: id),
    _ => DoctorMdtNewRoute(caseUid: id),
  };
}

/// The invite-a-colleague route for [role].
GoRouteData mdtInviteRoute(Role role, String conversationUid) => switch (role) {
  .pathologist => PathologistMdtInviteRoute(conversationUid: conversationUid),
  _ => DoctorMdtInviteRoute(conversationUid: conversationUid),
};
