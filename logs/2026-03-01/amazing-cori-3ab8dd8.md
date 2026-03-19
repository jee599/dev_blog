---
title: "[amazing-cori] fix: maxTokens 12000→24000, 잘린 JSON 복구, Gemini 비-JSON 응답 처리"
published: false
description: "amazing-cori 작업 로그. 커밋 3ab8dd8."
tags: ai, webdev, productivity, buildinpublic
---

fix: maxTokens 12000→24000, 잘린 JSON 복구, Gemini 비-JSON 응답 처리

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     M	apps/web/app/report/[orderId]/page.tsx
 M	apps/web/lib/llmEngine.ts

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit 3ab8dd8
branch claude/amazing-cori
remote git@github.com:jee599/saju.git

> "Ship small. Log everything."
