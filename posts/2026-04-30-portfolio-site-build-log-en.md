---
title: "Vercel Said CANCELED for 2 Days — 481 Files Scanned, One Missing Component Found"
published: true
description: "Vercel CANCELED two days straight. YAML was the suspect, 481 files were scanned — zero errors. The real blocker: a missing CountUp.tsx. Fixed in 2 sessions, 208 tool calls."
tags: claudecode, debugging, vercel, nextjs
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-30-portfolio-site-en
---

Two days. Same error message. Same CANCELED status in Vercel. The log was very specific about the culprit:

```
YAMLException: incomplete explicit mapping pair; a key node is missed;
or followed by a non-tabulated empty line at line 3, column 277
```

It even named the file: `/posts/2026-04-05-furiosa-ai-rngd-commercial-launch-en`.

**TL;DR** The YAML was fine. `HomeContent.tsx` was importing `CountUp.tsx`, which didn't exist. Turbopack caught it at build time and killed the build. The error log pointed at the wrong thing the entire time. Two Claude Code sessions and 208 tool calls to find out.

## The Log Named a File. The File Was Already Fixed.

First instinct: open the file the error named. Line 3 was 204 characters — well within normal range. A batch fix on April 14th (commit `3095c96`) had already handled it. The named file was clean.

That meant either the error was stale, or there was a different broken file somewhere. Time for a full content scan.

```js
const files = glob.sync('content/**/*.md');
let errors = [];
files.forEach(f => {
  try { matter(fs.readFileSync(f, 'utf8')); }
  catch(e) { errors.push({ file: f, error: e.message }); }
});
console.log('errors:', errors.length); // → 0
```

This ran `gray-matter` across all four content directories: `content/posts/`, `content/daily/`, `content/blog/`, and `content/weekly/`. 481 files total. Zero parse errors. Ran it again with `js-yaml` directly to rule out library differences. Still zero.

The YAML hypothesis was dead.

## "CANCELED" Was Covering for "BUILD FAILED"

This is where a Vercel pipeline configuration made things confusing. The dashboard showed CANCELED, which reads as "someone aborted the deploy" or "a prerequisite check failed." Not "the build itself crashed."

In reality, the build was failing. The CANCELED label was masking a BUILD FAILED state due to how the pipeline was configured.

Running `npm run build` locally cut through the noise immediately:

```
Error: Cannot find module './CountUp'
  at HomeContent.tsx:3:1
```

`HomeContent.tsx` had an import for `CountUp.tsx`. `CountUp.tsx` didn't exist anywhere in the codebase. Next.js 16 defaults to Turbopack as the bundler, and Turbopack resolves module references at build time — it doesn't silently fail or skip missing imports. It crashes the build.

The YAML exception in the Vercel logs was either a red herring from a previous build run, or a symptom of the build environment failing in an unexpected order. Either way, it wasn't the cause.

## Creating CountUp.tsx from Scratch

The fix required reading `HomeContent.tsx` to understand what interface `CountUp` was expected to expose, then writing the component.

The usage pattern made the props clear: `CountUp` needed to animate from 0 to a target number over a configurable duration, with an optional suffix string.

```tsx
// components/CountUp.tsx
'use client';

import { useState, useEffect } from 'react';

interface CountUpProps {
  end: number;
  duration?: number;
  suffix?: string;
}

export default function CountUp({ end, duration = 2000, suffix = '' }: CountUpProps) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const step = end / (duration / 16);
    let current = 0;
    const timer = setInterval(() => {
      current = Math.min(current + step, end);
      setCount(Math.floor(current));
      if (current >= end) clearInterval(timer);
    }, 16);
    return () => clearInterval(timer);
  }, [end, duration]);

  return <span>{count}{suffix}</span>;
}
```

The animation runs at ~60fps (16ms interval). `step` is calculated so the counter reaches `end` exactly at `duration` milliseconds. `Math.min` ensures it never overshoots.

Two files in `content/daily/` were also fixed during the same session — both were missing the closing `---` on their frontmatter blocks. The YAML parser hadn't thrown errors for them, but the structure was malformed. They got cleaned up alongside the main fix.

## Build Passed, Production Unblocked

```bash
npm run build
# ✓ 480 static pages generated
# ✓ Build completed successfully
```

All 480 static pages generated without errors. Pushed to `main`, Vercel triggered an automatic deploy, and production caught up to where it should have been since April 26th — four days behind.

## Two Sessions, 208 Tool Calls: What Took So Long

Session 1: 91 tool calls, 9 minutes. Session 2: 117 tool calls, 13 minutes.

Tool breakdown across both sessions: Bash 176, Read 22, TodoWrite 5, Skill 2, Write 1, Edit 1, ToolSearch 1. The Bash count reflects how much time went into scanning, validating, and re-validating the YAML hypothesis before pivoting.

Both sessions followed the same initial pattern: the error log named a specific file, so investigation started with that file. This is the natural, reasonable path. The problem was that the named file was already clean, and the full content scan confirmed nothing in 481 files was broken. Reaching the next step — "reproduce the build locally" — took longer than it should have.

In retrospect, the order of operations should have been:

1. Reproduce the build locally
2. Read the actual error output
3. Then investigate the specific failure

Instead, both sessions spent the first half chasing the YAML angle because the error message was specific and confident. Error messages that name files feel authoritative. They're not always right.

## The Actual Lesson

When a build fails, reproduce it locally before trusting what a cloud CI log says. Two things worked against fast debugging here:

**Status labels lie by omission.** "CANCELED" doesn't communicate "the build crashed." It implies something stopped the process before it could even run. Knowing the distinction between a build failure and a cancelled deployment isn't just semantic — it changes where you look first.

**Error messages can point at the wrong place.** The YAML exception may have been a real error from a previous run that somehow persisted in the log view, or it may have been Turbopack failing in an unusual sequence. Either way, it wasn't the root cause. A YAML scanner across 481 files proved that definitively — but that proof took time that could have been saved by running `npm run build` first.

The Claude Code sessions were thorough. They just started from the wrong assumption, the same assumption anyone would make when an error log names a specific file. Next time: local build first, log forensics second.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
