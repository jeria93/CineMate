import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v1";

import { LEGAL_PATHS, parseTermsVersionRecord } from "./types.js";

const AUTH_LIST_PAGE_SIZE = 1000;
const FIRESTORE_BATCH_SIZE = 400;

type SeedJobsResult = {
  totalUsersScanned: number;
  jobsQueued: number;
  skippedDisabled: number;
  skippedMissingEmail: number;
};

function makeTermsEmailJobId(version: string, uid: string): string {
  const safeVersion = version.replace(/\//g, "_");
  return `${safeVersion}_${uid}`;
}

async function seedTermsEmailJobs(
  version: string,
  whatChanged: string[],
): Promise<SeedJobsResult> {
  const auth = getAuth();
  const db = getFirestore();

  let totalUsersScanned = 0;
  let jobsQueued = 0;
  let skippedDisabled = 0;
  let skippedMissingEmail = 0;
  let stagedWrites = 0;
  let nextPageToken: string | undefined;

  let batch = db.batch();

  async function commitBatch(force: boolean): Promise<void> {
    if (stagedWrites === 0) {
      return;
    }
    if (!force && stagedWrites < FIRESTORE_BATCH_SIZE) {
      return;
    }
    await batch.commit();
    batch = db.batch();
    stagedWrites = 0;
  }

  do {
    const page = await auth.listUsers(AUTH_LIST_PAGE_SIZE, nextPageToken);
    nextPageToken = page.pageToken;

    for (const user of page.users) {
      totalUsersScanned += 1;

      if (user.disabled) {
        skippedDisabled += 1;
        continue;
      }

      const email = (user.email ?? "").trim().toLowerCase();
      if (!email) {
        skippedMissingEmail += 1;
        continue;
      }

      const jobId = makeTermsEmailJobId(version, user.uid);
      const jobRef = db
        .collection(LEGAL_PATHS.termsEmailJobsCollection)
        .doc(jobId);

      batch.set(
        jobRef,
        {
          uid: user.uid,
          email,
          version,
          whatChanged,
          status: "queued",
          attempts: 0,
          nextAttemptAt: FieldValue.serverTimestamp(),
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      stagedWrites += 1;
      jobsQueued += 1;
      await commitBatch(false);
    }
  } while (nextPageToken);

  await commitBatch(true);

  return {
    totalUsersScanned,
    jobsQueued,
    skippedDisabled,
    skippedMissingEmail,
  };
}

export const onTermsVersionPublished = functions
  .region("europe-west1")
  .firestore.document("legal/terms_versions/{version}")
  .onCreate(async (snapshot, context) => {
    const versionFromPath = String(context.params.version ?? "").trim();
    const record = parseTermsVersionRecord(snapshot.data(), versionFromPath);
    if (!record) {
      functions.logger.error("onTermsVersionPublished invalid payload", {
        versionFromPath,
      });
      return;
    }

    const db = getFirestore();

    await db.doc(LEGAL_PATHS.currentConfigDoc).set(
      {
        currentTermsVersion: record.version,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    if (!record.isMajor) {
      functions.logger.info("Published non major terms version", {
        version: record.version,
      });
      return;
    }

    await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .doc(record.version)
      .set(
        {
          version: record.version,
          status: "processing",
          whatChanged: record.whatChanged,
          publishedBy: record.publishedBy,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    const seedResult = await seedTermsEmailJobs(
      record.version,
      record.whatChanged,
    );

    await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .doc(record.version)
      .set(
        {
          status: "pending",
          jobsQueued: seedResult.jobsQueued,
          totalUsersScanned: seedResult.totalUsersScanned,
          skippedDisabled: seedResult.skippedDisabled,
          skippedMissingEmail: seedResult.skippedMissingEmail,
          jobsSeededAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    functions.logger.info("Published major terms version", {
      version: record.version,
      whatChangedCount: record.whatChanged.length,
      jobsQueued: seedResult.jobsQueued,
      totalUsersScanned: seedResult.totalUsersScanned,
      skippedDisabled: seedResult.skippedDisabled,
      skippedMissingEmail: seedResult.skippedMissingEmail,
    });
  });
