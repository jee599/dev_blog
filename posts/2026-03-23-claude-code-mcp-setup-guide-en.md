---
title: "How I Connected 20 Tools to Claude Code in 5 Minutes"
published: true
description: "MCP turns Claude Code into a tool-calling agent. Here's the exact setup for GitHub, web search, and browser testing — with before/after workflow numbers."
tags: [ai, webdev, productivity, tutorial]
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-mcp-setup-guide-hero.jpg
canonical_url: https://spoonai.me/posts/claude-code-mcp
series: "Claude Code Power User Guide"
---

Forty-two copy-paste operations per day. That is how many times I was manually ferrying context between Claude Code and my browser before I discovered MCP. I timed it over a full work week. The average operation took 45 seconds — open a tab, find the information Claude Code needed, copy it, switch back, paste it in. Over 30 minutes of pure overhead every day, doing nothing but being a slow, unreliable middleware layer between an AI agent and the tools it needed.

MCP, or Model Context Protocol, is the open standard that Anthropic built for connecting AI agents to external tools and data sources. Think of it as USB-C for AI tooling. Before USB-C, every device had its own charging cable. Before MCP, every AI coding tool had its own plugin system — ChatGPT Plugins, Cursor extensions, Copilot adapters — none of them compatible with each other. MCP collapses all of that into a single protocol. You write a JSON config file, and Claude Code gains access to GitHub, web search, browser automation, databases, or any of the 200+ servers in the MCP ecosystem. No custom code, no SDK wrangling, no vendor lock-in.

The setup that eliminated my daily copy-paste overhead took exactly one terminal command. I ran `claude mcp add github -- npx -y @modelcontextprotocol/server-github --env GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx`, restarted Claude Code, and suddenly had 20+ GitHub tools available inside my coding session. Issue lookup, PR creation, code search, commit history, review writing — all of it accessible without ever leaving the terminal.

{% link jee599/mcp-usbc-protocol %}

## What Changed After MCP

The before-and-after contrast is stark. Before MCP, a typical interaction looked like this: Claude Code says "I need to check the PR comments on the auth refactor." I open GitHub in my browser, navigate to the PR, copy the comments, switch back to the terminal, paste them in, and wait for Claude Code to process them. After MCP, the same request takes zero manual steps. Claude Code calls the GitHub MCP server directly, reads the comments, analyzes the diff, and drafts a response. The entire roundtrip happens in seconds, with no human middleware involved.

I tracked my workflow metrics for two weeks — one week before MCP and one week after. Manual context switches dropped from 42 per day to 3. Those remaining 3 were edge cases involving internal tools that do not have MCP servers yet. Total daily time saved: 31 minutes on average. That is roughly 2.5 hours per week, or about 10 hours per month, reclaimed from pure mechanical overhead.

The configuration itself lives in one of two places. For project-level settings that you want to share with your team, create a `.mcp.json` file in your project root and commit it to git. Every team member who clones the repo gets the same tool configuration automatically. For personal settings that contain API keys or tokens, use `~/.claude/.mcp.json` instead — this keeps secrets out of version control while still making them available across all your projects.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token"
      }
    }
  }
}
```

That JSON block is the entire configuration for the GitHub MCP server. No build step, no dependency installation, no API wrapper code. The `npx -y` flag downloads and runs the server package on demand. Claude Code communicates with it over stdio, which is the most common MCP transport type and works for any server that runs locally.

{% link jee599/claude-code-config-guide %}

## The Three Servers That Cover 90% of My Workflow

Out of 200+ available MCP servers, I use three daily. GitHub handles code collaboration — issues, PRs, reviews, and repository search. Brave Search gives Claude Code the ability to look things up on the web. When I hit an unfamiliar error message or need to check the latest API documentation for a third-party service, Claude Code searches for it directly instead of me having to Google and paste results. Playwright brings browser automation into the mix, which is invaluable for verifying deployments, taking screenshots of pages, and running quick visual regression checks after CSS changes.

The interaction between these three servers creates a workflow that was previously impossible. I can say "check if there is a GitHub issue about the login page rendering bug, search the web for known fixes, then open the staging site and verify the current state." Claude Code orchestrates all three MCP servers in sequence, gathering context from each one before making a decision. That kind of multi-tool reasoning is exactly what MCP was designed to enable.

There is an important performance consideration here. As you add more MCP servers, the total number of available tools grows. If Claude Code loaded every tool description into its context window on every conversation, the token overhead would be massive. Anthropic solved this with Tool Search, a lazy loading mechanism that only loads tool descriptions when Claude Code actually needs them. According to the official documentation, Tool Search reduces MCP-related context usage by up to 95%. In practice, I have 60+ tools registered across my MCP servers, but a typical conversation only loads descriptions for 3-5 of them. Subagents spawned during a session inherit all MCP tools from the main conversation automatically — no additional configuration required.

## Transport Types and When They Matter

MCP supports three transport protocols, and choosing the right one depends on where your server runs. stdio is the default for local servers. The MCP server runs as a child process on your machine, and Claude Code communicates with it through standard input and output. This is what you get with the `claude mcp add` CLI command, and it covers the vast majority of use cases for solo developers.

SSE, or Server-Sent Events, connects to remote MCP servers over HTTP. This matters when you want to share a single MCP server instance across a team, or when the server needs access to resources that are not available on your local machine. The tradeoff is added network latency and the need to manage authentication for the remote endpoint.

HTTP Streamable is the newest transport type and the one Anthropic recommends as the standard going forward in 2026. It improves on SSE by supporting bidirectional communication more cleanly, which matters for MCP servers that need to send progress updates or request additional input during long-running operations. For most developers starting with MCP today, stdio is the right choice. You can migrate to HTTP Streamable later when the ecosystem matures around it.

## The Trade-offs Nobody Talks About

MCP is not without friction. The first issue is cold start time. Every MCP server runs as a separate process. If you have five servers configured, Claude Code spawns five processes on startup. On my M3 MacBook, this adds about 2-3 seconds to the initial load. Not a dealbreaker, but noticeable if you are used to instant startup.

The second consideration is security. MCP servers can execute arbitrary code on your machine. The GitHub server needs a personal access token with repo permissions. The Playwright server can open any URL in a real browser. You need to treat MCP server selection with the same scrutiny you apply to npm packages — only install servers from trusted sources, and review the permissions they request.

The third limitation is ecosystem maturity. While 200+ servers exist, quality varies significantly. Some are actively maintained by their respective companies (like the official GitHub server from Anthropic), while others are community projects with varying levels of documentation and reliability. I have tried about 15 different MCP servers, and roughly half of them worked reliably out of the box. The other half required debugging, reading source code, or filing issues to get working.

Despite these caveats, the productivity gain outweighs the setup cost by a wide margin. Five minutes of configuration saved me over 10 hours in the first month alone. The three-server setup I described above (GitHub, Brave Search, Playwright) covers the vast majority of external context needs for web development work.

This is Part 1 of a three-part Claude Code Power User Guide series. Part 2 covers Hooks — Claude Code's automation trigger system for running scripts before and after specific events. Part 3 dives into the Agent architecture for orchestrating complex multi-step workflows. If you are already using Claude Code and have not tried MCP yet, the single-command GitHub setup described above is the fastest way to experience what tool-calling AI actually feels like in practice.

> The best middleware is no middleware. MCP eliminates the human relay between AI and tools.

---

Full Korean analysis on [spoonai.me](https://spoonai.me/posts/claude-code-mcp).

What MCP servers are you running? I went with the GitHub-Search-Playwright trio, but I am curious whether anyone has found a database or CI/CD server that is actually reliable in production.

---

**Sources:**
- [Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp) - Anthropic
- [MCP Protocol Specification](https://modelcontextprotocol.io) - Model Context Protocol
- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers) - GitHub
- [Anthropic](https://anthropic.com) - Creator of Claude and MCP
