import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/google_sign_in_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

/// What `completePatientSignUp` answered (CRQ-0016).
enum PatientSignUpOutcome { registered, clinicRecordExists }

/// Firebase Auth, the identity callables and the profile reads. No caching:
/// that is `AuthHelper`'s.
@lazySingleton
class AuthFirebase {
  AuthFirebase({
    required this._auth,
    required this._firestore,
    required this._functions,
  });

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final Logger _logger = Logger();

  static const _cancelledPopupCodes = {
    'popup-closed-by-user',
    'cancelled-popup-request',
    'user-cancelled',
  };

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Every failure leaves here as an [AppError], already translatable.
  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseFunctionsException() => AppError.fromFunctionsException(e),
    FirebaseException(:final code) => AppError.fromFirebaseCode(code),
    _ => AppError.unknown,
  };

  Future<T> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return await body();
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('$operation failed: $e');
      throw _toAppError(e);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(
    'Email sign-in',
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  /// Creates the Auth account only; the profile comes from a sign-up
  /// callable. The verification email is best-effort and never blocks.
  Future<void> createAccount({
    required String email,
    required String password,
  }) => _guard('Account creation', () async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      await credential.user?.sendEmailVerification();
    } on Exception catch (e) {
      if (kDebugMode) _logger.w('Verification email not sent: $e');
    }
  });

  /// False when the person dismissed the Google dialog: not an error, so
  /// nothing is shown. A new Google account arrives with no role and goes
  /// on to finish sign-up.
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return true;
      }
      final account = await GoogleSignInHelper.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw AppError.unknown;
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      if (kDebugMode) _logger.e('Google sign-in [${e.code}]');
      await _signOutOfGoogle();
      throw AppError.unknown;
    } on FirebaseAuthException catch (e) {
      if (_cancelledPopupCodes.contains(e.code)) return false;
      await _signOutOfGoogle();
      throw _toAppError(e);
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('Google sign-in failed: $e');
      await _signOutOfGoogle();
      throw _toAppError(e);
    }
  }

  Future<void> _signOutOfGoogle() async {
    if (kIsWeb) return;
    try {
      await GoogleSignInHelper.instance.signOut();
    } on Exception catch (_) {
      // Already signed out of Google, or never signed in.
    }
  }

  /// Reloads the user, then refreshes the ID token, so its `email_verified`
  /// claim (which the sign-up callables check) matches the account.
  Future<bool> reloadEmailVerified() =>
      _guard('Checking verification', () async {
        final user = _auth.currentUser;
        if (user == null) throw AppError.unauthenticated;
        await user.reload();
        final current = _auth.currentUser;
        final verified = current?.emailVerified ?? false;
        if (verified) await current?.getIdToken(true);
        return verified;
      });

  Future<void> sendEmailVerification() =>
      _guard('Sending verification', () async {
        final user = _auth.currentUser;
        if (user == null) throw AppError.unauthenticated;
        await user.sendEmailVerification();
      });

  Future<void> sendPasswordReset({required String email}) => _guard(
    'Password reset',
    () => _auth.sendPasswordResetEmail(email: email.trim()),
  );

  Future<void> signOut() async {
    await _signOutOfGoogle();
    await _guard('Sign-out', _auth.signOut);
  }

  /// The claims on the ID token. [forceRefresh] fetches a new token, which a
  /// sign-up or verification needs before its claim is visible.
  Future<RoleHelper> roles({bool forceRefresh = false}) =>
      _guard('Reading claims', () async {
        final user = _auth.currentUser;
        if (user == null) return RoleHelper.none;
        final token = await user.getIdTokenResult(forceRefresh);
        return RoleHelper.fromClaims(token.claims);
      });

  Future<PatientSignUpOutcome> completePatientSignUp(
    PatientSignUpRequest request,
  ) => _guard('Patient sign-up', () async {
    final result = await _functions
        .httpsCallable('completePatientSignUp')
        .call<Map<String, dynamic>>(request.toCallableData());
    return result.data['status'] == 'clinicRecordExists'
        ? PatientSignUpOutcome.clinicRecordExists
        : PatientSignUpOutcome.registered;
  });

  Future<VerificationStatus> completePractitionerSignUp(
    PractitionerSignUpRequest request,
  ) => _guard('Practitioner sign-up', () async {
    final result = await _functions
        .httpsCallable('completePractitionerSignUp')
        .call<Map<String, dynamic>>(request.toCallableData());
    return VerificationStatus.fromValue('${result.data['status']}');
  });

  /// Filtered on `uid`, which is what the rule checks (a linked record's id
  /// is not its uid).
  Future<PatientModel?> fetchOwnPatientRecord(String uid) =>
      _guard('Reading patient record', () async {
        final snapshot = await _firestore
            .collection('patients')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) return null;
        return PatientModel.fromJson(snapshot.docs.first.data());
      });

  /// [collection] is `patients` or `doctors`; [docId] is the patientId or
  /// the uid. Array operations, so another device's token written since the
  /// session was read is never overwritten.
  Future<void> addFcmToken({
    required String collection,
    required String docId,
    required String token,
  }) => _updateTokens(collection, docId, FieldValue.arrayUnion([token]));

  Future<void> removeFcmToken({
    required String collection,
    required String docId,
    required String token,
  }) => _updateTokens(collection, docId, FieldValue.arrayRemove([token]));

  Future<void> updateProfilePicture({
    required String collection,
    required String docId,
    required String url,
  }) => _guard(
    'Updating profile picture',
    () => _firestore.collection(collection).doc(docId).update({
      'profilePictureUrl': url,
      'lastUpdatedAt': syncTimestamp(),
    }),
  );

  /// The profile's language decides the language of its push notifications.
  Future<void> updateLanguage({
    required String collection,
    required String docId,
    required AppLanguage language,
  }) => _guard(
    'Updating language',
    () => _firestore.collection(collection).doc(docId).update({
      'language': language.value,
      'lastUpdatedAt': syncTimestamp(),
    }),
  );

  Future<void> _updateTokens(String collection, String docId, FieldValue op) =>
      _guard(
        'Updating device tokens',
        () => _firestore.collection(collection).doc(docId).update({
          'fcmTokens': op,
          'lastUpdatedAt': syncTimestamp(),
        }),
      );

  Future<DoctorModel?> fetchDoctorProfile(String uid) =>
      _guard('Reading practitioner profile', () async {
        final snapshot = await _firestore.collection('doctors').doc(uid).get();
        final data = snapshot.data();
        return data == null ? null : DoctorModel.fromJson(data);
      });
}
