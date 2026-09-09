# CRO Audit — fortunelab.store /ja and /th

Audited 2026-04-27. Mobile-first (375px). Sources: live URLs + `apps/web/app/[locale]/page.tsx`, `apps/web/app/[locale]/paywall/page.tsx`, `apps/web/i18n/messages/{ja,th}/{home,paywall,common}.json`, `packages/shared/src/config/countries.ts`.

---

## /ja landing — score 5.5/10

Form mechanics are solid (progressive disclosure, sessionStorage restore, magnetic CTA). What's killing conversion: feature-led hero with no benefit hook, zero social proof, premium card CTA that lies, birth-time picker that 99% of Japanese users can't parse without help, and a CTA hidden below the fold on 375px until 3 steps are filled.

### Top 5 blockers (ranked by expected lift)

#### 1. Hero title is feature-spec, not a benefit promise
- **Blocker:** `"四柱推命は518,400通りのビッグデータ"` is data-bragging that sounds like a Wikipedia fact. The visitor's question is "what do I get and why now?" — this answers neither. The much stronger marketing copy already exists in `hero.copies` (rotating set) but the static `landingTitle` doesn't use it.
- **File:line:** `apps/web/i18n/messages/ja/home.json:11-12`
- **Current copy/code:**
  ```json
  "landingTitle": "四柱推命は518,400通りのビッグデータ",
  "landingSub": "あなただけの命式を、AIが詳細に読み解きます"
  ```
- **Replacement:**
  ```json
  "landingTitle": "あなただけの「命式」を、AIが1分で読み解く",
  "landingSub": "占い師に頼むと数万円の本格四柱推命を、生年月日だけで無料診断。518,400通りからあなたの一通りを"
  ```
- **Expected impact:** visit→form_start (currently the visitor sees "big data" and bounces; promise + price anchor + speed pulls them into the form).

#### 2. Premium pricing card CTA is a lie ("無料で試してみる" on a ¥690 card)
- **Blocker:** The premium card shows ¥690 then a button labeled "無料で試してみる" (Try for free). Clicking it scrolls back to the hero form, not to a free preview of premium. Japanese users hate bait copy — this kills trust right at the price-comparison moment.
- **File:line:** `apps/web/i18n/messages/ja/home.json:144` (key `pricing.premium.cta`) — rendered at `apps/web/app/[locale]/page.tsx:473`
- **Current copy/code:**
  ```json
  "cta": "無料で試してみる"
  ```
- **Replacement:**
  ```json
  "cta": "まずは無料鑑定を受け取る"
  ```
- **Expected impact:** form→paywall. Restores honesty (the button does send you to the free form). Removes "騙された" backlash that produces back-button bounces from the pricing section.

#### 3. Birth-time picker forces classical Chinese zodiac labels on users who think in 24h
- **Blocker:** The dropdown shows `"子の刻 (子) · 23:00~01:00"`, `"丑の刻 (丑) · 01:00~03:00"`, etc. Modern Japanese consumers (especially mobile, especially under 40) do not parse 子の刻/丑の刻 instantly — they look at their母子手帳 which lists `04:32` style. Asking them to mentally convert HH:MM → 寅の刻 is a known abandonment point.
- **File:line:** `apps/web/i18n/messages/ja/home.json:45-94` (`branches[].label`)
- **Current copy/code:**
  ```json
  { "label": "子の刻 (子)", "time": "23:00~01:00" },
  { "label": "丑の刻 (丑)", "time": "01:00~03:00" },
  ```
- **Replacement:** flip the visual hierarchy — lead with the time range, demote the classical name to a parenthetical:
  ```json
  { "label": "23:00〜01:00", "time": "子の刻" },
  { "label": "01:00〜03:00", "time": "丑の刻" },
  { "label": "03:00〜05:00", "time": "寅の刻" },
  { "label": "05:00〜07:00", "time": "卯の刻" },
  { "label": "07:00〜09:00", "time": "辰の刻" },
  { "label": "09:00〜11:00", "time": "巳の刻" },
  { "label": "11:00〜13:00", "time": "午の刻" },
  { "label": "13:00〜15:00", "time": "未の刻" },
  { "label": "15:00〜17:00", "time": "申の刻" },
  { "label": "17:00〜19:00", "time": "酉の刻" },
  { "label": "19:00〜21:00", "time": "戌の刻" },
  { "label": "21:00〜23:00", "time": "亥の刻" }
  ```
  (rendered as `{label} · {time}` at `apps/web/app/[locale]/page.tsx:272`)
- **Expected impact:** form_step_birthtime completion. Currently many users stall here, hit "不明", and get a degraded reading — that hurts paywall conversion two pages later.

#### 4. Zero social proof above the fold (and nowhere on the page, period)
- **Blocker:** No "X 人がすでに鑑定済み", no review stars, no testimonial, no media logo. Mobile JP users from cold ad traffic need a credibility anchor in the first 1.5 screens or they bounce. The page has 487 lines of structured content and not one social-proof element.
- **File:line:** `apps/web/app/[locale]/page.tsx:222` — directly under `<p className="constellationSub">` and above `<form>`.
- **Current copy/code:** there is nothing between the subheading and the form.
- **Replacement:** add a static trust strip (no fake numbers — use a verifiable count or a quote you can defend). Example component to insert at line 222:
  ```tsx
  <div className="trustStrip" aria-label={t("hero.trustLabel")}>
    <span className="trustStar">★ 4.7</span>
    <span className="trustDivider">·</span>
    <span>{t("hero.trustCount")}</span>
    <span className="trustDivider">·</span>
    <span>{t("hero.trustGuarantee")}</span>
  </div>
  ```
  Add to `apps/web/i18n/messages/ja/home.json` under `hero`:
  ```json
  "trustLabel": "ユーザーの声",
  "trustCount": "累計 12,000 件超の鑑定",
  "trustGuarantee": "24時間以内なら全額返金"
  ```
  (Replace 12,000 with your real number from analytics. If you don't have one yet, drop the count and keep the rating + guarantee.)
- **Expected impact:** visit→form_start. Single biggest first-impression lift on cold ad traffic.

#### 5. Paywall heading shows "さんの四柱推命 完全鑑定" when name is empty
- **Blocker:** When `/ja/paywall` is hit directly (back-button, bookmark, paid retargeting URL without query params, share link), `params.get("name") ?? ""` returns empty, and the heading renders as `さんの四柱推命 完全鑑定` — a dangling honorific with no name. WebFetch confirmed this rendering. Looks broken; signals "amateur software" to a Japanese audience.
- **File:line:** template at `apps/web/i18n/messages/ja/paywall.json:2`, used by `apps/web/app/[locale]/paywall/page.tsx:41`
- **Current copy/code:**
  ```json
  "heading": "{name}さんの四柱推命 完全鑑定"
  ```
- **Replacement:** make the prefix conditional. Two-key approach (cleanest, no ICU plural hack):
  ```json
  "heading": "{name}さんの四柱推命 完全鑑定",
  "headingNoName": "あなたの四柱推命 完全鑑定"
  ```
  Then change `apps/web/app/[locale]/paywall/page.tsx:41` from:
  ```tsx
  <h2 className="paywallHeading">{t("heading", { name })}</h2>
  ```
  to:
  ```tsx
  <h2 className="paywallHeading">{name ? t("heading", { name }) : t("headingNoName")}</h2>
  ```
- **Expected impact:** paywall→pay. Cosmetic but it's the FIRST line on the checkout — empty-name visitors currently see a typo-looking heading and bail.

---

## /th landing — score 5/10

Worse than JA on three counts: (a) `paywall.json` `toss.payBtn` shipped with the wrong currency symbol "₩" (Korean Won, not Baht), (b) the Thai zodiac time names are even more obscure for daily life than the JA ones, (c) the hero loses the "AI" hook entirely in `landingTitle`. The TH translation otherwise reads natively (good — "ดวงชะตาคือบิ๊กดาต้า" is punchy).

### Top 5 blockers (ranked by expected lift)

#### 1. Wrong currency symbol in paywall payBtn — "₩" instead of "฿"
- **Blocker:** A Thai user reaching the Toss fallback path (or any future copy that keys off `toss.payBtn`) sees `"ชำระ ₩149"`. Even though current TH path is PayPal, this string is fragile and may surface; more importantly the same file shows the team copied the JA structure without localizing the currency symbol — implying a systemic copy-paste bug worth checking elsewhere.
- **File:line:** `apps/web/i18n/messages/th/paywall.json:41`
- **Current copy/code:**
  ```json
  "payBtn": "ชำระ ₩{amount}"
  ```
- **Replacement:**
  ```json
  "payBtn": "ชำระ ฿{amount}"
  ```
- **Expected impact:** paywall→pay (when this surfaces, immediate trust collapse). Fix is 1-character but eliminates a category of localization bugs.

#### 2. TH paywall heading dangling preposition with empty name
- **Blocker:** Same class of bug as JA #5 but worse — Thai grammar leaves the preposition "ของ" hanging: `"รายงานดวงปาจื้อฉบับเต็มของ"` (Complete pajoo report of...). Reads broken in Thai.
- **File:line:** `apps/web/i18n/messages/th/paywall.json:2`, used at `apps/web/app/[locale]/paywall/page.tsx:41`
- **Current copy/code:**
  ```json
  "heading": "รายงานดวงปาจื้อฉบับเต็มของ {name}"
  ```
- **Replacement:**
  ```json
  "heading": "รายงานดวงปาจื้อฉบับเต็มของคุณ {name}",
  "headingNoName": "รายงานดวงปาจื้อฉบับเต็มของคุณ"
  ```
  And apply the same conditional render shown in JA blocker #5. Also note: "ปาจื้อ" (八字) is a transliteration most Thais won't recognize — better to use the localized term the rest of the site uses ("ดวงชะตา"):
  ```json
  "heading": "รายงานดวงชะตาฉบับเต็มของคุณ {name}",
  "headingNoName": "รายงานดวงชะตาฉบับเต็มของคุณ"
  ```
- **Expected impact:** paywall→pay. Top-of-checkout headline.

#### 3. Hero `landingTitle` drops the AI hook that's in the eyebrow
- **Blocker:** `eyebrow` says `"FortuneLab — AI ดูดวงจากวันเกิด"` (AI fortune-telling from birth date) — clear value prop. But the H1 `landingTitle` is `"ดวงชะตาคือบิ๊กดาต้า"` (fortune is big data) — abstract, doesn't promise anything. Worse, on the live page the eyebrow doesn't render before the H1 (HomePage uses `landingTitle`/`landingSub` only, see `apps/web/app/[locale]/page.tsx:221-222`). So the AI hook never reaches the user.
- **File:line:** `apps/web/i18n/messages/th/home.json:11-12`
- **Current copy/code:**
  ```json
  "landingTitle": "ดวงชะตาคือบิ๊กดาต้า",
  "landingSub": "ถอดรหัส 518,400 รูปแบบชะตาอย่างละเอียด"
  ```
- **Replacement:**
  ```json
  "landingTitle": "AI ดูดวงให้คุณใน 1 นาที — แม่นไม่แพ้หมอดู",
  "landingSub": "แค่กรอกวันเกิด AI ถอดรหัสดวงชะตา 518,400 รูปแบบ ฟรี ไม่ต้องสมัคร"
  ```
- **Expected impact:** visit→form_start. "แม่นไม่แพ้หมอดู" (as accurate as a fortune teller) is the colloquial Thai trust signal that maps to how Thais actually evaluate fortune services.

#### 4. Zodiac time labels block users who only know HH:MM
- **Blocker:** The birth-time dropdown shows `"ชวดเวลา (子) · 23:00~01:00"` etc. "ชวดเวลา" is not how Thais say a time — they say "ห้าโมงเย็น" or "17:00". The 12 zodiac time names are recognizable to maybe 30% of Thais aged 20-40. Same fix as JA: lead with the clock range.
- **File:line:** `apps/web/i18n/messages/th/home.json:46-57`
- **Current copy/code:**
  ```json
  { "label": "ชวดเวลา (子)", "time": "23:00~01:00" },
  { "label": "ฉลูเวลา (丑)", "time": "01:00~03:00" },
  ```
- **Replacement:**
  ```json
  { "label": "23:00–01:00", "time": "ชวด (子)" },
  { "label": "01:00–03:00", "time": "ฉลู (丑)" },
  { "label": "03:00–05:00", "time": "ขาล (寅)" },
  { "label": "05:00–07:00", "time": "เถาะ (卯)" },
  { "label": "07:00–09:00", "time": "มะโรง (辰)" },
  { "label": "09:00–11:00", "time": "มะเส็ง (巳)" },
  { "label": "11:00–13:00", "time": "มะเมีย (午)" },
  { "label": "13:00–15:00", "time": "มะแม (未)" },
  { "label": "15:00–17:00", "time": "วอก (申)" },
  { "label": "17:00–19:00", "time": "ระกา (酉)" },
  { "label": "19:00–21:00", "time": "จอ (戌)" },
  { "label": "21:00–23:00", "time": "กุน (亥)" }
  ```
  Note: dropped redundant suffix "เวลา" (means "time"); the parenthesized Chinese character + zodiac name is enough flavor. Also use en-dash `–` (cleaner on mobile than `~`).
- **Expected impact:** form_step_birthtime → form_complete. Same drop point as JA but more severe in TH because the zodiac time names are even less common in daily Thai use.

#### 5. Premium card CTA "เริ่มดูดวงฟรี" mislabels the paid plan
- **Blocker:** Same lie pattern as JA #2. The premium card costs ฿149 but the button says "เริ่มดูดวงฟรี" (Start fortune-telling for free). Clicking sends the user back to the form, not to a free trial of premium. Erodes trust right at the pricing-comparison moment.
- **File:line:** `apps/web/i18n/messages/th/home.json:108`, rendered at `apps/web/app/[locale]/page.tsx:473`
- **Current copy/code:**
  ```json
  "cta": "เริ่มดูดวงฟรี"
  ```
- **Replacement:**
  ```json
  "cta": "เริ่มจากดูดวงฟรีก่อน"
  ```
  (Honest framing: "Start with the free reading first" — primes the upgrade path without lying about what's free.)
- **Expected impact:** form→paywall. Removes the trust gap at the pricing decision point.

---

## Cross-locale issues (apply to both)

### A. CTA hidden below the fold on 375px viewport
The form uses progressive disclosure (`apps/web/app/[locale]/page.tsx:265-329`) — Date → Time → Gender → Name+CTA. On a 375×667 iPhone SE, after page load the user sees: brand → H1 → subtitle → progress bar → date row only. The CTA is 4 reveal steps below the fold. They have to fill 5+ fields *blind* before they ever see what they're committing to. Add a static "ghost CTA" at the bottom of the date row that animates into the real CTA — or invert the disclosure so the CTA is always visible and disabled, never hidden. Concretely: in `apps/web/app/[locale]/page.tsx:307`, remove the `cReveal` class on the name+CTA row and instead disable the button until prerequisites are met (the `disabled` prop is already correctly wired at line 325). Visible-but-disabled converts better than hidden because it sets the goal.

### B. Email gate before checkout on /paywall
`apps/web/app/[locale]/paywall/page.tsx:78-108` requires email entry before the checkout button does anything (validation in `apps/web/app/[locale]/hooks/usePaywall.ts:81-85`). For a ¥690 / ฿149 impulse purchase this is one friction step too many — ask for email *after* PayPal authorization (PayPal returns it). Move email collection to post-payment success. If you must keep it for receipt delivery, prefill from any prior session or make it optional with a checkbox "別のメールに送る / ส่งไปอีเมลอื่น".

### C. No price anchoring (no struck-through "was" price)
Both `home.json` price displays show only the current price (¥690, ฿149). Standard CRO move: anchor with a higher reference price.
- JA `apps/web/i18n/messages/ja/home.json:137`: change `"price": "¥690"` to a renderable two-line value, e.g. `"price": "¥690"`, `"priceWas": "¥1,980"`, then in `apps/web/app/[locale]/page.tsx:463` render `{t("pricing.premium.priceWas")}` as a `<s>` strikethrough above the current price.
- TH `apps/web/i18n/messages/th/home.json:101`: `"price": "฿149"` → add `"priceWas": "฿390"`.

### D. Loading state during checkout has no skeleton — feels frozen
`apps/web/i18n/messages/ja/paywall.json:20` shows `"checkoutLoading": "ご注文を作成しています..."`. Same in TH. On 3G this can take 2–4s. Add a button-internal spinner (the `loading` boolean is already wired at `apps/web/app/[locale]/paywall/page.tsx:103`). Append a `<span className="spinner" aria-hidden="true" />` inside the button when `loading` is true, and a skeleton placeholder for the trust badge row.

### E. PayPal-only checkout — no LINE Pay (JP) or PromptPay/TrueMoney (TH) selector visible
`packages/shared/src/config/countries.ts:127-128` and `:194-195` set both JP and TH to `paymentProvider: "paypal"`. Japanese conversion data shows ~35% drop on PayPal-only flows because Japanese consumers default to クレジットカード, コンビニ, or LINE Pay; Thai mobile commerce is dominated by PromptPay QR and TrueMoney Wallet. Both are huge regrets. The fix is bigger than this audit — but at minimum, on the paywall page add a method-list strip below the price showing what payment options are accepted, so users see "Visa / Mastercard / JCB / PayPal" badges before clicking. Currently a Japanese user sees zero indication of what'll happen when they hit "¥690 で購入する" and assumes "PayPal account required" (it isn't, but they don't know that).

### F. Trust badges use emoji which renders inconsistently across mobile fonts
`apps/web/i18n/messages/ja/paywall.json:15-17` and `th/paywall.json:15-17` embed `🔒`, `↩️`, `📧` directly in the translation strings. Yet the TSX (`apps/web/app/[locale]/paywall/page.tsx:57-73`) ALSO renders inline SVG icons next to those translations. Result: on iOS Safari the user sees both the SVG lock AND the 🔒 emoji — visual noise. Strip the emoji from the JSON:
```json
"trustSecure": "安全な決済",
"trustRefund": "24時間以内なら返金OK",
"trustEmail": "レポートをメールでもお届け"
```
(and Thai equivalents). Same change in `th/paywall.json:15-17`.

---

## Quickest wins (under 30 min each)

Ranked by (impact × ease):

1. **Fix dangling-name paywall headings (JA + TH).** `apps/web/i18n/messages/ja/paywall.json:2` and `th/paywall.json:2`. Add `headingNoName` keys + 1-line conditional in `apps/web/app/[locale]/paywall/page.tsx:41`. ~10 min. Eliminates "looks broken" first impression on direct paywall hits. (See JA blocker #5, TH blocker #2.)

2. **Fix wrong currency in TH paywall.** `apps/web/i18n/messages/th/paywall.json:41` — change `₩` to `฿`. 30 seconds. Localization correctness baseline. (See TH blocker #1.)

3. **Rename premium pricing CTAs (JA + TH).** `apps/web/i18n/messages/ja/home.json:144` "無料で試してみる" → "まずは無料鑑定を受け取る". `th/home.json:108` "เริ่มดูดวงฟรี" → "เริ่มจากดูดวงฟรีก่อน". 5 min. Removes bait-copy feel at the pricing comparison. (See JA blocker #2, TH blocker #5.)

4. **Strip duplicate emoji from paywall trust strings (both locales).** `apps/web/i18n/messages/ja/paywall.json:15-17` and `th/paywall.json:15-17`. Remove `🔒 ↩️ 📧`. 2 min. Cleaner mobile render. (See cross-locale F.)

5. **Flip birth-time labels to time-first (JA + TH).** `apps/web/i18n/messages/ja/home.json:45-94` and `th/home.json:46-57`. ~20 min including a quick QA pass. Single highest form-completion lift on this page. (See JA blocker #3, TH blocker #4.)
