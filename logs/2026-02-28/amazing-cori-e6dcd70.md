---
title: "[amazing-cori] feat: Supabase DB 전환 — mockEngine → Prisma 실DB 연동"
published: false
description: "amazing-cori 작업 로그. 커밋 e6dcd70."
tags: ai, webdev, productivity, buildinpublic
---

feat: Supabase DB 전환 — mockEngine → Prisma 실DB 연동

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	apps/web/app/api/checkout/confirm/route.ts
 M	apps/web/app/api/checkout/create/route.ts
 M	apps/web/app/api/report/[orderId]/route.ts
 M	apps/web/app/report/[orderId]/page.tsx
 M	apps/web/lib/mockEngine.ts
 M	packages/shared/src/index.ts

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit e6dcd70
branch claude/amazing-cori
remote git@github.com:jee599/saju.git

> "Ship small. Log everything."
