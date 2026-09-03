# Changelog

Changes to the Selda REST API. An integration that breaks silently is worse than one that breaks
loudly, so anything that can break yours is recorded here.

`GET https://api.selda.ai/mcp/capabilities` is always the authority on what exists right now. This
file tells you what moved.

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
