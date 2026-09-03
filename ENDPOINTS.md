<!-- GENERATED from the Selda monorepo (convex/lib/mcpRegistry.ts). Do not edit here.
     Regenerate: node scripts/generate-rest-api-repo.mjs -->

# Endpoints

71 routes across 18 groups. Every one is answered by the same
dispatcher that answers the RPC form, with the same authentication, the same scope check and
the same organisation scoping. A path cannot reach anything the RPC form refuses.

`GET` carries its arguments in the query string. Everything else takes a JSON body. Repeat a
parameter for a list: `?tags=a&tags=b`.

Full request and response schemas are in [`openapi.json`](./openapi.json).

## `brain`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/brain` | The workspace's structured knowledge: products, partners, references, company facts, and the things Selda must never say. Each item has a type, a title and a body. |
| `POST` | `/v1/brain` | Add one thing Selda should know: a product, a partner, a reference, a company fact, a note, or something it must never say. |
| `POST` | `/v1/brain/remove` | Take one Brain item back out. The human owns what Selda knows. |
| `POST` | `/v1/brain/update` | Rewrite the title and body of one Brain item. |

## `campaigns`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/campaigns` | Campaigns in a workspace. |
| `POST` | `/v1/campaigns` | Create a campaign (legacy table, not the one the app's campaign-flow UI reads). |
| `GET` | `/v1/campaigns/{campaignId}` | One campaign: status, channels, settings, leads. |
| `PATCH` | `/v1/campaigns/{campaignId}` | Change a campaign. |
| `POST` | `/v1/campaigns/{campaignId}/add-leads` | Put specific leads into a campaign. |
| `POST` | `/v1/campaigns/{campaignId}/lock-message-structure` | Lock a campaign's message structure so every locked block ships exactly as written and nothing rewrites it, or unlock it with locked: false. Sends nothing. |
| `GET` | `/v1/campaigns/{campaignId}/message-structure` | Read what a campaign's message is made of: every block, which ones ship verbatim, the instruction behind each generated one, the shape, and whether it is locked. |
| `POST` | `/v1/campaigns/{campaignId}/set-message-structure` | State what a campaign's message is made of: blocks that ship WORD FOR WORD, blocks Selda writes from an instruction you give it, the paragraph count, and what must never appear. Refuses to change a locked structure. Sends nothing. |
| `GET` | `/v1/campaigns/{campaignId}/stats` | Campaign counters: sent, delivered, opened, clicked, replied, bounced. |
| `POST` | `/v1/campaigns/add-leads-by-tag` | Put every lead carrying a tag into a campaign (legacy table). |
| `POST` | `/v1/campaigns/add-rule` | Add a campaign rule. |

## `company`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/company/lookup` | Resolve a company and return the right people to reach. Starts nothing. |

## `connectors`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/connectors` | Data connectors registered for this workspace. |
| `POST` | `/v1/connectors` | Register a data connector. |
| `DELETE` | `/v1/connectors/{connectorId}` | Remove a data connector. |
| `POST` | `/v1/connectors/{connectorId}/sync` | Pull from a connected data source. |

## `credits`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/credits/info` | Credit balance, daily free credits, usage, plan. |

## `drafts`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/drafts/remove` | Take one draft out of a run so it cannot be sent. The row stays visible with your reason and the app can put it back. Refuses a message that already went out. |
| `POST` | `/v1/drafts/update` | Rewrite the draft on one run lead. Refuses a message that already went out; never sends. |

## `engine`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/engine/start` | The full pipeline from a brief: find companies → research → fit → hook → draft. It STOPS at the company list (run status `awaiting_profile`) and waits for a person to confirm the companies and the decision-maker roles in the Selda app. Poll `runs.status` and read `awaitingHuman`. Nothing is ever sent from here. |

## `events`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/events/ingest` | Report that something happened outside Selda (a form, an analysis, an ad response). Creates the lead if new, recognises it if known, records it on the timeline, and can put it on a campaign's review list. Pass autoAdvance to have Selda write the reply from the Brain straight away and leave it in the Sales Inbox, draft.ready is published when it is there. It never sends. |

## `flows`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/flows` | The flows in a workspace: what runs when something arrives from outside, the steps in order, and whether each is switched on. Includes the workspace's flow instruction files. |
| `POST` | `/v1/flows` | Create a flow: a trigger plus the steps to run when something arrives. Off unless you say otherwise. No step can send. |
| `DELETE` | `/v1/flows/{flowId}` | Delete a flow and its run log. |
| `PATCH` | `/v1/flows/{flowId}` | Rewrite a flow's name, trigger or steps. |
| `GET` | `/v1/flows/{flowId}/runs` | What a flow actually did, run by run, step by step, including the steps that did nothing and why. |
| `POST` | `/v1/flows/{flowId}/set-enabled` | Switch a flow on or off. |
| `POST` | `/v1/flows/save-skill` | Write or rewrite an instruction file a flow step reads: how this business decides what an enquiry is. |

## `inbox`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/inbox/add-message` | Put one message into a lead's Sales Inbox thread, in either direction, even for somebody who was never in a campaign. Creates the lead if it is new. This can send nothing. |

## `knowledge`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/knowledge` | What Selda knows about your business: the prose that grounds every message. |
| `POST` | `/v1/knowledge/append` | Add to what Selda knows about your business. |
| `POST` | `/v1/knowledge/set` | Replace what Selda knows about your business. |

## `leads`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/leads` | Leads in a workspace. |
| `POST` | `/v1/leads` | Add one company/contact. Pass `analysis` with research you already did and the message is written from it instead of a fresh crawl. |
| `DELETE` | `/v1/leads/{leadId}` | Remove one lead. Deleting is the caller's act, Selda never removes a lead on its own. |
| `GET` | `/v1/leads/{leadId}` | One lead in full: research, fit, outreach angle, notes. |
| `PATCH` | `/v1/leads/{leadId}` | Edit a lead's fields, including its status. Org-scoped, so an API key can reach it. |
| `POST` | `/v1/leads/{leadId}/add-alias` | Claim another email address for a lead, so a reply from it lands in the same conversation. Also adopts that address's earlier unlinked inbound. |
| `POST` | `/v1/leads/{leadId}/add-tag` | Tag a lead. |
| `POST` | `/v1/leads/{leadId}/enrich` | Enrich one lead from a natural-language instruction. |
| `POST` | `/v1/leads/{leadId}/skip` | DELETES a lead and every message on it (legacy path, Clerk-authenticated, an API key cannot reach this; use leads.delete instead). |
| `PATCH` | `/v1/leads/{leadId}/status` | Set a lead's status (legacy path, Clerk-authenticated, an API key cannot reach this; the MCP tool uses the org-scoped leads.update). |
| `POST` | `/v1/leads/add-batch` | Add many companies/contacts in one call. |
| `POST` | `/v1/leads/delete-batch` | Remove many leads. |
| `POST` | `/v1/leads/enrich-batch` | Enrich many leads from a natural-language instruction. |
| `POST` | `/v1/leads/merge` | Merge duplicate leads. |

## `material`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/material/import` | Your prospect folder → a campaign + company list, then it stops. Uploading material is not permission to send. |

## `messages`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/messages/{messageId}/approve` | Approve a drafted message. Approval only. It does not send. |
| `GET` | `/v1/messages/by-lead` | The whole thread with one lead, sent and received. |
| `GET` | `/v1/messages/by-project` | Messages in a workspace. |
| `POST` | `/v1/messages/generate` | Draft a message for a lead. |

## `projects`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/projects` | Your workspaces. Start here. Every other fn needs a projectId. |
| `GET` | `/v1/projects/{projectId}` | One workspace in full: business context, market analysis, ICP, settings. |
| `PATCH` | `/v1/projects/{projectId}/context` | Rewrite a workspace's business context. |

## `replies`

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/v1/replies/classify` | Classify inbound replies. |
| `POST` | `/v1/replies/draft` | Write a reply draft into a lead's Sales Inbox thread. A person reviews and sends it in the app, this can send nothing. |
| `POST` | `/v1/replies/preview` | Ask how Selda would answer an enquiry, from this workspace's Brain, without creating a lead or storing a draft. Same writer the real reply uses, so tuning against this tunes the real thing. Stores nothing and sends nothing. |

## `runs`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/runs` | Every campaign run in a project, newest first, with its status. Use it to find a runId you no longer have. |
| `POST` | `/v1/runs/{runId}/archive` | Close a campaign run and take it off the active list. Keeps every contact and every message, deleting contacts stays a human act in the app. |
| `POST` | `/v1/runs/{runId}/confirm-companies` | Confirm a run's company list so Selda finds the decision-makers and drafts the messages. Spends credits. Sends nothing, the send is still a human press in the app. |
| `GET` | `/v1/runs/{runId}/leads` | The companies a run found, each with the message Selda drafted for it. Nothing is sent. |
| `POST` | `/v1/runs/{runId}/rename` | Give a campaign run a name a person would recognise. An empty name restores the derived title. |
| `GET` | `/v1/runs/{runId}/status` | Status of one campaign run: phase, companies found, contacts resolved, drafts written, errors. |
| `POST` | `/v1/runs/start-from-leads` | Start a campaign from leads already pushed in with selda_add_lead, selected by the source label you gave them. No discovery, Selda writes a message per lead from the analysis that came with it, and stops at the drafts. |

## `webhooks`

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/v1/webhooks` | Outbound webhook endpoints registered for this workspace. |
| `POST` | `/v1/webhooks` | Register an endpoint for events like reply.received. |
| `DELETE` | `/v1/webhooks/{webhookId}` | Remove a webhook endpoint. |
