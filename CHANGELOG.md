# Changelog

Changes to the Selda REST API. An integration that breaks silently is worse than one that breaks
loudly, so anything that can break yours is recorded here.

`GET https://api.selda.ai/mcp/capabilities` is always the authority on what exists right now. This
file tells you what moved.

## 2026-09-15

**A picture can go out with a message, and it can be a different picture per lead.**
`POST /v1/leads`, `POST /v1/leads/batch` and `POST /v1/events/ingest` take `mediaImageUrl` and
`mediaLinkUrl` (plus `mediaAlt` and `mediaWidth`). The picture is written into that lead's draft
when the message is composed, so a human sees it on the approval screen before anything is sent; a
picture on the lead beats one set on the whole campaign.

Public `https` only. A `data:` base64 address is refused, and the response says so rather than
failing silently: Gmail shows no `data:` image in an email body at all, and the size base64 adds
truncates the message near 102 kB. An address that cannot be used never costs you the lead, the
lead is created and the response names what was dropped in `mediaRejected`.

`POST /v1/drafts/attach` and `POST /v1/runs/attach` take `linksTo` per file, so the ready-made
markdown snippet in the response comes back as a picture wrapped in a link instead of a bare
picture you would have to wrap yourself.

**Seven routes that existed and were not written down here.** The attachment surface
(`/v1/drafts/attach`, `/v1/drafts/attachments`, `/v1/drafts/detach`, `/v1/runs/attach`,
`/v1/runs/detach`) and signals (`/v1/signals/list`, `/v1/signals/start-campaign`). Nothing about
them changed; this file and `openapi.json` had gone stale, which is the failure the generator
exists to prevent, so the whole document is regenerated from the registry again. `GET /v1/runs`
also documents `includeArchived`, and `POST /v1/brain` documents the `writing_rule` type.

## 2026-09-03

**First publication.** The API itself is not new: the RPC form
(`POST /mcp/query|mutate|run` with `{ fn, args }`) has been serving for months and is unchanged.
What is new is that it is written down in one place, with the REST paths and an OpenAPI document
generated from the same registry the endpoints dispatch from.

**Fixed: every `GET` on a `/v1/` path returned `400`.** The edge proxy in front of
`api.selda.ai` forwarded a `host` query parameter that the platform's own host-matching rewrite had
appended, and the dispatcher refused it as an unknown argument. `POST` was unaffected, because its
arguments come from the JSON body, so the facade looked half alive rather than broken.
Authentication was never bypassed: the request failed one step later, in argument validation.
