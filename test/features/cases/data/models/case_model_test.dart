import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';

Map<String, dynamic> caseJson() => {
  'uid': 'uid-case-1',
  'orderNumber': 'ODR-TEST-001',
  'appointmentUid': 'uid-appointment-1',
  'createdByUid': 'uid-doctor-1',
  'doctorUid': 'uid-doctor-1',
  'doctorName': 'Test Doctor',
  'doctorFacilityName': 'Test Facility',
  'patientId': 'patient-1',
  'patientUid': 'uid-patient-1',
  'patientName': 'Test Patient',
  'patientSex': 'Female',
  'patientAgeYears': 40,
  'requestedPathologistUid': 'uid-pathologist-2',
  'requestedPathologistName': 'Test Requested',
  'pathologistRequestedAt': '2030-05-01T09:00:00.000Z',
  'pathologistRequestExpiresAt': '2030-05-03T09:00:00.000Z',
  'declinedPathologistUids': ['uid-pathologist-3'],
  'pathologistUid': 'uid-pathologist-1',
  'pathologistName': 'Test Pathologist',
  'pathologistAcceptedAt': '2030-05-01T10:00:00.000Z',
  'viewerUids': ['uid-viewer-1'],
  'participantUids': ['uid-doctor-1', 'uid-patient-1', 'uid-pathologist-1'],
  'tests': [
    {
      'labTestId': 'uid-test-1',
      'testTypeId': 'uid-type-1',
      'testTypeName': 'Test Type',
      'name': 'Test Name',
      'priceKes': 500,
      'isPriceEstimate': true,
    },
  ],
  'totalPriceKes': 500,
  'isPriceEstimate': true,
  'priority': 'Urgent',
  'clinicalNotes': 'Test clinical notes',
  'sampleNotes': 'Test sample notes',
  'notesLanguage': 'en',
  'sampleCollectedAt': '2030-05-01T08:00:00.000Z',
  'sampleReceivedAt': '2030-05-01T09:00:00.000Z',
  'labAccessionNo': 'ACC-001',
  'requiresSlides': true,
  'slideUploadUids': ['uid-image-1'],
  'slideImages': [
    {
      'imageUid': 'uid-image-1',
      'path': 'cases/uid-case-1/slides/uid-image-1.tiff',
      'contentType': 'image/tiff',
      'micronsPerPixel': 0.25,
      'uploadedByUid': 'uid-doctor-1',
      'uploadedAt': '2030-05-01T08:30:00.000Z',
    },
  ],
  'prereadRunUid': 'uid-preread-1',
  'currentReportUid': 'uid-report-1',
  'resultState': 'WithDoctor',
  'discussionAppointmentUid': 'uid-appointment-2',
  'currentLocation': 'Pathologist',
  'currentStage': 'ReportSigned',
  'currentStep': 'ReadReport',
  'stageSeq': 7,
  'stageEnteredAt': '2030-05-04T10:00:00.000Z',
  'releasedToPatient': true,
  'discussedAt': '',
  'releasedAt': '2030-05-05T10:00:00.000Z',
  'cancelReason': '',
  'createdAt': '2030-05-01T07:00:00.000Z',
  'lastUpdatedAt': '2030-05-05T10:00:00.000Z',
};

void main() {
  group('CaseModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = caseJson();
      final model = CaseModel.fromJson(json);
      expect(model.uid, 'uid-case-1');
      expect(model.orderNumber, 'ODR-TEST-001');
      expect(model.tests, hasLength(1));
      expect(model.tests.single.name, 'Test Name');
      expect(model.slideImages, hasLength(1));
      expect(model.slideImages.single.micronsPerPixel, 0.25);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = CaseModel.fromJson({});
      expect(model, CaseModel.empty());
      expect(model.priority, 'Routine');
      expect(model.resultState, 'Pending');
      expect(model.currentLocation, 'Doctor');
      expect(model.currentStage, 'OrderCreated');
      expect(model.tests, isEmpty);
    });

    test('toJson never contains synced', () {
      final model = CaseModel.fromJson(caseJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = CaseModel.fromJson(caseJson());
      expect(model.patientSexValue, Sex.female);
      expect(model.priorityValue, Urgency.urgent);
      expect(model.resultStateValue, ResultState.withDoctor);
      expect(model.currentLocationValue, CaseLocation.pathologist);
      expect(model.currentStageValue, CaseStage.reportSigned);
      expect(model.currentStepValue, CaseStep.readReport);
      expect(model.cancelReasonValue, CancelReason.other);

      final unknown = CaseModel.fromJson({
        'patientSex': 'Bogus',
        'priority': 'Bogus',
        'resultState': 'Bogus',
        'currentLocation': 'Bogus',
        'currentStage': 'Bogus',
        'currentStep': 'Bogus',
        'cancelReason': 'Bogus',
      });
      expect(unknown.patientSexValue, isNull);
      expect(unknown.priorityValue, Urgency.routine);
      expect(unknown.resultStateValue, ResultState.pending);
      expect(unknown.currentLocationValue, CaseLocation.doctor);
      expect(unknown.currentStageValue, CaseStage.orderCreated);
      expect(unknown.currentStepValue, CaseStep.none);
      expect(unknown.cancelReasonValue, CancelReason.other);
    });

    test('isParticipant follows the participant list', () {
      final model = CaseModel.fromJson(caseJson());
      expect(model.isParticipant('uid-doctor-1'), isTrue);
      expect(model.isParticipant('uid-stranger-1'), isFalse);
    });

    test('isPathologistOf is the accepted pathologist only', () {
      final model = CaseModel.fromJson(caseJson());
      expect(model.isPathologistOf('uid-pathologist-1'), isTrue);
      expect(model.isPathologistOf('uid-pathologist-2'), isFalse);
      expect(model.isPathologistOf('uid-doctor-1'), isFalse);
    });

    test('canSeeFullLog is the doctor and the accepted pathologist', () {
      final model = CaseModel.fromJson(caseJson());
      expect(model.canSeeFullLog('uid-doctor-1'), isTrue);
      expect(model.canSeeFullLog('uid-pathologist-1'), isTrue);
      expect(model.canSeeFullLog('uid-patient-1'), isFalse);
      expect(model.canSeeFullLog('uid-pathologist-2'), isFalse);
    });

    test('patientStage projects every stage', () {
      const projection = {
        CaseStage.orderCreated: CaseStage.orderCreated,
        CaseStage.pathologistRequested: CaseStage.orderCreated,
        CaseStage.pathologistRejected: CaseStage.orderCreated,
        CaseStage.pathologistAccepted: CaseStage.pathologistAccepted,
        CaseStage.sampleReceived: CaseStage.pathologistAccepted,
        CaseStage.slidesUploaded: CaseStage.pathologistAccepted,
        CaseStage.prereadQueued: CaseStage.pathologistAccepted,
        CaseStage.prereadReady: CaseStage.pathologistAccepted,
        CaseStage.prereadFailed: CaseStage.pathologistAccepted,
        CaseStage.reportInProgress: CaseStage.pathologistAccepted,
        CaseStage.reportSigned: CaseStage.reportSigned,
        CaseStage.discussionRequested: CaseStage.discussionRequested,
        CaseStage.discussionBooked: CaseStage.discussionBooked,
        CaseStage.resultReleased: CaseStage.resultReleased,
        CaseStage.completed: CaseStage.completed,
        CaseStage.cancelled: CaseStage.cancelled,
      };
      expect(projection.keys, CaseStage.values);
      for (final entry in projection.entries) {
        final model = CaseModel.fromJson({'currentStage': entry.key.value});
        expect(model.patientStage, entry.value, reason: '${entry.key}');
      }
    });
  });

  group('CaseHive', () {
    test('fromModel maps every field', () {
      final hive = CaseHive.fromModel(CaseModel.fromJson(caseJson()));
      expect(hive.uid, 'uid-case-1');
      expect(hive.orderNumber, 'ODR-TEST-001');
      expect(hive.appointmentUid, 'uid-appointment-1');
      expect(hive.createdByUid, 'uid-doctor-1');
      expect(hive.doctorUid, 'uid-doctor-1');
      expect(hive.doctorName, 'Test Doctor');
      expect(hive.doctorFacilityName, 'Test Facility');
      expect(hive.patientId, 'patient-1');
      expect(hive.patientUid, 'uid-patient-1');
      expect(hive.patientName, 'Test Patient');
      expect(hive.patientSex, 'Female');
      expect(hive.patientAgeYears, 40);
      expect(hive.requestedPathologistUid, 'uid-pathologist-2');
      expect(hive.requestedPathologistName, 'Test Requested');
      expect(hive.pathologistRequestedAt, '2030-05-01T09:00:00.000Z');
      expect(hive.pathologistRequestExpiresAt, '2030-05-03T09:00:00.000Z');
      expect(hive.declinedPathologistUids, ['uid-pathologist-3']);
      expect(hive.pathologistUid, 'uid-pathologist-1');
      expect(hive.pathologistName, 'Test Pathologist');
      expect(hive.pathologistAcceptedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.viewerUids, ['uid-viewer-1']);
      expect(hive.participantUids, [
        'uid-doctor-1',
        'uid-patient-1',
        'uid-pathologist-1',
      ]);
      expect(hive.tests, hasLength(1));
      expect(hive.tests.single.name, 'Test Name');
      expect(hive.totalPriceKes, 500);
      expect(hive.isPriceEstimate, isTrue);
      expect(hive.priority, 'Urgent');
      expect(hive.clinicalNotes, 'Test clinical notes');
      expect(hive.sampleNotes, 'Test sample notes');
      expect(hive.notesLanguage, 'en');
      expect(hive.sampleCollectedAt, '2030-05-01T08:00:00.000Z');
      expect(hive.sampleReceivedAt, '2030-05-01T09:00:00.000Z');
      expect(hive.labAccessionNo, 'ACC-001');
      expect(hive.requiresSlides, isTrue);
      expect(hive.slideUploadUids, ['uid-image-1']);
      expect(hive.slideImages, hasLength(1));
      expect(hive.slideImages.single.micronsPerPixel, 0.25);
      expect(hive.prereadRunUid, 'uid-preread-1');
      expect(hive.currentReportUid, 'uid-report-1');
      expect(hive.resultState, 'WithDoctor');
      expect(hive.discussionAppointmentUid, 'uid-appointment-2');
      expect(hive.currentLocation, 'Pathologist');
      expect(hive.currentStage, 'ReportSigned');
      expect(hive.currentStep, 'ReadReport');
      expect(hive.stageSeq, 7);
      expect(hive.stageEnteredAt, '2030-05-04T10:00:00.000Z');
      expect(hive.releasedToPatient, isTrue);
      expect(hive.discussedAt, '');
      expect(hive.releasedAt, '2030-05-05T10:00:00.000Z');
      expect(hive.cancelReason, '');
      expect(hive.createdAt, '2030-05-01T07:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-05T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = CaseModel.fromJson(caseJson());
      expect(CaseHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = CaseModel.fromJson(caseJson()).copyWith(synced: false);
      expect(CaseHive.fromModel(model).toModel().synced, isFalse);
    });

    test('an empty uid never matches, even before a pathologist accepts', () {
      final unassigned = CaseModel.empty();
      expect(unassigned.isPathologistOf(''), isFalse);
      expect(unassigned.canSeeFullLog(''), isFalse);
      expect(unassigned.isParticipant(''), isFalse);
    });
  });
}
