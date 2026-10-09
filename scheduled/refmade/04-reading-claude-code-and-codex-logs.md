---
title: "Reading Claude Code and Codex Session Logs: Four Traps"
published: false
description: "How Refmade tells a real request from a tool result, a fork from a sub-agent, and when claude -p ends. Four traps from reading session logs, with code."
tags:
  - claudecode
  - nodejs
  - ai
  - debugging
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/04-cover.png"
---

Claude Code writes a `turn_duration` line into the session log when an interactive request finishes. `claude -p` does not. I measured that on real logs on September 27, 2026 (Claude Code 2.1.283), and it is one of four places where reading these files differs from what a first guess would be.

This post is the technical follow-up to the last one, where I decided that Refmade, my solo-built desktop app that draws your AI sessions as an office, should read local logs instead of trusting agent reports. Refmade is independent and not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the reader at my direction, and the rules below were tuned against my own real logs. These are internal log formats that a version bump can change, so any of this can break.

## What is on disk

For Claude Code, one main session is a file like `~/.claude/projects/<project>/<session>.jsonl`. Sub-agents live under `<session>/subagents/`, each as `agent-<id>.jsonl` with a small `agent-<id>.meta.json` next to it. The meta file carries the agent type, a one-line description, `parentAgentId`, `workflowPhase`, and whether it is a fork. Workflow runs add a `journal.jsonl` per run. Codex writes `rollout-*.jsonl` under its own sessions folder, and its sub-agents point to a parent through `parent_thread_id`.

The reader follows each file from where the last read stopped, only complete lines, and picks lines by byte needles before parsing. A big user line that holds a tool result is most of a transcript's bytes, so it is never parsed; only its timestamp and `tool_use_id` are cut out. Prompts, answers, tool arguments and paths are looked at in memory for the rules and not kept. What is kept: times, the act for each tool name, agent type and one-line label, the session title and folder name, and the one-sentence result described at the end, all for the local page only.

## Trap 1: most "user" lines are not requests

A request starts at a `user` record, but a tool result is also a `user` record, and so are compaction summaries, task notifications, interrupt markers and the output of `!` shell commands. The start rule I ended up with: not meta, not a sidechain, not a tool result, not the summary written by auto-compaction, and not starting with one of a short prefix list (`<task-notification`, `<local-command`, `<system-reminder`, `[Request interrupted`, and a few more).

Slash commands and `!` commands are held back until the assistant answers. A local one like `/model` never gets an answer, so it never becomes a request. Ordinary typed prompts are not held: on real logs the first answer arrives a median of 7 seconds later, too long to leave the office blind.

A background task finishing while no request is open starts an automatic turn. The team shows as working, but the turn is not numbered and gets no card, because I did not ask for it.

## Trap 2: a fork starts with its parent's history

A fork's transcript begins with a copy of the parent's conversation. Read it naively and the fork appears to have done everything its parent did, with the parent's timestamps. The meta file holds the `toolUseId` of the call that spawned it, so the reader looks for that call inside the copy and starts counting after it.

```js
// excerpt: cli/lib/office/claude-source.mjs
const needle = Buffer.from(`"id":"${agent.forkTool}"`);
let found = false;
scanFdLines(fd, [needle], () => { found = true; }, {start: 0, completeOnly: true});
agent.copying = found ? needle : null;
```

The check only skips when the spawning call is really there, since a fork without a copy has nothing to skip. Without it, team members are counted twice.

## Trap 3: where does a request end?

Here is the order of rules, from most to least reliable.

| Session kind | How a request ends |
|---|---|
| Interactive | The next system `turn_duration` line. Failing that, a `[Request interrupted` marker. Failing that, the next request's start, using the last answer before it. |
| `claude -p` (entrypoint `sdk-cli`) | No `turn_duration`, and a Stop-hook summary only if the user has Stop hooks. So: the lead's final assistant record (`end_turn`, no tool call) or a successful `StructuredOutput` result. Provisional, because a later lead record reopens the request. |
| Nothing ends it | Closed after 30 quiet minutes, or 6 hours if the lead's last act is a question. |

The `claude -p` branch exists because the one-shot runs would otherwise sit open until the 30-minute idle rule closed them. A schema run ends at the successful `StructuredOutput` call, and workflow agents finish the same way. That is why the end is provisional: a blocking Stop hook, or the StructuredOutput reminder, can make the turn go on, and a record after the supposed end reopens the request.

Sub-agents get their own rules. An agent ends at an assistant stop, or at a successful `StructuredOutput` result. With no record for 10 minutes, its last record is its end. A record more than 30 seconds after a stop counts as a new visit, a new office agent, so the idle gap is never drawn as work.

A refused call is the small one. When I refuse a tool call on its approval card, the CLI writes my refusal as an error result. The reader ends that call's act at once instead of showing "editing a file" until the next record.

## Trap 4: the workflow journal has no clock

A workflow run's `journal.jsonl` has lines that begin `{"type":"launched"`, `"started"`, `"result"` or `"failed"`. Only `launched` and `started` are parsed. A result line holds the agent's whole output, so only the `agentId` at its head is cut out, as the signal that the agent is done. The journal has no timestamps. The run starts at the journal file's creation time (real on macOS and Windows) or at its first agent's start, whichever is earlier.

When the run is over, a `workflows/<runId>.json` file in the session folder gives the name, phase titles and duration. While it runs, the planned name and phases come from the `export const meta = {...}` literal in the Workflow call in the main transcript, scanned in its first 16 KB and read for at most 4 KB. The script is not kept.

## Nine kinds of work from tool names alone

Every observed step becomes one of nine acts, chosen by the tool's name.

| Act | Claude Code tools (examples) |
|---|---|
| read | Read, Grep, Glob, Skill, ToolSearch |
| write | Edit, Write, MultiEdit, design and media-generator MCP tools |
| run | Bash, Monitor, any unknown tool |
| web | WebSearch, WebFetch, browser and computer control |
| delegate | Agent, Task, Workflow |
| talk | SendMessage |
| ask | AskUserQuestion |
| plan | TaskCreate, TodoWrite, plan mode |
| think | no tool, text only |

Unknown tools fall back to `run`. Codex tools map to the same nine in a separate table, and an `exec` call is classified by a known tool identifier found inside its input, searched in the first 64 KB and not stored.

## What it gets wrong

A finished request is not a successful one. The office draws a card when Claude Code ends its turn, nothing more. A team in the `ask` state only means the lead's last act was a question. The app's task list says the same thing in plain words, as in the demo task below that is waiting for my answer.

![Task list of the Refmade app with a Codex task waiting for the user's answer and a step bar reading Look around, Build and fix, Waiting for my answer, Done](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/04-task-waiting.png)

*Demo data from the app's task list. The Korean reads "Waiting for an answer" and "Codex is waiting for my answer"; the step bar is "Look around > Build and fix > Waiting for my answer > Done". The task "Sort customer inquiry replies" is fake.*

Each finished request also gets a one-sentence `result`, taken from the lead's last answer and shown only on this computer's page. It is kept only when the answer is in Korean; otherwise the page writes its own sentence. AI-written identifiers sometimes leak into that sentence. And a `claude -p` or `codex exec` run is short enough that the office shows it as a resting team afterwards.

The next post covers the build process: one contract document, five builders in parallel, and one integrator. The app link comes in the last post of the series.

If you parse these files yourself, which of the four traps would you have hit first, and have you found a fifth I should handle?
