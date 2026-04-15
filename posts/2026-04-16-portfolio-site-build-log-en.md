---
title: "4 Sessions, 280 Tool Calls: Using Claude Code Beyond Coding"
published: true
description: "280 tool calls across 4 sessions: payment contract review, 288 SEO pages generated, and an image bug that wasn't a bug."
tags: claudecode, ai, productivity, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-16-portfolio-site-en
---

280 tool calls. 4 sessions. Bash 159 times, Read 42, Agent 19. And none of it was what most people think Claude Code is for.

This week: draft a payment processor contract review reply, auto-generate 288 SEO landing pages, debug a UI issue that turned out to be a missing type field from the start. One session ended in 7 tool calls because the environment wasn't set up right. Claude Code is only as useful as the context you give it — and the permissions you grant.

**TL;DR** Claude Code handles business admin work, not just code. Subagents keep the main context clean. Missing system permissions kill sessions faster than bad prompts.

## Claude Drafted the Payment Processor Contract Reply

Session 1 wasn't a coding session. Toss Payments (Korea's Stripe equivalent) sent a contract review email asking for business info, refund policy, and product pricing. The prompt was minimal:

```
접근해줘 (give me access to the coffeechat project)
```

Then I pasted the email. Claude read `/Users/jidong/projects/coffeechat/`, identified the stack (Next.js 16 + Supabase + Toss Payments), price structure, and where the refund policy lived. Draft reply ready in minutes.

It didn't stop there. When it found the business registration number field blank in `site-config.ts`, it added a conditional render to hide the number until it's filled — without me asking. Then it updated `Footer.tsx` to include a business address and phone number formatted to card issuer audit standards.

I never said "fix the footer." Claude read the context, identified what a payment processor would flag, and moved first.

Bash 42, Read 16, Edit 5. 27 minutes total.

## Without Browser Permissions, Claude Is Flying Blind

Session 2 was a dead end. I asked Claude to review the spoonai mobile design. It couldn't.

The `computer-use` tool was available, but macOS Accessibility and Screen Recording permissions weren't granted. Chrome MCP wasn't installed in this session. `WebFetch` converts HTML to Markdown — it doesn't render real layout. When `computer-use` can't see the screen, you're left with two options: grant the system permissions, or manually screenshot and paste.

7 tool calls. Session over.

The lesson here isn't about Claude. It's about environment setup. A capable model running without system access is still running blind. The ceiling on what Claude Code can do in a session is defined before the first prompt — by what you've installed and what permissions you've granted.

## 288 SEO Pages, Distributed Across Subagents

Session 3 was the week's main event. Goal: implement 288 zodiac compatibility SEO landing pages for a side project called `saju_global`. Bash 111, Read 20, Agent 17, TaskCreate 7, TaskUpdate 14. 182 total tool calls.

### Planning First

The `writing-plans` skill ran against the spec at `docs/superpowers/specs/2026-04-09-seo-compatibility-pages-design.md` and produced a structured implementation plan saved to:

```
docs/superpowers/plans/2026-04-10-seo-compatibility-pages.md
```

### Subagent-Driven Execution

Then `subagent-driven-development` kicked in. Each independent task dispatched to its own subagent. After each task completed: spec compliance review → code quality review. Two-pass verification, every time.

This is the part most people skip. Reviews aren't a formality — they catch the kind of drift that accumulates when you're moving fast. Running them as separate agents means the main thread doesn't get cluttered with verification noise.

### Background Content Generation

288 pages need 288 pieces of content. That ran in the background:

```bash
nohup npx tsx scripts/generate-compat-content.ts > /tmp/compat-gen.log 2>&1 &
```

While the script ran, the main thread kept working on other things. When I asked "how's it going?", Claude read the log file and reported progress. No polling, no context switching. Final output: `apps/web/data/zodiac-compat-content.json`.

### Why Subagents Matter for Scale

The subagent pattern's core value isn't parallelism — it's context hygiene. File exploration, implementation, and verification each run in isolated agents. The main thread only sees summaries. You're not burning tokens on 300-line grep outputs or intermediate file reads.

For a task this size, that's the difference between a coherent session and one where Claude loses track of what it was doing.

## The Archive Images Were Never There

Session 4. Images weren't showing in the spoonai archive UI. Looked like a rendering bug. It wasn't.

Read and Grep into the codebase. `ArchiveEntry` in `lib/types.ts` had no `image` field defined. The `getArchiveEntries()` function was explicitly dropping `meta.image` and only passing through `date`, `title`, and `summary`. `ArchiveList.tsx` rendered text-only cards with no thumbnail slot.

The code was never built to show images. "Images not showing" was the wrong framing — the right framing was "the data model never included images."

Bash 6, Read 6, WebFetch 2, Grep 1. 1 hour 39 minutes to reach that conclusion.

This is one of the more useful things Claude Code does: it doesn't just confirm your hypothesis. It reads the actual code and tells you when the premise is wrong.

## Week in Numbers

| Session | Work | Tool calls | Time |
|---------|------|-----------|------|
| 1 | Payment contract reply + footer fix | 73 | 27 min |
| 2 | Mobile design review attempt | 7 | — |
| 3 | 288 SEO pages: plan + generate | 182 | 105h cumulative |
| 4 | Archive image diagnosis | 16 | 1h 39min |

**Total: 278 tool calls across 4 sessions**

## What This Week Proved

Claude Code used only for coding is Claude Code at half capacity.

The contract reply session saved at least two hours of context-switching: reading the codebase, re-reading the email, matching business details to what the payment processor needed. Claude did that in one pass.

The SEO generation session would have taken days manually. With background scripts and subagent orchestration, the main effort was writing the spec and reviewing the output.

The failed design review session was a reminder that tooling setup matters as much as prompting. An hour spent on Chrome MCP installation or granting screen recording permissions pays back immediately.

The multi-agent workflow isn't a pattern you reach for on small tasks. But once you're dealing with 200+ files, background processes, and multi-pass validation, it's the only approach that keeps sessions coherent.

Give Claude the right context. Give it the right access. Then get out of the way.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
