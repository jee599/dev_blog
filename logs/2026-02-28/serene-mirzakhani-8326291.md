---
title: "[serene-mirzakhani] feat: light-mode only, remove discounts, UX improvements"
published: false
description: "serene-mirzakhani 작업 로그. 커밋 8326291."
tags: ai, webdev, productivity, buildinpublic
---

feat: light-mode only, remove discounts, UX improvements

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     A	.github/workflows/ci.yml
 M	docs/STATUS.md
 A	docs/ops/incident-response.md
 A	"docs/\352\270\260\355\232\215_\352\263\240\353\217\204\355\231\224/01_\353\271\204\354\246\210\353\213\210\354\212\244_\354\203\201\355\222\210_\352\270\260\355\232\215.md"
 A	"docs/\352\270\260\355\232\215_\352\263\240\353\217\204\355\231\224/02_UX_\353\224\224\354\236\220\354\235\270_\352\270\260\355\232\215.md"
 A	"docs/\352\270\260\355\232\215_\352\263\240\353\217\204\355\231\224/03_\352\270\260\354\210\240_\354\235\270\355\224\204\353\235\274_\352\270\260\355\232\215.md"
 M	package-lock.json
 M	package.json
 M	src/app/admin/page.tsx
 D	src/app/api/discount/validate/route.ts
 M	src/app/api/payment/confirm/route.ts
 M	src/app/globals.css
 M	src/app/layout.tsx
 M	src/app/mentor/dashboard/page.tsx
 M	src/app/mentors/page.tsx
 M	src/app/payment/success/page.tsx
 M	src/components/ConsultModal.tsx
 M	src/components/FreeTrialConversionCTA.tsx
 M	src/components/Header.tsx
 M	src/components/Hero.tsx
 M	src/components/HomeClient.tsx
 M	src/components/MentorDetailModal.tsx
 M	src/components/ReviewModal.tsx
 D	src/components/SeasonalBanner.tsx
 M	src/components/VerificationModal.tsx
 M	src/components/auth/ForgotPasswordModal.tsx
 M	src/components/auth/LoginModal.tsx
 M	src/components/auth/SignupModal.tsx
 D	src/contexts/ThemeContext.tsx
 A	src/lib/__tests__/admin.test.ts
 M	src/lib/analytics/conversion.ts
 M	src/lib/constants.ts
 D	src/lib/discount/codes.ts
 A	src/lib/settlement/__tests__/calculate.test.ts
 M	src/lib/settlement/calculate.ts
 A	vitest.config.ts

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit 8326291
branch claude/serene-mirzakhani
remote git@github.com:jee599/coffeechat.git

> "Ship small. Log everything."
