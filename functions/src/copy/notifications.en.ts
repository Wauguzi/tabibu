/** English push copy for the §4.2 event table. Placeholders: {newCount}, {disease}, {county}. */
export const pushEn: Record<string, { title?: string; body: string; bodyPlural?: string }> = {
  orderCreated: { title: 'Tests ordered', body: 'Your doctor has ordered tests for you.' },
  pathologistRequested: { title: 'New case waiting', body: 'A new case is waiting.' },
  pathologistAccepted: { title: 'Case accepted', body: 'A pathologist accepted your case.' },
  pathologistAcceptedPatient: { title: 'Your tests are in progress', body: 'A pathologist is working on your tests.' },
  pathologistRejected: { title: 'Case not taken', body: 'A pathologist could not take your case.' },
  pathologistRequestExpired: { title: 'Case not taken', body: 'A pathologist could not take your case.' },
  caseWithdrawn: { title: 'Case reassigned', body: 'A case was reassigned.' },
  prereadReady: { title: 'Pre-read ready', body: 'A case is ready to review.' },
  prereadFailed: { title: 'Manual read needed', body: 'A case needs a manual read.' },
  orderCancelled: { title: 'Order cancelled', body: 'An order was cancelled.' },
  caseShared: { title: 'Report shared with you', body: 'A case was shared with you. Open Tabibu to see your access code.' },
  shareRedeemed: { title: 'Shared report opened', body: 'Your shared case was opened.' },
  reportSigned: { title: 'Signed report ready', body: 'A signed report is ready.' },
  reportUpdated: { title: 'Report updated', body: 'A report has been updated.' },
  shareCodeReissued: { title: 'New access code', body: 'A new code is ready for a report.' },
  criticalReportUnopened: { title: 'Report waiting', body: 'A signed report is still waiting for you.' },
  criticalReportUnopenedSigner: { title: 'Report waiting', body: 'A report you signed has not been opened yet.' },
  resultsWithDoctor: { title: 'Results with your doctor', body: 'Your results are with your doctor. Book a time to discuss them.' },
  resultUpdateWithDoctor: { title: 'Results with your doctor', body: 'There is an update to your results with your doctor.' },
  resultReleased: { title: 'Result ready', body: 'Your result is ready in Tabibu.' },
  translationReady: { title: 'Translation ready', body: 'A translation is ready to review.' },
  explanationReady: { title: 'Explanation ready', body: 'An explanation is ready to review.' },
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
  mdtInvited: { title: 'Consult invitation', body: 'You have been invited to an MDT discussion.' },
  mdtInviteAccepted: { title: 'Invitation accepted', body: 'A colleague has joined your MDT discussion.' },
  mdtInviteDeclined: { title: 'Invitation declined', body: 'A colleague declined your MDT invitation.' },
  messageReceived: {
    title: 'New message',
    body: 'You have a new message in Tabibu.',
    bodyPlural: 'You have {newCount} new messages in Tabibu.',
  },
  mdtMessageReceived: {
    title: 'New message',
    body: 'There is a new message in an MDT discussion.',
    bodyPlural: '{newCount} new messages in an MDT discussion.',
  },
  alertDrafted: { title: 'Alert to review', body: 'An alert is waiting for approval.' },
  alertDraftReminder: { title: 'Alert still waiting', body: 'An urgent alert is still waiting for approval.' },
  alertExpired: { title: 'Alert expired', body: 'An alert expired without a decision.' },
  alertWithdrawn: { title: 'Alert withdrawn', body: 'An alert draft was withdrawn after a report was amended.' },
  alertEvidenceChanged: {
    title: 'Alert evidence changed',
    body: 'The results behind an approved alert have changed. Review it in Tabibu.',
  },
  alertDeliveredClinician: {
    title: 'Health alert',
    body: 'Health alert: {disease} in {county} County. Open Tabibu for guidance.',
  },
  alertDeliveredPatient: {
    title: 'Health notice',
    body: 'Health alert: {disease} in {county} County. Open Tabibu for guidance.',
  },
  confirmatoryTestRequested: {
    title: 'Further test advised',
    body: 'A pathologist recommends a further test for a case.',
  },
  alertDeliveryHeld: { title: 'Alert delivery held', body: 'Alert delivery is paused. Open Tabibu to review.' },
  alertDeliveryStopped: {
    title: 'Alert delivery held',
    body: 'An alert went to clinicians only and was not released to patients.',
  },
  alertDeliveredClinicianDemo: {
    title: 'Health alert',
    body: 'Demo: Health alert: {disease} in {county} County. This is a test, not a real alert.',
  },
  alertDeliveredPatientDemo: {
    title: 'Health notice',
    body: 'Demo: Health alert: {disease} in {county} County. This is a test, not a real alert.',
  },
};
