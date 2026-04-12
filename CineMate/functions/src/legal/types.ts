export const LEGAL_PATHS = {
  termsVersionsCollection: "legal/terms_versions",
  currentConfigDoc: "legal/config/current",
  termsEmailBatchCollection: "legal/terms_email_batches",
  termsEmailJobsCollection: "legal/terms_email_jobs",
} as const

export type TermsVersionRecord = {
  version: string
  isMajor: boolean
  whatChanged: string[]
  publishedBy: string | null
}

export function parseTermsVersionRecord(
  raw: Record<string, unknown> | undefined,
  versionFromPath: string
): TermsVersionRecord | null {
  if (!raw) {
    return null
  }

  const versionRaw = typeof raw.version === "string" ? raw.version.trim() : ""
  const version = versionRaw.length > 0 ? versionRaw : versionFromPath.trim()
  if (!version) {
    return null
  }

  const isMajor = raw.isMajor === true
  const publishedBy = typeof raw.publishedBy === "string" ? raw.publishedBy.trim() || null : null

  const whatChangedRaw = Array.isArray(raw.whatChanged) ? raw.whatChanged : []
  const whatChanged = whatChangedRaw
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0)

  return {
    version,
    isMajor,
    whatChanged,
    publishedBy,
  }
}

