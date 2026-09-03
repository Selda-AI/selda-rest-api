# Selda REST API

Push leads in, read your pipeline out, run the engine. HTTP, JSON, one bearer token.

```
https://api.selda.ai/v1/...
Authorization: Bearer sk_live_...
```

**Nothing here sends a message.** The only send in Selda is a button a person presses in the app,
and it is reachable by no key of any kind. An API key can research, write and draft; a human
approves. That is a property of the dispatch registry, not a setting, so it is not something you
can turn off or forget to turn on.

This repository is the REST API. **MCP is a different thing** and lives in
[Selda-mcp-docs](https://github.com/Selda-AI/Selda-mcp-docs): that is for driving a workspace from
Claude, ChatGPT or Cursor. Use this one when you are writing code.

## Quick start

Create a key in the app under **Settings → Apps → Selda MCP**. A free workspace mints an `sk_test_` key: the
full product in test mode, nothing sends for real. A paid workspace can mint `sk_live_`.

```bash
# 1. What can this key do? No key needed for this one.
curl -s https://api.selda.ai/mcp/capabilities | jq '.value.count'

# 2. Your workspaces. Every other call needs a projectId.
curl -s https://api.selda.ai/v1/projects \
  -H "Authorization: Bearer $SELDA_API_KEY"

# 3. Push a company you already researched. Selda writes the message FROM your text.
curl -s -X POST https://api.selda.ai/v1/leads \
  -H "Authorization: Bearer $SELDA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "projectId": "PASTE_PROJECT_ID",
    "company":   "Nordic Books Oy",
    "email":     "mika@nordicbooks.fi",
    "firstName": "Mika",
    "analysis":  "They run three shops and close the books by hand every month."
  }'
```

`analysis` is the point. Pass it and the eventual message is written from your research instead of
a fresh crawl. Anything invented in that field becomes a claim in a real message, so put facts in
it.

## Two forms of the same API

```
POST https://api.selda.ai/mcp/query     { "fn": "projects.list", "args": {} }     read
POST https://api.selda.ai/mcp/mutate    { "fn": "leads.add",     "args": {...} }  write
POST https://api.selda.ai/mcp/run       { "fn": "engine.start",  "args": {...} }  start work
```

The RPC form above and the REST paths in [ENDPOINTS.md](./ENDPOINTS.md) are the same dispatcher.
Pick either. The RPC form is one URL and one body shape, which is less to learn; the REST paths are
what an OpenAPI client generator wants. Everything under `/v1/` is the versioned seam: behaviour
changes appear there, and the unversioned paths are kept working.

## Authentication

A key is `sk_live_` or `sk_test_` plus 40 characters, sent as `Authorization: Bearer`. It is shown
once, at creation, and only a SHA-256 hash is stored.

**The key IS the workspace.** Its organisation is injected server side into every call, so you
never send an org id and cannot reach another organisation's data by asking for it. Every
underlying function re-checks ownership on top of that.

Scopes are `read`, `write` and `pipeline`, granted per key. `admin` exists for internal cross-org
tooling and cannot be self-issued, which is why it appears nowhere in this documentation.

## Errors

```json
{ "error": { "type": "authentication_error", "code": "invalid_api_key",
             "message": "Invalid or expired API key.", "request_id": "req_..." } }
```

| Status | Means |
|--------|-------|
| `400` | The arguments are wrong. The message names the parameter and what the function takes. |
| `401` | No key, or a key that is expired, revoked, or whose user or workspace is gone. |
| `403` | The key lacks the scope (`missing_scope`), or the plan does not include this function (`plan_not_eligible`), or a test key asked for something that spends real money (`live_key_required:...`). The `code` says which. |
| `404` | No such route. |
| `405` | That path exists, with a different method. |
| `429` | Over the per-key rate limit. `X-RateLimit-Limit` and `X-RateLimit-Remaining` come back on every call. |
| `500` | Ours. Quote the `request_id`. |

There is no `402`. Running out of credits is not a status of its own; it comes back from the
function that would have spent them.

Quote `request_id` when you ask about a call. It is in the body and in the `X-Request-Id` header.

## What a test key cannot do

A free `sk_test_` key reaches everything that reads data the workspace already has, and everything
that pushes your own data in. It is refused, with a reason, on anything that makes the engine
produce new contact data, spends at a paid provider, or reaches a real person. The refusal names
which of those it was, so "why not" is never a guess.

## Capabilities, live

```bash
curl -s https://api.selda.ai/mcp/capabilities
```

No key needed. It lists every function, its endpoint, its scope, whether a test key may call it and
why not when it may not. It is derived from the same tables the endpoints dispatch from, so it
cannot describe a function that does not exist. **When this repository and that endpoint disagree,
the endpoint is right.**

## Contents

| File | What |
|------|------|
| [ENDPOINTS.md](./ENDPOINTS.md) | Every route, by group |
| [openapi.json](./openapi.json) | OpenAPI 3.1.0, 62 paths. Import into Postman or a client generator. |
| [CHANGELOG.md](./CHANGELOG.md) | What moved, and when |

**Response shapes are mostly absent from the OpenAPI document, on purpose.** One operation declares
a return validator, so one has a derived shape; everywhere else `value` carries a description
saying exactly that instead of an invented object. A generated client that enforces a shape nobody
derived is worse than one that enforces nothing. Call an operation once with a test key and read
what comes back.
