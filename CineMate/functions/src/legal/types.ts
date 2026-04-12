export const LEGAL_PATHS = {
  termsVersionsCollection: "legal/terms_versions",
  currentConfigDoc: "legal/config/current",
  termsEmailBatchCollection: "legal/terms_email_batches",
  termsEmailJobsCollection: "legal/terms_email_jobs",
} as const;

export const TERMS_EMAIL_JOB_STATUS = {
  queued: "queued",
  retry: "retry",
  sent: "sent",
  failed: "failed",
} as const;

export type TermsEmailJobStatus =
  (typeof TERMS_EMAIL_JOB_STATUS)[keyof typeof TERMS_EMAIL_JOB_STATUS];

export type TermsVersionRecord = {
  version: string;
  isMajor: boolean;
  whatChanged: string[];
  publishedBy: string | null;
};

export type TermsEmailJobRecord = {
  uid: string;
  email: string;
  version: string;
  whatChanged: string[];
  status: TermsEmailJobStatus;
  attempts: number;
  nextAttemptAt: Date | null;
};

export function parseTermsVersionRecord(
  raw: Record<string, unknown> | undefined,
  versionFromPath: string,
): TermsVersionRecord | null {
  if (!raw) {
    return null;
  }

  const versionRaw = typeof raw.version === "string" ? raw.version.trim() : "";
  const version = versionRaw.length > 0 ? versionRaw : versionFromPath.trim();
  if (!version) {
    return null;
  }

  const isMajor = raw.isMajor === true;
  const publishedBy =
    typeof raw.publishedBy === "string" ? raw.publishedBy.trim() || null : null;

  const whatChangedRaw = Array.isArray(raw.whatChanged) ? raw.whatChanged : [];
  const whatChanged = whatChangedRaw
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);

  return {
    version,
    isMajor,
    whatChanged,
    publishedBy,
  };
}

export function parseTermsEmailJobRecord(
  raw: Record<string, unknown> | undefined,
): TermsEmailJobRecord | null {
  if (!raw) {
    return null;
  }

  const uid = typeof raw.uid === "string" ? raw.uid.trim() : "";
  const email =
    typeof raw.email === "string" ? raw.email.trim().toLowerCase() : "";
  const version = typeof raw.version === "string" ? raw.version.trim() : "";
  if (!uid || !email || !version) {
    return null;
  }

  const statusRaw = typeof raw.status === "string" ? raw.status : "";
  const isStatusValid = Object.values(TERMS_EMAIL_JOB_STATUS).includes(
    statusRaw as TermsEmailJobStatus,
  );
  if (!isStatusValid) {
    return null;
  }

  const attempts =
    typeof raw.attempts === "number" && Number.isFinite(raw.attempts)
      ? Math.max(0, Math.floor(raw.attempts))
      : 0;

  const nextAttemptAt = parseUnknownDate(raw.nextAttemptAt);

  const whatChangedRaw = Array.isArray(raw.whatChanged) ? raw.whatChanged : [];
  const whatChanged = whatChangedRaw
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);

  return {
    uid,
    email,
    version,
    whatChanged,
    status: statusRaw as TermsEmailJobStatus,
    attempts,
    nextAttemptAt,
  };
}

function parseUnknownDate(raw: unknown): Date | null {
  if (raw instanceof Date) {
    return raw;
  }
  if (raw && typeof raw === "object" && "toDate" in raw) {
    const toDate = (raw as { toDate?: unknown }).toDate;
    if (typeof toDate === "function") {
      const result = toDate.call(raw);
      return result instanceof Date ? result : null;
    }
  }
  return null;
}
