import 'package:injectable/injectable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/utils/email_address.dart';
import 'package:tabibu/features/auth/data/datasources/auth_firebase.dart';
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

/// Turns a signed-in Firebase user into an [AuthSession], and owns the
/// cache-versus-remote decision for the profile (architecture §3, §6).
@lazySingleton
class AuthHelper {
  AuthHelper({
    AuthFirebase? authFirebase,
    HiveHelper? hiveHelper,
    ProfileStorage? profileStorage,
    NotificationService? notificationService,
    @ignoreParam this.bestEffortTimeout = const Duration(seconds: 3),
  }) : _remote = authFirebase ?? getIt<AuthFirebase>(),
       _cache = hiveHelper ?? getIt<HiveHelper>(),
       _storage = profileStorage ?? getIt<ProfileStorage>(),
       _notifications = notificationService ?? getIt<NotificationService>();

  final AuthFirebase _remote;
  final HiveHelper _cache;
  final ProfileStorage _storage;
  final NotificationService _notifications;

  /// How long a best-effort write may hold up what follows it. Offline, a
  /// Firestore write waits for the server rather than failing, so without a
  /// bound it would never end.
  final Duration bestEffortTimeout;

  /// An upload retries for minutes by default; an optional photo must not
  /// hold a finished sign-up that long.
  static const _photoTimeout = Duration(seconds: 30);

  /// The rules' `tokens()` limit.
  static const maxDeviceTokens = 10;

  String? get currentUid => _remote.currentUser?.uid;

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
    _requireEmail(email);
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
    _requireEmail(email);
    await _remote.createAccount(email: email, password: password);
    return await resolveSession();
  }

  Future<void> sendPasswordReset({required String email}) async {
    _requireEmail(email);
    await _remote.sendPasswordReset(email: email);
  }

  /// "I've verified": reloads the account, then resolves where it now
  /// belongs. Still unverified, the session says so and nothing else moves.
  Future<AuthSession> checkEmailVerified() async {
    await _remote.reloadEmailVerified();
    return await resolveSession();
  }

  Future<void> resendVerificationEmail() => _remote.sendEmailVerification();

  /// The same check the screens make, so a malformed address never costs a
  /// round trip, whichever screen sent it.
  static void _requireEmail(String email) {
    if (!isValidEmail(email)) throw AppError.invalidEmail;
  }

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

  /// Uploads the practitioner's photo and one or two license files into
  /// their own folders, for the sign-up request to name.
  Future<({String pictureUrl, List<String> licenseUrls})> uploadSignUpFiles({
    required UploadFile picture,
    required List<UploadFile> licenses,
  }) async {
    final uid = currentUid;
    if (uid == null) throw AppError.unauthenticated;
    if (licenses.isEmpty || licenses.length > 2) throw AppError.invalidLicense;
    final pictureUrl = await _storage.uploadProfilePicture(
      owner: uid,
      file: picture,
    );
    final licenseUrls = [
      for (var i = 0; i < licenses.length; i++)
        await _storage.uploadLicense(uid: uid, index: i, file: licenses[i]),
    ];
    return (pictureUrl: pictureUrl, licenseUrls: licenseUrls);
  }

  /// The optional photo from D1, added once the record exists (sign-up
  /// takes no picture). Returns the session with the photo, or [session]
  /// unchanged if any step fails: a photo never fails a sign-up.
  Future<PatientSession> addPatientPicture(
    PatientSession session,
    UploadFile picture,
  ) async {
    final patientId = session.patient.patientId;
    try {
      final url = await _storage
          .uploadProfilePicture(owner: patientId, file: picture)
          .timeout(_photoTimeout);
      await _remote
          .updateProfilePicture(
            collection: 'patients',
            docId: patientId,
            url: url,
          )
          .timeout(bestEffortTimeout);
      return PatientSession(
        patient: session.patient.copyWith(profilePictureUrl: url),
        roles: session.roles,
      );
    } on Object catch (_) {
      // A slow network or an odd failure still lets the patient in; the
      // photo can be added from the profile.
      return session;
    }
  }

  /// Adds this install's push token to the signed-in profile, making room
  /// at the rules' limit by dropping the oldest. Best-effort: a device with
  /// no token yet still signs in.
  Future<void> registerDeviceToken(AuthSession session) async {
    final target = _tokenTarget(session);
    if (target == null) return;
    final token = await _notifications.deviceToken();
    if (token == null || target.tokens.contains(token)) return;
    if (target.tokens.length >= maxDeviceTokens) {
      await _remote.removeFcmToken(
        collection: target.collection,
        docId: target.docId,
        token: target.tokens.first,
      );
    }
    await _remote.addFcmToken(
      collection: target.collection,
      docId: target.docId,
      token: token,
    );
  }

  /// On the device first, so the app switches at once and the choice
  /// survives sign-out; then on the profile, best-effort, for push text.
  Future<void> changeLanguage(
    AppLanguage language, {
    required AuthSession session,
  }) async {
    await _cache.updateLanguage(languageString: language.value);
    final target = _tokenTarget(session);
    if (target == null) return;
    try {
      await _remote
          .updateLanguage(
            collection: target.collection,
            docId: target.docId,
            language: language,
          )
          .timeout(bestEffortTimeout);
    } on Object catch (_) {
      // Offline: the profile catches up on the next change.
    }
  }

  /// Removes this install's token first, while the credentials can still
  /// write it, then signs out of Firebase before the cache is wiped, so
  /// nothing is fetched into it afterwards.
  Future<void> signOut({AuthSession? session}) async {
    if (session != null) await _forgetDeviceToken(session);
    await _remote.signOut();
    await _cache.clearOnSignOut();
  }

  /// A signed-out phone must not keep receiving this person's pushes; a
  /// failure here never blocks the sign-out.
  Future<void> _forgetDeviceToken(AuthSession session) async {
    try {
      final target = _tokenTarget(session);
      if (target == null) return;
      final token = await _notifications.deviceToken();
      if (token == null) return;
      await _remote
          .removeFcmToken(
            collection: target.collection,
            docId: target.docId,
            token: token,
          )
          .timeout(bestEffortTimeout);
    } on Object catch (_) {
      // Offline, or the profile is gone. The stale token rotates out once
      // the list reaches its limit.
    }
  }

  static ({String collection, String docId, List<String> tokens})? _tokenTarget(
    AuthSession session,
  ) => switch (session) {
    PatientSession(:final patient) => (
      collection: 'patients',
      docId: patient.patientId,
      tokens: patient.fcmTokens,
    ),
    PractitionerSession(:final doctor) ||
    PendingVerificationSession(
      :final doctor,
    ) => (collection: 'doctors', docId: doctor.uid, tokens: doctor.fcmTokens),
    _ => null,
  };

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
    return SignUpIncompleteSession(
      email: user.email ?? '',
      emailVerified: user.emailVerified,
    );
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
      // Nothing cached is "could not read", never "there is none".
      return await _cache.getCachedOwnPatientRecord(uid) ?? (throw e);
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
      // Nothing cached is "could not read", never "there is none".
      return await _cache.getCachedDoctorProfile(uid) ?? (throw e);
    }
  }
}
