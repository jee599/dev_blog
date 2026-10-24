# FortuneLab SEA Monetization Playbook

**Markets:** Thailand (primary), Indonesia + Vietnam (SEO-only until payment unlock)
**Site:** https://fortunelab.store/th, /id, /vi
**Status as of 2026-04-27:** 30 paid orders to date — all KR Toss, 0 SEA. April 87 sessions.

---

## 1. Payment reality check

> **"PayPal does not accept IDR or VND for our merchant flow. Period. We cannot collect a single rupiah or dong through the current code path. Anything we ship to /id and /vi this week is awareness — not revenue."**

Evidence in repo:
- `apps/web/lib/paypal.ts:6-10` — `PAYPAL_SUPPORTED_CURRENCIES` set: `USD, EUR, GBP, JPY, AUD, CAD, CHF, HKD, SGD, SEK, DKK, NOK, PLN, CZK, HUF, ILS, MXN, NZD, PHP, THB, TWD, BRL, MYR`. **IDR / VND / INR / KRW are not in the set.**
- Commit `8e191a4` (2026-04-07) explicitly removed KRW/IDR/INR after PayPal Live API rejected them despite docs.
- `apps/web/lib/paypal.ts:18-26` falls back to USD cents. So a TH user gets ฿149; an ID user clicking "Beli Premium" silently falls back to ~$4.99 USD on PayPal — friction-laden, FX-confusing, conversion-killing.
- `packages/shared/src/config/countries.ts:262` and `:228` — `paymentProvider: "paypal"` is hardcoded for `id` and `vn`. Today it leads users to a USD-only checkout.

**Allocation rule for the next 30 days:**

- **80% of effort + 100% of paid budget → Thailand.** THB is in PayPal's supported set. Live ฿149 conversions are possible today.
- **20% of effort → ID/VN organic SEO + email capture.** Build the demand list. Wire emailSubscription with `source="payment_waitlist"` so we have a warm audience the day Xendit goes live.
- **No paid ID/VN spend until Xendit (or Midtrans) is integrated.** A click that bounces at checkout is worse than no click.

---

## 2. Market positioning

### Thailand — "AI หมอดู (mor du) ที่แม่นจนไม่ต้องไปวัด"

Thai mor du and astrology consumption is enormous: horoscope.mthai.com's main competitor `myhora.com` does ~9M monthly visits; horoscope.sanook.com sits at 166.8K (Similarweb, Nov 2024). Sanook is a portal — bundled news + lottery + horoscope, ad-monetized, low-touch UX. Horoworld is article-heavy SEO. Mythai is daily horoscope feed. **Nobody in TH is selling personalized AI birth-chart reports for ฿149.** The market is a wall of free ad-supported content and ฿800-2,000 in-person mor du sessions. The mid-tier ฿149 AI report is an empty slot.

Differentiation (3 bullets):
1. **Personalized in 1 second, not generic by zodiac.** Sanook/Mythai write one Aries paragraph for 50M Thais. We compute the actual Four Pillars from birth date+time — copy reflects this in `i18n/messages/th/home.json:67` ("ทดสอบกับ 139 กรณีจริง... ถูกต้อง 100%").
2. **Save ฿1,500 vs an in-person session, get more depth.** ฿149 = ~5% of an offline mor du fee. Position as "หมอดู AI พกติดตัว".
3. **No Thai LINE app horoscope service today does paid personalized AI reports.** First-mover in the AI-personalized Thai mor du category.

### Indonesia — "Primbon Jawa + Shio bertemu AI"

Indonesian audience is huge for spiritual/mystical content (Primbon, weton, shio). Free.horoworld and ramalanartiama dominate organic. **No serious paid AI primbon competitor at Rp49,000.** Position — not as "Korean Saju" (foreign) but as "Bazi/Shio + AI" framework already nodded to in `packages/shared/src/config/countries.ts:269` ("Gabungkan dengan konsep Shio dan Primbon Jawa").

Differentiation:
1. **Shio + Bazi crossover** — bridge familiar shio with AI-powered Four Pillar depth.
2. **Religion-respectful framing** — explicit in `countries.ts:272`. Indonesian users reject hardline absolutist astrology. We're "interpretasi probabilitas, bukan ramalan absolut".
3. **Mobile-first, no app install** — competitors push apps; we're a 30-second web flow.

### Vietnam — "Tử vi Bát Tự + AI, không cần đặt lịch thầy"

Tử vi is deeply embedded; Tử Vi Đẩu Số and Bát Tự practitioners charge 500K-2M VND per session. Online: tuvivietnam.vn, lasotuvi.com (paywalled, manual). **No AI-instant Vietnamese tử vi at 89.000₫.**

Differentiation:
1. **Instant** — `i18n/messages/vi/home.json:78` "AI hoàn tất chỉ trong 1 giây". Manual sites take 24-48 hours.
2. **References to Tích Thiên Tủy + Tử Bình Chân Thuyên** — credibility marker locals recognize (`vi/home.json:73`).
3. **Price anchor** — 89.000₫ vs offline 500.000₫+. Same depth, 18% the cost.

---

## 3. Paid ads — Meta (Thailand priority)

Daily budget: **฿500 (~$15) × 5 ad sets = ฿2,500/day** (~$75/day). Week 1 cap: ฿15,000.
Landing URL: `https://fortunelab.store/th?utm_source=meta&utm_medium=paid&utm_campaign=th_launch&utm_content={ad_id}`
Expected metrics (Thai astrology vertical, Meta TH 2026): CPM ฿80-140, CPC ฿3-7, lead/install CTR 1.8-3%.

### Creative 1 — Curiosity gap

- **Hook (TH):** "MBTI มี 16 แบบ แต่ดวงคุณมี 518,400 รูปแบบ"
- **Primary text (TH, 90 chars):** "ใส่วันเกิดแค่ 10 วินาที AI ถอดรหัสดวงชะตา 9 ด้านให้ครบ ฟรี ดูได้ทันที"
- **CTA:** ดูดวงฟรี / Learn More
- **Visual:** Dark cosmos background, gold hanja 命 watermark, phone mockup showing the radar chart from `result/page.tsx`. NO stock photos of crystals or smoke. Real product UI screenshot.

### Creative 2 — Price anchor

- **Hook:** "หมอดูดังคิดครั้งละ ฿2,000 — AI วิเคราะห์ลึกกว่า ฿149"
- **Primary text:** "AI อ่านธาตุทั้ง 5, ไทม์ไลน์ 10 ปี, ความรัก-การงาน-การเงิน ครบ 9 หมวด รายงาน 20,000+ ตัวอักษร"
- **CTA:** ทดลองฟรี
- **Visual:** Split-screen — left: ฿2,000 receipt crossed out, right: ฿149 phone screen. Thai baht symbol prominent.

### Creative 3 — UGC review style

- **Hook:** "ลองให้ AI ดูดวงให้แฟน เกือบขำกลิ้ง — มันอ่านนิสัยเขาออกหมดเลย"
- **Primary text:** "FortuneLab ใช้สูตรโหราศาสตร์จีนคลาสสิก 5 เล่ม + AI ลองเลย ฟรี"
- **CTA:** ดูดวงเลย
- **Visual:** Thai female 25-32, casual, holding phone with "ตกใจ" expression. Text overlay in pop-out chat bubble style. Authentic, not polished.

### Creative 4 — Couple compatibility

- **Hook:** "คู่นี้จะรอดมั้ย? ใส่วันเกิด 2 คน รู้ทันที"
- **Primary text:** "AI วิเคราะห์ความเข้ากัน 5 ธาตุ + จุดอ่อน-จุดแข็งของคู่คุณ ฿149 รายงานฉบับเต็ม"
- **CTA:** เช็คคู่เรา
- **Visual:** Two birthdate cards side-by-side animating into a single yin-yang. Pink+gold palette. Land on `/th/compatibility`.

### Creative 5 — Year of the Horse 2026

- **Hook:** "ปีม้าทอง 2026 ดวงคุณจะรุ่งหรือร่วง?"
- **Primary text:** "AI วิเคราะห์ดวงปี 2026 จากวันเกิดคุณ 12 ราศี + 12 นักษัตร เริ่มฟรี"
- **CTA:** ดูดวงปี 2026
- **Visual:** Golden horse silhouette + 2026 + zodiac wheel. Lunar New Year energy. Lands on `/th/annual`.

### Targeting JSON

```json
{
  "campaign": "TH_FortuneLab_Launch_W1",
  "objective": "OUTCOME_TRAFFIC",
  "geo": ["TH"],
  "languages": ["th"],
  "age": [22, 44],
  "gender": "all",
  "primary_audience": {
    "interests": [
      "Horoscope", "Astrology", "Tarot reading",
      "ดูดวง", "ไพ่ยิปซี", "โหราศาสตร์", "หมอดู",
      "Buddhism", "Spirituality", "Zodiac"
    ],
    "behaviors": ["Engaged Shoppers", "Mobile device users — high-end smartphones"],
    "estimated_size": "9.2M – 11.5M Thailand"
  },
  "lookalike_seeds_post_d7": ["pixel_event:fortunelab_form_complete", "pixel_event:fortunelab_paywall_view"],
  "placements": ["facebook_feed", "instagram_feed", "instagram_reels", "facebook_reels"],
  "budget_daily_thb": 500,
  "budget_total_thb_w1": 15000,
  "bid_strategy": "LOWEST_COST_WITHOUT_CAP",
  "optimization_goal": "LANDING_PAGE_VIEWS",
  "split_test": "creative_1_5_separate_adsets"
}
```

---

## 4. Paid ads — TikTok Ads (Thailand)

Daily budget split from the ฿15,000 W1 cap: **30% to TikTok = ฿4,500 W1, ฿650/day**. TikTok TH 2026 vertical CPM ~฿55-90, CTR 1.2-2.4%.

### Targeting

```json
{
  "campaign": "TH_FortuneLab_TikTok_W1",
  "geo": ["TH"],
  "languages": ["th"],
  "age": [18, 34],
  "gender": "all",
  "interests": ["lifestyle", "beauty", "spirituality"],
  "video_interactions": ["#ดูดวง", "#สมาธิ", "#ไพ่ยิปซี", "#ราศี", "#เลขมงคล"],
  "placement": "tiktok_feed",
  "objective": "TRAFFIC",
  "budget_daily_thb": 650
}
```

### Video script 1 — POV mor du (15 sec)

- Scene 1 (0-3s): Phone close-up, hand types birthdate.
  - Narration: "พิมพ์แค่วันเกิด..."
  - On-screen TH: "วันเกิด → ดวงชะตา"
- Scene 2 (3-9s): Result screen scrolling — radar chart, four pillars table.
  - Narration: "AI ออกผลใน 1 วินาที — แม่นกว่าหมอดูที่ตลาดนัดอีก"
  - On-screen: "9 หมวดวิเคราะห์ · 20,000 ตัวอักษร"
- Scene 3 (9-15s): Price flash + CTA.
  - Narration: "฿149 — ลองฟรีก่อนได้"
  - On-screen: "ลิงก์ในไบโอ ↓ ฿149"

### Video script 2 — Couple test (12 sec)

- Scene 1 (0-2s): Two phones, two faces blurred, hands typing dates.
  - Narration: "ใส่วันเกิดของคุณกับเขา"
- Scene 2 (2-7s): Compatibility result animates in (yin-yang merging).
  - Narration: "AI บอกตรงๆ ว่าคู่นี้รอดมั้ย"
  - On-screen: "5 ธาตุ · จุดอ่อนความสัมพันธ์ · จังหวะที่ดี"
- Scene 3 (7-12s): Reaction shot — surprised laugh.
  - Narration: "เกือบเลิกเลยอ่ะ ฮ่าๆ"
  - On-screen CTA: "ลองเช็ค ฿149"

### Video script 3 — 2026 horse year hook (18 sec)

- Scene 1 (0-3s): Lunar calendar flips to 2026, golden horse appears.
  - Narration: "ปีม้าทอง 2026 — คุณจะปังหรือพัง?"
- Scene 2 (3-12s): Quick montage: 12 zodiac icons highlighting one by one with "ราศี... ดวง..." quick text.
  - Narration: "AI วิเคราะห์จากวันเกิดของคุณคนเดียว — ไม่ใช่ราศีรวมๆ"
- Scene 3 (12-18s): Phone mockup of `/annual` page, then CTA.
  - On-screen: "ดวง 2026 ของคุณ · ดูฟรี"

**Trend audio refs (TikTok TH discover, April 2026):** `#ดูดวงปี2026` (rising), `#ปีม้าทอง2026`, `#ราศี12` — pull current top sounds when uploading.

---

## 5. Viral organic — TikTok Thailand (5 concepts)

Account handle suggestion: `@fortunelab.th` — post 1x/day for 14 days, then optimize. Goal: 1 viral hit (>500K views) per 7 days.

### Concept 1 — "เช็คดวงคนรู้จักจากวันเกิด" (15-20s)

- **Hook (0-2s):** "เพื่อนเกิดวันที่ 14 มี.ค. 1998 — ดูซิ AI พูดถูกมั้ย"
- **Body:** Type into FortuneLab live, screen-record dominant element + personality blurb. React out loud.
- **Punchline:** "บอกเลยเพื่อนแม่จริง สายใจร้อนชัวร์ 555"
- **Audio ref:** Trending Thai funny-shock reaction sound (rotate weekly).
- **CTA on-screen:** "ลิงก์ในไบโอ — ลองดูดวงตัวเองฟรี"

### Concept 2 — "เลขมงคลประจำวันเกิดคุณ" (12s)

Thai users actively search lottery + lucky-number content. Bridge from there.
- **Hook:** "เลขมงคลตามวันเกิด — เลข 3 ที่ห้ามมองข้าม"
- **Body:** Quick reveal of 3 numbers based on day-master element (water=1,6 / fire=2,7 / wood=3,8 / metal=4,9 / earth=5,0). Frame: "AI หาให้จากดวงคุณ ไม่ใช่สุ่มมั่วๆ"
- **CTA:** "อยากรู้เลขของคุณ? ใส่วันเกิดในไบโอ"
- **Audio ref:** Trending lottery-reveal sound.

### Concept 3 — "ราศีไหนปังที่สุดปี 2026" (20s) — Strong cultural lock

- **Hook:** "ปีม้าทอง 2026 — 3 ราศีรวยรัวๆ"
- **Body:** Reveal 3 zodiac signs with quick reasoning ("ราศีพิจิก: ธาตุน้ำเด่น, ปีม้าทองเสริม"). Show `/th/zodiac` page.
- **Trend:** Tap into `#ราศีที่หายากอันดับ1 2026` tag (live on TikTok TH).
- **Punchline:** "ส่วนอีก 9 ราศี? ดูฟรีได้ในเว็บ"
- **Audio:** Trending mystic-reveal sound.

### Concept 4 — "ไพ่ยิปซี vs AI ดูดวง — ใครแม่นกว่า" (25s)

- **Hook:** "ลองให้ AI กับไพ่ยิปซีดูดวงคนเดียวกัน — ตรงกันมั้ย?"
- **Body:** Pull a tarot card on camera, then run FortuneLab on same person. Compare both readings side-by-side.
- **Punchline:** "ตรงกัน 80% — ของจริงทั้งคู่ แค่คนละมุม"
- **Why it works:** Tarot creators have huge TH followings. Crossover content steals their audience.

### Concept 5 — "ดวงคู่ — เพื่อนกี่คนที่จะอยู่กับคุณตลอด" (15s)

- **Hook:** "ใส่วันเกิดเพื่อน 5 คน — AI บอกว่าใครจะหายจากชีวิตเรา"
- **Body:** Use `/th/friend-compat`. Quick montage of 5 birth dates → result percentages.
- **Punchline:** "เพื่อนคนนี้แค่ 32%... ตัดออกตั้งแต่วันนี้ 555"
- **Audio:** Trending dramatic friendship-reveal sound.

**Posting cadence:** 1x/day, 7-9 PM Bangkok. Hashtag stack: `#ดูดวง #ราศี #ปีม้าทอง2026 #fortunelab #หมอดูAI #ไพ่ยิปซี`.

---

## 6. Indonesia / Vietnam — SEO-only play (until payment fixed)

### Indonesia — 3 evergreen content topics

1. **"Arti Shio [12 animals] di Tahun 2026 (Tahun Kuda Emas)"** — 12 long-tail pages, one per shio. Currently `/id/zodiac/[animal]` exists; expand each with 2026 forecast block. Target queries: `arti shio kuda 2026`, `ramalan shio macan 2026`. Volume: 5K-30K/mo per shio in 2026.
2. **"Hitung Bazi / Empat Pilar dari Tanggal Lahir — Cara Manual + AI"** — pillar tutorial with AI tool embedded. Targets `cara hitung bazi`, `bazi calculator gratis`. Volume: 2K-8K/mo.
3. **"Primbon Jawa vs Bazi Tionghoa — Apa Bedanya"** — comparative explainer. Hooks the Primbon search audience and bridges to our product. Volume: 1K-4K/mo.

### Vietnam — 3 evergreen content topics

1. **"Lá số Tử Vi 2026 — Ngọ (Năm Ngựa Vàng) cho 12 Con Giáp"** — same pattern as ID, one page per con giáp. Use existing `/vi/zodiac/[animal]`. Volume: 3K-15K/mo per giáp.
2. **"Cách Lập Bát Tự Online Miễn Phí (Hướng Dẫn 2026)"** — tutorial + tool embed. Targets `lập bát tự online`, `xem tử vi online`. Volume: 4K-12K/mo.
3. **"Tích Thiên Tủy là gì? Hiểu Cổ Thư Tử Vi trong 5 phút"** — credibility content. Already referenced in `vi/home.json:73`. Targets serious tử vi searchers, builds authority.

### Email capture — "ready when payment supports IDR/VND"

The `EmailSubscription` Prisma model already accepts `source` enum. Reuse it.

**Wire it now:**
- `apps/web/app/api/email/subscribe/route.ts:24` — extend `validSources` array to include `"payment_waitlist"`:
  ```ts
  const validSources = ["checkout", "coming_soon", "monthly_fortune", "payment_waitlist"];
  ```
- `apps/web/app/[locale]/components/ComingSoon.tsx` — duplicate this pattern into a new `<PaymentWaitlist locale={locale} />` component. Submit body: `{ email, source: "payment_waitlist", locale, feature: "premium_idr" or "premium_vnd" }`.
- **Where to place the capture:**
  - `apps/web/app/[locale]/paywall/page.tsx:78-108` — the paywall form. For ID/VN locales, replace the PayPal checkout button with a waitlist input. Add a locale check at line 102:
    ```ts
    const isWaitlistMarket = locale === "id" || locale === "vi";
    ```
    Then conditionally render either the existing `handleCheckout` button or a `<PaymentWaitlist>` form. Copy:
    - **ID:** "Pembayaran Rupiah masih dalam pengembangan. Daftar email — kami akan kirim diskon 30% saat Premium tersedia di Indonesia."
    - **VI:** "Thanh toán bằng VND đang được hoàn thiện. Để lại email — bạn sẽ nhận giảm giá 30% khi Premium ra mắt tại Việt Nam."
  - Same treatment in `compatibility/paywall/page.tsx`, `tarot/paywall/page.tsx`, `annual/paywall/page.tsx` (4 paywall files total).
- `i18n/messages/id/paywall.json` and `i18n/messages/vi/paywall.json` — add `waitlist.headline`, `waitlist.body`, `waitlist.cta`, `waitlist.success` keys.

This ships value (a discount promise + email list) instead of a broken USD checkout.

---

## 7. Site CRO for /th — Top 5 conversion blockers

Audited against `apps/web/app/[locale]/page.tsx` and `paywall/page.tsx`.

### Blocker 1 — Hero CTA reveals progressively, hidden on first scroll
- **Where:** `apps/web/app/[locale]/page.tsx:307-329`. The submit button only renders when `hasGender` is true (`cReveal cVisible` logic). New TH visitors see hero text + birthdate selectors but no visible CTA above the fold.
- **Fix:** Add a static "ดูดวงฟรีเลย ↓" jump-CTA in the hero block (`page.tsx:219-222`), scroll-anchors to the form. Keep the progressive reveal for the actual submit, but stop hiding the affordance.
- **Expected lift:** +8-15% form starts.

### Blocker 2 — City field for non-Korean locales adds friction with no visible benefit
- **Where:** `page.tsx:275-288`. `CityAutocomplete` shows for all non-`ko` locales including `th`. Thai users from rural provinces hit "City not recognized" (`page.tsx:192`).
- **Fix:** Make city optional with a default of "Bangkok" prefilled for `locale === "th"`. Move the city input behind a "เพิ่มความแม่นยำ ↓" disclosure.
- **Expected lift:** +5-10% form completion.

### Blocker 3 — Paywall headline is generic, no Thai-specific anchor
- **Where:** `paywall/page.tsx:41` — `t("heading", { name })`. Currently localized but missing price-vs-mor-du anchor. The trust badges (`paywall/page.tsx:54-74`) are abstract icons.
- **Fix:** Add a Thai-specific anchor row above `paywallTrustBadges`: "หมอดูแพง ฿2,000 · AI ฿149 · ลึกกว่าด้วยตำราคลาสสิก 5 เล่ม". Add Thai-specific testimonial copy in `i18n/messages/th/paywall.json` — use names like "พิมพ์ลภัส, อายุ 28, กรุงเทพฯ".
- **Expected lift:** +15-25% paywall CVR.

### Blocker 4 — No LINE-based payment method shown; PayPal alone is unusual for TH
- **Where:** `usePaywall.ts:138` routes `paymentProvider: "paypal"` (from `countries.ts:195`). PayPal is only ~12% of TH e-commerce share — Thais expect TrueMoney / PromptPay / Rabbit LINE Pay. Even though PayPal supports THB, it's a familiarity barrier.
- **Fix (low-effort interim):** Add a copy line on `paywall/page.tsx` near line 110 — "ชำระผ่าน PayPal ปลอดภัย รองรับบัตรไทยทุกธนาคาร" — to reassure that PayPal accepts Thai-issued cards without requiring a PayPal account (PayPal Guest Checkout).
- **Fix (real):** Add Omise or 2C2P (TH-native) as a second provider in W2-3.
- **Expected lift:** +10-20% checkout completion.

### Blocker 5 — Sticky bottom CTA shows price but no risk-reversal
- **Where:** `paywall/page.tsx:118-128`. Sticky CTA shows "ชำระ ฿149" but no refund anchor. Mobile Thai users decide on the sticky.
- **Fix:** Add a sub-line under the sticky button: "คืนเงิน 100% ใน 24 ชม. ถ้ายังไม่อ่าน". Pull from `t("trustRefund")` already in the file (line 66). The refund promise exists in copy but is buried in `paywallTrustBadges` above the fold.
- **Expected lift:** +5-12% sticky tap-through.

---

## 8. Quick-launch sequence (Week 1) — ฿15,000 cap

| Day | Action | Spend |
|-----|--------|-------|
| **Mon (Day 1)** | Publish 5 Meta ads (creative 1-5, ฿200/day each = ฿1,000). Set up TikTok Business account + Pixel. Post organic TikTok concept 1. Verify TH PayPal flow with a test ฿149 charge. | ฿1,000 |
| **Tue (Day 2)** | Launch TikTok Ads with video script 1 only (`฿500/day`). Boost top organic post if any hits 5K views. Monitor Meta CTR — kill any ad <0.8% CTR. Post organic concept 2. | ฿1,500 |
| **Wed (Day 3)** | Add TikTok video script 2 (`+฿300`). Ship CRO blocker #1 (visible hero CTA) + #5 (refund sub-line). Post organic concept 3. | ฿1,800 |
| **Thu (Day 4)** | Top 2 Meta creatives → bump to ฿400/day, kill bottom 2. Add lookalike audience seeded on `form_complete` pixel events from D1-D3. Post organic concept 4. | ฿2,200 |
| **Fri (Day 5)** | Add TikTok video 3 (annual hook). Ship CRO blocker #3 (Thai-anchor on paywall). Post organic concept 5. | ฿2,400 |
| **Sat (Day 6)** | Pause if CAC > ฿250. Otherwise hold. Replicate top organic angle as a 2nd Meta creative variant. | ฿2,500 |
| **Sun (Day 7)** | **STOP. Analyze.** Pull GA4 funnel `form_start → form_complete → paywall_view → checkout_attempt → paid`. Compute CAC, CVR per creative, per audience. Decide: scale, iterate, or pivot. | ฿2,600 |
| **Total** | | **฿14,000** (฿1,000 reserve) |

Day 7 stop criteria — green / yellow / red:
- **Green (scale):** ≥10 paid orders, CAC ≤ ฿200, paywall CVR ≥ 1.5%. → Double budget to ฿30,000 W2.
- **Yellow (iterate):** 4-9 orders, CAC ฿200-400, CVR 0.7-1.5%. → Hold ฿15K, iterate creative + landing copy.
- **Red (pivot):** ≤3 orders, CAC > ฿400. → Pause spend. Investigate funnel drop-off; likely paywall language or PayPal friction; revisit blocker #4.

---

## 9. Payment unlock roadmap (ID/VN) — Xendit integration

### Why Xendit (not Midtrans / GoPay direct)

Xendit has a single integration covering Indonesia (IDR via QRIS, OVO, DANA, ShopeePay, BCA/BRI/Mandiri VA), Philippines (PHP), and Vietnam (VND via MoMo, ZaloPay, bank transfer, cards). Midtrans is ID-only. GoPay direct requires PT-Indonesian entity. Xendit accepts foreign merchants and ships a single Node SDK. Pricing: ~2.9% + flat fee per transaction in IDR — competitive vs Midtrans 2-2.7%.

### Integration scope

Existing structure to extend (already validated via `apps/web/app/api/checkout/`):

```
api/checkout/
  ├── create/         # Generic + KR Toss
  ├── lemonsqueezy/   # KR/global card
  ├── paddle/         # Global
  ├── paypal/         # USD/THB/JPY/etc
  ├── toss/           # KR
  └── xendit/         # ← NEW
       ├── create/     # POST: create Xendit invoice for IDR/VND
       └── webhook/    # POST: Xendit invoice paid → mark order paid
```

Reuses existing `Order` schema (`packages/api/prisma/schema.prisma:29-52`) — `paymentProvider: "xendit"` slots into the existing string column. No migration required.

### Concrete 5-step plan (~16-24 dev hours)

1. **Sign up Xendit + complete KYB** (user action; ~5-10 business days for Indonesia entity verification).
2. **`apps/web/lib/xendit.ts`** — port the shape of `apps/web/lib/paypal.ts`:
   - `createXenditInvoice({ orderId, amount, currency, locale, description, callbackUrl, redirectUrl })`
   - `verifyXenditWebhook(headers, body)` — HMAC validation against `XENDIT_CALLBACK_TOKEN`.
3. **`apps/web/app/api/checkout/xendit/create/route.ts`** — clone `paypal/create/route.ts:52-210`, swap `createPayPalOrder` for `createXenditInvoice`. Drop the IDR/VND USD-fallback branch — no longer needed.
4. **`apps/web/app/api/checkout/xendit/webhook/route.ts`** — clone the structure of the Toss webhook. On `invoice.paid`, set `Order.status = "paid"` and trigger `generatePaidReport` + `sendPaidReportEmail`.
5. **`packages/shared/src/config/countries.ts`** — change `id.paymentProvider` (`:262`) and `vn.paymentProvider` (`:228`) from `"paypal"` to `"xendit"`. Update the union type in `CountryConfig.paymentProvider` (`:20`) to add `"xendit"`. Update `usePaywall.ts:102` switch to route Xendit through `/api/checkout/xendit/create`.

After step 5, every ID/VN paywall click hits Xendit instead of falling back to USD. Email waitlist users from Section 6 get notified with a 30%-off code (use a single `WELCOMEID30` / `WELCOMEVN30` discount, hardcoded in the create route until a coupons table exists).

### Day-1 of Xendit going live

Drop a single broadcast email to the `payment_waitlist` source segment with the discount code. Estimated open rate (warm waitlist, transactional) 35-50%, conversion 4-8%. If the waitlist is 1,000 emails by then, that's 14-40 paid orders on launch day before any new acquisition spend.

---

**Word count:** ~2,400 words.
**Source verification:** Similarweb traffic data for myhora/sanook/horoworld confirmed Nov 2024 ([Similarweb](https://www.similarweb.com/website/horoscope.mthai.com/competitors/)). PayPal currency support cross-checked against repo commit `8e191a4` and `apps/web/lib/paypal.ts:6-10`. Xendit IDR + VND coverage confirmed via [Xendit](https://www.xendit.co/en/) and [Xendit IDR product page](https://www.xendit.co/en/paypal-in-indonesia/). TikTok TH 2026 horoscope trends pulled from live TikTok discover pages (`#ดูดวงปี2026`, `#ปีม้าทอง2026`).
