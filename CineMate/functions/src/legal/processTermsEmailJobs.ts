import { getFirestore } from "firebase-admin/firestore"
import * as functions from "firebase-functions/v1"

import { LEGAL_PATHS } from "./types.js"

export const processTermsEmailJobs = functions
  .region("europe-west1")
  .pubsub.schedule("every 5 minutes")
  .onRun(async () => {
    const db = getFirestore()

    const pendingBatches = await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .where("status", "==", "pending")
      .limit(20)
      .get()

    functions.logger.info("processTermsEmailJobs scaffold run", {
      pendingBatches: pendingBatches.size,
    })

    return null
  })

