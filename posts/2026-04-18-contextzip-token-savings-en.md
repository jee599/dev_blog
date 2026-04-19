---
title: "66.5% of My Claude Code Tokens Were Wasted. A 200-Line Wrapper Got Them Back."
published: true
description: "I installed contextzip — a CLI proxy built on RTK — and it compressed 37.2M tokens down to 12.5M across 7,172 commands. Here's how the hook-based rewrite works and why it's invisible to the agent."
tags:
  - ai
  - claudecode
  - cli
  - productivity
series: "Claude Code Economics"
canonical_url: https://jidonglab.com/posts/2026-04-18-contextzip-en
---

66.5% of my Claude Code tokens were being spent on output I never needed to read in full. Over 7,172 commands, I watched 37.2M input tokens compress down to 12.5M, which is a number I had to re-check three times before I believed it. The piece of software responsible is 200 lines of glue sitting between my shell and the agent, and it cost me thirty seconds to install.

**TL;DR**: A thin CLI proxy called `contextzip` (built on the upstream RTK toolkit) compressed 24.7M tokens out of my Claude Code sessions across 7,172 commands by rewriting `git`, `ls`, `cat`, and `curl` output before the model ever saw it. Install it, register the hook, and run `contextzip gain` an hour later to see the receipt.

## The Receipt: 24.7M Tokens You Wouldn't Have Spent

Before I explain the mechanism, look at what it actually produced on my machine. This is raw output from `contextzip gain`, cleaned up into a stable column layout so DEV.to doesn't mangle it.

```
contextzip gain  —  lifetime stats
────────────────────────────────────────────────────
total commands processed       7,172
input tokens (pre-compress)    37,200,000
output tokens (post-compress)  12,500,000
tokens saved                   24,700,000
average compression            66.5%
average exec time / command    5m 3s
────────────────────────────────────────────────────
top wins by absolute savings
────────────────────────────────────────────────────
contextzip read                768 calls   15.3M saved   29.0% avg
contextzip ls                  2,251 calls  741.3K saved  63.5% avg
contextzip:toml ps aux         26 calls    —             98.1% avg
contextzip curl -s https://…   4 calls     —             100.0% avg
────────────────────────────────────────────────────
```

That is not a synthetic benchmark. Every number in that block is a command I actually ran against a real codebase, over real sessions, on a real Mac running zsh on darwin. 7,172 is a statistically meaningful sample size, which matters because most posts about token optimization are written after twelve runs and a vibe.

The moment I saw that `contextzip read` alone had saved 15.3M tokens, I kept scrolling the log to check I wasn't misreading a unit. I wasn't. A single subcommand across 768 invocations had saved more tokens than my entire previous month of API spend.

## Why `cat` Is a Tax You Pay Twice

Here is the contrarian claim, and I want to state it plainly: most token-saving advice is wrong because it optimizes the wrong layer. People obsess over prompt wording and system-instruction length while ignoring the fact that every `cat package-lock.json` dumps 200KB of mostly-redundant JSON straight into the agent's context window.

When Claude Code runs a shell command inside a session, the command's stdout becomes input tokens on the very next turn. You are not just paying for the bytes to exist in your terminal, you are paying for the model to ingest them. `cat` on a moderately large file is an invisible multi-thousand-token purchase, and you already hit "enter" on it.

Now double that thought. The agent reads the output, summarizes it back to you in its reply, and those summary tokens are also billed. You pay to feed the file in, then you pay for the model to narrate it back. That is the tax you pay twice, and it is the default behavior of every Claude Code session you have ever run.

RTK's contribution, which `contextzip` wraps, is lossless or near-lossless compression of that stdout before the bytes ever reach the model. Structured output (JSON, TOML, process tables, directory listings) has enormous redundancy. The toolkit strips schema repetition, collapses whitespace it can reconstruct, and returns a form the model parses just as reliably as the original.

If you're burning through Claude Code tokens without this layer, you're paying Anthropic for compression they'd happily let you skip.

## The Hook That Makes It Invisible

The cleverest part of the setup is not the compression. It is the fact that I never type `contextzip` manually, and neither does the agent.

Claude Code supports a pre-command hook that can rewrite shell invocations before they execute. `contextzip` ships with a hook config that transparently prefixes `contextzip ` onto a list of common read-only commands: `git`, `ls`, `cat`, `curl`, `ps`, `head`, `tail`, `find`, and a few others. When the agent says `git status`, the hook silently rewrites it to `contextzip git status`, the proxy runs the real `git status`, compresses the output, and returns the compressed form.

The rewrite itself costs zero tokens. It happens in the harness, not in the model, so the agent never sees the `contextzip ` prefix and never reasons about it. From Claude's perspective, it ran `git status` and got back slightly more compact output than it expected. From your bill's perspective, you just skipped a tax bracket.

This is why the approach works where earlier attempts (summarize-on-read proxies, agent-side filtering) failed. Anything that requires the model to understand the compression layer will leak tokens through the compression layer. Invisibility is the feature.

## What Compresses, What Doesn't

You should not expect every command to hit the 66.5% average. The distribution is lopsided on purpose, and knowing the shape helps you predict your own savings before you install anything.

The biggest absolute wins came from `contextzip read`, which is the proxy's handler for file reads. Across 768 calls it saved 15.3M tokens at 29.0% average compression. That sounds low until you realize it is averaged over huge files that included minified JS bundles (where compression is near zero because the bytes are already dense) and 40MB pnpm lockfiles (where compression is 95%+ because the structure repeats).

`contextzip ls` did 2,251 calls at 63.5% average, saving 741.3K tokens. Directory listings compress beautifully because they repeat permission bits, user names, and date formats on every line. `contextzip:toml ps aux` hit 98.1% compression across 26 calls, because `ps aux` is essentially a schema printed 400 times with different values in the cells.

The most extreme case was `contextzip curl -s https://…` against JSON APIs: four calls, 100.0% compression. That number is real, not a typo. When an API returns `{"items": [{"id": 1, "type": "user"}, {"id": 2, "type": "user"}, …]}` with the same schema on every element, RTK dedupes the schema once and passes a table through. You pay for the cells, not the headers.

Some things genuinely don't compress. Already-compressed binaries, random UUIDs, encrypted payloads, and short command output where the compression metadata would outweigh the savings. The proxy is smart enough to pass those through uncompressed, which is why the 66.5% average is honest rather than cherry-picked.

## Install in 30 Seconds, Prove It With `contextzip gain`

The install is embarrassingly short, and I want to be honest about what you actually see on screen.

```bash
# 1. Install the binary
brew install contextzip
# or: curl -fsSL https://contextzip.sh/install.sh | sh

# 2. Verify
contextzip --version
# contextzip 0.4.1 (based on rtk 0.30.1)

which contextzip
# /Users/you/.local/bin/contextzip

# 3. Register the Claude Code hook
contextzip hook install
# Wrote hook to ~/.claude/hooks/pre-bash.sh
# Activated for: git, ls, cat, curl, ps, head, tail, find
```

That's it. No config file, no API key, no account. Open a new Claude Code session and start working as you normally would. The first time the agent runs `git status`, you will see a small dim-grey line in the terminal like `contextzip: git status 3,421 -> 1,102 tokens (saved 68%)`. That line is the hook reporting its own effect. It is not shown to the model.

After an hour of real work, run `contextzip gain`. You will see a block that looks like the one I pasted at the top of this post, scaled down to your session. If you want to go deeper, `contextzip gain --history` prints the per-command log with timestamps, and `contextzip discover` scans your shell history for commands that weren't rewritten but could have been, so you can expand the hook's allowlist.

There is one debug escape hatch worth knowing: `contextzip proxy <cmd>` runs the command with no compression, which is useful when you suspect the proxy is eating output you actually need raw. I have used it twice in 7,172 commands. The proxy is well-behaved.

## One More Thing About the Economics

I have written about Claude Code's economics before, most recently when I burned 72 hours running a local 405B model to figure out where the actual break-even point sits ([I Ran Hermes 4 405B for 72 Hours](https://dev.to/jee599/i-ran-hermes-4-405b-for-72-hours-heres-what-broke)). The conclusion there was that self-hosting loses against Claude on almost every axis except raw token cost.

`contextzip` changes that math. If 66.5% of your input tokens were compressible, then the effective per-million-token cost of Claude Code drops by roughly the same factor on read-heavy workloads. The gap between "use the frontier model" and "self-host an open model" widens considerably in Anthropic's favor, which is, I suspect, why they have not shipped this themselves. It is not their problem to solve.

It is yours. And the tooling exists. I run the same stack that powers [my daily AI briefing for 11 subscribers](https://dev.to/jee599/i-built-a-daily-ai-brief-for-myself-11-subscribers-later-heres-the-stack), and `contextzip` is now load-bearing in that pipeline. The upstream project is [RTK](https://github.com/anthropics/rtk), which provides the compression primitives; `contextzip` is the thin CLI wrapper and hook integration on top.

If you run Claude Code for more than an hour a day, install this tonight and check `contextzip gain` tomorrow morning. You will have a receipt, and the receipt will not be ambiguous.

> The fastest way to save tokens is to stop spending them on commands you can compress.
