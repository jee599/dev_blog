---
title: "[coffeechat] fix: 깨진 로직 7건 수정 — 쿠폰/이메일/정산/검증"
published: false
description: "coffeechat 작업 로그. 커밋 2d5fc7f."
tags: webdev, nextjs, supabase, saas
---

fix: 깨진 로직 7건 수정 — 쿠폰/이메일/정산/검증

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	src/app/api/admin/coupons/route.ts
 M	src/app/api/cron/auto-complete/route.ts
 M	src/app/api/cron/weekly-settlement/route.ts
 M	src/app/api/discount/validate/route.ts
 M	src/app/api/email/booking-notification/route.ts
 M	src/components/ConsultModal.tsx

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit 2d5fc7f
branch main
remote git@github.com:jee599/coffeechat.git

> "Ship small. Log everything."
