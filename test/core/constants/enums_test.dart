import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/l10n/l10n.dart';

// The real constructor is protected; a subclass can call it.
class _TestFunctionsException extends FirebaseFunctionsException {
  _TestFunctionsException({required super.code, required super.message});
}

void main() {
  group('Role', () {
    test('fromClaim resolves the three claims', () {
      expect(Role.fromClaim('patient'), Role.patient);
      expect(Role.fromClaim('doctor'), Role.doctor);
      expect(Role.fromClaim('pathologist'), Role.pathologist);
    });

    test('fromClaim returns null for unknown values', () {
      expect(Role.fromClaim('admin'), isNull);
      expect(Role.fromClaim(''), isNull);
      expect(Role.fromClaim('Patient'), isNull);
    });
  });

  group('Sex', () {
    test('value round-trips', () {
      expect(Sex.fromValue(Sex.male.value), Sex.male);
      expect(Sex.fromValue(Sex.female.value), Sex.female);
      expect(Sex.male.value, 'Male');
      expect(Sex.female.value, 'Female');
    });

    test('fromValue is null for unknown values, never a guess', () {
      expect(Sex.fromValue('Other'), isNull);
      expect(Sex.fromValue(''), isNull);
    });
  });

  group('VerificationStatus', () {
    test('value round-trips', () {
      for (final status in VerificationStatus.values) {
        expect(VerificationStatus.fromValue(status.value), status);
      }
      expect(VerificationStatus.pending.value, 'Pending');
      expect(VerificationStatus.verified.value, 'Verified');
      expect(VerificationStatus.rejected.value, 'Rejected');
    });

    test('fromValue reads an unknown value as pending', () {
      expect(
        VerificationStatus.fromValue('Unknown'),
        VerificationStatus.pending,
      );
      expect(VerificationStatus.fromValue(''), VerificationStatus.pending);
    });
  });

  group('AppLanguage', () {
    test('value round-trips', () {
      expect(AppLanguage.fromValue('en'), AppLanguage.en);
      expect(AppLanguage.fromValue('sw'), AppLanguage.sw);
      expect(AppLanguage.en.value, 'en');
      expect(AppLanguage.sw.value, 'sw');
    });

    test('fromValue reads an unknown value as en', () {
      expect(AppLanguage.fromValue('fr'), AppLanguage.en);
      expect(AppLanguage.fromValue(''), AppLanguage.en);
    });
  });

  group('PractitionerTitle', () {
    test('values are the stored display strings', () {
      expect(PractitionerTitle.dr.value, 'Dr.');
      expect(PractitionerTitle.prof.value, 'Prof.');
      expect(PractitionerTitle.mr.value, 'Mr.');
      expect(PractitionerTitle.mrs.value, 'Mrs.');
      expect(PractitionerTitle.ms.value, 'Ms.');
    });
  });

  group('AppError.fromFirebaseCode', () {
    test('maps every known code', () {
      const codes = {
        'invalid-email': AppError.invalidEmail,
        'user-disabled': AppError.userDisabled,
        'user-not-found': AppError.userNotFound,
        'wrong-password': AppError.wrongPassword,
        'email-already-in-use': AppError.emailAlreadyInUse,
        'weak-password': AppError.weakPassword,
        'operation-not-allowed': AppError.operationNotAllowed,
        'too-many-requests': AppError.tooManyRequests,
        'resource-exhausted': AppError.tooManyRequests,
        'network-request-failed': AppError.noInternet,
        'invalid-credential': AppError.invalidCredential,
        'account-exists-with-different-credential':
            AppError.accountExistsWithDifferentCredential,
        'requires-recent-login': AppError.requiresRecentLogin,
        'credential-already-in-use': AppError.credentialAlreadyInUse,
        'expired-action-code': AppError.expiredActionCode,
        'invalid-action-code': AppError.invalidActionCode,
        'user-token-expired': AppError.userTokenExpired,
        'permission-denied': AppError.permissionDenied,
        'not-found': AppError.dataNotFound,
        'unavailable': AppError.serviceUnavailable,
        'deadline-exceeded': AppError.requestTimeout,
      };
      for (final entry in codes.entries) {
        expect(
          AppError.fromFirebaseCode(entry.key),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('falls back to unknown', () {
      expect(AppError.fromFirebaseCode('internal'), AppError.unknown);
      expect(AppError.fromFirebaseCode(''), AppError.unknown);
    });
  });

  group('AppError.fromFunctionsException', () {
    test('maps every refusal key', () {
      const keys = {
        'unauthenticated': AppError.unauthenticated,
        'emailRequired': AppError.emailRequired,
        'invalidName': AppError.invalidName,
        'invalidSex': AppError.invalidSex,
        'invalidDateOfBirth': AppError.invalidDateOfBirth,
        'invalidPhone': AppError.invalidPhone,
        'invalidEmail': AppError.invalidEmail,
        'invalidCounty': AppError.invalidCounty,
        'invalidSubCounty': AppError.invalidSubCounty,
        'invalidLanguage': AppError.invalidLanguage,
        'roleAlreadySet': AppError.roleAlreadySet,
        'patientAlreadyRegistered': AppError.patientAlreadyRegistered,
        'patientExists': AppError.patientExists,
        'doctorsOnly': AppError.doctorsOnly,
        'invalidPatient': AppError.invalidPatient,
        'accountNotFound': AppError.accountNotFound,
        'accountAlreadyHasRole': AppError.accountAlreadyHasRole,
        'alreadyLinked': AppError.alreadyLinked,
        'invalidRole': AppError.invalidRole,
        'termsRequired': AppError.termsRequired,
        'invalidKmpdcNumber': AppError.invalidKmpdcNumber,
        'invalidFacility': AppError.invalidFacility,
        'facilityNotOperational': AppError.facilityNotOperational,
        'invalidTitle': AppError.invalidTitle,
        'invalidPicture': AppError.invalidPicture,
        'invalidSpecialties': AppError.invalidSpecialties,
        'invalidAvailability': AppError.invalidAvailability,
        'invalidBio': AppError.invalidBio,
        'invalidLicense': AppError.invalidLicense,
        'kmpdcNumberInUse': AppError.kmpdcNumberInUse,
        'adminOnly': AppError.adminOnly,
        'invalidPractitioner': AppError.invalidPractitioner,
        'invalidDecision': AppError.invalidDecision,
      };
      for (final entry in keys.entries) {
        final exception = _TestFunctionsException(
          code: 'invalid-argument',
          message: entry.key,
        );
        expect(
          AppError.fromFunctionsException(exception),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('falls back to the Firebase code for unknown messages', () {
      final knownCode = _TestFunctionsException(
        code: 'user-not-found',
        message: 'somethingNew',
      );
      expect(AppError.fromFunctionsException(knownCode), AppError.userNotFound);

      final unknownCode = _TestFunctionsException(
        code: 'internal',
        message: 'somethingNew',
      );
      expect(AppError.fromFunctionsException(unknownCode), AppError.unknown);
    });
  });

  group('descriptions', () {
    late AppLocalizations en;
    late AppLocalizations sw;

    setUpAll(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      sw = await AppLocalizations.delegate.load(const Locale('sw'));
    });

    test('every AppError has a description in en and sw', () {
      for (final error in AppError.values) {
        expect(error.description(en), isNotEmpty, reason: '$error en');
        expect(error.description(sw), isNotEmpty, reason: '$error sw');
      }
    });

    test('spot-checks', () {
      expect(
        AppError.kmpdcNumberInUse.description(en),
        'This KMPDC number is already registered. '
        'Check it, or contact support.',
      );
      expect(
        AppError.unknown.description(en),
        'Something went wrong. Please try again.',
      );
      expect(
        AppError.unknown.description(sw),
        'Hitilafu imetokea. Tafadhali jaribu tena.',
      );
    });

    test('enum descriptions', () {
      expect(Sex.male.description(en), 'Male');
      expect(Sex.female.description(en), 'Female');
      expect(Sex.male.description(sw), 'Mwanaume');
      expect(Sex.female.description(sw), 'Mwanamke');
      expect(VerificationStatus.pending.description(en), 'Pending');
      expect(VerificationStatus.verified.description(en), 'Verified');
      expect(VerificationStatus.rejected.description(en), 'Rejected');
      expect(VerificationStatus.pending.description(sw), 'Inasubiri');
      expect(VerificationStatus.verified.description(sw), 'Imethibitishwa');
      expect(VerificationStatus.rejected.description(sw), 'Imekataliwa');
      expect(AppLanguage.en.description(en), 'English');
      expect(AppLanguage.sw.description(en), 'Kiswahili');
      expect(AppLanguage.en.description(sw), 'Kiingereza');
      expect(AppLanguage.sw.description(sw), 'Kiswahili');
    });
  });
}
