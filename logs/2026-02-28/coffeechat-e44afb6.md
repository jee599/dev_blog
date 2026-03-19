---
title: "[coffeechat] fix: QA round 4 — 13 bugs fixed"
published: false
description: "coffeechat 작업 로그. 커밋 e44afb6."
tags: webdev, nextjs, supabase, saas
---

fix: QA round 4 — 13 bugs fixed

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	src/app/api/auth/social/route.ts
 M	src/app/api/referral/mentee/claim/route.ts
 M	src/app/booking/bundle/[bundleType]/page.tsx
 M	src/app/mentor/content/page.tsx
 M	src/app/mentor/dashboard/page.tsx
 M	src/app/mentor/pricing/page.tsx
 M	src/app/mentors/[id]/page.tsx
 M	src/app/subscribe/page.tsx
 M	src/components/ConsultModal.tsx
 M	src/components/mentor/BookingCalendar.tsx
 M	src/components/review/ReportReviewButton.tsx
 M	src/hooks/useFocusTrap.ts
 M	src/lib/supabase/types.ts
 M	supabase/migrations/20260228_enterprise.sql

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit e44afb6
branch main
remote git@github.com:jee599/coffeechat.git

> "Ship small. Log everything."
