---
title: "[saju] feat(i18n): add legal page translations for all 8 locales + migrate ESLint"
published: false
description: "saju 작업 로그. 커밋 a15e725."
tags: ai, llm, webdev, saju
---

feat(i18n): add legal page translations for all 8 locales + migrate ESLint

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	apps/web/app/[locale]/disclaimer/page.tsx
 M	apps/web/app/[locale]/paywall/page.tsx
 M	apps/web/app/[locale]/privacy/page.tsx
 M	apps/web/app/[locale]/refund/page.tsx
 M	apps/web/app/[locale]/terms/page.tsx
 M	apps/web/app/error.tsx
 A	apps/web/eslint.config.mjs
 A	apps/web/i18n/messages/en/legal.json
 A	apps/web/i18n/messages/hi/legal.json
 A	apps/web/i18n/messages/id/legal.json
 A	apps/web/i18n/messages/ja/legal.json
 A	apps/web/i18n/messages/ko/legal.json
 A	apps/web/i18n/messages/th/legal.json
 A	apps/web/i18n/messages/vi/legal.json
 A	apps/web/i18n/messages/zh/legal.json
 M	apps/web/i18n/request.ts
 M	apps/web/lib/analytics.ts
 M	apps/web/package.json
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

commit a15e725
branch main
remote git@github.com:jee599/saju.git

> "Ship small. Log everything."
