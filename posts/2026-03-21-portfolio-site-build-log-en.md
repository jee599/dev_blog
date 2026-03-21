---
title: "55 Hours Using Claude Code to Build a Tool That Makes Claude Code Better"
published: true
description: "I forked RTK into contextzip using 62 subagents, 405 tool calls, and 55 hours. npm install went from 150 lines to 3. Here's the full build report."
tags: claudecode, rust, ai, productivity
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-21-portfolio-site-en
---

150 lines of `npm install` output. 300 lines of Docker logs. 80 lines of Rust build errors.

All of it filling Claude's context window — which means less room for the code that actually matters.

If you've ever noticed Claude "forgetting" earlier decisions in a long session, this is usually why. It's not the model getting dumber. It's the context window getting noisier. Terminal output is verbose by design. AI context windows are finite by design. These two facts combine badly.

So I built a fix: `contextzip`, a CLI that automatically compresses tool output before it reaches the model. And I built it with Claude Code. The irony is intentional.

**TL;DR**: Forked [RTK](https://github.com/rtk-ai/rtk) into contextzip. 62 subagent calls, 405 tool calls, 55 hours total. `npm install` output: 150 lines → 3. `cargo build` error output: 80 lines → 5 essential ones. Published to npm. The loop: Claude Code builds the tool that makes Claude Code better.


## Three Questions Before a Single Line of Code

The starting point was [RTK](https://github.com/rtk-ai/rtk) — an open-source CLI output compression tool built specifically for Claude Code. The plan was straightforward: fork it, rename everything to `contextzip`, publish it.

I dropped the spec file into Claude. Instead of immediately starting, a brainstorming skill triggered. Claude asked three questions before writing any code.

"The repo is `tokenzip` in the spec — what should the binary name be?"

"Are you forking RTK's source, or using it as a dependency?"

"One continuous session, or weekly validation gates?"

Left to myself, I would have started coding and hit these decisions mid-implementation. That's the most expensive time to make them — you're already deep in a branch of work that might need to unravel.

The answers: binary/repo/crate all named `contextzip`, full source fork, weekly validation gates.

Three minutes of questions. Fifty-five hours of direction set.

This is the part of the Claude Code workflow that most build logs skip. The brainstorming phase doesn't ask "how should we implement this?" It asks "what do you need to decide first?" The upstream decision quality determines everything downstream.

After brainstorming came planning: Week 1 through Week 3, 16 tasks total. Each task had specific files to modify, a verification method, and an expected commit message. Not milestone labels — concrete, checkable units.

One prompt built the weekly gate structure: "Validate and confirm before moving to the next week."

That constraint created automatic quality checkpoints at zero overhead.


## 62 Agents Working While I Made Decisions

With a plan in place, tasks started distributing to parallel agents.

Here's what the actual execution looked like: Task 4 (update LICENSE with RTK attribution), Task 6 (write install.sh), and Task 7 (set up GitHub Actions CI/CD) started simultaneously. Each agent reported completion. Claude queued the next batch. Any tasks without file conflicts ran in parallel.

Task 4 — updating the LICENSE file with proper RTK attribution — took the agent 15 minutes. If I'd done it manually: find the right file, read RTK's original license, decide attribution format, write it, commit. Realistically an hour.

Full session stats: `Agent` tool invoked 62 times. `Bash` ran 176 times (builds, tests, verification — agents implement, Claude runs and checks). `Read` 37 times, `Edit` 28 times. My own prompts across the entire 55-hour session: roughly 80.

My role shifted from implementer to decision-maker. "Is the naming consistent everywhere?" "Move to Week 2." "Cold audit everything before release." The decisions I was making were higher-order. The volume of my work didn't go down — the character of it changed.


## The Bug That Static Analysis Would Have Missed

The RTK → contextzip rename seemed complete. Late in Week 3, a QA agent ran the binary directly and inspected the actual output.

```
contextzip 0.1.0 (based on rtk 0.30.1)
```

Binary name: updated. Version string: still `rtk`, hardcoded in the version formatting logic. Not in an obvious location — grep with the wrong query wouldn't find it.

This is the core reason to have a QA agent that *executes* things, separate from review agents that *read* things. Code review would have missed this. Running the binary caught it.

Two other bugs surfaced the same way. Java stack traces were producing negative savings — the compressed output was longer than the input. The regex was too aggressive, collapsing both framework boilerplate and core application lines, stripping more than it should. Rust panic parsing had a parallel issue: only the standard panic format was handled, missing variants that include thread names in the output.

The prompt that surfaced all three: "What did you do here? Is everything actually working?"

That's a different question from "what did you implement?" One asks for a feature list. The other asks for evidence that the features work. QA quality comes from which question you ask.


## Four Simultaneous Audits

Near the end of implementation, I wanted a hard evaluation.

"Give me an objective assessment of everything. Code, features, all of it. Be brutal. Commercial-release standard."

Claude spawned four agents at once.

**PM agent** audited market readiness. Value proposition was unclear — "why contextzip over RTK?" had no answer in the README. RTK artifacts still visible in places. P0.

**Senior engineer agent** reviewed code quality. 1,049 tests passing, but `#[allow(dead_code)]` annotations scattered across `build_cmd.rs`, `error_cmd.rs`, and others. Technical debt to resolve before release.

**UX/README agent** found documentation mismatches. Savings percentages in the README didn't align with actual benchmark results. Conclusion: rewrite from real numbers.

**QA agent** ran end-to-end tests. That's where the `--version` string issue appeared.

Four reports arrived simultaneously. I prioritized P0 items first, dispatching fix agents in sequence.

Solo review covers 1-2 perspectives. Four simultaneous roles expose code quality, documentation accuracy, positioning, and functional correctness in one pass. The 100-test-case performance validation also happened here — agents generated test cases, ran them, aggregated results. Real benchmarks that could actually go in the README without fabrication.


## Shipping a Rust Binary via npm

Target UX: `npx contextzip` works immediately, no Rust toolchain required.

The approach: npm wrapper package. `bin/install.js` detects OS and architecture, then downloads the correct pre-built binary from GitHub Releases. Mac ARM, Mac x86, Linux. Windows was evaluated by the agent and deferred — the cross-compilation complexity wasn't justified for v1.

GitHub Actions was written by the agent from scratch. Push/PR: run tests. Release tag (`v*`): build platform-specific binaries, upload to GitHub Releases, trigger npm publish. The npm package fetches the right binary at install time.

I provided an npm token. The agent wrote the CI YAML and committed it. The full pipeline — git tag → build → release → publish — works end-to-end without me having written a single line of the workflow.

Manual path for this: half a day of CI design and debugging, minimum. One agent pass.


## Promotion Automation and Hard Stops

With the tool ready, the problem shifted to distribution.

Claude drafted Reddit posts for r/claudeai and r/rust, a Hacker News submission, a DEV.to post, and a GitHub Actions workflow for automated ongoing promotion.

The first hard wall: the Awesome Claude Code list. The agent attempted submission via `gh` CLI. Blocked immediately — the repo's CONTRIBUTING guide explicitly states "no automated submissions via gh CLI, auto-closed." The agent read the contributing rules, reported "manual submission required," and stopped.

That's the correct behavior. The alternative — retrying past a stated policy — would result in the PR being silently ignored. The agent made the right call without being told to.

X (Twitter) API restrictions blocked automation for new accounts. No workaround exists — it's a time-based restriction. Reddit new-account posting restrictions had the same effect.

The agent prepared copy-paste ready text for each platform. Manual posting became a 5-minute task. Automate what can be automated. Report what can't. Have the fallback ready. This triage happens correctly without prompting.


## Iteration After Shipping

After posting to Reddit, one piece of feedback was consistent: users wanted clearer explanation of how contextzip integrates with Claude Code hooks. The mechanism — how the hook intercepts CLI output before it reaches Claude — wasn't obvious from the README.

The agent rewrote the README to make the hook integration explicit. That file became the most-revised artifact in the project — written, reviewed, revised, reviewed again. Language translations were added in speaker-count order: Korean, Japanese, Chinese, German, French, Spanish, Portuguese, Russian.

The conclusion from this: a README is a marketing document. The single metric that matters is whether someone understands what the tool does and how to use it within 10 seconds of landing on the page. If the answer is no, the quality of the implementation is irrelevant.


## What the 55-Hour Session Actually Looks Like

A few patterns that repeated and are worth capturing:

**Brainstorming before building surfaces decisions, not implementation steps.** The 3-minute session before any code was written shaped every subsequent hour. Decisions made early are cheap. Decisions made mid-implementation require unraveling work.

**Weekly gates prevent session drift.** "Validate before moving forward" as an explicit constraint turns a continuous session into a series of verified checkpoints. Without it, long sessions can accumulate technical debt invisibly.

**Parallel agents for non-overlapping tasks.** Any work that doesn't share files runs simultaneously. This is where the real speed multiplier comes from.

**Four-role audit over self-review.** PM, engineer, UX/docs, QA simultaneously. Each angle catches different failure modes.

**"Did it work?" is different from "what did you build?"** The second question produces feature lists. The first produces evidence of function.

Session totals: 405 tool calls, 62 agent invocations. My direct prompts: ~80. Agents accounted for most of the work.

Implementing this scope in Rust manually — 6 new modules, 1,056 tests, npm distribution pipeline, multilingual documentation — would have taken two weeks. 55 hours sounds like a lot until you look at the output list.

> Claude Code builds the tool. The tool makes Claude Code better. The loop compounds.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
