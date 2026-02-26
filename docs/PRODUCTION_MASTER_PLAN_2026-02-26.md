# dev_blog – 프로덕션 마스터 플랜

- Repo: `jee599/dev_blog`
- Canonical root: `/Users/jidong/dev_blog`
- Owner: jidong
- Updated: 2026-02-26

목적은 하나다.

커밋과 삽질을 글로 바꿔서, DEV.to에 꾸준히 쌓는다.

원칙은 이것만 지킨다.

STATUS는 한 장만 유지한다.
Gate 통과 전에는 publish하지 않는다.
worklog는 소재고, posts는 발행물이다.

-----

## 0) One-liner

DEV.to에 블로그 글을 자동 발행하는 레포다.

`posts/*.md`에 글을 넣고 `main`에 푸시하면 GitHub Actions가 DEV.to로 올린다.

---

## 1) North Star + Metrics

North Star Metric은 “발행된 글 수 / 주”다.

가드레일은 품질, 실패율, 운영비용이다.

- 발행된 글 수 / 주
- 한/영 페어 완성률 (같은 주제 KO+EN)
- 실패율: GitHub Actions 실패 비율, DEV.to API 실패(403/429/5xx)
- 작업 지속성: worklog → posts로 승격된 비율

Gate는 숫자가 나오게 만드는 거다.

추적은 이 레포 안에서 끝낸다.

- 실패/응답 기록: `publish-log.txt`
- 작업 로그: `logs/YYYY-MM-DD/*.md`
- 실제 발행물: `posts/*.md`

---

## 2) Business / UX / Design principles (Gate 포함)

이 프로젝트는 “수익”보다 “자산”이 목적이다.

블로그가 자산이 되려면, 글이 계속 나가고, 읽히고, 신뢰가 쌓여야 한다.

### 2.1 Business

원칙.

- 목표는 트래픽이 아니라 신뢰다.
- 파이프라인 자동화로 발행 비용(시간/의지)을 낮춘다.
- 소재는 프로젝트 커밋에서 나온다(현실 기반).

Gate-Business.

- 매주 최소 1편은 posts로 발행된다.
- 발행 실패가 나도 “원인 확인 → 재시도” 루틴이 10분 안에 끝난다.

### 2.2 UX

독자는 “처음 3줄”에서 떠나거나 남는다.

- 글은 첫 문장에서 바로 핵심을 던진다.
- 문단은 짧게, 여백을 크게.
- 실패/삽질을 숨기지 않고, 대신 배울 거리를 준다.

Gate-UX.

- 글을 `prompts/blog-writing.md` 규칙으로 썼다.
- 한국어/영어 모두 같은 톤으로 자연스럽다(직역 금지).

### 2.3 Design

DEV.to는 디자인보다 텍스트 구조가 이긴다.

- 제목/설명/태그가 클릭을 만든다.
- 긴 글은 `<details>`로 접고, 코드는 최소한으로.
- 이모지는 최소.

Gate-Design.

- description은 짧고, 숫자/팩트를 포함한다.
- 태그는 최대 4개, 소문자.

---

## 3) Architecture snapshot

```text
/Users/jidong/dev_blog/
├─ posts/                     # 발행 대상 글(DEV.to)
├─ prompts/blog-writing.md    # 글쓰기 규칙(문체/구조/한영)
├─ logs/YYYY-MM-DD/           # 커밋 기반 worklog(소재)
├─ tools/                     # worklog 자동 생성(깃 훅)
├─ .github/workflows/publish.yml
└─ publish-log.txt            # 마지막 발행 시도 로그
```

외부 서비스.

- DEV.to API
- GitHub Actions (크론 + push 트리거)

---

## 4) Phases & Gates

이 레포는 기능 개발보다 운영 품질이 전부다.

### Phase 0: 기반 (Done)

목표.

자동 발행이 돌아가고, 중복/실패에 대한 최소한의 보호가 있다.

Gate.

- `posts/*.md`를 푸시하면 GitHub Actions가 DEV.to 발행을 시도한다.
- 성공 시 frontmatter에 `id:`/`date:`가 자동으로 써지고 커밋된다.

### Phase 1: “글 생산” 표준화 (Now)

목표.

worklog가 posts로 자연스럽게 승격되게 만든다.

Gate.

- STATUS에 다음 발행 후보 1~3개가 항상 있다.
- KO+EN 페어링 규칙이 지켜진다.

P0 태스크.

- `docs/STATUS.md`에 “이번 주 발행 목표”와 “다음 글”을 유지한다.
- `prompts/blog-writing.md`를 글 생성/리라이트의 단일 기준으로 쓴다.

### Phase 2: 품질 Gate 자동화 (Next)

목표.

실수(프론트매터/태그/퍼블리시 플래그/중복)를 자동으로 잡는다.

Gate.

- PR/커밋 시 “형식 검사”가 실패를 먼저 만든다(발행 전에).

(현재는 문서 기반 Gate만 있고, 스크립트 Gate는 선택사항이다.)

---

## 5) Publishing pipeline gates (재현 가능한 체크)

발행은 단순해야 한다.

하지만 실수는 대부분 “앞에서” 잡아야 한다.

### Gate A: 글 파일 형식

- 파일 위치: `posts/*.md`
- frontmatter 포함
- `tags`는 4개 이하, 소문자

### Gate B: publish 플래그

- 새 글은 항상 `published: false`로 시작한다.
- 준비가 되면 `published: true`로 바꾼다.

(이 파이프라인은 draft-then-publish 전략을 사용한다.)

### Gate C: 중복 방지

- `id:`가 이미 있으면 pipeline은 스킵한다.
- DEV.to에 같은 title이 있으면 duplicate로 처리하고 기존 id를 쓴다.

### Gate D: 실패 회복 가능성

- 실패해도 다음 실행에서 “재생성”이 아니라 “상태 복구”가 되어야 한다.

---

## 6) Failure recovery (Runbook)

### 6.1 GitHub Actions 실패

1) `publish-log.txt`를 본다.

- HTTP status
- response body(일부)
- rate-limit headers

2) 실패 유형을 분류한다.

- 403: 권한/토큰/발행 방식 문제 가능
- 429: rate limit
- 5xx: DEV.to 서버 문제

3) 재시도.

- 자동 크론: 6시간마다 돌아간다.
- 수동 실행: Actions → Publish to DEV.to → Run workflow

### 6.2 draft는 만들어졌는데 publish가 실패한 경우

이 경우 frontmatter에 이렇게 남는다.

- `id: <number>`
- `date: 'draft'`

다음 실행에서는 `id:`가 있으니 “재발행”을 안 한다.

다시 publish를 시도하고 싶으면 이 두 줄을 지우고 푸시한다.

### 6.3 잘못된 글을 올렸을 때(롤백)

DEV.to에서의 롤백은 이 레포가 완전히 자동화하지 않는다.

권장 순서.

- DEV.to에서 글을 unpublish 또는 삭제
- 이 레포에서는 해당 포스트의 `id:`/`date:`를 제거하고 다시 푸시(필요할 때만)

---

## 7) Status / Worklog linkage

### 7.1 STATUS는 1장

`docs/STATUS.md`는 운영의 single source of truth다.

- 이번 주 목표
- 다음 발행 후보
- 현재 파이프라인 상태
- 확인 커맨드

### 7.2 worklog는 어디서 오나

`tools/install-worklog-hooks.sh`를 실행하면, 여러 레포에 `post-commit` 훅이 설치된다.

그 훅이 매 커밋마다 `dev_blog/logs/YYYY-MM-DD/<project>-<sha>.md`를 만든다.

즉.

- logs는 “소재 자동 수집”
- posts는 “의도적으로 편집된 발행물”

### 7.3 worklog → posts 승격 규칙

기본 원칙.

- worklog는 그대로 올리지 않는다(메모는 메모다).
- logs를 재료로 삼아서 `prompts/blog-writing.md` 규칙에 맞게 글을 다시 쓴다.
- 한 주제면 KO/EN 2편으로 만들고, 같은 날(또는 같은 주) 안에 묶어 낸다.

실무 흐름(권장).

- logs에서 한 파일을 고른다.
- “왜 했는지 / 무엇이 바뀌었는지 / 어떤 수치가 나왔는지”를 중심으로 재구성한다.
- `posts/`에 KO/EN을 만든다.

---

## 8) Writing spec (링크)

글쓰기 규칙은 여기 하나로 끝낸다.

- `prompts/blog-writing.md`

---

## 9) Decisions

큰 결정이 생기면 문서로 남긴다.

- (선택) `docs/DECISIONS.md`
