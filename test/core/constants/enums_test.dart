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
  group('CaseLocation', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in CaseLocation.values) {
        expect(CaseLocation.fromValue(v.value), v);
      }
      expect(CaseLocation.values.map((e) => e.value), [
        'Doctor',
        'Pathologist',
        'Lab',
        'Patient',
      ]);
    });

    test('fromValue reads an unknown value as doctor', () {
      expect(CaseLocation.fromValue('Bogus'), CaseLocation.doctor);
      expect(CaseLocation.fromValue(''), CaseLocation.doctor);
    });
  });

  group('CaseStage', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in CaseStage.values) {
        expect(CaseStage.fromValue(v.value), v);
      }
      expect(CaseStage.values.map((e) => e.value), [
        'OrderCreated',
        'PathologistRequested',
        'PathologistRejected',
        'PathologistAccepted',
        'SampleReceived',
        'SlidesUploaded',
        'PrereadQueued',
        'PrereadReady',
        'PrereadFailed',
        'ReportInProgress',
        'ReportSigned',
        'DiscussionRequested',
        'DiscussionBooked',
        'ResultReleased',
        'Completed',
        'Cancelled',
      ]);
    });

    test('fromValue reads an unknown value as orderCreated', () {
      expect(CaseStage.fromValue('Bogus'), CaseStage.orderCreated);
      expect(CaseStage.fromValue(''), CaseStage.orderCreated);
    });
  });

  group('CaseStep', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in CaseStep.values) {
        expect(CaseStep.fromValue(v.value), v);
      }
      expect(CaseStep.values.map((e) => e.value), [
        '',
        'RequestPathologist',
        'AwaitPathologist',
        'ReceiveSample',
        'UploadSlides',
        'ReviewPreread',
        'WriteReport',
        'ReadReport',
        'BookDiscussion',
        'ReplyToDiscussion',
        'MarkDiscussed',
        'Complete',
      ]);
    });

    test('fromValue reads an unknown value as none', () {
      expect(CaseStep.fromValue('Bogus'), CaseStep.none);
    });
  });

  group('ActorRole', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ActorRole.values) {
        expect(ActorRole.fromValue(v.value), v);
      }
      expect(ActorRole.values.map((e) => e.value), [
        'Doctor',
        'Pathologist',
        'Patient',
        'System',
      ]);
    });

    test('fromValue reads an unknown value as system', () {
      expect(ActorRole.fromValue('Bogus'), ActorRole.system);
      expect(ActorRole.fromValue(''), ActorRole.system);
    });
  });

  group('CaseAction', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in CaseAction.values) {
        expect(CaseAction.fromValue(v.value), v);
      }
      expect(CaseAction.values.map((e) => e.value), [
        '',
        'Reject',
        'Expire',
        'Reassign',
        'Cancel',
        'Share',
        'RemoveViewer',
        'Revise',
        'Receive',
        'AddSlides',
      ]);
    });

    test('fromValue reads an unknown value as none', () {
      expect(CaseAction.fromValue('Bogus'), CaseAction.none);
    });
  });

  group('ResultState', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ResultState.values) {
        expect(ResultState.fromValue(v.value), v);
      }
      expect(ResultState.values.map((e) => e.value), [
        'Pending',
        'WithDoctor',
        'Released',
        'UpdateWithDoctor',
      ]);
    });

    test('fromValue reads an unknown value as pending', () {
      expect(ResultState.fromValue('Bogus'), ResultState.pending);
      expect(ResultState.fromValue(''), ResultState.pending);
    });
  });

  group('PaymentMethod', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in PaymentMethod.values) {
        expect(PaymentMethod.fromValue(v.value), v);
      }
      expect(PaymentMethod.values.map((e) => e.value), ['Cash', 'Insurance']);
    });

    test('fromValue reads an unknown value as cash', () {
      expect(PaymentMethod.fromValue('Bogus'), PaymentMethod.cash);
      expect(PaymentMethod.fromValue(''), PaymentMethod.cash);
    });
  });

  group('SharePurpose', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in SharePurpose.values) {
        expect(SharePurpose.fromValue(v.value), v);
      }
      expect(SharePurpose.values.map((e) => e.value), ['Join', 'ReportUnlock']);
    });

    test('fromValue reads an unknown value as join', () {
      expect(SharePurpose.fromValue('Bogus'), SharePurpose.join);
      expect(SharePurpose.fromValue(''), SharePurpose.join);
    });
  });

  group('ShareStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ShareStatus.values) {
        expect(ShareStatus.fromValue(v.value), v);
      }
      expect(ShareStatus.values.map((e) => e.value), [
        'Pending',
        'Redeemed',
        'Expired',
        'Locked',
        'Revoked',
      ]);
    });

    test('fromValue reads an unknown value as revoked', () {
      expect(ShareStatus.fromValue('Bogus'), ShareStatus.revoked);
      expect(ShareStatus.fromValue(''), ShareStatus.revoked);
    });
  });

  group('JobStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in JobStatus.values) {
        expect(JobStatus.fromValue(v.value), v);
      }
      expect(JobStatus.values.map((e) => e.value), [
        'Queued',
        'Running',
        'Ready',
        'Failed',
      ]);
    });

    test('fromValue reads an unknown value as queued', () {
      expect(JobStatus.fromValue('Bogus'), JobStatus.queued);
      expect(JobStatus.fromValue(''), JobStatus.queued);
    });
  });

  group('Urgency', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in Urgency.values) {
        expect(Urgency.fromValue(v.value), v);
      }
      expect(Urgency.values.map((e) => e.value), [
        'Routine',
        'Priority',
        'Urgent',
      ]);
    });

    test('fromValue reads an unknown value as routine', () {
      expect(Urgency.fromValue('Bogus'), Urgency.routine);
      expect(Urgency.fromValue(''), Urgency.routine);
    });
  });

  group('ConfidenceBand', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ConfidenceBand.values) {
        expect(ConfidenceBand.fromValue(v.value), v);
      }
      expect(ConfidenceBand.values.map((e) => e.value), [
        'High',
        'Moderate',
        'Low',
      ]);
    });

    test('fromValue reads an unknown value as low', () {
      expect(ConfidenceBand.fromValue('Bogus'), ConfidenceBand.low);
      expect(ConfidenceBand.fromValue(''), ConfidenceBand.low);
    });
  });

  group('PrereadProfile', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in PrereadProfile.values) {
        expect(PrereadProfile.fromValue(v.value), v);
      }
      expect(PrereadProfile.values.map((e) => e.value), [
        'Cancer',
        'Malaria',
        'None',
      ]);
    });

    test('fromValue reads an unknown value as noProfile', () {
      expect(PrereadProfile.fromValue('Bogus'), PrereadProfile.noProfile);
      expect(PrereadProfile.fromValue(''), PrereadProfile.noProfile);
    });
  });

  group('ReportStage', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportStage.values) {
        expect(ReportStage.fromValue(v.value), v);
      }
      expect(ReportStage.values.map((e) => e.value), [
        'Initial',
        'Addended',
        'Amended',
      ]);
    });

    test('fromValue reads an unknown value as initial', () {
      expect(ReportStage.fromValue('Bogus'), ReportStage.initial);
      expect(ReportStage.fromValue(''), ReportStage.initial);
    });
  });

  group('ReportStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportStatus.values) {
        expect(ReportStatus.fromValue(v.value), v);
      }
      expect(ReportStatus.values.map((e) => e.value), ['Signed', 'Superseded']);
    });

    test('fromValue reads an unknown value as superseded', () {
      expect(ReportStatus.fromValue('Bogus'), ReportStatus.superseded);
      expect(ReportStatus.fromValue(''), ReportStatus.superseded);
    });
  });

  group('DiagnosisType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in DiagnosisType.values) {
        expect(DiagnosisType.fromValue(v.value), v);
      }
      expect(DiagnosisType.values.map((e) => e.value), [
        'Final',
        'Provisional',
        'Inconclusive',
      ]);
    });

    test('fromValue reads an unknown value as provisional', () {
      expect(DiagnosisType.fromValue('Bogus'), DiagnosisType.provisional);
      expect(DiagnosisType.fromValue(''), DiagnosisType.provisional);
    });
  });

  group('ReportTemplate', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportTemplate.values) {
        expect(ReportTemplate.fromValue(v.value), v);
      }
      expect(ReportTemplate.values.map((e) => e.value), [
        'Cancer',
        'Malaria',
        'General',
      ]);
    });

    test('fromValue reads an unknown value as general', () {
      expect(ReportTemplate.fromValue('Bogus'), ReportTemplate.general);
      expect(ReportTemplate.fromValue(''), ReportTemplate.general);
    });
  });

  group('ReportLanguage', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportLanguage.values) {
        expect(ReportLanguage.fromValue(v.value), v);
      }
      expect(ReportLanguage.values.map((e) => e.value), ['en', 'sw']);
    });

    test('fromValue reads an unknown value as en', () {
      expect(ReportLanguage.fromValue('Bogus'), ReportLanguage.en);
      expect(ReportLanguage.fromValue(''), ReportLanguage.en);
    });
  });

  group('DraftKind', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in DraftKind.values) {
        expect(DraftKind.fromValue(v.value), v);
      }
      expect(DraftKind.values.map((e) => e.value), [
        'Initial',
        'Addendum',
        'Amendment',
      ]);
    });

    test('fromValue reads an unknown value as initial', () {
      expect(DraftKind.fromValue('Bogus'), DraftKind.initial);
      expect(DraftKind.fromValue(''), DraftKind.initial);
    });
  });

  group('DraftStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in DraftStatus.values) {
        expect(DraftStatus.fromValue(v.value), v);
      }
      expect(DraftStatus.values.map((e) => e.value), [
        'Editing',
        'Signed',
        'Closed',
      ]);
    });

    test('fromValue reads an unknown value as closed', () {
      expect(DraftStatus.fromValue('Bogus'), DraftStatus.closed);
      expect(DraftStatus.fromValue(''), DraftStatus.closed);
    });
  });

  group('ScoreVerdict', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ScoreVerdict.values) {
        expect(ScoreVerdict.fromValue(v.value), v);
      }
      expect(ScoreVerdict.values.map((e) => e.value), [
        'Agree',
        'PartlyAgree',
        'Disagree',
      ]);
    });

    test('fromValue reads an unknown value as disagree', () {
      expect(ScoreVerdict.fromValue('Bogus'), ScoreVerdict.disagree);
      expect(ScoreVerdict.fromValue(''), ScoreVerdict.disagree);
    });
  });

  group('MeasurementsVerdict', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in MeasurementsVerdict.values) {
        expect(MeasurementsVerdict.fromValue(v.value), v);
      }
      expect(MeasurementsVerdict.values.map((e) => e.value), [
        'Accepted',
        'Corrected',
        'NotApplicable',
      ]);
    });

    test('fromValue reads an unknown value as notApplicable', () {
      expect(
        MeasurementsVerdict.fromValue('Bogus'),
        MeasurementsVerdict.notApplicable,
      );
      expect(
        MeasurementsVerdict.fromValue(''),
        MeasurementsVerdict.notApplicable,
      );
    });
  });

  group('SegmentationVerdict', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in SegmentationVerdict.values) {
        expect(SegmentationVerdict.fromValue(v.value), v);
      }
      expect(SegmentationVerdict.values.map((e) => e.value), [
        'Good',
        'Acceptable',
        'Poor',
        'NotApplicable',
      ]);
    });

    test('fromValue reads an unknown value as notApplicable', () {
      expect(
        SegmentationVerdict.fromValue('Bogus'),
        SegmentationVerdict.notApplicable,
      );
      expect(
        SegmentationVerdict.fromValue(''),
        SegmentationVerdict.notApplicable,
      );
    });
  });

  group('WorklistStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in WorklistStatus.values) {
        expect(WorklistStatus.fromValue(v.value), v);
      }
      expect(WorklistStatus.values.map((e) => e.value), [
        'Open',
        'InProgress',
        'Signed',
        'Closed',
      ]);
    });

    test('fromValue reads an unknown value as closed', () {
      expect(WorklistStatus.fromValue('Bogus'), WorklistStatus.closed);
      expect(WorklistStatus.fromValue(''), WorklistStatus.closed);
    });
  });

  group('DiffBase', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in DiffBase.values) {
        expect(DiffBase.fromValue(v.value), v);
      }
      expect(DiffBase.values.map((e) => e.value), [
        'AiDraft',
        'PreviousVersion',
        'None',
      ]);
    });

    test('fromValue reads an unknown value as noBase', () {
      expect(DiffBase.fromValue('Bogus'), DiffBase.noBase);
      expect(DiffBase.fromValue(''), DiffBase.noBase);
    });
  });

  group('FieldChange', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in FieldChange.values) {
        expect(FieldChange.fromValue(v.value), v);
      }
      expect(FieldChange.values.map((e) => e.value), [
        'Unchanged',
        'Edited',
        'Added',
        'Removed',
      ]);
    });

    test('fromValue reads an unknown value as edited', () {
      expect(FieldChange.fromValue('Bogus'), FieldChange.edited);
      expect(FieldChange.fromValue(''), FieldChange.edited);
    });
  });

  group('ReportTextKind', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportTextKind.values) {
        expect(ReportTextKind.fromValue(v.value), v);
      }
      expect(ReportTextKind.values.map((e) => e.value), [
        'Translation',
        'Explanation',
      ]);
    });

    test('fromValue reads an unknown value as translation', () {
      expect(ReportTextKind.fromValue('Bogus'), ReportTextKind.translation);
      expect(ReportTextKind.fromValue(''), ReportTextKind.translation);
    });
  });

  group('ReportTextStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ReportTextStatus.values) {
        expect(ReportTextStatus.fromValue(v.value), v);
      }
      expect(ReportTextStatus.values.map((e) => e.value), [
        'Queued',
        'Running',
        'Ready',
        'Failed',
        'Approved',
        'Rejected',
      ]);
    });

    test('fromValue reads an unknown value as queued', () {
      expect(ReportTextStatus.fromValue('Bogus'), ReportTextStatus.queued);
      expect(ReportTextStatus.fromValue(''), ReportTextStatus.queued);
    });
  });

  group('ApprovalDecision', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ApprovalDecision.values) {
        expect(ApprovalDecision.fromValue(v.value), v);
      }
      expect(ApprovalDecision.values.map((e) => e.value), [
        'Approve',
        'ApproveEdited',
        'Reject',
      ]);
    });

    test('fromValue reads an unknown value as reject', () {
      expect(ApprovalDecision.fromValue('Bogus'), ApprovalDecision.reject);
      expect(ApprovalDecision.fromValue(''), ApprovalDecision.reject);
    });
  });

  group('FailureReason', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in FailureReason.values) {
        expect(FailureReason.fromValue(v.value), v);
      }
      expect(FailureReason.values.map((e) => e.value), [
        '',
        'Timeout',
        'ServiceError',
        'OffSchema',
        'NumberCheck',
        'Stale',
        'Banned',
        'Disabled',
      ]);
    });

    test('fromValue reads an unknown value as serviceError', () {
      expect(FailureReason.fromValue('Bogus'), FailureReason.serviceError);
    });
  });

  group('InputMode', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in InputMode.values) {
        expect(InputMode.fromValue(v.value), v);
      }
      expect(InputMode.values.map((e) => e.value), ['Typed', 'Voice']);
    });

    test('fromValue reads an unknown value as typed', () {
      expect(InputMode.fromValue('Bogus'), InputMode.typed);
      expect(InputMode.fromValue(''), InputMode.typed);
    });
  });

  group('MessageKind', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in MessageKind.values) {
        expect(MessageKind.fromValue(v.value), v);
      }
      expect(MessageKind.values.map((e) => e.value), [
        'Text',
        'Image',
        'Voice',
      ]);
    });

    test('fromValue reads an unknown value as text', () {
      expect(MessageKind.fromValue('Bogus'), MessageKind.text);
      expect(MessageKind.fromValue(''), MessageKind.text);
    });
  });

  group('TranscriptStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in TranscriptStatus.values) {
        expect(TranscriptStatus.fromValue(v.value), v);
      }
      expect(TranscriptStatus.values.map((e) => e.value), [
        'None',
        'Queued',
        'Running',
        'Ready',
        'Failed',
      ]);
    });

    test('fromValue reads an unknown value as noTranscript', () {
      expect(
        TranscriptStatus.fromValue('Bogus'),
        TranscriptStatus.noTranscript,
      );
      expect(TranscriptStatus.fromValue(''), TranscriptStatus.noTranscript);
    });
  });

  group('AppointmentType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in AppointmentType.values) {
        expect(AppointmentType.fromValue(v.value), v);
      }
      expect(AppointmentType.values.map((e) => e.value), [
        'Consultation',
        'CaseDiscussion',
      ]);
    });

    test('fromValue reads an unknown value as consultation', () {
      expect(AppointmentType.fromValue('Bogus'), AppointmentType.consultation);
      expect(AppointmentType.fromValue(''), AppointmentType.consultation);
    });
  });

  group('AppointmentStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in AppointmentStatus.values) {
        expect(AppointmentStatus.fromValue(v.value), v);
      }
      expect(AppointmentStatus.values.map((e) => e.value), [
        'Requested',
        'Accepted',
        'Declined',
        'Expired',
        'Cancelled',
        'Completed',
        'NoShow',
      ]);
    });

    test('fromValue reads an unknown value as expired', () {
      expect(AppointmentStatus.fromValue('Bogus'), AppointmentStatus.expired);
      expect(AppointmentStatus.fromValue(''), AppointmentStatus.expired);
    });
  });

  group('IntakeStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in IntakeStatus.values) {
        expect(IntakeStatus.fromValue(v.value), v);
      }
      expect(IntakeStatus.values.map((e) => e.value), [
        'None',
        'Queued',
        'Ready',
        'Failed',
      ]);
    });

    test('fromValue reads an unknown value as noIntake', () {
      expect(IntakeStatus.fromValue('Bogus'), IntakeStatus.noIntake);
      expect(IntakeStatus.fromValue(''), IntakeStatus.noIntake);
    });
  });

  group('ConversationType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ConversationType.values) {
        expect(ConversationType.fromValue(v.value), v);
      }
      expect(ConversationType.values.map((e) => e.value), [
        'GroupConsult',
        'Direct',
      ]);
    });

    test('fromValue reads an unknown value as direct', () {
      expect(ConversationType.fromValue('Bogus'), ConversationType.direct);
      expect(ConversationType.fromValue(''), ConversationType.direct);
    });
  });

  group('ConversationStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in ConversationStatus.values) {
        expect(ConversationStatus.fromValue(v.value), v);
      }
      expect(ConversationStatus.values.map((e) => e.value), ['Open', 'Closed']);
    });

    test('fromValue reads an unknown value as closed', () {
      expect(ConversationStatus.fromValue('Bogus'), ConversationStatus.closed);
      expect(ConversationStatus.fromValue(''), ConversationStatus.closed);
    });
  });

  group('LinkedResourceType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in LinkedResourceType.values) {
        expect(LinkedResourceType.fromValue(v.value), v);
      }
      expect(LinkedResourceType.values.map((e) => e.value), [
        'Appointment',
        'Case',
      ]);
    });

    test('fromValue reads an unknown value as patientCase', () {
      expect(
        LinkedResourceType.fromValue('Bogus'),
        LinkedResourceType.patientCase,
      );
      expect(LinkedResourceType.fromValue(''), LinkedResourceType.patientCase);
    });
  });

  group('MemberRole', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in MemberRole.values) {
        expect(MemberRole.fromValue(v.value), v);
      }
      expect(MemberRole.values.map((e) => e.value), ['Owner', 'Member']);
    });

    test('fromValue reads an unknown value as member', () {
      expect(MemberRole.fromValue('Bogus'), MemberRole.member);
      expect(MemberRole.fromValue(''), MemberRole.member);
    });
  });

  group('MemberStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in MemberStatus.values) {
        expect(MemberStatus.fromValue(v.value), v);
      }
      expect(MemberStatus.values.map((e) => e.value), [
        'Invited',
        'Accepted',
        'Declined',
        'Expired',
        'Left',
        'Removed',
      ]);
    });

    test('fromValue reads an unknown value as removed', () {
      expect(MemberStatus.fromValue('Bogus'), MemberStatus.removed);
      expect(MemberStatus.fromValue(''), MemberStatus.removed);
    });
  });

  group('MessageStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in MessageStatus.values) {
        expect(MessageStatus.fromValue(v.value), v);
      }
      expect(MessageStatus.values.map((e) => e.value), [
        'Pending',
        'Failed',
        'Sent',
        'Delivered',
        'Withheld',
      ]);
    });

    test('fromValue reads an unknown value as withheld', () {
      expect(MessageStatus.fromValue('Bogus'), MessageStatus.withheld);
      expect(MessageStatus.fromValue(''), MessageStatus.withheld);
    });
  });

  group('SummaryReportStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in SummaryReportStatus.values) {
        expect(SummaryReportStatus.fromValue(v.value), v);
      }
      expect(SummaryReportStatus.values.map((e) => e.value), [
        'Pending',
        'Signed',
        'Amended',
      ]);
    });

    test('fromValue reads an unknown value as pending', () {
      expect(
        SummaryReportStatus.fromValue('Bogus'),
        SummaryReportStatus.pending,
      );
      expect(SummaryReportStatus.fromValue(''), SummaryReportStatus.pending);
    });
  });

  group('NotificationCategory', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationCategory.values) {
        expect(NotificationCategory.fromValue(v.value), v);
      }
      expect(NotificationCategory.values.map((e) => e.value), [
        'Case',
        'Preread',
        'Report',
        'Result',
        'Alert',
        'Account',
        'Appointment',
        'Mdt',
        'Message',
      ]);
    });

    test('fromValue reads an unknown value as patientCase', () {
      expect(
        NotificationCategory.fromValue('Bogus'),
        NotificationCategory.patientCase,
      );
      expect(
        NotificationCategory.fromValue(''),
        NotificationCategory.patientCase,
      );
    });
  });

  group('NotificationResourceType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationResourceType.values) {
        expect(NotificationResourceType.fromValue(v.value), v);
      }
      expect(NotificationResourceType.values.map((e) => e.value), [
        'Case',
        'Alert',
        'Report',
        'Appointment',
        'Conversation',
      ]);
    });

    test('fromValue reads an unknown value as patientCase', () {
      expect(
        NotificationResourceType.fromValue('Bogus'),
        NotificationResourceType.patientCase,
      );
      expect(
        NotificationResourceType.fromValue(''),
        NotificationResourceType.patientCase,
      );
    });
  });

  group('NotificationActionType', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationActionType.values) {
        expect(NotificationActionType.fromValue(v.value), v);
      }
      expect(NotificationActionType.values.map((e) => e.value), [
        '',
        'Approval',
        'Acknowledge',
      ]);
    });

    test('fromValue reads an unknown value as none', () {
      expect(
        NotificationActionType.fromValue('Bogus'),
        NotificationActionType.none,
      );
    });
  });

  group('NotificationActionStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationActionStatus.values) {
        expect(NotificationActionStatus.fromValue(v.value), v);
      }
      expect(NotificationActionStatus.values.map((e) => e.value), [
        '',
        'Pending',
        'Accepted',
        'Declined',
        'Expired',
        'Cancelled',
        'Acknowledged',
      ]);
    });

    test('fromValue reads an unknown value as none', () {
      expect(
        NotificationActionStatus.fromValue('Bogus'),
        NotificationActionStatus.none,
      );
    });
  });

  group('NotificationPriority', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationPriority.values) {
        expect(NotificationPriority.fromValue(v.value), v);
      }
      expect(NotificationPriority.values.map((e) => e.value), [
        'High',
        'Normal',
        'Low',
      ]);
    });

    test('fromValue reads an unknown value as normal', () {
      expect(
        NotificationPriority.fromValue('Bogus'),
        NotificationPriority.normal,
      );
      expect(NotificationPriority.fromValue(''), NotificationPriority.normal);
    });
  });

  group('NotificationChannel', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationChannel.values) {
        expect(NotificationChannel.fromValue(v.value), v);
      }
      expect(NotificationChannel.values.map((e) => e.value), ['InApp', 'Push']);
    });

    test('fromValue reads an unknown value as inApp', () {
      expect(NotificationChannel.fromValue('Bogus'), NotificationChannel.inApp);
      expect(NotificationChannel.fromValue(''), NotificationChannel.inApp);
    });
  });

  group('NotificationSource', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationSource.values) {
        expect(NotificationSource.fromValue(v.value), v);
      }
      expect(NotificationSource.values.map((e) => e.value), [
        'Function',
        'App',
      ]);
    });

    test('fromValue reads an unknown value as cloudFunction', () {
      expect(
        NotificationSource.fromValue('Bogus'),
        NotificationSource.cloudFunction,
      );
      expect(
        NotificationSource.fromValue(''),
        NotificationSource.cloudFunction,
      );
    });
  });

  group('NotificationScope', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationScope.values) {
        expect(NotificationScope.fromValue(v.value), v);
      }
      expect(NotificationScope.values.map((e) => e.value), ['Local', 'Cloud']);
    });

    test('fromValue reads an unknown value as cloud', () {
      expect(NotificationScope.fromValue('Bogus'), NotificationScope.cloud);
      expect(NotificationScope.fromValue(''), NotificationScope.cloud);
    });
  });

  group('NotificationStatus', () {
    test('values round-trip with the exact wire strings', () {
      for (final v in NotificationStatus.values) {
        expect(NotificationStatus.fromValue(v.value), v);
      }
      expect(NotificationStatus.values.map((e) => e.value), [
        'Unread',
        'Read',
        'Archived',
      ]);
    });

    test('fromValue reads an unknown value as unread', () {
      expect(NotificationStatus.fromValue('Bogus'), NotificationStatus.unread);
      expect(NotificationStatus.fromValue(''), NotificationStatus.unread);
    });
  });
}
