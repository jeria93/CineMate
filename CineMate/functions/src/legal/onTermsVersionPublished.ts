import { FieldValue, getFirestore } from "firebase-admin/firestore"
import * as functions from "firebase-functions/v1"

import { LEGAL_PATHS, parseTermsVersionRecord } from "./types.js"

export const onTermsVersionPublished = functions
  .region("europe-west1")
  .firestore.document("legal/terms_versions/{version}")
  .onCreate(async (snapshot, context) => {
    const versionFromPath = String(context.params.version ?? "").trim()
    const record = parseTermsVersionRecord(snapshot.data(), versionFromPath)
    if (!record) {
      functions.logger.error("onTermsVersionPublished invalid payload", {
        versionFromPath,
      })
      return
    }

    const db = getFirestore()

    await db.doc(LEGAL_PATHS.currentConfigDoc).set(
      {
        currentTermsVersion: record.version,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    )

    if (!record.isMajor) {
      functions.logger.info("Published non major terms version", {
        version: record.version,
      })
      return
    }

    await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .doc(record.version)
      .set(
        {
          version: record.version,
          status: "pending",
          whatChanged: record.whatChanged,
          publishedBy: record.publishedBy,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      )

    functions.logger.info("Published major terms version", {
      version: record.version,
      whatChangedCount: record.whatChanged.length,
    })
  })

