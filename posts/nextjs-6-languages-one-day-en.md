---
title: How I Added 6 Languages to a Next.js App in One Day
published: true
description: 'Korean, English, Japanese, Chinese, Vietnamese, Hindi. One day with next-intl. Here''s every gotcha.'
tags:
  - webdev
  - nextjs
  - beginners
  - ai
---

I decided to ship my AI fortune-telling app to 6 countries. Korea, US, Japan, China, Vietnam, India.

Will Korean fortune-telling (saju — four-pillar destiny analysis based on birth date and time) work outside East Asia? No idea. But tarot and astrology are global. "AI analyzes your destiny" probably gets clicks everywhere.

The problem: hardcoded Korean strings were scattered across every page.


## Why next-intl

For Next.js 15 App Router, next-intl was the cleanest option. Native App Router support with `[locale]` dynamic segments. Middleware auto-redirects based on browser language. Same `useTranslations()` hook works in both Server and Client Components.

```
apps/web/
├── app/
│   ├── [locale]/          ← all pages live here now
│   │   ├── page.tsx
│   │   ├── result/page.tsx
│   │   └── layout.tsx     ← html lang={locale} here
│   └── layout.tsx          ← empty pass-through
├── i18n/
│   ├── config.ts           ← locales, defaultLocale
│   ├── routing.ts          ← localePrefix: "as-needed"
│   └── navigation.ts       ← i18n-aware Link, useRouter
├── messages/
│   ├── ko.json, en.json, ja.json
│   ├── zh.json, vi.json, hi.json
└── middleware.ts            ← Accept-Language detection
```

The key setting is `localePrefix: "as-needed"`. Korean is default, so `/` serves Korean. `/en/` serves English. Korean users never see `/ko/` in their URL.


## The Biggest Gotcha: Nested html Tags

I knew Next.js App Router requires root layout to render `<html>` and `<body>`. So I put them in root layout AND in `[locale]/layout.tsx` with `<html lang={locale}>`.

Result: **html inside html.** Browsers silently ignore it, but the DOM is completely wrong.

```typescript
// app/layout.tsx — the fix
export default function RootLayout({ children }) {
  return children;  // no html/body, just pass through
}

// app/[locale]/layout.tsx — this owns html/body
export default function LocaleLayout({ children, params }) {
  return (
    <html lang={locale}>
      <body>{children}</body>
    </html>
  );
}
```

Root layout returning just `children` works fine in Next.js 15. The `[locale]` layout provides html/body, so the framework is satisfied.


## Localized Pricing

Charging $9.90 in India means zero sales. Each country gets pricing matched to local purchasing power.

```json
// ko.json → "₩12,900"
// en.json → "$9.90"
// ja.json → "¥1,490"
// zh.json → "¥68"
// vi.json → "199.000₫"
// hi.json → "₹799"
```

Prices are hardcoded in translation files. When payment integration comes later, the server will handle this. But for MVP, this is the fastest path. Even placeholder names are localized — Korea gets "홍길동", Japan gets "山田太郎", India gets "राहुल शर्मा".


## Import Path Hell

Moving `app/page.tsx` to `app/[locale]/page.tsx` means every import gets one level deeper.

```typescript
// Before — app/page.tsx
import { types } from "../lib/types";

// After — app/[locale]/page.tsx
import { types } from "../../lib/types";
```

Fifteen files. Dozens of imports. One wrong path and the build breaks. The deepest page — `report/[orderId]/page.tsx` — needed `../../../../lib/types`. Four levels up. TypeScript caught every mistake, which is the only reason this worked.


## The Result

Build output shows pages generated for every locale.

```
├ /ko/result
├ /en/result
├ /ja/result
├ /zh/result
├ /vi/result
├ /hi/result
```

Browser set to Japanese? Auto-redirect to `/ja/`. Header dropdown lets you switch manually. 한국어 ↔ English ↔ 日本語 ↔ 中文 ↔ Tiếng Việt ↔ हिन्दी.

Not bad for a day's work. Visitors from 6 countries each see "AI analyzes your destiny" in their own language, with their own currency, and a name placeholder they recognize.

> "Going global isn't translation — it's localization. Different prices, different names, different currencies. The words are the easy part."
