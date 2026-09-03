#!/usr/bin/env bash
# Tell Selda something happened outside it: a form was submitted, a trial started, a report was
# generated. One call. Selda works out whether this is a new person or somebody it already knows,
# and records it on the right lead.
#
# `autoAdvance: true` makes Selda write the reply from your Brain and leave it in the Sales Inbox.
# It spends credits and it NEVER sends. Leave it out and the lead is simply stored.
#
#   SELDA_API_KEY=sk_live_... SELDA_PROJECT_ID=... ./ingest-event.sh
#
# Needs the Selda Inbound add-on on a live key. Free on a test key.
set -euo pipefail

: "${SELDA_API_KEY:?set SELDA_API_KEY}"
: "${SELDA_PROJECT_ID:?set SELDA_PROJECT_ID}"

curl -sS -X POST https://api.selda.ai/mcp/mutate \
  -H "Authorization: Bearer $SELDA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "fn": "events.ingest",
    "args": {
      "projectId": "'"$SELDA_PROJECT_ID"'",
      "type": "form_submitted",
      "identity": {
        "email": "matti@yritys.fi",
        "name": "Matti Meikalainen",
        "company": "Yritys Oy"
      },
      "payload": { "form": "contact", "message": "Mita maksaa?" },
      "source": "yoursite.com",
      "idempotencyKey": "contact-matti@yritys.fi-2026-08-21",
      "autoAdvance": true
    }
  }'

# The `idempotencyKey` is what makes a retry safe: the same key replays instead of creating a
# second lead. Use something derived from the submission, not a random value.
