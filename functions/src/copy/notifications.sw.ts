/** Kiswahili push copy for the §4.2 event table. */
export const pushSw: Record<string, { title?: string; body: string; bodyPlural?: string }> = {
  orderCreated: { title: 'Vipimo vimeagizwa', body: 'Daktari wako amekuagizia vipimo.' },
  pathologistRequested: { title: 'Kesi mpya inasubiri', body: 'Kesi mpya inakusubiri.' },
  pathologistAccepted: { title: 'Kesi imekubaliwa', body: 'Mtaalamu wa patholojia amekubali kesi yako.' },
  pathologistAcceptedPatient: { title: 'Vipimo vyako vinaendelea', body: 'Mtaalamu wa patholojia anashughulikia vipimo vyako.' },
  pathologistRejected: { title: 'Kesi haijachukuliwa', body: 'Mtaalamu wa patholojia hakuweza kuchukua kesi yako.' },
  pathologistRequestExpired: { title: 'Kesi haijachukuliwa', body: 'Mtaalamu wa patholojia hakuweza kuchukua kesi yako.' },
  caseWithdrawn: { title: 'Kesi imehamishwa', body: 'Kesi imekabidhiwa mtu mwingine.' },
  prereadReady: { title: 'Usomaji wa awali uko tayari', body: 'Kesi iko tayari kukaguliwa.' },
  prereadFailed: { title: 'Usomaji wa mkono unahitajika', body: 'Kesi inahitaji kusomwa na wewe mwenyewe.' },
  orderCancelled: { title: 'Agizo limeghairiwa', body: 'Agizo limeghairiwa.' },
  caseShared: { title: 'Ripoti imeshirikiwa nawe', body: 'Kesi imeshirikishwa nawe. Fungua Tabibu kuona nambari yako ya ufikiaji.' },
  shareRedeemed: { title: 'Ripoti iliyoshirikiwa imefunguliwa', body: 'Kesi uliyoshiriki imefunguliwa.' },
  reportSigned: { title: 'Ripoti iliyosainiwa iko tayari', body: 'Ripoti iliyotiwa sahihi iko tayari.' },
  reportUpdated: { title: 'Ripoti imesasishwa', body: 'Ripoti imesasishwa.' },
  shareCodeReissued: { title: 'Msimbo mpya wa ufikiaji', body: 'Nambari mpya ya ripoti iko tayari.' },
  criticalReportUnopened: { title: 'Ripoti inasubiri', body: 'Ripoti iliyotiwa sahihi bado inakusubiri.' },
  criticalReportUnopenedSigner: { title: 'Ripoti inasubiri', body: 'Ripoti uliyotia sahihi bado haijafunguliwa.' },
  resultsWithDoctor: {
    title: 'Matokeo yako yako kwa daktari',
    body: 'Majibu yako yako kwa daktari wako. Panga muda wa kuyajadili.',
  },
  resultUpdateWithDoctor: {
    title: 'Matokeo yako yako kwa daktari',
    body: 'Kuna taarifa mpya kuhusu majibu yako kwa daktari wako.',
  },
  resultReleased: { title: 'Matokeo yako tayari', body: 'Majibu yako yako tayari kwenye Tabibu.' },
  translationReady: { title: 'Tafsiri iko tayari', body: 'Tafsiri iko tayari kukaguliwa.' },
  explanationReady: { title: 'Maelezo yako tayari', body: 'Maelezo yako tayari kukaguliwa.' },
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
  mdtInvited: { title: 'Mwaliko wa mjadala', body: 'Umealikwa kwenye majadiliano ya MDT.' },
  mdtInviteAccepted: { title: 'Mwaliko umekubaliwa', body: 'Mwenzako amejiunga na majadiliano yako ya MDT.' },
  mdtInviteDeclined: { title: 'Mwaliko umekataliwa', body: 'Mwenzako amekataa mwaliko wako wa MDT.' },
  messageReceived: {
    title: 'Ujumbe mpya',
    body: 'Una ujumbe mpya kwenye Tabibu.',
    bodyPlural: 'Una jumbe {newCount} mpya kwenye Tabibu.',
  },
  mdtMessageReceived: {
    title: 'Ujumbe mpya',
    body: 'Kuna ujumbe mpya kwenye majadiliano ya MDT.',
    bodyPlural: 'Jumbe {newCount} mpya kwenye majadiliano ya MDT.',
  },
  alertDrafted: { title: 'Arifa ya kukagua', body: 'Tahadhari inasubiri idhini.' },
  alertDraftReminder: { title: 'Arifa bado inasubiri', body: 'Tahadhari ya dharura bado inasubiri idhini.' },
  alertExpired: { title: 'Arifa imeisha muda', body: 'Tahadhari imeisha muda bila uamuzi.' },
  alertWithdrawn: {
    title: 'Arifa imeondolewa',
    body: 'Rasimu ya tahadhari imeondolewa baada ya ripoti kurekebishwa.',
  },
  alertEvidenceChanged: {
    title: 'Ushahidi wa arifa umebadilika',
    body: 'Majibu yaliyotumika kwa tahadhari iliyoidhinishwa yamebadilika. Ikague kwenye Tabibu.',
  },
  alertDeliveredClinician: {
    title: 'Arifa ya afya',
    body: 'Tahadhari ya afya: {disease} katika Kaunti ya {county}. Fungua Tabibu upate mwongozo.',
  },
  alertDeliveredPatient: {
    title: 'Taarifa ya afya',
    body: 'Tahadhari ya afya: {disease} katika Kaunti ya {county}. Fungua Tabibu upate mwongozo.',
  },
  confirmatoryTestRequested: {
    title: 'Kipimo zaidi kinapendekezwa',
    body: 'Mtaalamu wa patholojia anapendekeza kipimo kingine kwa kesi.',
  },
  alertDeliveryHeld: {
    title: 'Utoaji wa arifa umesimamishwa',
    body: 'Utumaji wa tahadhari umesitishwa. Fungua Tabibu ukague.',
  },
  alertDeliveryStopped: {
    title: 'Utoaji wa arifa umesimamishwa',
    body: 'Tahadhari imetumwa kwa wahudumu wa afya pekee na haikutolewa kwa wagonjwa.',
  },
  alertDeliveredClinicianDemo: {
    title: 'Arifa ya afya',
    body: 'Majaribio: Tahadhari ya afya: {disease} katika Kaunti ya {county}. Hili ni jaribio, si tahadhari halisi.',
  },
  alertDeliveredPatientDemo: {
    title: 'Taarifa ya afya',
    body: 'Majaribio: Tahadhari ya afya: {disease} katika Kaunti ya {county}. Hili ni jaribio, si tahadhari halisi.',
  },
};
