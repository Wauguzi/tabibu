/** English push copy for the §4.2 event table. Placeholders: {newCount}, {disease}, {county}. */
export const pushEn: Record<string, { title?: string; body: string; bodyPlural?: string }> = {
  orderCreated: { body: 'Your doctor has ordered tests for you.' },
  pathologistRequested: { body: 'A new case is waiting.' },
  pathologistAccepted: { body: 'A pathologist accepted your case.' },
  pathologistAcceptedPatient: { body: 'A pathologist is working on your tests.' },
  pathologistRejected: { body: 'A pathologist could not take your case.' },
  pathologistRequestExpired: { body: 'A pathologist could not take your case.' },
  caseWithdrawn: { body: 'A case was reassigned.' },
  prereadReady: { body: 'A case is ready to review.' },
  prereadFailed: { body: 'A case needs a manual read.' },
  orderCancelled: { body: 'An order was cancelled.' },
  caseShared: { body: 'A case was shared with you. Open Tabibu to see your access code.' },
  shareRedeemed: { body: 'Your shared case was opened.' },
  reportSigned: { body: 'A signed report is ready.' },
  reportUpdated: { body: 'A report has been updated.' },
  shareCodeReissued: { body: 'A new code is ready for a report.' },
  criticalReportUnopened: { body: 'A signed report is still waiting for you.' },
  criticalReportUnopenedSigner: { body: 'A report you signed has not been opened yet.' },
  resultsWithDoctor: { body: 'Your results are with your doctor. Book a time to discuss them.' },
  resultUpdateWithDoctor: { body: 'There is an update to your results with your doctor.' },
  resultReleased: { body: 'Your result is ready in Tabibu.' },
  translationReady: { body: 'A translation is ready to review.' },
  explanationReady: { body: 'An explanation is ready to review.' },
  appointmentRequested: {
    title: 'New appointment request',
    body: 'A patient has asked to see you. Reply before the request expires.',
  },
  caseDiscussionRequested: {
    title: 'New discussion request',
    body: 'A patient has asked for time to discuss a result.',
  },
  appointmentAccepted: {
    title: 'Appointment confirmed',
    body: 'Your appointment request was accepted.',
  },
  appointmentDeclined: {
    title: 'Appointment request declined',
    body: 'You can choose another time or another doctor.',
  },
  appointmentExpired: {
    title: 'Appointment request expired',
    body: 'Your request had no reply in time. You can choose another time.',
  },
  appointmentCancelledByPatient: {
    title: 'Appointment cancelled',
    body: 'A patient cancelled an appointment.',
  },
  appointmentCancelledByDoctor: {
    title: 'Appointment cancelled',
    body: 'Your doctor cancelled your appointment. You can book another time.',
  },
  mdtInvited: { body: 'You have been invited to an MDT discussion.' },
  mdtInviteAccepted: { body: 'A colleague has joined your MDT discussion.' },
  mdtInviteDeclined: { body: 'A colleague declined your MDT invitation.' },
  messageReceived: {
    body: 'You have a new message in Tabibu.',
    bodyPlural: 'You have {newCount} new messages in Tabibu.',
  },
  mdtMessageReceived: {
    body: 'There is a new message in an MDT discussion.',
    bodyPlural: '{newCount} new messages in an MDT discussion.',
  },
  alertDrafted: { body: 'An alert is waiting for approval.' },
  alertDraftReminder: { body: 'An urgent alert is still waiting for approval.' },
  alertExpired: { body: 'An alert expired without a decision.' },
  alertWithdrawn: { body: 'An alert draft was withdrawn after a report was amended.' },
  alertEvidenceChanged: {
    body: 'The results behind an approved alert have changed. Review it in Tabibu.',
  },
  alertDeliveredClinician: {
    body: 'Health alert: {disease} in {county} County. Open Tabibu for guidance.',
  },
  alertDeliveredPatient: {
    body: 'Health alert: {disease} in {county} County. Open Tabibu for guidance.',
  },
  confirmatoryTestRequested: {
    body: 'A pathologist recommends a further test for a case.',
  },
  alertDeliveryHeld: { body: 'Alert delivery is paused. Open Tabibu to review.' },
  alertDeliveryStopped: {
    body: 'An alert went to clinicians only and was not released to patients.',
  },
  alertDeliveredClinicianDemo: {
    body: 'Demo: Health alert: {disease} in {county} County. This is a test, not a real alert.',
  },
  alertDeliveredPatientDemo: {
    body: 'Demo: Health alert: {disease} in {county} County. This is a test, not a real alert.',
  },
};
