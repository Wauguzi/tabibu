import 'package:injectable/injectable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

/// Turns a signed-in Firebase user into an [AuthSession], and owns the
/// cache-versus-remote decision for the profile (architecture §3, §6).
@lazySingleton
class AuthHelper {
  AuthHelper({AuthFirebase? authFirebase, HiveHelper? hiveHelper})
    : _remote = authFirebase ?? getIt<AuthFirebase>(),
      _cache = hiveHelper ?? getIt<HiveHelper>();

  final AuthFirebase _remote;
  final HiveHelper _cache;

  /// Failures that mean "the cloud cannot be reached", for which the cached
  /// profile stands in.
  static const Set<AppError> _offline = {
    AppError.noInternet,
    AppError.serviceUnavailable,
    AppError.requestTimeout,
  };

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _remote.signInWithEmail(email: email, password: password);
    return await resolveSession();
  }

  /// Null when the person dismissed the Google dialog.
  Future<AuthSession?> signInWithGoogle() async {
    if (!await _remote.signInWithGoogle()) return null;
    return await resolveSession();
  }

  Future<AuthSession> createAccount({
    required String email,
    required String password,
  }) async {
    await _remote.createAccount(email: email, password: password);
    return await resolveSession();
  }

  Future<void> sendPasswordReset({required String email}) =>
      _remote.sendPasswordReset(email: email);

  Future<AuthSession> completePatientSignUp(
    PatientSignUpRequest request,
  ) async {
    final outcome = await _remote.completePatientSignUp(request);
    if (outcome == PatientSignUpOutcome.clinicRecordExists) {
      return const ClinicRecordExistsSession();
    }
    // The claim was set after this token was issued.
    return await resolveSession(forceRefresh: true);
  }

  Future<AuthSession> completePractitionerSignUp(
    PractitionerSignUpRequest request,
  ) async {
    await _remote.completePractitionerSignUp(request);
    return await resolveSession();
  }

  /// Signs out of Firebase first, so nothing is fetched into the cache after
  /// it is wiped.
  Future<void> signOut() async {
    await _remote.signOut();
    await _cache.clearOnSignOut();
  }

  /// Where this user belongs now. [forceRefresh] fetches a new ID token, for
  /// a role granted since the current one was issued.
  Future<AuthSession> resolveSession({bool forceRefresh = false}) async {
    final user = _remote.currentUser;
    if (user == null) return const SignedOutSession();
    await _cache.scopeTo(user.uid);

    final roles = await _rolesOrNone(forceRefresh: forceRefresh);
    if (roles.isPatient) {
      final patient = await _patient(user.uid);
      if (patient != null) {
        return PatientSession(patient: patient, roles: roles);
      }
    }
    if (roles.isPractitioner) {
      final doctor = await _doctor(user.uid);
      if (doctor != null) {
        return PractitionerSession(doctor: doctor, roles: roles);
      }
    }
    if (roles.hasRole) {
      // A role with no profile to show: nothing reachable is safe to open.
      throw AppError.noRoleAssigned;
    }

    final doctor = await _doctor(user.uid);
    if (doctor != null) {
      if (doctor.verificationStatusValue == VerificationStatus.verified &&
          !forceRefresh) {
        // Verified since this token was issued.
        return await resolveSession(forceRefresh: true);
      }
      return PendingVerificationSession(doctor: doctor);
    }
    if (!forceRefresh && await _patient(user.uid) != null) {
      // Linked or registered since this token was issued.
      return await resolveSession(forceRefresh: true);
    }
    return SignUpIncompleteSession(email: user.email ?? '');
  }

  Future<RoleHelper> _rolesOrNone({required bool forceRefresh}) async {
    try {
      return await _remote.roles(forceRefresh: forceRefresh);
    } on AppError catch (e) {
      // Offline, a forced refresh fails; the token already held still has
      // the claims it was issued with.
      if (!forceRefresh || !_offline.contains(e)) rethrow;
      return await _remote.roles();
    }
  }

  /// Remote first, so a cold start shows the current profile; the cache
  /// answers only when the cloud cannot.
  Future<PatientModel?> _patient(String uid) async {
    try {
      final remote = await _remote.fetchOwnPatientRecord(uid);
      if (remote != null) await _cache.cachePatients([remote], fromCloud: true);
      return remote;
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      return await _cache.getCachedOwnPatientRecord(uid);
    }
  }

  Future<DoctorModel?> _doctor(String uid) async {
    try {
      final remote = await _remote.fetchDoctorProfile(uid);
      if (remote != null) {
        await _cache.cacheDoctorProfile(remote, fromCloud: true);
      }
      return remote;
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      return await _cache.getCachedDoctorProfile(uid);
    }
  }
}
