---
title: "Dual Orchestrator Bottleneck: 3 Sessions, 20 Tool Calls, Zero Lines of Code Changed"
published: true
description: "Discovered a dual-pipeline bottleneck where Claude Code ORCHESTRATION.md and OMX team_pipeline both enforce the same plan→verify loop. Diagnosed in 20 tool calls across 3 sessions without touching a single file."
tags: claudecode, ai, workflow, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-05-portfolio-site-en
---

Two orchestrators were doing the same job twice.

**TL;DR** 3 sessions. 20 tool calls. 0 lines of code changed. I traced a structural conflict between Claude Code's `ORCHESTRATION.md` and Oh My Codex's `team_pipeline`, diagnosed the root cause, and drafted the MVP package for `dentalad`'s first real customer — all without writing a single line of code.

---

A quick note on setup: I run Claude Code with a two-tier orchestrator pattern. The main Claude instance classifies tasks, dispatches subagents via the `Agent` tool, and manages state files. Subagents handle actual execution. Today's sessions exposed a problem in the orchestration layer itself.

## Two Pipelines, One Job, Zero Agreement

While auditing the `dentalad` project workflow, I found a structural collision: Claude Code's `ORCHESTRATION.md` and OMX `team_pipeline` were each independently enforcing an identical `plan → implement → verify → cross-verify` sequence.

```
Claude ORCHESTRATION.md:  plan.md → diff.patch → verifier-report.md → codex-report.md
OMX team_pipeline:         plans/ → state/ → logs/ → cross-verify
```

When a task hits both pipelines, every stage runs twice. Artifact storage splits between `current/` and `.omx/state|plans|logs/`. There's no single source of truth, and every result requires checking two locations to confirm consistency. The overhead is proportional to task frequency — trivial tasks become expensive because the orchestration overhead is constant regardless of task size.

The second problem was the classification heuristic. Even pure analysis requests — questions with no code change involved — were being promoted to `standard` complexity, which triggers a `plan-orchestrator` invocation. Zero-code analysis was being forced through a heavyweight multi-agent pipeline designed for architectural work.

## 9 Reads, 7 Bash Calls — Diagnosing Without Writing Anything

Session 1 closed at 16 tool calls. Nine `Read` calls covered four files:

- `CLAUDE.md` — Lightweight First principle and complexity classification rules
- `workflow/AGENTS.md` — subagent catalog and invocation conventions
- `.omx/README.md` — Oh My Codex team_pipeline structure
- `~/.codex/config.toml` — Codex global config

Seven `Bash` calls handled `git status`, `state.sh` helper invocations, and directory checks. No `Edit`. No `Write`. The session's entire output was understanding — reading the structure until the bottleneck became visible.

The diagnosis compressed to five findings:

1. **Dual orchestrator conflict** — two pipelines independently enforcing the same `plan → verify` flow
2. **Split artifact storage** — `current/` vs `.omx/` with no reconciliation between them
3. **Conservative task classification** — analysis and questions routed to `standard`, triggering heavy pipelines
4. **OMX `$team` / `$ultrawork` active by default** — swarm logic attaching to tasks that didn't explicitly request it
5. **Unnecessary Codex cross-verify** — external model validation loop firing on trivial tasks

The interesting thing: all five problems were traceable to the same root cause. Both orchestrators were optimized for worst-case tasks — multi-file architecture changes, breaking API integrations, security-sensitive code. That's the right design for those tasks. The failure was applying those same constraints to every task uniformly, regardless of size.

## The Rule Was Already There — It Just Wasn't Being Enforced

The fix wasn't inventing something new. `ORCHESTRATION.md` already stated the principle clearly: "don't attach a heavyweight pipeline to small tasks." The gap was enforcement.

The corrected routing:

| Complexity | Criteria | Pipeline |
|------------|----------|----------|
| `trivial` | Pure questions, no code change | Direct response, no agents |
| `simple` | Single file, ≤30 lines changed | Direct edit, fast validation |
| `standard` | 2–5 files, small feature | Checklist → implement → optional Codex |
| `major` | 6+ files, architecture/auth/payment | Full plan → verify → Codex cross-verify |

OMX `$team` and `$ultrawork` stay as explicit heavy mode. Parallel workloads and large PRD-driven builds only. Not analysis queries, not minor config changes, not single-file edits.

> More pipelines don't mean higher quality. The fastest path is the one sized to the actual task.

This is a general principle in multi-agent AI automation: the temptation is to route everything through the most rigorous pipeline because it feels safer. But rigor has overhead. When overhead is fixed and task size varies, small tasks pay a disproportionate cost. The architecture should match that cost to complexity.

## Session 2: One Tool Call

Session 2 was a single `Bash` call. Checked the current workflow state: `task_id: 20260505-052532`, stage `classified`, no artifacts in flight. That was the entire session. One of the 20 total tool calls across the day.

This is worth noting because sessions like this are easy to undercount. A one-call session that confirms system state cleanly is a good session — it means the state machine is working as intended. The alternative is a session that fires off agents to confirm something that a single status check would have settled.

## First Real Customer: Building the Dental AI MVP

Session 3 ran three `Bash` calls. The subject shifted from workflow introspection to `dentalad`'s first pilot customer — a dental clinic in Yongin, Gyeonggi Province, South Korea.

`dentalad` is a project building AI-driven dental practice marketing automation: Naver blog generation, ad performance analysis, keyword gap identification, and Korean Medical Act compliance checking. Dental advertising in South Korea has strict legal requirements — medical claims require evidence, before/after photos have specific rules, and comparative advertising is heavily regulated. Any automation layer has to be built around those constraints.

The first pilot validates the full workflow against a real clinic's needs. Public data baseline: weekday hours 09:30–18:30, Saturday 09:30–14:30. Naver appointment booking available. Services span restorative, prosthetics, orthodontics, periodontics, oral surgery, and implants.

MVP structure, sequenced from Week 1:

**A. Ad Diagnostic Report (Week 1)** — designed as a standalone, independently sellable deliverable:
- Naver Place, blog, map, and YouTube visibility audit
- Competitive comparison against five nearby clinics in the same district
- Keyword gap analysis: "Dongbaek implant", "Yongin orthodontics", "children's dentist Dongbaek"
- Korean Medical Act self-audit
- Five quick wins the clinic can act on immediately

**B. Medical Compliance Package** — prerequisite for any dental marketing automation in Korea. Document the legal requirements before generating content. Apply a compliance checklist to every output before publication.

The sequencing decision is intentional: sell the diagnostic report first, automation second. Diagnosis makes the problem visible. When the customer can see their own keyword gaps and competitor positions, the value of automated content generation stops being abstract. Week 1 builds trust through a concrete deliverable; the automation contract follows from demonstrated understanding of their specific situation.

This pattern transfers to AI automation projects generally: lead with diagnosis. The audit is the product that makes the automation product sellable. Skipping straight to "here's the AI system" asks customers to trust a solution before they've acknowledged the problem.

## The Numbers

| Item | Count |
|------|-------|
| Sessions | 3 |
| Total tool calls | 20 |
| Bash | 11 |
| Read | 9 |
| Edit / Write | 0 |
| Files modified | 0 |
| Files created | 0 |
| Total elapsed | ~3 minutes |

No code was written. Two Read-only sessions diagnosed a structural problem in a multi-agent workflow and clarified a go-to-market sequence. The sessions that produce zero diffs are sometimes the ones that produce the most clarity.

There's a meta-lesson in the bottleneck itself: the system that was over-orchestrating simple tasks was also over-complicating its own diagnosis. The fix required stepping outside the pipeline and reading it as a document, not executing it as a workflow.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
