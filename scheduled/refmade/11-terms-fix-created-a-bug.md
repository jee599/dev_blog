---
title: "My Claude Code Sign-in Fix Needed Two Fixes of Its Own"
published: false
description: "I removed an API-key refusal from my Electron wrapper for Claude Code and Codex. Review then found two bugs in my own fix before the first public release."
tags:
  - claudecode
  - electron
  - security
  - ai
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/11-cover.png"
---

On September 29 I removed a sign-in refusal from my app. The next day a review pass whose only job was to break that change found that it left some sign-ins reported as ready that then failed, and my repair of that opened a second hole. Both were caught before the first public release on October 1.

Refmade is a desktop app that wraps the Claude Code and Codex command-line tools and draws what they are doing as an office floor. It is an independent app, not affiliated with Anthropic or OpenAI. The UI is Korean right now; that changes later in this series. Claude Code and Codex agents wrote most of the code, working from specs I gave them. I planned the work, made the calls and reviewed the results. This post is about one call that turned out to be half right.

## The problem: the app refused a sign-in the CLI accepts

The app has a "team" mode, where several agents plan, write and check a task. Until September 29 it only worked when Claude Code was signed in with a Claude account (the plan login). If you had an API key instead, the app answered with a reason code, `AUTH_MODE_UNSUPPORTED`, and stopped.

I read Anthropic's documentation around that refusal. My conclusion was that an app wrapping the CLI should not refuse a sign-in method the CLI itself supports. I'm a developer, not a lawyer, and this is not legal advice. It is simply how I decided to design it, so I asked for the refusal to be removed.

The app also tells people what it does with their data. Here is the first screen as it looked in a capture from the end of September:

![Refmade preview-mode first screen with two cards, Claude Code ready and Codex needing login, and four plain notes below about data, sign-in, usage and wrong answers](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/11-first-screen-notes.png)

*Preview-mode first screen, late September (Korean UI, demo state). Title: "First, let's get an AI ready." Cards: Claude Code "ready", Codex "login needed". Notes below, translated: the app itself sends nothing to the internet; when you hand it a task, the Claude Code or Codex on your computer sends your request and needed file contents to Anthropic, OpenAI or wherever you connected, and checking that the AI is ready can also reach Anthropic; sign-in is managed by each AI tool and the app only checks whether and how you are signed in; tasks use up your plan's usage; AI answers can be wrong. A fifth note, cropped here, says the app is not made or endorsed by Anthropic or OpenAI.*

One correction to that first note. It was true when I took the capture. Since version 0.3.0 the app also asks for a version number once a day, and since 0.3.3 it fetches banners for my other services in the office view. Neither request carries task content, but "sends nothing" is no longer an accurate sentence.

## Review round one: the status check and the run disagree

Removing the refusal was a small change. I asked for an adversarial review (September 30), a few agents whose only task is to find how the change fails, and it found this.

Team mode starts Claude Code with `--restricted`, which keeps settings files out of the run. That includes your own user settings file. But before a run, the app asks `claude auth status --json` whether you are ready, and that command does read the user settings file. Some sign-ins live only there: an `apiKeyHelper`, or the Bedrock and Google Cloud login wizards.

| Step | Reads user settings file? | What it sees |
|---|---|---|
| Readiness check (`auth status`) | yes | "signed in, ready" |
| Team run (`--restricted`) | no | no sign-in at all |
| Result | | run fails, or quietly uses another stored login |

I reproduced it with a fake API key and a local test server standing in for the API. The run either failed after the screen said "ready" or went out under a different Claude account that happened to be stored on the machine. For those people the screen now showed a green light, followed by a failure or a silent account switch.

## The fix, and the second problem inside it

`--settings` still applies under `--restricted`, so the app can hand the file back by path. I never read its contents. The app checks that it exists, is at most 2 MB and is readable, and Claude Code reads the rest. This is the condition from `providers/claude.mjs` (one branch for third-party providers trimmed):

```js
function signInFromSettings(signIn, env, platform) {
  if (!signIn) return false;
  const has = name => Boolean(envValue(env, name, platform));
  if (signIn.method === 'api_key_helper' || signIn.keySource === 'apiKeyHelper') return true;
  if (signIn.keySource === 'ANTHROPIC_API_KEY') return !has('ANTHROPIC_API_KEY');
  if (signIn.method === 'oauth_token') return !has('ANTHROPIC_AUTH_TOKEN') && !has('CLAUDE_CODE_OAUTH_TOKEN');
  return false;
}
```

My first version passed the file whenever a sign-in existed. A second review pass, one agent this time, found that the same file can contain `permissions.additionalDirectories`. Handing it back would let a run reach folders outside the one you picked. The restriction I was relying on was gone. So the file is passed only when the sign-in actually comes from it.

That condition has a trap. `auth status` reports a key from the environment and a key from the settings file with the same label, `api_key` and `ANTHROPIC_API_KEY`. The only way I found to tell them apart was to check whether the run's own environment holds the key, which is what `has(...)` does above. A related lesson from the Codex side: its `-c` override values are type-checked, so a value that looks right can still be rejected.

## Other things the same review turned up

- Team runs with Codex forced the provider to OpenAI. People using Azure or another provider had their tasks sent to OpenAI. I removed the forcing.
- Claude Code and Codex could each receive the other's API key through the environment. Each tool now gets only its own family of variables (`ENV_FAMILIES` in the code).
- The label "Claude account" appeared for any login. It now appears only for a plan login.

## What passed, and what that proves

After the fixes: app tests 405, CLI tests 323, engine tests 401 plus one. I also ran mutation checks, which deliberately break the code and confirm a test fails. Real team runs through the actual CLIs finished in 6.1 seconds for Claude and 14.3 seconds for Codex.

Those numbers say the code does what my specs say. They say nothing about whether real users find sign-in easy. I have not run a usability test with real users.

## A correction that belongs here

On September 29 I reported that the app's macOS signature check had zero fatal findings. That was wrong. When I ran `syspolicy_check` again, it listed three: two about the signature and one about missing notarization. Version 0.2.3 (September 30, 08:07) went out ad-hoc signed with 1,042 files sealed, and the count dropped from three to one. The remaining one is notarization, which I chose not to do. The next post covers that choice.

## Takeaways

- A status check and a run must read the same inputs. If they differ, "ready" is a promise the run can't keep.
- Review the fix, not only the original change. Both regressions here came from the repairs, not from the code that was already there.
- Reproduce with fake credentials and a local server before you trust a login fix.
- Say what a test count measures. 405 passing tests is a statement about the specs.

The app link comes in the last post of the series.

If you wrap a CLI that has several ways to sign in, how do you keep your readiness check and your actual run reading the same configuration?
