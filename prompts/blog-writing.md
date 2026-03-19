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

-----

## SEO 최적화 가이드 (2025-2026)

이 섹션은 블로그 글 작성 시 적용해야 할 SEO 체크리스트다. 플랫폼별로 다르게 적용한다.

-----

### 제목 최적화

제목은 55~65자(영문 기준). 70자 초과하면 검색결과에서 잘린다. 핵심 키워드를 제목 앞쪽에 배치한다. Google은 앞에 있는 단어에 더 높은 가중치를 준다.

패턴: `[숫자] + [결과/혜택] + [키워드]` 또는 `[키워드]: [구체적 결과]`

예시: "I Cut My API Costs by 94% — Here's the Exact Prompt" (좋음) vs "A Study on Cost Optimization Methods for AI APIs" (나쁨)

한국어 제목은 30자 내외. 네이버에서는 키워드가 제목 앞부분에 있어야 상위 노출 확률이 높다.


### 메타 설명 (Description)

140~160자(영문). 한국어는 70~80자. 사용자 의도에 맞는 가치를 전달하고, "Learn how", "Discover", "Find out" 같은 클릭 유도 문구를 자연스럽게 넣는다. 핵심 키워드를 반드시 포함한다.

DEV.to frontmatter의 `description` 필드가 메타 설명 역할을 한다. 현재 스킬 규칙(50자 내외 한/120자 내외 영)을 유지하되, 영문은 가능하면 140자까지 확장해도 좋다.


### 헤더 구조 (H1 → H2 → H3)

H1은 페이지당 1개. 기본 키워드를 포함한다. H2는 주요 섹션 제목으로 관련 키워드를 자연스럽게 넣는다. H3은 H2의 하위 세부 내용이다.

Google은 헤더 구조를 통해 글의 토픽 계층을 파악한다. H2를 건너뛰고 H3을 쓰거나, H1을 여러 개 쓰면 안 된다.

DEV.to에서는 제목이 H1이므로 본문에서는 `##`(H2)부터 시작한다.


### URL 슬러그

짧고 설명적으로. 영문 소문자, 하이픈으로 구분. 불필요한 단어(the, a, and, of)를 뺀다.

좋은 예: `/blog/cut-api-costs-94-percent`
나쁜 예: `/blog/how-i-managed-to-cut-my-api-costs-by-94-percent-using-prompt-engineering`

Astro 블로그에서는 파일명이 슬러그가 된다. 파일명을 만들 때부터 키워드를 넣는다.


### 이미지 Alt 텍스트

모든 이미지에 alt 텍스트를 넣는다. 이미지 내용을 구체적으로 설명하되, 키워드를 자연스럽게 포함한다. "image of" "picture of" 같은 불필요한 접두어를 쓰지 않는다.

좋은 예: `alt="API 비용 비교 차트: GPT-4 $0.085 vs Haiku $0.005 per request"`
나쁜 예: `alt="chart"` 또는 alt 텍스트 없음


### 내부/외부 링크 전략

글 하나에 내부 링크 2~3개, 외부 링크 1~2개를 목표로 한다. 내부 링크는 관련 이전 글로 연결해서 체류 시간을 늘린다. 외부 링크는 신뢰할 수 있는 출처(공식 문서, GitHub, 논문)로 연결한다.

앵커 텍스트는 구체적으로. "여기 클릭"이 아니라 "GPT-4o 가격 정책"처럼 링크 대상의 내용을 담는다.


### Schema Markup (JSON-LD)

Astro 블로그에 `BlogPosting` 스키마를 추가한다. 검색결과에 리치 스니펫(작성자, 날짜, 설명)이 표시된다.

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "글 제목",
  "description": "메타 설명",
  "author": {
    "@type": "Person",
    "name": "작성자명",
    "url": "https://jidonglab.com"
  },
  "datePublished": "2026-03-19",
  "dateModified": "2026-03-19",
  "image": "커버 이미지 URL",
  "publisher": {
    "@type": "Organization",
    "name": "Make Me Rich AI",
    "logo": { "@type": "ImageObject", "url": "로고 URL" }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "글의 canonical URL"
  }
}
```

Astro에서는 `<script type="application/ld+json">` 태그로 레이아웃 컴포넌트에 삽입한다. `astro-seo-schema` npm 패키지를 사용하면 타입 안전하게 구현 가능하다. 검증은 Schema.org Markup Validator 또는 Google Rich Results Test로 한다.


### Open Graph / Twitter Card 메타 태그

소셜 미디어에서 공유될 때 미리보기 카드를 제어한다. 필수 태그 5개 + twitter:card:

```html
<meta property="og:title" content="글 제목" />
<meta property="og:description" content="메타 설명" />
<meta property="og:image" content="1200x630px 이미지 URL" />
<meta property="og:url" content="canonical URL" />
<meta property="og:type" content="article" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@jee599" />
```

이미지는 최소 1200x630px, 비율 1.91:1. `twitter:card`와 `twitter:site`만 설정하면 나머지는 OG 태그에서 자동 상속된다. Facebook Sharing Debugger와 Twitter Card Validator로 미리보기를 확인한다.

DEV.to는 커버 이미지와 제목/설명을 자동으로 OG 태그에 매핑하므로 별도 설정 불필요.


### DEV.to Canonical URL 전략

원본은 항상 개인 블로그(jidonglab.com)에 먼저 발행한다. 1주 후 DEV.to에 크로스 포스팅한다. 이렇게 하면 Google이 원본을 먼저 인덱싱한다.

RSS 자동 임포트 설정: Settings → Extensions → "Publishing to DEV Community from RSS" → RSS URL 입력 → "Mark the RSS source as canonical URL by default" 체크 → Submit.

수동 설정: 글 에디터 하단 펜타곤 아이콘 → canonical URL 필드에 원본 URL 입력.

canonical URL을 설정하면 DEV.to 글의 트래픽/링크가 원본 블로그의 SEO 크레딧으로 잡힌다.


### Medium Canonical URL 전략

Medium에 크로스 포스팅할 때도 canonical URL을 설정한다. Medium의 Import Tool(medium.com/p/import)을 사용하면 canonical 태그가 자동 유지된다. 수동 작성 시에는 Story Settings에서 canonical link를 원본 URL로 지정한다.

Medium은 도메인 권한(DA)이 높아서 검색결과에서 개인 블로그보다 위에 뜰 수 있다. canonical URL이 없으면 원본 블로그의 랭킹이 밀린다.

Medium 태그는 최대 5개. 검색량이 높은 태그를 선택하고, 1개는 반드시 대중적 태그(Programming, JavaScript, AI 등)로 넣는다.


### 네이버 검색 최적화

네이버는 Google과 다른 알고리즘을 사용한다. 2025년부터 "키워드 매칭"보다 "의도 일치"를 중시한다.

네이버 서치어드바이저 설정: searchadvisor.naver.com에서 사이트 등록 → 소유권 확인(HTML 태그 또는 파일) → sitemap.xml 제출 → RSS 제출. 크롤링 현황, 인덱싱 상태, 클릭률을 모니터링한다.

네이버 블로그 키워드 전략: 1500~2000자 기준으로 제목+본문에 키워드 5~6회 자연스럽게 배치한다. 대표 키워드의 검색량 10~30% 수준인 롱테일 키워드를 노린다. 네이버 키워드 도구(searchad.naver.com)로 검색량을 확인한다.

네이버 블로그 상위노출 핵심: C-Rank(블로그 전문성 점수)와 D.I.A(콘텐츠 품질 평가). 하나의 주제로 꾸준히 글을 써야 C-Rank가 올라간다. 클릭률, 체류 시간, 이탈률 같은 사용자 행동 데이터가 순위에 직접 영향을 준다.


### Google Search Console 연동

search.google.com/search-console에서 사이트 등록 → 소유권 확인(DNS, HTML 태그, 또는 파일) → sitemap.xml 제출.

모니터링 항목: 인덱싱 상태(어떤 페이지가 인덱싱됐는지), 검색 성과(노출수, 클릭수, CTR, 평균 순위), 크롤링 오류. 새 글을 발행하면 URL 검사 도구로 인덱싱을 요청할 수 있다.

Astro 블로그는 `@astrojs/sitemap` 패키지로 빌드 시 자동 sitemap 생성. `robots.txt`에 sitemap 위치를 명시한다.


### 키워드 리서치 (개발자 콘텐츠)

개발자 콘텐츠의 키워드는 일반 마케팅 키워드와 다르다. 검색량보다 의도 정확도가 중요하다.

도구: Google Keyword Planner(무료), Ubersuggest, Ahrefs, 네이버 키워드 도구(searchad.naver.com). daily.dev의 Tech Trend Keyword Finder도 개발자 트렌드 파악에 유용하다.

전략: 롱테일 키워드를 노린다. 전체 검색 트래픽의 70%가 롱테일에서 온다. "React" 대신 "React server component data fetching pattern"처럼 구체적으로. 키워드 클러스터링으로 관련 쿼리를 묶어서 하나의 글이 여러 검색어에 랭킹되게 한다.

경쟁 분석: 목표 키워드를 검색해서 상위 10개 글의 평균 길이, 구조, 다루는 하위 주제를 파악한 뒤 더 깊거나 더 실용적인 글을 쓴다.


### 콘텐츠 길이

기술 블로그 최적 길이는 1,500~2,500단어(영문). 한국어는 2,000~3,000자(현재 스킬 규칙과 일치). 단, 길이 자체는 랭킹 팩터가 아니다. 주제를 충분히 커버하는 깊이가 핵심이다.

경쟁 키워드일수록 더 깊은 콘텐츠가 필요하다. 상위 10개 글 평균이 2,000단어면 그 깊이를 맞추거나 넘어야 한다.


### Featured Snippets / AI Overview 최적화

2025~2026년 기준으로 Featured Snippets 노출 비율이 64% 하락했다(AI Overview 확대 때문). 하지만 여전히 fact-based 질문("What is X?", "How to Y?")에서는 유효하다.

최적화 방법: H2/H3 바로 아래에 40~60단어로 핵심 답변을 먼저 제공한다. 정의, 순서, 비교 형식이 추출에 유리하다. 구조화된 데이터(Schema)를 함께 사용하면 AI Overview에서 인용될 확률도 높아진다. E-E-A-T(경험, 전문성, 권위, 신뢰) 시그널을 강화한다.

2026년 핵심 변화: AI Overview가 검색의 47%에 등장하고, 그 중 83%가 zero-click이다. 전통적 SEO를 잘 해야 AI Overview에도 인용된다. 상위 20위 안에 있는 페이지의 97%가 AI Overview에 인용된다.


### SEO 체크리스트 (글 발행 전)

글을 발행하기 전에 확인한다.

- 제목에 핵심 키워드가 앞쪽에 있는가 (55~65자 영문 / 30자 한글)
- description에 키워드와 클릭 유도 문구가 있는가
- H2/H3 구조가 논리적인가, H1은 하나인가
- 이미지에 alt 텍스트가 있는가
- 내부 링크 2~3개, 외부 링크 1~2개가 있는가
- URL 슬러그가 짧고 키워드를 포함하는가
- canonical URL이 올바르게 설정됐는가 (크로스 포스팅 시)
- OG/Twitter Card 메타 태그가 설정됐는가 (Astro 블로그)
- sitemap이 업데이트됐는가
