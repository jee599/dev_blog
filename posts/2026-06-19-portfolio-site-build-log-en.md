---
title: "Claude Code, 939 Tool Calls Later: 37-Agent Security Audit, Payment Stack, and a Bot That Never Existed"
published: true
description: "9 sessions, 939 tool calls, 37 parallel agents. A Twitter bot that lived only in local memory, a full security audit, and a payment integration full of detours."
tags: claudecode, webdev, ai, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-19-portfolio-site-en
---

I thought I had shipped a Twitter bot. I hadn't committed a single line to git.

That's the kind of gap that only shows up when you ask Claude Code to actually run something in production. Over two days — 9 sessions, 939+ tool calls — three projects ran in parallel: the saju (Korean astrology) X bot, Preterview (an AI mock interview product), and a dental marketing side project. Each one surfaced something different about how Claude Code changes the shape of work.

**TL;DR**: The saju X bot "existed" only in local memory — no commits, no deploy, no API keys registered. Preterview got a 37-agent parallel security audit, a full repository rename from `coffeechat`, and a working payment system, all within one day.

## The Bot That Never Made It to Git

On June 17, I asked Claude Code to do a live post from the saju project's X auto-posting system. The response was disorienting.

```bash
git ls-files apps/web/lib/xbot/
# → (empty)
```

Production endpoint `/api/cron/x-post` returned **HTTP 404**. The bot had been built locally on June 15, but nothing had been committed. No deploy. No X API keys registered anywhere. The cron job was firing every 6 hours and producing exactly zero tweets.

One session fixed it: diagnose, commit, register Vercel environment variables (58 Bash calls, 9 Edit calls). Then the next session looked at actual output — and the tweets read like AI wrote them. Phrases like "This tweet resonates deeply" leaked through. That's the kind of meta-commentary that makes real users cringe.

Fixed `voices.ts` and `cohorts.ts` to add a banned-word list and reset the persona to "a sharp friend who actually knows saju" — not a content marketing account. Republished.

The lesson here isn't a Claude Code limitation. It's that "local done" and "shipped" are completely different states, and AI tools are good at blurring that line if you don't verify against a real environment. Build velocity and verified-shipped velocity are different numbers.

## 37 Agents Audited the Entire Codebase in One Session

The highlight of this two-day stretch was a parallel multi-agent security audit of the Preterview codebase. Seven dimensions ran as independent agents simultaneously:

- Security vulnerabilities
- Resume validation logic
- Portfolio assessment accuracy
- Interview realism
- Report accuracy
- Report design quality
- Token efficiency

37 agents total. One session. The raw numbers: Edit ×139, Read ×78, Bash ×66 — 357 tool calls from a single context window.

What made this worth doing: **adversarial verification**. Two of the initial findings were rejected at the verify stage — a separate agent was prompted to actually refute each claim by checking it against the real code. Without that pass, those false positives would have made it into the fix queue. Finding agents and refuting agents are different agents; that separation is what makes the pattern reliable.

The confirmed high-severity bugs went straight into fixes:

- **PayPal amount tampering** — client-controlled price was being trusted server-side without re-verification against the order record.
- **Admin IDOR** — an admin endpoint was accessible with a predictable user ID, no ownership check.
- **Rate limit DB migration** — `ratelimit-db.ts` created fresh to fix a schema mismatch that let burst requests slip through.
- **Interview state machine reset** — users who completed one interview couldn't start a second. The client-side state machine never reset the `completed` flag. This one had been sitting unnoticed.

The multi-agent workflow pattern works well for audits because each dimension is genuinely independent — no cross-dimension dependency that needs a synchronization barrier. Fan out, adversarially verify, synthesize confirmed findings, fix. The main context window stays light while the agents return only their results.

## coffeechat → preterview: When the CLI Doesn't Have the Command You Need

Session 8: "rename the repo and everything git-related to preterview."

Package names and branding were already updated to `preterview`. What remained was the repository identifier — GitHub repo name, Vercel project name, and local git remote URL.

The GitHub rename was straightforward via `gh api`. Updating `.vercel/project.json` was a one-liner. The problem: Vercel CLI has no `rename` command. So we hit the REST API directly:

```bash
curl -X PATCH "https://api.vercel.com/v9/projects/coffeechat" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"preterview"}'
```

The token lived only inside a subshell variable and never appeared in terminal output. After the rename, `git ls-remote` confirmed the new remote connection before anything else touched it.

This is one of those cases where the gap between "what the CLI exposes" and "what the API supports" matters. Claude Code found the correct endpoint and formed the right request on the first try.

## Building a Payment Stack: Three Providers, Two Dead Ends

Payment integration had the most detours.

**KakaoPay** requires merchant verification before you can process anything. Applied for review — and a workflow audit immediately flagged that the app had none of the legally required pages for Korean e-commerce: no refund policy, no terms of service, no privacy policy. 12 required items under Korean e-commerce law. Most were missing.

Three legal pages generated and wired in:

```
app/[locale]/terms/page.tsx
app/[locale]/refund/page.tsx
app/[locale]/privacy/page.tsx
```

Business registration number added to the footer. This is the kind of compliance gap that's easy to miss when moving fast — the audit catches it before users do.

**Toss Payments** had a fee structure that was too high for the current stage. Moved on.

**Payapp** ended up being the choice. Created `lib/payments/payapp.ts`, wired it to the pricing page.

One clean addition: Korean users see KakaoPay and Naver Pay options, everyone else sees the standard flow. Cloudflare handles geo-detection:

```typescript
// lib/geo.ts
export function getCountry(req: Request): string {
  return req.headers.get('cf-ipcountry') ?? 'US'
}
```

No IP geolocation library, no external service call. The header is already present from Cloudflare's edge.

## The Numbers

| Metric | Count |
|---|---|
| Sessions | 9 (June 17–18) |
| Total tool calls | 939+ |
| Workflow agents (security audit) | 37 |
| Workflow agents (GTM research) | 24 |
| Files modified | 50+ |
| Files created | 20+ |

Session 5 alone: 357 tool calls, Edit ×139. At that scale, context pressure becomes real. The workflow fan-out pattern addresses this: the main context stays light while agents return only results. For large-scale audit work over an unknown-size codebase, this is the right shape.

The saju bot incident is a useful data point for anyone building with Claude Code at speed. The tool makes it easy to move fast locally. Verified-shipped is a separate discipline — checking actual production state, not just local state, before declaring done. That check is still on you.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
