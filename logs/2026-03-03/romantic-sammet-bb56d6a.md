---
title: "[romantic-sammet] fix(qa): 2nd-pass 37-issue QA hardening — security, engine, i18n, a11y, perf"
published: false
description: "romantic-sammet 작업 로그. 커밋 bb56d6a."
tags: ai, webdev, productivity, buildinpublic
---

fix(qa): 2nd-pass 37-issue QA hardening — security, engine, i18n, a11y, perf

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	.env.example
 M	apps/web/__tests__/smoke.test.ts
 M	apps/web/app/[locale]/compatibility/page.tsx
 M	apps/web/app/[locale]/components/ComingSoon.tsx
 M	apps/web/app/[locale]/components/LanguageSelector.tsx
 M	apps/web/app/[locale]/components/ui.tsx
 M	apps/web/app/[locale]/daily/page.tsx
 M	apps/web/app/[locale]/free-fortune/page.tsx
 M	apps/web/app/[locale]/layout.tsx
 M	apps/web/app/[locale]/loading-analysis/page.tsx
 M	apps/web/app/[locale]/page.tsx
 M	apps/web/app/[locale]/paywall/page.tsx
 M	apps/web/app/[locale]/refund/page.tsx
 M	apps/web/app/[locale]/result/page.tsx
 M	apps/web/app/[locale]/youth-policy/page.tsx
 M	apps/web/app/api/admin/_auth.ts
 M	apps/web/app/api/admin/logout/route.ts
 M	apps/web/app/api/checkout/confirm/route.ts
 M	apps/web/app/api/checkout/create/route.ts
 M	apps/web/app/api/checkout/stripe/create/route.ts
 M	apps/web/app/api/checkout/stripe/webhook/route.ts
 M	apps/web/app/api/cron/cleanup-reports/route.ts
 M	apps/web/app/api/fortune/mock/route.ts
 M	apps/web/app/api/report/[orderId]/route.ts
 M	apps/web/app/api/report/generate/route.ts
 M	apps/web/app/error.tsx
 M	apps/web/app/globals.css
 M	apps/web/i18n/messages/en/loading.json
 M	apps/web/i18n/messages/hi/home.json
 M	apps/web/i18n/messages/hi/loading.json
 M	apps/web/i18n/messages/id/loading.json
 M	apps/web/i18n/messages/ja/loading.json
 M	apps/web/i18n/messages/ko/loading.json
 M	apps/web/i18n/messages/th/loading.json
 M	apps/web/i18n/messages/vi/loading.json
 M	apps/web/i18n/messages/zh/loading.json
 D	apps/web/lib/fortune.ts
 M	apps/web/lib/llmEngine.ts
 A	apps/web/lib/lunarConvert.ts
 M	apps/web/lib/sendReportEmail.ts
 M	apps/web/lib/viewToken.ts
 M	apps/web/middleware.ts
 M	apps/web/next.config.ts
 M	packages/api/prisma/schema.prisma
 M	packages/shared/src/config/dictionaries.ts
 M	packages/shared/src/index.ts
 M	vitest.config.ts

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit bb56d6a
branch claude/romantic-sammet
remote git@github.com:jee599/saju.git

> "Ship small. Log everything."
