---
title: "444 Tool Calls in One Day: Claude Code Harness Audit, OpenDesign Port, and Automated Reports"
published: true
description: "16 sessions, 444 tool calls, Bash 220×, Edit 72×. Audited the entire Claude CLI harness, ported OpenDesign locally, and built PDF reports."
tags: claudecode, ai, automation, opensource
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-02-portfolio-site-en
---

444 tool calls. One day. 16 sessions with Claude Opus 4.8, 220 Bash invocations, 72 Edit calls. The output wasn't a feature — it was a redesign of how Claude Code itself operates.

**TL;DR** — Audited `~/.claude/` end-to-end, found 9 hook scripts that weren't registered anywhere, and purged 8 dormant hooks. Realigned the entire harness to Opus 4.8. Ported the OpenDesign engine from claude.ai/design as a local skill so every design request automatically routes through the OD loop without explicit invocation.

## The Harness Audit: 9 Hook Scripts That Did Nothing

Session 11 was the longest — roughly 17 hours, 81 tool calls. It started with one question: "Check what tools are actually active right now."

I ran the `harness-audit` skill and started pulling `~/.claude/` state in parallel. The first `jq` call against `settings.json` failed immediately. No `hooks` key at all. Nine hook scripts existed on disk; none of them were registered.

```bash
cat ~/.claude/settings.json | jq '.enabledPlugins, (.hooks | keys)'
# null | keys → TypeError
```

Tracing the root cause: registration paths were scattered between `settings.json` and `settings.local.json`. Eight hooks were sitting dormant with no active registration. Three symbolic links were broken. Purged them all and rebuilt from a clean baseline.

> A hook file on disk without an entry in `settings.json` is not a hook — it's just a file.

This is a class of failure that's invisible until you audit. The hooks appeared to exist. They were in the right directory. But Claude Code never loaded them because the registration entries weren't where they needed to be. If you're building a multi-hook Claude Code harness, this is the first thing to verify.

After the cleanup, I unified all agents on Opus 4.8. `claude-fast`, `claude-work`, `claude-review`, `claude-heavy` — updated all four wrapper model configs in one pass, and fixed a latency bottleneck in the `codex-cross-verify` pipeline.

## Porting OpenDesign: Running claude.ai/design Without the Browser

Session 14 started with: "OpenDesign is great. Can every design request automatically go through that route?"

claude.ai/design is Anthropic's design loop, launched April 2026. The flow: `discovery questions → direction selection → sandbox → 5-dimension self-review`. The open-source OpenDesign repo ships an `od mcp` CLI — making a local Claude Code port straightforward.

The first step was reading the engine prompts directly: `reference/charter.md` and `reference/directions.md`. These contain the RULE 1/2/3 discovery flow, 5 visual directions with OKLch palettes, and 5-dimension review criteria that the web UI runs. I mapped the web-native `<question-form>` and `<artifact>` rendering to terminal-native `AskUserQuestion` calls.

Output files created:

```
~/.claude/skills/open-design/SKILL.md          # the OD route skill
~/.claude/skills/open-design/reference/charter.md
~/.claude/skills/open-design/reference/directions.md
~/.claude/hooks/design-router.sh               # UserPromptSubmit hook
```

Now when keywords like "design", "prototype", "mockup", "landing", "dashboard", or "redesign" appear in a prompt, the hook intercepts and routes to OD automatically — no explicit `/open-design` invocation needed.

The porting was faster than expected. If a cloud service publishes its engine prompts, local porting is essentially a translation exercise: web UI primitives → terminal primitives, same logic. The OD repo's openness made a full day's work happen in one session.

## The Report Project: 7 Sessions, Two PDFs, Multiple Rendering Surprises

Across sessions 6–16, I built two versions of an online visibility diagnostic report for small business owners: a free diagnostic and a paid deliverable sample. The kind of report that shows up as a lead magnet or a client deliverable in a digital marketing workflow.

The iteration sequence:

1. **Session 6** — Design direction research. Audited HubSpot Website Grader, SEMrush Site Audit, and Toss's credit score UX as structural references for what a good diagnostic report feels like
2. **Session 7** — Content structure HTML/PDF mockup. Chrome headless PDF generation pipeline
3. **Sessions 8–9** — Paid deliverable sample. Optimized for "ready to hand to a client" format
4. **Session 10** — OpenDesign-style redesign. Chose **ink minimal** direction: `oklch(98.6% 0.005 95)` background, `oklch(23% 0.018 260)` ink
5. **Sessions 13, 15, 16** — Codex cross-review feedback fixes

Two blocking bugs surfaced in Codex review:

**Bug 1**: In the free PDF, a `.cov` block with `break-inside: avoid` was clipping the last table row. The cell was there — just rendered off-page. Fixed by adjusting page break behavior for the entire containing section.

**Bug 2**: In the paid PDF, a label was rendering as `Why we changed thisprevious` — two strings concatenated without a separator character. Fixed with a one-character patch, but it required reading the generated HTML output carefully rather than trusting the source template.

The lesson that cost the most time came from Chrome headless PDF behavior: **it only applies `@media print` styles, not `@media screen` or default styles that happen to look correct on screen**. A layout that looked clean in the browser rendered completely differently in the PDF output. After discovering this, I added `pdfinfo` and `pdftotext` verification to the end of every PDF generation run.

```bash
# verify the output before calling it done
pdfinfo output.pdf
pdftotext output.pdf - | head -50
```

## Why Codex Cross-Review Is Worth the Extra Step

In session 13, the Codex independent review returned `VERDICT: request-changes`. The setup: Claude builds, Codex reviews read-only with no shared build context.

This pattern works because self-review from within the same context creates structural blind spots. The author of a piece of code saw it work on their machine. They internalized the intended behavior. When they re-read the same code, they read what they meant to write, not what's actually there. Codex, running with no session history, reads what's actually there.

> It's not that Claude is wrong. It's that the same model checking its own output in the same session is structurally limited. A second reader with fresh context catches what the first one normalizes away.

This applies beyond AI. It's why code review exists, why editors exist, why "does this make sense to someone who wasn't in the room?" is such a valuable question. The multi-agent pattern just makes it automatable.

The PDF rendering bugs are a good example: I saw the layout on screen, it looked correct, I shipped it. Codex looked at the same HTML with fresh eyes and flagged the cut-off row and the concatenated label. Neither was visible on screen. Both mattered in the actual output.

## By the Numbers

| Metric | Count |
|---|---|
| Total sessions | 16 |
| Total tool calls | 444 |
| Bash | 220 |
| Read | 73 |
| Edit | 72 |
| Write | 19 |
| WebSearch | 15 |
| Files modified | 18 |
| Files created | 18 |
| Longest session | Session 11 (~17 hours, 81 tool calls) |

220 Bash calls in one day is a lot. It's also roughly what Claude Code looks like when it's doing real infrastructure work — verifying state, running checks, confirming outputs — rather than just editing files.

## What I'd Do Differently

**On the harness audit**: run this quarterly, not when something breaks. The `settings.json` / `settings.local.json` split is a known footgun. Any hook added to a config file other than the one Claude Code reads first silently does nothing.

**On PDF generation**: always prototype with `@media print` from the start. Screen layout and print layout are different CSS contexts. Don't build the whole thing in screen mode and then try to adapt it — build print-first if the output is PDF.

**On cross-review**: the Codex pass added roughly 2 extra sessions of iteration, but it caught two bugs that would have shipped to clients. The ROI is obvious in retrospect. Running it only on final deliverables, not intermediate drafts, keeps the overhead manageable.

## What's Still Rough

The `design-router.sh` hook occasionally intercepts non-visual tasks — API design sessions, database schema discussions — because keyword matching on "design" is too coarse. Routing a DB schema conversation into the OpenDesign flow creates noise. A more precise intent classifier (looking at full sentence context, not just keyword presence) is next on the list.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
