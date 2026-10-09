---
title: "Wrapping Claude Code and Codex in Electron: A Stop Bug"
published: false
description: "How my Electron app drives claude -p stream-json and codex app-server, turns permission requests into plain cards, and what a nohup test file taught me."
tags:
  - electron
  - claudecode
  - ai
  - node
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/09-cover.png"
---

I pressed Stop on a task. When I looked 35 seconds later, a file in my test folder was gone.

The file was `keep.txt`, the folder was throwaway, and I had told the agent to set the trap itself: `nohup sh -c 'sleep 20; rm keep.txt' > /dev/null 2>&1 &`. Stop was supposed to end everything the task had started. It ended Claude Code, and the `rm` ran anyway. Of the bugs my end-to-end runs found in the wrapper app, this is the one that deleted a file.

This is part 9 of a series about Refmade, a desktop app I'm building alone. Refmade lets people who don't live in a terminal hand work to the Claude Code or Codex they have already installed, and shows the agents as an office you can watch. It is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction; I planned, decided and reviewed. The UI is Korean right now; that changes later in this series. This part covers the evening of September 27 through September 29, when the app went from a web dashboard to an Electron shell around two command-line tools.

## Spawn the CLI, don't call the model

A wrapper that calls the model API itself needs a key, and then it is a different product with a different bill. Refmade starts the `claude` or `codex` binary you installed, in the folder you picked, under your login. The header of the Codex runner in the current source says it plainly: the user's own binary and config are used as-is, and the app never reads auth or tokens.

Both tools turned out to have a machine-readable mode with a channel for permission questions. That channel is the whole trick.

## Claude Code: JSON lines in both directions

The runner starts one long-lived `claude -p` per task. Everything on stdin and stdout is one JSON object per line.

```
claude -p --input-format stream-json --output-format stream-json \
  --verbose --include-partial-messages --replay-user-messages \
  --permission-prompt-tool stdio
# stdin, first line:
{"type":"control_request","request_id":"init_1","request":{"subtype":"initialize","hooks":null}}
# answers to the CLI's questions reuse the question's id:
{"type":"control_response","response":{"subtype":"success","request_id":"<id>","response":{...}}}
```

`--permission-prompt-tool stdio` is what replaces the terminal prompt. When Claude Code wants to run a tool that its settings don't already allow, it sends a `can_use_tool` request on stdout. The app shows a card, waits for a click, and sends back a control response. `--replay-user-messages` makes the CLI echo each message it takes up, which is how the app knows whose turn it is when a background job finishes on its own. I pass no permission mode. Your `settings.json` rules apply, and a tool you allowed there runs without a card.

## Codex: JSON-RPC over stdio

Codex goes through `codex app-server`, newline-delimited JSON-RPC on stdio. My runner was written against the schema of Codex CLI 0.156.0.

```
 Refmade window
      |  IPC
 Refmade main process ---- JSON lines ----> claude -p            (your install, your login)
      |                 \-- JSON-RPC  ----> codex app-server     (your install, your login)
      '-- plain-words card <---- permission request
```

| | Claude Code | Codex |
|---|---|---|
| Process | `claude -p`, stream-json | `codex app-server` |
| Permission asks | `can_use_tool` control request | `item/commandExecution/requestApproval`, `item/fileChange/requestApproval`, `item/permissions/requestApproval` |
| Questions to the person | `AskUserQuestion` through the same channel | `item/tool/requestUserInput` |

A request the runner doesn't know gets a JSON-RPC error back, `-32601`, with the text "Refmade does not handle" and the method name. I would rather fail loudly on a request I don't understand than guess an answer.

## Cards in words, not command lines

A raw `rm -rf` prompt is useless to a person who has never used a shell. `main/plain.mjs` turns a request into a title, one plain sentence, a place (inside or outside the folder you picked), and chips for what changes. It is over 5,000 lines now.

For shell commands it splits on `|`, `&&`, `;`, `||` and newlines, reads each part by its first word, skips prefixes like `sudo`, `env` and `nohup`, and reads `bash -c '...'` from the inside. The sentence is always the app's own reading of the command. The AI's description is shown separately as "AI explanation", so a soft description can never hide what the command does. A program it can't read with confidence gets the `maybe` chip, and "don't ask again" is not offered for it.

![Approval card for creating a file outside the chosen folder](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/09-codex-outside-card.png)

*A Codex permission card from my Sept 29 test run, in a throwaway test folder (Korean UI). Title: "May I create a new file?" What: "Creates the file c2.txt in the w-codex-outside folder." Where, in red: "Outside the folder you picked (your user folder)". Changes: "A new file appears". Buttons: "Yes, go ahead", "No, don't", "No, do it differently".*

The two runners never answer a permission request by themselves. "Don't ask again" only forwards the CLI's own suggestion, scoped to the session. Later versions add an auto mode that answers light multiple-choice questions for you. It is not a safety guarantee, and a later post covers where I got that wrong in my own copy.

None of this is a sandbox. It is a reading of requests, and the reading can be wrong.

## The nohup bug

Claude Code 2.1.283 runs each Bash command in a detached shell of its own. When I stopped a task, the app ended the CLI and its process group, and that did not reach a process the command had pushed into the background. `nohup sh -c 'sleep 20; rm keep.txt' &` outlived the Stop button and deleted the file.

The fix is in `main/procs.mjs`, and it is a heuristic. Linux can read another process's environment, so every CLI session gets a `REFMADE_TASK` variable and leftovers are found by it. macOS `ps` will not show another process's environment. There the app looks for processes that were orphaned (parent pid 1), started while that task's CLI was running, and whose working folder is the task folder or inside it. It leaves apps and system programs alone.

Known limit, written in the file: a dev server that you or another program started in the same folder while the task ran, and left running, looks identical. On Windows the function returns an empty list. Stop ends only the CLI's own process tree there, and the public Windows build is older than the Mac one. After the fix, the same test left `keep.txt` in place 35 seconds after Stop.

![Stop card after the fix](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/09-nohup-stop-card.png)

*The same test after the fix, Sept 28, 10:05 to 10:08 PM (Korean UI). My message asks for the `nohup` command and then a `sleep 40`. The row says "Thought it through, ran 1 command on the computer, may have deleted 1 file". The status lines read "Task stopped" and "Work running in the background stopped too".*

## A race I found by launching in the wrong order

Start a task right after launching the app, and the team did not appear in the mini office within 60 seconds. If I opened the office first, it appeared in about a second. The collector's first read of the session logs takes around 4 seconds, and a session folder created during that read was never picked up. After the fix, a first task showed up in 6 seconds.

An end-to-end run against the real app found it, because the run sent a task in the first seconds after launch.

## How it was checked

Three rounds of adversarial review by separate agents went over this code. Round 1 ended with 36 fixes and round 2 with 35 more. After round 3 the app tests passed 394 of 394, three runs in a row. Those numbers say the tests agree with the code. They say nothing about whether anyone finds the app easy to use, and I haven't run a usability test with a non-developer.

The app link comes in the last post of the series.

If you wrap an agent CLI, how do you decide that a stopped session is really stopped: process-group kill, an environment tag like mine, or something else?
