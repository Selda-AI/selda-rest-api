/**
 * Push a lead into Selda from any Node backend. No SDK, no dependencies.
 *
 *   SELDA_API_KEY=sk_live_... SELDA_PROJECT_ID=... node push-lead.mjs
 */

const API = "https://api.selda.ai";

async function selda(path, fn, args) {
  const res = await fetch(`${API}/mcp/${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.SELDA_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ fn, args }),
  });
  const body = await res.json();
  // Selda answers a refusal with a reason rather than a bare status. Read it: "wait a moment"
  // and "this address asked us to stop" are different problems and only one is worth retrying.
  // The `code` is what you branch on; the `message` is written for a person to read.
  if (!res.ok || body?.error) {
    const e = body?.error ?? {};
    throw new Error(`${e.code ?? res.status}: ${e.message ?? JSON.stringify(body)} (${e.request_id ?? "no request id"})`);
  }
  return body.value;
}

const projectId = process.env.SELDA_PROJECT_ID;

const lead = await selda("mutate", "leads.add", {
  projectId,
  company: "Acme Oy",
  email: "owner@acme.fi",
  companyDomain: "acme.fi",
  notes: "views:1200 · no_video:true",
  source: "my-app",

  // Optional: your own research. Selda writes the message FROM this instead of crawling the site,
  // and stays faithful to it. Keep it factual and the outreach stays accurate.
  // analysis: "Acme builds industrial IoT sensors. Opened a Munich office in Q1 and is hiring
  //            field engineers, a clear expansion signal to lead with.",
});

// The response always carries leadId, duplicate, blocked and reason, so the shape never varies.
// `blocked` means the address asked Selda to stop: nothing was created, and pushing it again
// will not change that.
if (lead.blocked) console.log(`Not added: ${lead.reason}`);
else console.log(lead.duplicate ? `Already known: ${lead.leadId}` : `Added: ${lead.leadId}`);

// Nothing has been sent. The lead is in Selda waiting for a campaign and a human press.
