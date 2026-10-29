import { setGlobalOptions } from 'firebase-functions/v2';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import { callerOf } from './common';
import {
  Deps,
  addPatientHandler,
  completePatientSignUpHandler,
  completePractitionerSignUpHandler,
  linkPatientAccountHandler,
  syncPractitionerHandler,
  verifyPractitionerHandler,
} from './identity';

initializeApp();

// europe-west1 sits inside the database's eur3 location. The instance cap bounds the cost of
// a scripted burst until App Check is enforced (CRQ-0010).
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

function deps(): Deps {
  return { db: getFirestore(), auth: getAuth(), bucket: getStorage().bucket().name };
}

export const completePatientSignUp = onCall((request) =>
  completePatientSignUpHandler(deps(), callerOf(request), request.data),
);

export const completePractitionerSignUp = onCall((request) =>
  completePractitionerSignUpHandler(deps(), callerOf(request), request.data),
);

export const verifyPractitioner = onCall((request) =>
  verifyPractitionerHandler(deps(), callerOf(request), request.data),
);

export const addPatient = onCall((request) =>
  addPatientHandler(deps(), callerOf(request), request.data),
);

export const linkPatientAccount = onCall((request) =>
  linkPatientAccountHandler(deps(), callerOf(request), request.data),
);

// Retried on failure: the handler reads the stored profile, so running it twice is safe.
export const syncPractitioner = onDocumentWritten({ document: 'doctors/{uid}', retry: true }, async (event) => {
  await syncPractitionerHandler(getFirestore(), event.params.uid);
});
