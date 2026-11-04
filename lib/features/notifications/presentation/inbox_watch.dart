import 'package:tabibu/features/auth/data/models/auth_session.dart';

/// Whose inbox the app watches live: the signed-in person with a role,
/// while the app is in front; nobody otherwise (signed out, still signing
/// up, awaiting verification, or in the background).
String? inboxWatchUid(AuthSession session, {bool foreground = true}) {
  if (!foreground) return null;
  final uid = switch (session) {
    PatientSession(:final patient) => patient.uid,
    PractitionerSession(:final doctor, :final roles) when roles.hasRole =>
      doctor.uid,
    _ => '',
  };
  return uid.isEmpty ? null : uid;
}
