export type TermsUpdateEmailPayload = {
  to: string;
  version: string;
  whatChanged: string[];
  termsUrl: string;
};

function isDryRunEnabled(): boolean {
  return (process.env.TERMS_EMAIL_DRY_RUN ?? "true").toLowerCase() !== "false";
}

function getWebhookUrl(): string | null {
  const url = (process.env.TERMS_EMAIL_WEBHOOK_URL ?? "").trim();
  return url.length > 0 ? url : null;
}

export async function sendTermsUpdateEmail(
  payload: TermsUpdateEmailPayload,
): Promise<{ providerMessageId: string }> {
  if (isDryRunEnabled()) {
    return {
      providerMessageId: `dryrun-${payload.version}-${Date.now()}`,
    };
  }

  const webhookUrl = getWebhookUrl();
  if (!webhookUrl) {
    throw new Error(
      "TERMS_EMAIL_WEBHOOK_URL is required when TERMS_EMAIL_DRY_RUN=false",
    );
  }

  const webhookToken = (process.env.TERMS_EMAIL_WEBHOOK_AUTH ?? "").trim();
  const response = await fetch(webhookUrl, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(webhookToken ? { authorization: `Bearer ${webhookToken}` } : {}),
    },
    body: JSON.stringify({
      kind: "terms_update",
      to: payload.to,
      version: payload.version,
      whatChanged: payload.whatChanged,
      termsUrl: payload.termsUrl,
    }),
  });

  if (!response.ok) {
    const body = (await response.text()).trim();
    const shortBody = body.length > 250 ? `${body.slice(0, 250)}...` : body;
    throw new Error(
      `Terms email webhook failed with status ${response.status}${
        shortBody ? ` body=${shortBody}` : ""
      }`,
    );
  }

  let providerMessageId = `webhook-${payload.version}-${Date.now()}`;
  try {
    const json = (await response.json()) as { messageId?: unknown };
    if (
      typeof json.messageId === "string" &&
      json.messageId.trim().length > 0
    ) {
      providerMessageId = json.messageId.trim();
    }
  } catch {
    // Response body is optional for this webhook contract.
  }

  return { providerMessageId };
}
