---
title: "Shipping a Mac Electron App Without Apple Notarization"
published: false
description: "Why I ship an ad-hoc signed Electron app with a notice-only updater: the options I weighed, the App Store rules, and a Windows build without Rosetta."
tags:
  - electron
  - macos
  - buildinpublic
  - claudecode
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/12-cover.png"
---

Every new version of Refmade asks every Mac user to click "Open Anyway" in System Settings again. I chose that. The macOS signature check on the app reports one fatal finding, a missing notarization, and I decided to leave it there.

Refmade is a desktop app that wraps the Claude Code and Codex command-line tools and shows their work as an office floor. It is an independent app, not affiliated with Anthropic or OpenAI. The UI is Korean right now; that changes later in this series. Claude Code and Codex agents wrote most of the code at my direction. The decisions in this post are mine.

## What the update notice does

The app does not update itself. About ten seconds after launch, and then once a day, it makes one GET request to a fixed address and reads a version number from the JSON that comes back. If the number is newer than its own, it shows a notice with a button that opens the download page in your browser. You can turn the check off from the menu.

The check is written to learn as little as possible about you and to trust the answer as little as possible. No app version, no ID and no cookie go out (the server sees your IP address, like any visit). The request has an 8-second limit for the whole answer, reads at most 16 KB, and follows no redirects. The app never opens or downloads an address that came from the answer, so a wrong answer can only produce a wrong number.

The answer can list a version per platform, and that matters for the Windows build later:

```js
export function latestVersionOf(body, key = platformKey()) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) return null;
  const platforms = body.platforms && typeof body.platforms === 'object' && !Array.isArray(body.platforms) ? body.platforms : null;
  if (platforms && Object.hasOwn(platforms, key)) return parseVersion(platforms[key]) ? platforms[key] : null;
  if (platforms) return null;   // a list without this platform: nothing for it yet
  return parseVersion(body.version) ? body.version : null;
}
```

On October 1 I saw it work for real. After I published 0.3.1, an installed 0.3.0 app picked it up as available from the production file.

![A site update-log card titled Mac 0.3.9 dated October 10, 2026, with three change notes and a button to get the latest version](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/12-update-log.png)

*The site's update log for Mac 0.3.9, October 10, 2026 (Korean). Headline: "When it needs my answer, the letters bounce." Three notes: my turn gets a color and two bounces, working gets a wave, news gets one bounce. Below: "This update is for Mac. The public Windows version is 0.3.2." Button: "Get latest version". The decision card on the right is public demo data.*

## Why notify and not auto-update

I decided on September 30 that a notice is enough for the first public version. I did not write down a motive beyond that, so here is the effect of the design. With an auto-updater, my server's reply would decide what runs on your machine. With a notice, the reply is one number, which the app can check against its own.

Installers are never overwritten. When I changed things after 0.3.5 was published, I shipped 0.3.6 instead of replacing the 0.3.5 file. Each build has a versioned file name and is served with immutable cache headers. Only the current version stays downloadable, so an old link returns 404. That is a real cost for anyone who bookmarked it.

## The three ways to ship on a Mac

On October 1 I decided between these three.

| Option | What users see | What it needs | My verdict |
|---|---|---|---|
| Notarized | Opens normally | Paid Apple Developer membership, notarization step per build | Not now |
| Ad-hoc signed, not notarized | "Open Anyway" once per version | Nothing paid (`identity: "-"` in electron-builder) | Chosen |
| Mac App Store | Store install | Sandbox, store review | Doesn't fit, see below |

Ad-hoc signing seals the bundle (1,042 files in 0.2.3) so macOS can tell it was not modified, but it does not identify a developer. After it, `syspolicy_check` dropped from three fatal findings to one. The one left is the missing notarization.

The download page says plainly why the warning appears and where to click. The page explains that macOS blocks the first launch because the app has no Apple notarization, that it is not a malfunction, and which two clicks to make. It also repeats that the step comes back with every new version, so nobody is surprised by it after an update. Windows has the same shape: an unsigned installer, a "More info" link and a Run button, once per version.

## Why the App Store is out

This is my reading of Apple's [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), not an official ruling. Guideline 2.5.2 says apps "may not read or write data outside the designated container area" and may not "execute code which introduces or changes features or functionality of the app". Refmade reads session logs that Claude Code and Codex keep in the user's home folder, and it launches those tools. 2.4.5(i) also requires Mac App Store apps to be sandboxed. Both go against what the app is for.

## Building the Windows installer without Rosetta

I build on a Mac that runs macOS 27.0.1 and has no Rosetta. When I first tried a Windows installer there (for 0.2.2), electron-builder's NSIS step spawned `makensis`, an x86_64 binary, and failed with `spawn -86`.

The workaround was a flag that pulls a native NSIS toolset, `-c.toolsets.nsis=1.2.1`, passed to `electron-builder --win nsis --x64`. That produced `Refmade-0.3.1-x64.exe`, 133,331,616 bytes, with no code signature. Up to that point the file had never run on Windows. A 15-minute checklist was run on a real Windows PC. It passed, and only then did I publish 0.3.1.

Windows is still behind. The public Windows build is 0.3.2. The Mac build is 0.3.9. A 0.3.8 Windows installer exists, cross-built, but I did not publish it because I could not run it. That is what the per-platform list in `latest.json` is for. Windows users are not told about 0.3.9, because there is nothing for them to get.

## The yellow stripe

Version 0.3.1 also fixed a visual bug. The game theme drew a yellow stripe along the left edge of every card title. The cause was a 12×7 pixel PNG, `frame-title`, whose left 9 pixels are stretched as a slice. A gold jewel sat inside those 9 pixels and got stretched to the card's height.

I asked for the stripe to go. The fix is a script, `drop_title_jewel.py`, that erases the jewel from four images and from two CSS data URIs. A test, `game-art.test.mjs`, now decodes the PNGs directly and counts gold pixels. The expected count is zero.

## Takeaways

- A notice that reads one number is a smaller promise than an updater. I can keep it.
- Never overwrite a published installer. A new number costs nothing.
- Say which platform got tested and on which version.
- Read the store rules before building toward a store. Two guidelines were enough to rule it out for me.

The app link comes in the last post of the series.

If you ship an unsigned or ad-hoc signed desktop app, what did you put on the download page to make the "Open Anyway" step less scary?
