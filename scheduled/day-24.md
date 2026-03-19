---
title: "Security Warnings Preserved, Deprecated Noise Deleted"
published: false
description: "ContextZip distinguishes between actionable security warnings and noise warnings. One stays, the other goes."
tags:
  - ai
  - productivity
  - opensource
  - devops
---

Not all warnings are noise. `npm audit` security warnings matter. `npm warn deprecated` warnings don't. ContextZip knows the difference.

## What Gets Deleted

```
npm warn deprecated inflight@1.0.6: This module is not supported...
npm warn deprecated glob@7.2.3: Glob versions prior to v9...
npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4...
```

Deprecated package warnings. You can't fix them (they're transitive dependencies). Your AI can't fix them either. They just consume context.

## What Gets Preserved

```
6 vulnerabilities (2 moderate, 3 high, 1 critical)

critical: Remote Code Execution in lodash
  Dependency: lodash < 4.17.21
  Path: myapp > some-lib > lodash
  Fix: npm audit fix --force
```

Security vulnerabilities with severity, affected paths, and fix commands. This is actionable. Your AI needs to see this.

## The Rule

ContextZip applies a simple heuristic: if a warning is **actionable** (you can do something about it), it's preserved. If it's **informational** (nothing you can do), it's stripped.

| Warning Type | Action | ContextZip |
|---|---|---|
| `npm audit` vulnerabilities | Fix with `npm audit fix` | Preserved |
| `deprecated` warnings | Nothing (transitive dep) | Stripped |
| Peer dependency conflicts | Update package.json | Preserved |
| Version deprecation notices | Nothing | Stripped |
| Security advisory with CVE | Patch or mitigate | Preserved |
| Download progress | Nothing | Stripped |

## The Impact

In a project with 47 deprecated warnings and 2 security vulnerabilities, ContextZip strips the 47 warnings (7,832 chars) and keeps the 2 vulnerabilities (412 chars). Your AI focuses on what it can actually help with.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
