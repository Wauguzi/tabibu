/** Kiswahili push copy for the §4.2 event table. */
export const pushSw: Record<string, { title?: string; body: string; bodyPlural?: string }> = {
  orderCreated: { body: 'Daktari wako amekuagizia vipimo.' },
  pathologistRequested: { body: 'Kesi mpya inakusubiri.' },
  pathologistAccepted: { body: 'Mtaalamu wa patholojia amekubali kesi yako.' },
  pathologistAcceptedPatient: { body: 'Mtaalamu wa patholojia anashughulikia vipimo vyako.' },
  pathologistRejected: { body: 'Mtaalamu wa patholojia hakuweza kuchukua kesi yako.' },
  pathologistRequestExpired: { body: 'Mtaalamu wa patholojia hakuweza kuchukua kesi yako.' },
  caseWithdrawn: { body: 'Kesi imekabidhiwa mtu mwingine.' },
  prereadReady: { body: 'Kesi iko tayari kukaguliwa.' },
  prereadFailed: { body: 'Kesi inahitaji kusomwa na wewe mwenyewe.' },
  orderCancelled: { body: 'Agizo limeghairiwa.' },
  caseShared: { body: 'Kesi imeshirikishwa nawe. Fungua Tabibu kuona nambari yako ya ufikiaji.' },
  shareRedeemed: { body: 'Kesi uliyoshiriki imefunguliwa.' },
  reportSigned: { body: 'Ripoti iliyotiwa sahihi iko tayari.' },
  reportUpdated: { body: 'Ripoti imesasishwa.' },
  shareCodeReissued: { body: 'Nambari mpya ya ripoti iko tayari.' },
  criticalReportUnopened: { body: 'Ripoti iliyotiwa sahihi bado inakusubiri.' },
  criticalReportUnopenedSigner: { body: 'Ripoti uliyotia sahihi bado haijafunguliwa.' },
  resultsWithDoctor: {
    body: 'Majibu yako yako kwa daktari wako. Panga muda wa kuyajadili.',
  },
  resultUpdateWithDoctor: {
    body: 'Kuna taarifa mpya kuhusu majibu yako kwa daktari wako.',
  },
  resultReleased: { body: 'Majibu yako yako tayari kwenye Tabibu.' },
  translationReady: { body: 'Tafsiri iko tayari kukaguliwa.' },
  explanationReady: { body: 'Maelezo yako tayari kukaguliwa.' },
  appointmentRequested: {
    title: 'Ombi jipya la miadi',
    body: 'Mgonjwa ameomba kukuona. Jibu kabla muda wa ombi haujaisha.',
  },
  caseDiscussionRequested: {
    title: 'Ombi jipya la mazungumzo',
    body: 'Mgonjwa ameomba muda wa kujadili matokeo.',
  },
  appointmentAccepted: {
    title: 'Miadi imethibitishwa',
    body: 'Ombi lako la miadi limekubaliwa.',
  },
  appointmentDeclined: {
    title: 'Ombi la miadi limekataliwa',
    body: 'Unaweza kuchagua muda mwingine au daktari mwingine.',
  },
  appointmentExpired: {
    title: 'Ombi la miadi limeisha muda',
    body: 'Ombi lako halikujibiwa kwa wakati. Unaweza kuchagua muda mwingine.',
  },
  appointmentCancelledByPatient: {
    title: 'Miadi imeghairiwa',
    body: 'Mgonjwa ameghairi miadi.',
  },
  appointmentCancelledByDoctor: {
    title: 'Miadi imeghairiwa',
    body: 'Daktari wako ameghairi miadi yako. Unaweza kuweka muda mwingine.',
  },
  mdtInvited: { body: 'Umealikwa kwenye majadiliano ya MDT.' },
  mdtInviteAccepted: { body: 'Mwenzako amejiunga na majadiliano yako ya MDT.' },
  mdtInviteDeclined: { body: 'Mwenzako amekataa mwaliko wako wa MDT.' },
  messageReceived: {
    body: 'Una ujumbe mpya kwenye Tabibu.',
    bodyPlural: 'Una jumbe {newCount} mpya kwenye Tabibu.',
  },
  mdtMessageReceived: {
    body: 'Kuna ujumbe mpya kwenye majadiliano ya MDT.',
    bodyPlural: 'Jumbe {newCount} mpya kwenye majadiliano ya MDT.',
  },
  alertDrafted: { body: 'Tahadhari inasubiri idhini.' },
  alertDraftReminder: { body: 'Tahadhari ya dharura bado inasubiri idhini.' },
  alertExpired: { body: 'Tahadhari imeisha muda bila uamuzi.' },
  alertWithdrawn: {
    body: 'Rasimu ya tahadhari imeondolewa baada ya ripoti kurekebishwa.',
  },
  alertEvidenceChanged: {
    body: 'Majibu yaliyotumika kwa tahadhari iliyoidhinishwa yamebadilika. Ikague kwenye Tabibu.',
  },
  alertDeliveredClinician: {
    body: 'Tahadhari ya afya: {disease} katika Kaunti ya {county}. Fungua Tabibu upate mwongozo.',
  },
  alertDeliveredPatient: {
    body: 'Tahadhari ya afya: {disease} katika Kaunti ya {county}. Fungua Tabibu upate mwongozo.',
  },
  confirmatoryTestRequested: {
    body: 'Mtaalamu wa patholojia anapendekeza kipimo kingine kwa kesi.',
  },
  alertDeliveryHeld: {
    body: 'Utumaji wa tahadhari umesitishwa. Fungua Tabibu ukague.',
  },
  alertDeliveryStopped: {
    body: 'Tahadhari imetumwa kwa wahudumu wa afya pekee na haikutolewa kwa wagonjwa.',
  },
  alertDeliveredClinicianDemo: {
    body: 'Majaribio: Tahadhari ya afya: {disease} katika Kaunti ya {county}. Hili ni jaribio, si tahadhari halisi.',
  },
  alertDeliveredPatientDemo: {
    body: 'Majaribio: Tahadhari ya afya: {disease} katika Kaunti ya {county}. Hili ni jaribio, si tahadhari halisi.',
  },
};
