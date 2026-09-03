"""
Push a lead into Selda from Python. Standard library only.

    SELDA_API_KEY=sk_live_... SELDA_PROJECT_ID=... python push_lead.py
"""

import json
import os
import urllib.request

API = "https://api.selda.ai"


def selda(path: str, fn: str, args: dict) -> dict:
    req = urllib.request.Request(
        f"{API}/mcp/{path}",
        data=json.dumps({"fn": fn, "args": args}).encode(),
        headers={
            "Authorization": f"Bearer {os.environ['SELDA_API_KEY']}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as res:
            return json.load(res)["value"]
    except urllib.error.HTTPError as e:
        # A refusal carries a reason. "too_many" is worth retrying in a moment; an address that
        # asked Selda to stop is not, and should not be pushed again.
        raise SystemExit(f"{e.code}: {e.read().decode()}") from e


lead = selda(
    "mutate",
    "leads.add",
    {
        "projectId": os.environ["SELDA_PROJECT_ID"],
        "company": "Acme Oy",
        "email": "owner@acme.fi",
        "companyDomain": "acme.fi",
        "source": "my-app",
        # "analysis": "Your own research. Selda writes the message from this and invents
        #              nothing beyond it.",
    },
)

print("Already known:" if lead["duplicate"] else "Added:", lead["leadId"])

# Nothing has been sent. Sending is a human press in the Selda app.
