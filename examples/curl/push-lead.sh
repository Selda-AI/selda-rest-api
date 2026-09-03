#!/usr/bin/env bash
# Push one lead into Selda. Selda dedupes by email, so re-running this is safe.
#
#   SELDA_API_KEY=sk_live_... SELDA_PROJECT_ID=... ./push-lead.sh
set -euo pipefail

: "${SELDA_API_KEY:?set SELDA_API_KEY}"
: "${SELDA_PROJECT_ID:?set SELDA_PROJECT_ID}"

curl -sS -X POST https://api.selda.ai/mcp/mutate \
  -H "Authorization: Bearer $SELDA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "fn": "leads.add",
    "args": {
      "projectId": "'"$SELDA_PROJECT_ID"'",
      "company": "Acme Oy",
      "email": "owner@acme.fi",
      "companyDomain": "acme.fi",
      "source": "my-app"
    }
  }'

# → { "value": { "leadId": "...", "duplicate": false } }
#
# Already researched the company yourself? Pass it as `analysis` and Selda writes the outreach
# FROM your write-up instead of crawling from scratch. It stays faithful to what you wrote and
# invents nothing beyond it.
