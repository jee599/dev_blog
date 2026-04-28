---
title: "Claude Couldn't Write Its Own Logs: An Expired API Key Kills the Build Log Pipeline Twice"
published: true
description: "The saju_global build log automation ran twice on 2026-04-28, failed both times, and logged exactly zero tool calls. An expired Anthropic API key was the culprit."
tags: claudecode, automation, debugging, ai
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-04-29-saju_global-en
---

On 2026-04-28, the saju_global build log automation pipeline spun up twice. It failed both times. Combined tool calls across both sessions: **zero**.

**TL;DR** An expired `ANTHROPIC_API_KEY` prevented the Claude-powered build log pipeline from initializing at all. No files were read, no commit diffs were analyzed, no logs were written. The fix was a single environment variable replacement. This build log existing is proof the pipeline is back.

---

## Background: What Is This Pipeline?

I'm building [saju_global](https://jidonglab.com), a multilingual service powered by several AI APIs. As part of the development workflow, every Claude Code session gets automatically converted into a structured build log — a record of what was done, what changed, and why. The pipeline that generates those logs also runs on Claude API (`claude-haiku-4-5-20251001`): feed it commit diffs, get formatted build logs back.

It's a fully automated paper trail. And on 2026-04-28, the paper trail generation system itself quietly broke.

---

## When Claude Can't Write Claude's Logs

Session 1 started. It hit the Anthropic API authentication check immediately:

```
Error: Invalid API key
```

Session terminated. Zero tool calls. Zero file writes.

Session 2 started — a retry, or a second scheduled run. Same result:

```
Error: Invalid API key
```

Session terminated. Zero tool calls. Zero file writes.

Claude couldn't write Claude's logs. The `ANTHROPIC_API_KEY` environment variable had become invalid — either expired, rotated and not propagated, or invalidated by some account-level event.

There's a particular kind of irony in an AI-powered automation pipeline failing because the AI lost its credentials. The code is fine. The integration logic is fine. The API key is not fine. And that's all it takes to bring the whole thing down.

---

## What Silent Failures Look Like

When an API key expires, pipelines don't fail dramatically. There's no cascade of exceptions through your application logic. No partial state. No stack trace pointing to a specific file. The failure is fast, clean, and completely invisible unless you're actively looking for the expected output.

Here's what the failure looks like from the outside:

| Check | Status |
|---|---|
| Pipeline scheduled | ✓ |
| Pipeline started | ✓ |
| Pipeline exited | ✓ |
| Output files | None |
| Errors surfaced | None |

From the inside, `Invalid API key` surfaces on the first API call. In Claude Code's case, that's during session initialization — before any tools are called, before any files are read, before anything useful happens. The session fails at the authentication layer and exits.

For monitoring purposes, a failed Claude Code session with zero tool calls looks identical to a session that simply found nothing to do. There's nothing in the session log to differentiate "failed at auth" from "ran cleanly but had no commits to process" without examining the specific error output.

> **Zero-output success is indistinguishable from zero-output failure.**

Unless you're specifically checking whether expected output was produced, you won't know the pipeline failed until you notice the gap.

---

## The Same Root Cause, Twice, Same Day

What makes 2026-04-28 particularly notable is that the build log pipeline failure wasn't the only incident. On the same day, the saju_global *service itself* went down for the same structural reason: an external API key expired, and integrations with third-party APIs began failing across all 8 language regions the service supports.

Two separate systems. Same day. Same root cause.

The pattern both incidents share:

1. **External dependency** — Claude API, or another third-party service
2. **Authentication credential expires** — silently, at some point before the incident
3. **System attempts normal operation** — pipeline runs, service handles requests
4. **Silent failure** — nothing executes, no alert fires, no noise
5. **Manual discovery** — someone notices missing output and investigates manually

The saju_global service outage had direct user impact — 8 language regions, live traffic, degraded features. The build log pipeline failure had zero user impact — it's an internal automation tool. The severity is completely different.

The *structure* is identical.

When you see the same failure mode hit two different systems on the same calendar day, that's not bad luck. That's a systematic gap in how external credentials are managed and monitored.

---

## Why API Keys Go Invalid Quietly

Anthropic API keys don't expire on a fixed schedule by default, but there are several ways a key becomes invalid without any warning reaching your pipeline:

**Rotation without full propagation.** You rotate keys for security hygiene. You update the key in your local environment but forget to update it in Cloudflare Pages, GitHub Actions secrets, or wherever the cron job actually runs. The pipeline continues running against the old, now-invalid key.

**Account-level events.** Billing issues, plan changes, security alerts, or admin actions on a shared account can invalidate keys you didn't explicitly rotate. The Anthropic API rejects the key. Your pipeline finds out at runtime. No notification reaches you proactively.

**Configured expiry forgotten.** You set an expiration date when generating the key — good security practice — but didn't schedule a renewal reminder. The key expires on schedule. The pipeline finds out at runtime.

**Organization or workspace changes.** If the API key was scoped to a specific workspace or generated under a team member's account, organizational changes can affect key validity without touching the key directly.

In this case, the exact reason wasn't captured — the session that would have logged that context couldn't start. What's clear: the key was invalid, two runs hit the failure, and nobody found out until someone noticed the missing logs.

---

## Diagnosing and Fixing

The diagnosis is straightforward once you know to look:

```bash
# Test whether the key is actually invalid
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"ping"}]}'
```

Response from an invalid key:

```json
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "message": "invalid x-api-key"
  }
}
```

Response from a valid key:

```json
{
  "id": "msg_...",
  "type": "message",
  "role": "assistant",
  "content": [{ "type": "text", "text": "..." }]
}
```

The fix itself is a one-liner: generate a new key at `console.anthropic.com` and replace `ANTHROPIC_API_KEY` in every environment that uses it.

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

For Cloudflare Pages: update the environment variable in the Pages dashboard and trigger a new deployment. For GitHub Actions: update the secret in repository settings. No code deploy — just a config update.

**Important:** check every environment, not just the obvious one. The stale key may exist in multiple places:
- Local development `.env`
- Cloudflare Pages environment variables
- GitHub Actions secrets
- Any other CI/CD system or cron host

---

## The Commit Record

| Item | Before | After |
|---|---|---|
| `ANTHROPIC_API_KEY` | expired / invalidated | newly issued key |
| Build log pipeline | failed twice (0 tool calls) | resumed normally |
| Sessions | 2 (failed) | — |

**Commit:** `fix: replace invalid external API key`

---

## What Should Have Caught This

Three specific gaps made this failure hard to detect before multiple runs were lost:

**No pre-flight auth check.** The pipeline assumes a valid key and proceeds. A health check at startup — one that explicitly fails loudly on 401 — would surface the error immediately on the first affected run.

**No output-presence monitoring.** If the pipeline is supposed to produce a file and doesn't, that absence is detectable. A post-run check for expected output would catch zero-output failures regardless of cause — invalid key, network error, empty diff, whatever.

**No 401 alerting.** When the API returns a 401, that information should reach a human in minutes. Instead it was buried in session output that nobody reads until they go looking for missing logs.

Here's what a pre-flight auth check looks like in practice:

```typescript
import Anthropic from "@anthropic-ai/sdk";

async function verifyApiKeyBeforeRun(): Promise<void> {
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

  try {
    // Minimal request — just enough to verify auth
    await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1,
      messages: [{ role: "user", content: "ping" }],
    });
  } catch (error) {
    if (error instanceof Anthropic.AuthenticationError) {
      // Fail loud, not silent
      await sendAlert({
        severity: "critical",
        title: "Build log pipeline: API key invalid",
        message:
          "ANTHROPIC_API_KEY returned 401. Replace the key in environment settings before the next run.",
      });
      process.exit(1); // Non-zero exit surfaces as a pipeline failure in CI
    }
    throw error; // Re-throw anything that isn't an auth error
  }
}
```

`sendAlert` connects to whatever notification channel gets monitored: Slack webhook, Discord bot, PagerDuty, email. The critical design principle:

> **Fail loud, not silent.** A pipeline that exits with a clear error and fires an alert is far more useful than one that exits with zero output and zero indication that anything went wrong.

A `process.exit(1)` also matters for CI/CD systems — it causes GitHub Actions, Cloudflare Workers, and most pipeline runners to mark the run as failed, which surfaces the problem in their dashboards without relying on anyone manually checking for missing output.

---

## The Broader Pattern: External Credentials Are Invisible Dependencies

Both the saju_global service outage and the build log pipeline failure share a structural pattern that applies to any system with external API dependencies:

**External credentials are invisible until they stop working.**

When a service you own breaks, you have logs, error tracking, and alerts. When an *external* credential expires, you often have nothing — because the failure happens before your code runs.

The mental model that helps: treat API keys like infrastructure, not configuration. You wouldn't run production infrastructure without health checks. You shouldn't run production pipelines against API keys that have no validity monitoring.

Concrete approaches that prevent this class of failure:

- **Pre-flight health checks** — verify auth at pipeline startup, fail loudly on 401
- **Output-presence monitoring** — after each scheduled run, confirm expected output exists
- **Synthetic monitoring** — ping the API on a regular schedule (hourly, daily), alert on auth failures independent of actual pipeline runs
- **Rotation reminders** — when you rotate a key, schedule a reminder to verify propagation across all environments before the old key expires
- **Key expiry alerts** — if your API provider supports it, subscribe to notifications before key expiry (Anthropic Console supports this)

None of these are complex to implement. The reason they often don't exist is that key expiry happens infrequently enough that building the monitoring feels like overkill — until two systems fail on the same day for the same reason.

---

## Prevention Checklist

If you're running Claude Code pipelines or any Claude API-dependent automation:

- [ ] Pre-flight auth check at pipeline startup
- [ ] Post-run check for expected output
- [ ] Alert on non-zero exit / auth failures
- [ ] Document every environment where `ANTHROPIC_API_KEY` lives
- [ ] Set a calendar reminder when you issue a key to rotate it before expiry
- [ ] If the key is shared across environments, verify all of them after rotation

---

## What's Next

One item goes on the backlog with high priority: when `ANTHROPIC_API_KEY` returns `401`, fire an immediate alert.

The pipeline should fail loud, not quiet. A cron job that silently produces nothing is operationally equivalent to a cron job that doesn't exist — except worse, because you think it's working.

Today's log getting generated is the happy path. The goal is making the failure path equally observable.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
