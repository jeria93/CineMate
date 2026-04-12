export type TermsUpdateEmailPayload = {
  to: string
  version: string
  whatChanged: string[]
  termsUrl: string
}

export async function sendTermsUpdateEmail(
  payload: TermsUpdateEmailPayload
): Promise<{ providerMessageId: string }> {
  void payload
  throw new Error("sendTermsUpdateEmail not implemented")
}

