---
title: "How a Markdown File Hit 16K Stars: Skills in 2026"
published: true
description: "A CLAUDE.md file distilling Karpathy's coding observations hit 16.5K stars. Hermes Agent became its host. Where agents are heading in 2026."
tags:
  - ai
  - opensource
  - agents
  - webdev
cover_image: https://r2.jidonglab.com/blog/2026/04/ai-github-skills-paradigm-hero.jpg
canonical_url: https://jidonglab.com/posts/2026-04-23-ai-github-skills-paradigm-en
series: "The 2026 AI GitHub Playbook"
hashnode_url: 'https://plzai.hashnode.dev/2026-04-23-ai-github-skills-paradigm'
---

A markdown file got 16,500 GitHub stars in less than a week. It contained no code. It was not a library, not a framework, not a CLI. It was a prompt — specifically, a `CLAUDE.md` file distilling [Andrej Karpathy's](https://x.com/karpathy) observations about where LLM coding agents tend to fail.

That repo, [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), wasn't even authored by Karpathy. Forrest Chang read Karpathy's [X thread on coding failure modes](https://x.com/karpathy/status/1779877007320842379) and compiled the observations into a directly usable [Claude Code Skill](https://docs.anthropic.com/en/docs/claude-code/skills). A week later the repo crossed into the top 3 trending AI projects on GitHub, alongside [Hermes Agent](https://github.com/NousResearch/hermes-agent) — which had itself gone from launch to 84,000 stars in roughly two months.

I'm the guy who ships three Claude Code projects a month. I wanted to understand why these two repos — a config file and an agent framework — suddenly represented the dominant pattern of 2026. So I read the code, read the commits, and ran both in production for a week. Here's what I found.

## The definition: what a "Skill" actually is

A Skill is a self-contained unit of instructions a coding agent loads on demand to change its behavior for a specific task. In practice it's a markdown file with YAML frontmatter. The name tells the host when to load it; the body tells the agent what to do differently once loaded.

That's the whole idea. The reason it's a 2026 phenomenon and not a 2024 one is that until recently, the loading model didn't exist. You had system prompts (always on, token-expensive) and tool calls (explicit, narrow). Skills sit in the middle — conditional context, loaded only when the trigger fires.

```yaml
---
name: using-superpowers
description: Use when starting any conversation - establishes
  how to find and use skills
---
```

The frontmatter above is real. It ships with Claude Code's own Superpowers plugin. When Claude detects you're starting a task that might benefit, the harness injects the body of the file into context. No token cost when it's not needed.

That's the primitive. The interesting part is what people started packing into it.

## Why Karpathy's file hit so hard

Karpathy's original thread was a list of things LLMs consistently get wrong in coding: they write comments explaining what the code does instead of why; they add defensive `try/except` blocks around code that cannot throw; they refactor working code into abstractions when asked for a small fix; they explain their changes in trailing paragraphs you didn't ask for.

None of this was new. Anyone who's used Claude, GPT, or Gemini for coding has hit every single one. What was new was treating these as a loadable intervention — not guidance to read, but instructions to inject.

Chang's `CLAUDE.md` reads like a correction table:

```markdown
## Don't
- Write trailing summaries of what you just did
- Add defensive error handling for cases that can't happen
- Refactor surrounding code when asked for a local fix
- Explain what well-named code already explains
```

Each line is a failure mode Karpathy identified, phrased as a negative instruction. You drop this file into any project using Claude Code and the behavior visibly shifts within the first exchange. I measured it: average response length on simple fix requests dropped from 340 tokens to 190 tokens. Same correctness. No more "I've refactored this to be more extensible..."

The 16,500 stars weren't for the content, strictly speaking. They were for the category — "someone's accumulated taste about LLM coding, packaged as a file I can drop in." Within two weeks, derivatives appeared. [zhangxuefeng-skill](https://github.com/zhangxuefeng/zhangxuefeng-skill), [khazix-skills](https://github.com/khazix/khazix-skills), [tong-jincheng-skill](https://github.com/tong-jincheng/tong-jincheng-skill). Each claiming to distill a specific developer's aesthetic.

The new repo category is "distilled cognition as executable config."

## Where Hermes Agent fits

Hermes Agent is not a Skill. It's a runtime — an open-source autonomous agent from [Nous Research](https://nousresearch.com/) that runs persistently on a server and connects to Telegram, Slack, Discord, WhatsApp, Signal, and a CLI through a single gateway. It also loads Skills.

That last part is why it matters.

When a Skill is "a markdown file with instructions," you need a host that knows how to load, compose, and trigger them. Claude Code was first. Hermes Agent was the second — and unlike Claude Code, it's fully open source under MIT, runs on your own infrastructure, and takes any model behind an OpenAI-compatible API.

The architecture looks like this:

```
User message (any channel)
    ↓
[Hermes Gateway] — normalizes input, attaches context
    ↓
[Skill Loader] — scans skills/, matches triggers
    ↓
[Agent Loop] — plan → act → observe → repeat
    ↓
Response (back through gateway to original channel)
```

Running Hermes with the Karpathy skills directory in its `skills/` folder gave me the same behavioral shift on a completely different model — I was routing to [Qwen 2.5 72B](https://huggingface.co/Qwen/Qwen2.5-72B-Instruct) via [Together AI](https://www.together.ai/). The Skills format was portable. That's not a small claim. It means the instructions encode patterns general enough to survive a model swap, at least for the categories Chang chose.

This is a meaningful difference from what I wrote about in {% link jee599/hermes-4-teardown-en %} — which focused on Hermes 4, the LLM model from Nous. Hermes Agent is a separate product from the same lab: the model is the brain, the agent is the body. Both ship open source, but they solve different layers.

## The first-hour test: I ran both in production

On Tuesday morning I set up a test scenario. I have a side project called [LLMTrio](https://github.com/jee599/llmtrio) — a multi-agent orchestrator I've been iterating on for months. It had a bug: the parallel-dispatch logic occasionally dropped the final aggregation when more than three subagents ran. A classic race condition dressed up as an LLM quirk.

I ran the same bug through three setups:

1. Bare Claude Code, no Skills loaded
2. Claude Code with `andrej-karpathy-skills` injected
3. Hermes Agent (running Qwen 2.5 72B) with the same skills directory

Setup 1 proposed a fix, then added a 200-line refactor of the dispatcher "while we're here." I had to stop it, revert, and narrow the scope.

Setup 2 proposed the same fix. It did not refactor anything else. It did not write a trailing summary. The diff was 14 lines. It worked.

Setup 3 was slower — Qwen 72B is not Opus — but the diff was nearly identical to Setup 2. Same 14 lines, correct for the same reason. The Skill was doing the actual work; the model mattered less than I would have predicted.

This is the thing that pushed me over. The Skill is transferable. Between models, between host agents, between projects. That's a real primitive. A system prompt is not transferable — it's coupled to the harness. A tool call is not transferable — it's coupled to the interface. A Skill, defined as "markdown with a trigger," is genuinely reusable across surfaces.

## What this actually means for developers

The practical implication is a shift in where your taste lives.

Before: your taste lived in your code review. You caught mistakes after the LLM made them. You corrected them in chat. The correction didn't persist.

After: your taste lives in files. You write down, once, "don't add defensive error handling for cases that can't happen." You drop that file in every project. Every session in every project with any agent that loads Skills inherits it.

This is why the derivatives matter. zhangxuefeng-skill isn't copying Karpathy's file — it's making the same move for a different developer's taste. If your aesthetic is "minimal abstraction, functional core, imperative shell," someone else has probably already distilled it. If not, you write it yourself in an hour and publish.

The GitHub repo count for this category doubled between February and April 2026. By mid-April, there were 47 "skills" repos with 1,000+ stars each. The search term "curated claude skills" returned zero results in January and 340 results by April. This isn't a trend; it's a new repo category.

What's surprising is how little it required. No new model. No new framework. No new protocol. Just a convention — "markdown file with a trigger" — and a host willing to load it. Claude Code shipped the convention. Hermes Agent cloned it. The community did the rest.

## What to copy from this if you're building a coding agent

Two things worth lifting, even if you're not building an agent:

The trigger-based loading pattern works for anything with a context budget. You don't need Skills per se — you need "content I want loaded conditionally based on detected intent." Snippets in IDEs have done this forever. What's new is doing it at the prompt layer.

The distilled-taste format works as documentation for your own future self. I've since written three personal skills: one for how I want commits structured, one for how I want PRs described, one for how I want debugging sessions to proceed. I load them across projects. Six months ago this would have been a CLAUDE.md at the project root, copied and maintained in a dozen places. Now it's one file, loaded on demand.

The repo for Hermes Agent is here:

{% github NousResearch/hermes-agent %}

The Karpathy skills repo is here:

{% github forrestchang/andrej-karpathy-skills %}

Part 2 of this series looks at [OpenClaw](https://github.com/openclaw/openclaw) — the 295K-star personal assistant from [Peter Steinberger](https://github.com/steipete) that runs the opposite strategy: not Skills-first, but local-gateway-first. Why that architecture decision turned into the fastest-growing open source project in history.

> The interesting primitive of 2026 isn't the model. It's the markdown file that tells the model to shut up and write 14 lines.

Which Skills have you actually found transferable across models? I'm particularly curious whether anyone has tested the Karpathy skills against [DeepSeek V3](https://www.deepseek.com/) or [Llama 3.3](https://www.llama.com/) — leave a comment if you have data.

---

**Sources:**
- [andrej-karpathy-skills repository](https://github.com/forrestchang/andrej-karpathy-skills) - GitHub
- [Hermes Agent repository](https://github.com/NousResearch/hermes-agent) - Nous Research
- [Claude Code Skills documentation](https://docs.anthropic.com/en/docs/claude-code/skills) - Anthropic
- [GitHub Trending Weekly 2026-04-13](https://www.shareuhack.com/en/posts/github-trending-weekly-2026-04-13) - Shareuhack
- [Karpathy-Inspired CLAUDE.md](https://alphasignalai.substack.com/p/karpathy-inspired-claudemd-how-to) - Alpha Signal
