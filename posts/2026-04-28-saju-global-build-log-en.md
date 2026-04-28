---
title: "One Expired API Key Took Down 8 Language Markets — saju_global Incident Postmortem"
published: true
description: "An external API key silently expired on saju_global. No code changed, no deploy failed — one stale env var killed all 8 language markets. The real problem was detection lag."
tags: claudecode, debugging, devops, production
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-04-28-saju_global-en
---

No code changed. No deploy failed. One expired API key, and eight language markets went dark simultaneously.

**TL;DR** An external service API key was silently invalidated on saju_global. Fixed by rotating the env var and force-redeploying. The real problem wasn't the outage itself — it was finding out from a user report.

## The Three Words That Started It

`Invalid API key` — sitting right there in the logs. Looks harmless. But in saju_global's architecture, a single `401` from an external dependency cascades into a full service halt.

saju_global currently serves `ko`, `en`, `ja`, `zh`, `hi`, `th`, `id`, `vi` — eight language markets running concurrently. The LLM interpretation engine, the payment module, and i18n translation validation all depend on external APIs. Any one of them going down means users get nothing. No saju reading. Just silence.

The first signal came from a user report. That's the part worth fixing.

## API Keys Die Without Warning

External service API keys don't send you a calendar invite before they expire. The provider rotates keys, usage limits get hit, a billing payment fails and the account locks — and your production service breaks with zero code changes on your end.

Root cause analysis was straightforward. Follow the stack trace to find which module threw the `401`. It was the external API client. Check that service's dashboard: key status showed expired or invalidated.

That's it. That's the whole investigation.

## The Recovery

```bash
# Check current production env vars
vercel env ls --environment=production

# Confirmed the key was expired
# Generate a new key from the provider dashboard
# Rotate the env var
vercel env add EXTERNAL_API_KEY production
```

One thing that's easy to forget: rotating an env var doesn't apply automatically. Both Cloudflare Pages and Vercel require a new build to pick up the change.

```bash
# Force a fresh production deploy
vercel --prod --force
```

After the redeploy, hit the same endpoint directly and verify `200 OK`. When the `401` is gone, recovery is complete.

## What the Diff Actually Looked Like

| Item | Before | After |
|------|--------|-------|
| External API status | 401 Unauthorized | 200 OK |
| Service availability | Full outage (8 language markets) | Normal operation |
| Environment variable | Expired key | Newly issued key |

Commit: `3a9f7c2` — `fix: replace invalid external API key, force redeploy`

## Know Before Your Users Do

The fix was two commands and a redeploy. The problem is structural.

You can't prevent external API keys from expiring. What you can control is **whether you find out before your users do**.

Two approaches worth implementing:

**Monitor for `401` responses** on all external API calls and fire an immediate alert. Sentry works. A simple health check cron job works. The bar here is low — you just need something that doesn't require a user to tell you your service is broken.

**Put expiration dates in the calendar.** If the API key has a known expiration date, add a reminder. If it doesn't, build a quarterly rotation check into your routine. Manual, but it closes the gap.

## Takeaway

The code wasn't wrong. The environment changed underneath it. The more external dependencies a service runs — and saju_global runs LLM, payments, and multilingual infrastructure simultaneously — the more a single expired key can take everything down.

For any service with multiple external API dependencies, this class of failure is inevitable. Fast detection and fast rotation are the baseline. The next step is building a system where you're never the last person to know your service is broken.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
