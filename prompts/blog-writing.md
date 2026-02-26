## name: blog-writing

description: Use this skill whenever the user asks to write a blog post, create blog content, or mentions ‘블로그’, ‘blog’, ‘post’, or ‘article’. Also trigger when the user drops raw materials (conversation logs, notes, screenshots) and wants them turned into blog posts. This skill defines the writing style, structure, tone, and bilingual (Korean/English) publishing rules for a solo developer’s AI build log. Always use this skill for any blog-related writing task, even if the user doesn’t explicitly say ‘use the blog skill’.

# Blog Writing Skill

이 스킬은 블로그 글 작성 시 따라야 할 스타일, 구조, 규칙을 정의한다. 소재(대화 내용, 메모, 스크린샷 등)를 받으면 이 가이드에 맞춰 블로그 글을 생성한다.

> 주의: 이 스킬 문서 자체는 가이드 정리용으로 표, 구분선 등을 사용한다. 실제 블로그 출력물에는 이 문서의 포맷팅을 따르지 않는다. 블로그 출력물은 아래 규칙을 따른다.

-----

## 블로그 정체성

- 저자: AI를 공부하고, AI로 프로덕트를 만들고, 수익화를 실험하는 1인 개발자
- 목표: AI로 돈 벌어보기. 사주 앱, 트레이딩 봇, 커피챗 등 여러 프로젝트 진행 중
- 블로그 목적: 그 과정 전체를 기록 + 브랜딩 + 교육
- 블로그 이름: Make Me Rich AI
- 플랫폼: DEV.to (GitHub Actions 자동 발행, 레포: jee599/dev_blog)

-----

## 문체 규칙

### 톤

- 대화체. 친구한테 설명하듯이. “~합니다”가 아니라 “~다” 체.
- 가볍지만 내용은 탄탄하게. 논문이 아니라 일기. 근데 배울 게 있는 일기.
- 솔직하게. 삽질, 실수, 모르는 것을 숨기지 않는다.
- 영어 버전도 같은 톤. 격식 없이, 직접적으로. 학술적이지 않게.

### 금지

- ❌ “~하겠습니다”, “~인 것 같습니다” 같은 존댓말
- ❌ 이모지 남용 (최소한으로, 제목에도 안 씀)
- ❌ “이 글에서는 ~에 대해 알아보겠습니다” 같은 교과서 도입부
- ❌ 불릿 포인트, 넘버링 리스트 절대 금지 (코드 블록 안의 나열도 최소화)
- ❌ “하나, 둘, 셋” 같은 넘버링 서술도 금지
- ❌ 결론에서 “정리하자면” “요약하면” 등 상투적 표현
- ❌ 뻔한 AI 블로그 톤 (“AI의 발전은 눈부시게~”)

### 권장

- ✅ 첫 문장에서 바로 핵심을 던진다
- ✅ 경험 기반. “나는 이렇게 했다”
- ✅ 구체적 숫자 포함 ($0.001, 88%, 28명 등)
- ✅ Before/After 대비 (❌ 잘못된 방식 vs ✅ 올바른 방식)
- ✅ 코드 블록으로 시각적 이해 도움
- ✅ 한줄 정리(인용구)로 마무리

### 가독성 규칙 (여백과 호흡)

글이 빽빽하면 안 읽힌다. 여백이 곧 가독성이다.

- 문단은 3~4줄 이내. 5줄 넘어가면 반드시 나눈다.
- 문단 사이에 빈 줄 1개. 항상.
- 핵심 문장은 홀로 한 줄에. 앞뒤를 비워서 강조한다.
- 코드 블록 앞뒤에 빈 줄.
- 섹션(##) 앞에는 빈 줄 2개 느낌으로 충분히 띄운다.
- 한 문장이 너무 길면 쪼갠다.
- 짧은 문장과 긴 문장을 섞는다.
- 나열이 필요하면 문장 속에 녹인다.
- “하나, 둘, 셋” 넘버링 서술 금지.

나쁜 예:

사주 앱을 만들면서 처음 비용을 계산했을 때 숫자를 보고 멈췄다. 무료 분석 1건에 $0.085이고 하루 1,000명이 오면 월 $2,550이 되는데 무료인데 돈이 나가는 구조라 유료 전환율이 3%여도 유료 매출로 무료 비용을 못 메운다.

좋은 예:

사주 앱을 만들면서 처음 비용을 계산했을 때 숫자를 보고 멈췄다.

무료 분석 1건에 $0.085.

하루 1,000명이 오면 월 $2,550.

무료인데 돈이 나간다.

이건 사업이 아니라 기부다.

-----

## 시각적 몰입 요소

글마다 최소 1개 이상 포함한다. 소재에 맞는 요소를 아래 기준으로 선택한다.

- 코드 변경이 있으면 → Before/After 코드
- 비용/성능/수치 비교가 있으면 → 숫자 강조 패턴
- 디버깅/시행착오/대화 기반 스토리면 → 대화체 장면 재현

※ DEV.to는 Mermaid를 네이티브 지원하지 않는다. 흐름도는 ASCII/코드블록으로.

-----

## DEV.to 트렌디 기법

### 제목에 숫자 + 결과

### 첫 3줄이 전부

### 커버 이미지

### 구분선(---)

### 볼드/이탤릭 전략

### <details>로 긴 코드 접기

### 강한 문장으로 끝내기

-----

## 글 구조

고정 구조 없음. 내용에 맞게 유연.

가능하면 포함:

- 첫 문장 핵심 (필수)
- 문제/배경 (권장)
- 삽질/깨달음 (권장)
- 구체적 내용 (권장)
- 한줄 정리(인용구) (필수)

글 마지막은 인용구로 끝낸다. 그 뒤에 아무것도 붙이지 않는다.

-----

## Frontmatter 및 메타데이터

템플릿(DEV.to):

---

title: [제목]

published: false

description: [한 줄 설명]

tags: [tag1, tag2, tag3, tag4]

---

- published: false — 항상 false.
- tags — 최대 4개, 소문자.

description 규칙:

- 50자 내외(한) / 120자 내외(영)
- 숫자 포함
- 질문 또는 충격적 사실

태그 전략:

- ai, webdev, beginners, productivity 중 최소 하나
- 나머지는 주제 태그

-----

## 분량

- 편당 2000~3000자 (한국어 기준)
- 5분 내외
- 한 글 한 메시지

-----

## 한영 동시 작성 규칙

한국어 1편 + 영어 1편.

영어는 직역이 아니라 영어 독자 관점에서 다시 쓴다.

한국 특화 개념은 첫 등장 1회만 풀어서 설명한다.

-----

## 소재 → 블로그 변환 프로세스

- 먼저 제안한다(몇 편/제목/한줄요약)
- 승인 받는다(편수/제목/방향)
- 승인 후 한영 동시 작성(frontmatter 포함)

승인 없이 바로 쓰지 않는다.

-----

## 문체 샘플

### 한국어

사주 앱을 만들면서 가장 먼저 배운 건, AI한테 뭘 시킬지가 아니라 뭘 안 시킬지였다.

"1990년 3월 15일생 사주 알려줘."

이렇게 LLM한테 바로 던졌다.

답변은 그럴듯하게 나온다.

근데 문제가 있다.

간지가 틀린다.

### 영어

The first lesson I learned building a fortune-telling app: it's not about what you ask AI to do — it's about what you don't.

"Tell me the fortune for someone born March 15, 1990."

I threw this straight at an LLM.

The response looked great.

But there was a problem.

The base calculations were wrong.
