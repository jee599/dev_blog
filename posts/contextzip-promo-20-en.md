---
title: "Web Scraping for Claude Code: Strip Nav, Keep Content"
published: true
description: "When your AI scrapes a webpage, it gets navbars, footers, cookie banners, and script tags. ContextZip extracts just the meaningful text content."
tags:
  - ai
  - webdev
  - productivity
  - claudecode
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-20'
---

Claude Code can fetch web pages. But when it does, it gets the full HTML — navigation bars, footer links, cookie banners, script tags, SVG icons, meta tags.

On a typical documentation page, the actual content is 30% of the HTML. The other 70% is page structure, navigation, and decoration.

## Before: Raw HTML Fetch

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
  <title>API Reference - MyLib</title>
  <link rel="stylesheet" href="/styles.css">
  <script src="/analytics.js"></script>
</head>
<body>
  <nav class="sidebar">
    <a href="/">Home</a>
    <a href="/docs">Docs</a>
    <a href="/api">API</a>
    <!-- 50 more nav links -->
  </nav>
  <main>
    <h1>createUser()</h1>
    <p>Creates a new user with the given parameters.</p>
    <pre><code>const user = await createUser({ name, email })</code></pre>
  </main>
  <footer>
    <!-- 30 lines of footer -->
  </footer>
</body>
</html>
```

Your AI needs the `<main>` content. It gets everything.

## After: Through ContextZip

```
# createUser()

Creates a new user with the given parameters.

    const user = await createUser({ name, email })

💾 contextzip: 4,212 → 124 chars (97% saved)
```

Navigation, footer, scripts, stylesheets, meta tags — all stripped. The actual content extracted and converted to plain text. 97% reduction.

This is especially powerful when your AI needs to read documentation, blog posts, or Stack Overflow answers. The signal-to-noise ratio on most web pages is terrible for AI consumption.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
