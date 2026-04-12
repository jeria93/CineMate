import { FieldValue, getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v1";

import { sendTermsUpdateEmail } from "./emailProvider.js";
import {
  LEGAL_PATHS,
  parseTermsEmailJobRecord,
  TERMS_EMAIL_JOB_STATUS,
  type TermsEmailJobRecord,
} from "./types.js";

const MAX_EMAILS_PER_BATCH_RUN = 200;
const MAX_ATTEMPTS = 5;
const RETRY_BASE_MINUTES = 5;
const RETRY_MAX_MINUTES = 24 * 60;
const DEFAULT_TERMS_URL = "https://www.themoviedb.org/terms-of-use";

function resolveTermsUrl(): string {
  const value = (process.env.APP_TERMS_URL ?? "").trim();
  return value.length > 0 ? value : DEFAULT_TERMS_URL;
}

function isDue(job: TermsEmailJobRecord, now: Date): boolean {
  if (!job.nextAttemptAt) {
    return true;
  }
  return job.nextAttemptAt.getTime() <= now.getTime();
}

function compareByNextAttemptAtAsc(
  a: TermsEmailJobRecord,
  b: TermsEmailJobRecord,
): number {
  const aTs = a.nextAttemptAt?.getTime() ?? 0;
  const bTs = b.nextAttemptAt?.getTime() ?? 0;
  return aTs - bTs;
}

function retryDelayMinutes(attemptAfterFailure: number): number {
  const backoff =
    RETRY_BASE_MINUTES * 2 ** Math.max(0, attemptAfterFailure - 1);
  return Math.min(backoff, RETRY_MAX_MINUTES);
}

function toErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}

export const processTermsEmailJobs = functions
  .region("europe-west1")
  .pubsub.schedule("every 5 minutes")
  .onRun(async () => {
    const db = getFirestore();
    const now = new Date();
    const termsUrl = resolveTermsUrl();

    const pendingBatchesSnapshot = await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .where("status", "==", "pending")
      .limit(20)
      .get();
    const processingBatchesSnapshot = await db
      .collection(LEGAL_PATHS.termsEmailBatchCollection)
      .where("status", "==", "processing")
      .limit(20)
      .get();

    const batchesById = new Map<
      string,
      FirebaseFirestore.QueryDocumentSnapshot
    >();
    for (const doc of pendingBatchesSnapshot.docs) {
      batchesById.set(doc.id, doc);
    }
    for (const doc of processingBatchesSnapshot.docs) {
      batchesById.set(doc.id, doc);
    }

    if (batchesById.size === 0) {
      functions.logger.info("processTermsEmailJobs no pending batches");
      return null;
    }

    for (const batchDoc of batchesById.values()) {
      const version = String(batchDoc.get("version") ?? batchDoc.id).trim();
      if (!version) {
        functions.logger.warn("processTermsEmailJobs batch without version", {
          batchId: batchDoc.id,
        });
        continue;
      }

      const batchRef = db
        .collection(LEGAL_PATHS.termsEmailBatchCollection)
        .doc(batchDoc.id);
      await batchRef.set(
        {
          status: "processing",
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      const queuedJobsSnapshot = await db
        .collection(LEGAL_PATHS.termsEmailJobsCollection)
        .where("version", "==", version)
        .where("status", "==", TERMS_EMAIL_JOB_STATUS.queued)
        .get();
      const retryJobsSnapshot = await db
        .collection(LEGAL_PATHS.termsEmailJobsCollection)
        .where("version", "==", version)
        .where("status", "==", TERMS_EMAIL_JOB_STATUS.retry)
        .get();

      const jobsToProcess: Array<{
        doc: FirebaseFirestore.QueryDocumentSnapshot;
        parsed: TermsEmailJobRecord;
      }> = [];
      const invalidJobDocs: FirebaseFirestore.QueryDocumentSnapshot[] = [];

      for (const doc of [
        ...queuedJobsSnapshot.docs,
        ...retryJobsSnapshot.docs,
      ]) {
        const parsed = parseTermsEmailJobRecord(doc.data());
        if (!parsed) {
          invalidJobDocs.push(doc);
          continue;
        }
        jobsToProcess.push({ doc, parsed });
      }

      const dueJobs = jobsToProcess
        .filter((job) => isDue(job.parsed, now))
        .sort((a, b) => compareByNextAttemptAtAsc(a.parsed, b.parsed))
        .slice(0, MAX_EMAILS_PER_BATCH_RUN);

      let sentCount = 0;
      let retryCount = 0;
      let failedCount = 0;
      let invalidCount = 0;

      for (const invalidDoc of invalidJobDocs) {
        invalidCount += 1;
        await invalidDoc.ref.set(
          {
            status: TERMS_EMAIL_JOB_STATUS.failed,
            lastError: "Invalid job payload",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      for (const { doc, parsed } of dueJobs) {
        const attemptsAfterRun = parsed.attempts + 1;

        try {
          const result = await sendTermsUpdateEmail({
            to: parsed.email,
            version: parsed.version,
            whatChanged: parsed.whatChanged,
            termsUrl,
          });

          await doc.ref.set(
            {
              status: TERMS_EMAIL_JOB_STATUS.sent,
              attempts: attemptsAfterRun,
              providerMessageId: result.providerMessageId,
              sentAt: FieldValue.serverTimestamp(),
              nextAttemptAt: FieldValue.delete(),
              lastError: FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );

          await db
            .doc(`users/${parsed.uid}/legal_notifications/${parsed.version}`)
            .set(
              {
                version: parsed.version,
                status: TERMS_EMAIL_JOB_STATUS.sent,
                sentAt: FieldValue.serverTimestamp(),
                attempts: attemptsAfterRun,
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true },
            );

          sentCount += 1;
        } catch (error) {
          const message = toErrorMessage(error);
          if (attemptsAfterRun >= MAX_ATTEMPTS) {
            await doc.ref.set(
              {
                status: TERMS_EMAIL_JOB_STATUS.failed,
                attempts: attemptsAfterRun,
                lastError: message,
                nextAttemptAt: FieldValue.delete(),
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true },
            );
            failedCount += 1;
          } else {
            const delayMinutes = retryDelayMinutes(attemptsAfterRun);
            const retryAt = new Date(now.getTime() + delayMinutes * 60 * 1000);
            await doc.ref.set(
              {
                status: TERMS_EMAIL_JOB_STATUS.retry,
                attempts: attemptsAfterRun,
                lastError: message,
                nextAttemptAt: retryAt,
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true },
            );
            retryCount += 1;
          }
        }
      }

      const remainingQueued = await db
        .collection(LEGAL_PATHS.termsEmailJobsCollection)
        .where("version", "==", version)
        .where("status", "==", TERMS_EMAIL_JOB_STATUS.queued)
        .limit(1)
        .get();
      const remainingRetry = await db
        .collection(LEGAL_PATHS.termsEmailJobsCollection)
        .where("version", "==", version)
        .where("status", "==", TERMS_EMAIL_JOB_STATUS.retry)
        .limit(1)
        .get();

      const isDone = remainingQueued.empty && remainingRetry.empty;
      await batchRef.set(
        {
          status: isDone ? "completed" : "pending",
          lastRunAt: FieldValue.serverTimestamp(),
          lastRunProcessed: dueJobs.length + invalidCount,
          lastRunSent: sentCount,
          lastRunRetried: retryCount,
          lastRunFailed: failedCount + invalidCount,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      functions.logger.info("processTermsEmailJobs batch processed", {
        version,
        processed: dueJobs.length + invalidCount,
        sentCount,
        retryCount,
        failedCount: failedCount + invalidCount,
        remaining: !isDone,
      });
    }

    return null;
  });
