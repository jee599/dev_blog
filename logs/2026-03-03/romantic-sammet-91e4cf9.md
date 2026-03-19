---
title: "[romantic-sammet] fix(qa): comprehensive 50-issue QA pass — security, logic, i18n, a11y, performance"
published: false
description: "romantic-sammet 작업 로그. 커밋 91e4cf9."
tags: ai, webdev, productivity, buildinpublic
---

fix(qa): comprehensive 50-issue QA pass — security, logic, i18n, a11y, performance

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	.github/workflows/ci.yml
 M	apps/mobile/App.tsx
 A	apps/web/__tests__/smoke.test.ts
 M	apps/web/app/[locale]/compatibility/page.tsx
 M	apps/web/app/[locale]/components/BottomSheet.tsx
 M	apps/web/app/[locale]/disclaimer/page.tsx
 M	apps/web/app/[locale]/layout.tsx
 M	apps/web/app/[locale]/loading-analysis/page.tsx
 M	apps/web/app/[locale]/page.tsx
 M	apps/web/app/[locale]/paywall/page.tsx
 M	apps/web/app/[locale]/privacy/page.tsx
 M	apps/web/app/[locale]/refund/page.tsx
 M	apps/web/app/[locale]/report/[orderId]/page.tsx
 M	apps/web/app/[locale]/result/page.tsx
 M	apps/web/app/[locale]/terms/page.tsx
 M	apps/web/app/api/admin/_auth.ts
 M	apps/web/app/api/admin/login/route.ts
 M	apps/web/app/api/admin/stats/route.ts
 M	apps/web/app/api/checkout/confirm/route.ts
 M	apps/web/app/api/checkout/stripe/webhook/route.ts
 M	apps/web/app/api/report/[orderId]/route.ts
 M	apps/web/app/api/report/generate/route.ts
 M	apps/web/app/error.tsx
 M	apps/web/app/globals.css
 M	apps/web/i18n/messages/en/common.json
 M	apps/web/i18n/messages/en/compat.json
 M	apps/web/i18n/messages/en/daily.json
 M	apps/web/i18n/messages/en/loading.json
 M	apps/web/i18n/messages/en/result.json
 M	apps/web/i18n/messages/hi/common.json
 M	apps/web/i18n/messages/hi/compat.json
 M	apps/web/i18n/messages/hi/daily.json
 M	apps/web/i18n/messages/hi/loading.json
 M	apps/web/i18n/messages/hi/result.json
 M	apps/web/i18n/messages/id/common.json
 M	apps/web/i18n/messages/id/compat.json
 M	apps/web/i18n/messages/id/daily.json
 M	apps/web/i18n/messages/id/loading.json
 M	apps/web/i18n/messages/id/result.json
 M	apps/web/i18n/messages/ja/common.json
 M	apps/web/i18n/messages/ja/compat.json
 M	apps/web/i18n/messages/ja/daily.json
 M	apps/web/i18n/messages/ja/loading.json
 M	apps/web/i18n/messages/ja/result.json
 M	apps/web/i18n/messages/ko/common.json
 M	apps/web/i18n/messages/ko/compat.json
 M	apps/web/i18n/messages/ko/daily.json
 M	apps/web/i18n/messages/ko/loading.json
 M	apps/web/i18n/messages/ko/result.json
 M	apps/web/i18n/messages/th/common.json
 M	apps/web/i18n/messages/th/compat.json
 M	apps/web/i18n/messages/th/daily.json
 M	apps/web/i18n/messages/th/loading.json
 M	apps/web/i18n/messages/th/result.json
 M	apps/web/i18n/messages/vi/common.json
 M	apps/web/i18n/messages/vi/compat.json
 M	apps/web/i18n/messages/vi/daily.json
 M	apps/web/i18n/messages/vi/loading.json
 M	apps/web/i18n/messages/vi/result.json
 M	apps/web/i18n/messages/zh/common.json
 M	apps/web/i18n/messages/zh/compat.json
 M	apps/web/i18n/messages/zh/daily.json
 M	apps/web/i18n/messages/zh/loading.json
 M	apps/web/i18n/messages/zh/result.json
 M	apps/web/lib/api.ts
 M	apps/web/lib/llmEngine.ts
 M	apps/web/lib/mockEngine.ts
 M	apps/web/lib/sendReportEmail.ts
 A	apps/web/lib/viewToken.ts
 M	apps/web/middleware.ts
 M	apps/web/next.config.ts
 M	apps/web/package.json
 M	apps/web/tsconfig.json
 M	packages/api/src/reportPrompt.ts
 M	packages/api/src/server.ts
 M	packages/engine/saju/src/index.ts
 M	packages/shared/src/config/dictionaries.ts
 M	packages/shared/src/index.ts
 M	pnpm-lock.yaml

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit 91e4cf9
branch claude/romantic-sammet
remote git@github.com:jee599/saju.git

> "Ship small. Log everything."
