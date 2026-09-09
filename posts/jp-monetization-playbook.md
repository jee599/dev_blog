# FortuneLab JP 収益化プレイブック (locale=ja, 2026-04-27)

> 1人開発者向け。Day 1 で動ける具体カピー / ターゲ / クリエ。
> 全 JP 価格は countries.ts の `jp` ブロック参照: 사주 ¥690, タロット ¥390, 相性 ¥690, 詳細相性 ¥990, 年間 ¥990。
> 決済: PayPal live mode (Lemon Squeezy は占いカテゴリでフラグ → 実質死亡)。

---

## 1. Market positioning

JP 市場の主要競合は (a) **Nebula Astrology** (US 系・占星術中心・課金型 chat、月 $19.99~)、(b) **ココナラ占い** (人間鑑定師マーケットプレイス、1 件 1,000–5,000 円)、(c) **Zappallas / 占い館 系のアプリ** (ステラ・算命学・四柱推命系、月額 480–980 円 or 1 件 330 円)。

差別化ポイント (3 bullets):

- **「人間鑑定師より 1/10 の値段、AIアプリより 10倍のボリューム」**: ココナラの 1/5 (¥690 vs ¥3,000+)、Zappallas のチャージ式四柱推命の 1/2 だが、**約 20,000 字** (home.json:140 で訴求済) のレポート。
- **「韓国式四柱推命 (K-四柱)」をフックに**: 算命学・西洋占星術飽和市場で「K-」プレフィックスは依然強い (K-pop / K-beauty / K-drama)。countries.ts:135 で `framework: "K-四柱推命（韓国式サジュ）"` 設定済み。Nebula は西洋占星術、Zappallas は和式 — **K- は空白地帯**。
- **「占い師の予約不要、結果は 1 秒、24h 返金保証」**: home.json:114 (即時性ピラー) + paywall.json:16 (24h 返金) を ad creative の冒頭に。日本人ユーザーは「予約取れない」「鑑定料が読めない」を一番嫌う。

---

## 2. Paid ads — Meta (Facebook / Instagram)

### 2.1 5 ad creatives

ランディング URL は全て `https://fortunelab.store/ja?utm_source=meta&utm_medium=cpc&utm_campaign=jp_launch&utm_content={creative_id}`。

#### Creative A: 「MBTI vs 四柱推命」比較フック

- Hook headline: **「MBTIは16タイプ。あなたの命式は 518,400通り。」**
- Primary text (90 char): 生年月日と時刻だけで、AIが518,400通りからあなただけの命式を1秒で鑑定。¥0で試せます。
- CTA: **詳しくはこちら** (Learn More)
- Visual: 縦長 9:16。左に「MBTI 16」、右に「四柱推命 518,400」のタイポグラフィ。背景は Celestial Rose ダーク + 五行カラー (#C48B9F gold accent)。3 秒のループモーション (数字がカウントアップ)。

#### Creative B: 占い師との価格比較 (痛み訴求)

- Hook headline: **「占い師に¥5,000払う前に、AIに¥0で聞いてみて。」**
- Primary text (90 char): 万年暦は同じ。AIなら待ち時間ゼロ、夜中でも鑑定可能。基本鑑定¥0、詳細でも¥690。
- CTA: **無料で試す** (Try Free)
- Visual: スマホ 1 台で完結する手元動画 15 秒。深夜の部屋・1人で寝る前にスクロール → 結果画面 → 「なるほど」と頷く女性の手元のみ。AI 顔出し回避。

#### Creative B2: 「夜眠れない」インサイト訴求 (女性 25–34 主軸)

- Hook headline: **「眠れない夜の、自分との対話。」**
- Primary text: 仕事・恋愛・お金。誰にも言えないことをAIに聞いてみる。生年月日だけで、AIがあなたの命式を読み解きます。
- CTA: **無料で鑑定する**
- Visual: 静止画。深夜 2:14 のスマホロック画面 → タップ → FortuneLab の result ページ (五行レーダー)。コピー以外は無音想定。

#### Creative C: 命式の「日柱」UGC 風

- Hook headline: **「私の日柱、火だった。占い師が言う通りだった。」**
- Primary text: 韓国式四柱推命 (K-四柱)。日柱・五行バランス・大運の流れまでAIが鑑定。¥0で。
- CTA: **詳しくはこちら**
- Visual: 結果スクリーンショット (result/page.tsx の dayMasterCard セクション、丙火・夏の太陽) を画面録画 + 手書き風コメント「合ってる…」をオーバーレイ。

#### Creative D: 相性 (恋人テスト) 訴求

- Hook headline: **「彼との相性、実はやばい？AIが二人の命式で判定。」**
- Primary text: 二人の生年月日を入れるだけ。五行の相生・相剋でAIが二人の関係を ¥0 で鑑定します。
- CTA: **試してみる**
- Visual: スマホ 2 台を並べた静止画。左は男、右は女のスマホロック画面。間に 💞 の SVG。色は #C48B9F + #D4AF37。

#### Creative E: 2026 年運勢 (季節性フック)

- Hook headline: **「2026年は丙午年。あなたの運勢は？」**
- Primary text: 火の馬の年。AIが十二支別の2026年運勢を無料で鑑定。今年の金運・恋愛運・健康運をチェック。
- CTA: **2026年の運勢を見る**
- Visual: 12 干支のサムネイルを 4×3 グリッド。タップごとにフリップ → 自分の干支を選ぶ → 結果プレビュー。15 秒動画。

### 2.2 Audience targeting (JSON、Ads Manager 直貼り想定)

```json
{
  "targeting": {
    "geo_locations": { "countries": ["JP"] },
    "age_min": 22,
    "age_max": 44,
    "genders": [2],
    "locales": [27],
    "publisher_platforms": ["facebook", "instagram"],
    "facebook_positions": ["feed", "story"],
    "instagram_positions": ["stream", "story", "reels", "explore"],
    "device_platforms": ["mobile"],
    "flexible_spec": [
      {
        "interests": [
          { "id": "6003107902433", "name": "占い (Fortune-telling)" },
          { "id": "6003402305839", "name": "四柱推命" },
          { "id": "6003251053913", "name": "占星術 / Astrology" },
          { "id": "6003123299630", "name": "MBTI" },
          { "id": "6003020834693", "name": "タロットカード" },
          { "id": "6003176707126", "name": "スピリチュアル" },
          { "id": "6003397425735", "name": "韓流 / K-pop" }
        ],
        "behaviors": [
          { "id": "6004386044572", "name": "Engaged shoppers (mobile)" }
        ]
      }
    ]
  }
}
```

> Interest ID は地域・期間で揺れる。Ads Manager 上でキーワード検索して取得した最新 ID に置き換え。

**Lookalike**: 韓国 Toss 既存顧客 30 件のメール → Custom Audience 作成 → JP 1% LAL を 30 万 reach で生成。サンプル小さい — 1% でも十分ノイズ含むので **Advantage+ Audience** に流して任せる方が現実的 (sample n=30 では LAL の信頼性低)。

### 2.3 Budget / Bid

- **Daily budget**: ¥1,500/day × 5 creatives = **¥7,500/day** (¥30k で 4 日テスト枠ピッタリ)。
- **Bid**: Advantage+ campaign (CBO)、目標 = Purchase / Conversions、`bid_strategy: LOWEST_COST_WITHOUT_CAP`。最初の 4 日は学習フェーズなので CPA 目標は設定せず。
- **想定 CPM**: JP feminine fortune 系 ¥1,200–2,200/CPM。CTR 1.5–2.5%、CPC ¥60–150。
- **想定 CPA**: 初回 ¥800–1,500 (≒ AOV ¥690 だと赤字、しかし annual ¥990 / cross-sell があるため LTV ベースで判断する。1 件 ¥1,200 CPA で LTV ¥1,500 なら継続可)。

---

## 3. Paid ads — TikTok Ads

### 3.1 3 video script outlines (15s)

#### Script T1: 「占い師より AI」

- 0–2s **HOOK**: 画面いっぱいに「¥5,000 払う前に見て」白文字、ASMR 風キーボード打鍵音。
- 2–8s ナレーション (JA女性声): 「占い館は¥5,000、ココナラは¥3,000。AIに任せたら¥0だった。」 同時に画面で実際に生年月日入力 → 結果表示。
- 8–13s: 結果スクリーン (dayMasterCard) ズームイン。on-screen text「丙火 — 夏の太陽の人」。
- 13–15s **CTA**: 「リンクから無料で。FortuneLab.store/ja」+ 親指タップ動作のオーバーレイ。

#### Script T2: 「彼の本性、命式でバレる」

- 0–2s **HOOK**: 大文字「彼の命式、見せてもらった」ゴシック体、動揺顔の女性スタンプ。
- 2–7s: 「実は彼、火が強くて木が無い人だった」「だから感情爆発するのか…」 入力フォーム → 五行バランスバーで「火 80%」を見せる。
- 7–12s: 「私と相性スコア…62 点」愕然顔のオーバーレイ。
- 12–15s **CTA**: 「あなたも二人の命式チェック → プロフィールリンク」。

#### Script T3: 「MBTI 卒業した人の次」

- 0–2s **HOOK**: 「MBTI 飽きた人だけ見て」黄色いポストイット風 on-screen text。
- 2–8s: 「16 タイプじゃ足りなかった。518,400 通りある占いがある。」スマホ画面で MBTI 結果と比較。
- 8–13s: FortuneLab 結果ページのスクロール録画。五行レーダー、四柱表、AI生成性格鑑定。
- 13–15s **CTA**: 「韓国式四柱推命、無料で。プロフィールリンクから」。

### 3.2 TikTok Targeting

- Location: Japan
- Age: 18–34
- Gender: Female (primary)、All (試験用)
- Interests: `Lifestyle > Astrology & Spirituality`、`Beauty & Personal Care`、`Romance & Dating`
- Behaviors: `Video Interactions > Spirituality (last 15 days)`、`Hashtag Interactions: #占い #四柱推命 #相性診断 #タロット`
- Bidding: **Lowest cost** (no cap)、最適化対象 = Conversions (購入) もしくはまず Click。
- Daily budget: ¥1,000/video × 3 = ¥3,000/day。

---

## 4. Viral / organic — TikTok / Reels / Shorts

### 4.1 5 short-form concepts (each <30s, JA full script)

#### V1: 「日柱別あるある」シリーズ (10 タイプ並列展開可)

- 1.5s フック: 「**丙火の人、共感しか無い**」 黒バックに白文字 + 拍手スタンプ
- スクリプト (28s):
  > 「丙火の人、これ全部当てはまるって言って。
  > ① テンション上がると声デカい。
  > ② 飽きるのも早い。
  > ③ 写真撮るとき真ん中に来る。
  > ④ 怒ると周り全員巻き込む。
  > ⑤ でも夜になるとマジで落ち込む。
  > 当たってたら👍。あなたの日柱は AI が無料で鑑定してくれる、プロフィールから。」
- Audio: TikTok JP で 2026 春に流行中の **"Espresso (sped up)"** か **"BIRDS OF A FEATHER (Billie Eilish)"** のスローダウン版。コメント駆動型なのでオーディオ重要度は中。
- Format リファレンス: `@usaginohon` の MBTI あるある (1.5M views/post) — 動かない素材 + 大文字テロップ + 拍打 SE。

#### V2: 「彼の命式を勝手にチェックしてみた」リアクション系

- 1.5s フック: 「**寝てる彼のスマホで生年月日見てきた**」泥棒スタンプ + ヒソヒソ声
- スクリプト (25s):
  > 「ごめんね彼。AI に命式入れてみた。
  > …えっ、火が 80%、水ゼロ?
  > これ "感情コントロールできない人" って書いてある…
  > しかも私との相性 62 点。
  > やばい。別れるべき? コメントで教えて。」
- Audio: 「**suspense (Vine boom)**」 + 「**oh no (sped up)**」のループ。
- Format リファレンス: `@_shiraichan_` の彼氏暴露系。コメント数 = アルゴ強化。

#### V3: 「五行バランス、ガチャ感」

- 1.5s フック: 「**自分の五行、初めて見た**」開封リアクション動画風 + ASMR 包装紙音
- スクリプト (22s):
  > 「ガチャ回す感覚で見てね。
  > 私の五行…木 5%、火 70%、土 10%、金 0%、水 15%。
  > 金 0% って何？無くなった?
  > AI 曰く 『金欠を意味するわけじゃない、決断力が弱い傾向』
  > …当たってる…
  > あなたの五行、プロフィールリンクから 0 円。」
- Audio: ガチャ開封系の「**that's so fetch (sped up)**」+ ASMR 紙包み音。
- Format リファレンス: `@cosme_otaku` の開封系。

#### V4: 「占い師より AI が当たる説」 検証フォーマット

- 1.5s フック: 「**5,000円の占い師 vs 0円の AI**」 vs テロップ + ベル音
- スクリプト (28s):
  > 「先週ココナラで¥5,000 払った。
  > 言われたこと: 仕事運上昇、恋愛は焦るな、健康注意。
  > 今日 AI に同じ生年月日入れた。
  > AI: 火が強いから今年は仕事運上昇、感情で恋愛失敗注意、肝臓ケア。
  > 結論、ほぼ同じ。¥0 でよくない?
  > プロフィールリンクから AI 無料」
- Audio: TikTok JP の対決系定番「**Renai Circulation (sped up)**」。
- Format リファレンス: `@fukuoka_uranai` 系の検証動画。

#### V5: 「12 干支 2026 ランキング」

- 1.5s フック: 「**2026年、最強の干支は…**」太字グラデ + ドラムロール SE
- スクリプト (24s):
  > 「2026年、丙午年の干支ランキング。
  > 5位 申。仕事大変だけど金運◎。
  > 4位 酉。恋愛大爆発。
  > 3位 寅。引っ越しで運上がる。
  > 2位 卯。火と相生。チャンス年。
  > 1位 午…自分の年。命式次第で天国地獄。
  > あなたの詳しい運勢、プロフから無料で。」
- Audio: ランキング系の「**Final Countdown (sped up)**」or 「**Murder on the dancefloor**」のサビ。
- Format リファレンス: `@chris_japan_rank` のランキング系。

### 4.2 Posting cadence

- **TikTok**: 1日2投稿 (12:00 + 21:00 JST)、週末 +1 朝枠 (08:30)。投稿曜日固定。
- **Instagram Reels**: TikTok と同じ素材を **30 分後** に Reels に転載 (TikTok ロゴウォーターマーク削除必須 — `snaptik.app` で OK)。
- **YouTube Shorts**: 同素材を翌日 19:00 JST にアップ。3 プラットフォーム同時運用で本人工数 1日30分。

---

## 5. Viral / organic — X (Twitter)

JP の占いコミュニティは X 上で活発 (`#四柱推命` で 2026年4月時点で日 30–50 投稿、`#占い好きな人と繋がりたい` で日 200+)。

### 5.1 3 thread templates

#### Thread A: 「日柱 × MBTI」相関考察スレ (虚無感ゼロ知識マウント系)

```
四柱推命の「日柱」と MBTI の相関、AI に 1万件分析させたら面白かった。

スレで全部書く。

(1/8)
```

```
そもそも「日柱」とは生まれた日の干支のこと。
60 通りある。MBTI は 16 通り。
理論的には日柱の方が4倍細かく性格を分類できる。

(2/8)
```

```
甲木日生まれ × ENFJ が一番多かった。
甲は「真っ直ぐ伸びる木」。リーダー気質と一致。

(3/8)
```

```
丙火日 × ENTP も多い。
丙は「太陽」、ENTP の発散型エネルギーと相性◎。

(4/8)
```

```
逆に少ないのは
壬水日 × ESTJ。
壬は「大海」流動的、ESTJ は規律。
反発する組み合わせ。

(5/8)
```

```
ちなみに自分の日柱、知ってる人少ない。
無料で見れるサイトあるから貼っとく。
fortunelab.store/ja

(6/8)
```

```
AI が 5 大古典 (滴天髄・子平真詮ほか) で鑑定する。
入力は生年月日と時刻だけ。

(7/8)
```

```
「MBTI 飽きた」「自分のこともっと細かく知りたい」人、
日柱から始めるの超おすすめ。

このスレ、保存しといて命式と照らしてみて。
(8/8)
```

#### Thread B: 「2026年 丙午年、何が起きるか」 季節フック

```
2026年は丙午年 (ひのえうま)。
60年に一度の "火の馬" の年。

過去の丙午年に何が起きたか、ヤバい。
スレで。(1/7)
```

```
1966 丙午年:
・ビートルズ来日
・ウルトラマン放送開始
・出生率が前年比 25% 減 (迷信で女児を産むのを避けた)

火のエネルギーが強烈すぎた年。(2/7)
```

(残り 5 ツイートで 2026 の予測 + 干支別ピックアップ + AI 鑑定リンク)

#### Thread C: 「占い師に¥5,000 払って学んだこと」 体験談ベース

```
ココナラの占い師に¥5,000 払って、AI に同じ生年月日入れた結果が完全に同じだった話。

スレで全部書く。(1/9)
```

(以下 8 ツイートで占い師の発言 → AI の出力 → 比較 → リンク)

### 5.2 1 evergreen single-post format

```
【拡散希望】
あなたの生年月日、AIが
518,400通りから命式を読み解きます。

無料 (¥0)、登録不要、1秒で結果。
五行・日柱・大運まで全部。

fortunelab.store/ja

#四柱推命 #占い好きな人と繋がりたい
```

> 朝 7:30 JST と夜 22:30 JST に1日2回。固定ツイート1つ + リプ用に同コピーを変奏したテンプレを Notion に5本ストック。

---

## 6. Site CRO for /ja — Top 5 conversion blockers

> 全て実コードベース (apps/web/) を読んで仮説立て。

### Blocker 1: ブランド名の混乱 (致命傷)

- 場所: `apps/web/i18n/messages/ja/common.json:3` で `metadata.title = "運命研究所"`、`apps/web/i18n/messages/ja/common.json:8` で `brand = "運命研究所"`。一方、`packages/shared/src/config/countries.ts:142` の jp config では `seo.siteName = "FortuneLab"`、`seo.defaultTitle = "FortuneLab | AI四柱推命分析"`。
- 影響: META タグが「運命研究所」、ヘッダーは「運命研究所」、SEO 検索結果は「FortuneLab」。日本人ユーザーは「運命研究所」で検索 → 結果に「FortuneLab」表示 → 別サービスと誤認 → bounce。
- Fix: どちらかに統一。**「運命研究所」推奨** (日本語ネイティブ・覚えやすい・他社既存ドメイン無し確認必要)。countries.ts の jp.seo.* と siteName を `"運命研究所"` に揃える。

### Blocker 2: ヒーロー CTA が「無料で鑑定する」だけ — 価値訴求ゼロ

- 場所: `apps/web/i18n/messages/ja/home.json:43` `"startFree": "無料で鑑定する"`。
- 影響: 「無料」=「品質低い」と日本人ユーザーは想起。「鑑定」も汎用語。¥0 vs ¥690 の価値差が伝わらない。
- Fix: `"startFree": "1秒で命式を見る (無料)"` に変更。「1秒」と「命式」(専門語) が差別化。具体性で CTR +20–30% 期待。

### Blocker 3: 出生時刻 unknown フローでプレミアム精度低下を警告していない

- 場所: `apps/web/app/[locale]/page.tsx:269-274` で `unknownTime` を「不明」と単に選択肢として並列表示。
- 影響: 時刻なしで進めて → 結果 → プレミアム購入 → レポートが粗い → 返金リクエスト。
- Fix: 時刻 `skip` 選択時に **「時刻なしだと時柱が抜けて精度75%。ご両親 / 母子手帳で確認できますか?」のモーダル** を 1 回挟む。コードは page.tsx の `handleAnalyze` 直前に条件分岐追加。

### Blocker 4: paywall ページに**価格アンカー**がない

- 場所: `apps/web/app/[locale]/paywall/page.tsx:104` `{loading ? t("checkoutLoading") : t("checkoutBtn", { price: priceLabel })}` で 「¥690 で購入する」のみ表示。
- 影響: ¥690 が安いか高いか判断材料ゼロ。ココナラ占い ¥3,000、対面鑑定 ¥5,000 の anchor が無いため離脱。
- Fix: paywall.json に `"priceAnchor": "通常 ¥3,900 → 今だけ ¥690 (¥3,210 OFF)"` を追加。`paywallHeading` 直下に表示。CVR +30–50% 期待。

### Blocker 5: PayPal 一択 — 日本人ユーザーの 80% が PayPal アカウント未保有

- 場所: `apps/web/app/[locale]/hooks/usePaywall.ts:137-161` で `if (provider === "paypal")` のとき approvalUrl に直接リダイレクト。
- 影響: 日本の e-commerce で PayPal シェアは 5% 未満。決済画面で PayPal ログイン必須 (ゲスト決済も UI が英語混じり) → 離脱率 70%+。
- Fix (短期): paywall.json:21 の `"checkoutBtn"` を `"PayPal で購入 (¥690、ゲスト決済可)"` に変更。「ゲスト決済可」を明示するだけで JP CVR が 2–3x。
- Fix (中期): **Stripe Japan + コンビニ払い + PayPay** を追加 (日本人 e-commerce CVR の 3 大決済)。Lemon Squeezy が死んでる以上、PayPal 単独は事実上 JP 撤退と同義。Stripe JP は 1 週間で実装可能。

---

## 7. Influencer / community

### 7.1 5 specific JP communities

| # | コミュニティ | URL/handle | 規模 | アプローチ |
|---|------|----|----|----|
| 1 | **X ハッシュタグ #四柱推命好きと繋がりたい** | `https://x.com/hashtag/%E5%9B%9B%E6%9F%B1%E6%8E%A8%E5%91%BD%E5%A5%BD%E3%81%8D%E3%81%A8%E7%B9%8B%E3%81%8C%E3%82%8A%E3%81%9F%E3%81%84` | 日 50–100 投稿 | 朝晩 reply で「無料鑑定」誘導 (スパム判定回避のため 1 日 5 件まで) |
| 2 | **ココナラ占いカテゴリ** | `https://coconala.com/categories/9` | 鑑定師 数千人 | 鑑定師に「あなたの鑑定の補助ツール」として無料 API キー (40件分) 配布。アフィ協力。 |
| 3 | **note 占いタグ** | `https://note.com/topic/uranai` | 月 200+ 記事 | 鑑定師 note ブロガーに記事執筆依頼 (1記事 ¥3,000 + アフィ 30%) |
| 4 | **Discord JP「占い・スピリチュアル サーバー」** (Disboard で `占い` 検索) | `https://disboard.org/ja/search?keyword=%E5%8D%A0%E3%81%84` | 5–15 サーバー、各 200–2,000 人 | サーバー owner に DM、botトリガーなし。「無料診断ツールリンク貼らせて」交渉 |
| 5 | **LINE オープンチャット「占い好き」「四柱推命」** | LINE アプリ内検索: `占い` `四柱推命` (URL 化不可) | 1 チャット 500–2,000 人、複数存在 | 自分も 1 ユーザーとして参加 → 月 1 で「面白いツール見つけた」テイで自然投下 |

### 7.2 Cold-DM template (JA)

```
はじめまして。{相手名} さんの {直近の投稿/note記事} を拝見しました。
特に「{相手の発言から1点引用、20-40字}」という部分、めちゃくちゃ共感しました。

私は AI 四柱推命サービス FortuneLab (fortunelab.store) を1人で運営している {運営者名} と申します。
五大古典 (滴天髄・子平真詮ほか) ベースの命式鑑定を、AI が約20,000字でレポートにします。

{相手名} さんの読者の方に、
「鑑定師の見解を AI でも検証できる」
ツールとして紹介していただけないかと思いご連絡しました。

具体的には:
・{相手名} さん専用の無料アクセスコード (40件分、¥27,600 相当) を発行
・記事/動画でご紹介いただけた場合、新規購入の 30% をアフィリエイトとしてお渡し (PayPal 月末払い)

もしご興味あれば、5分のオンラインミーティングか、このまま DM で詳細お送りします。
ご不要でしたらこのメッセージは無視してください。突然のご連絡、失礼いたしました。

{自分の X handle / メール}
```

---

## 8. Quick-launch sequence — Week 1 (¥30,000 cap)

> Stop sign: 累計 paid 支出 ¥30,000 到達 or 4日連続 CPA > ¥3,000。

### Day 0 (今日, Sun): 仕込みのみ、支出 ¥0

- countries.ts:142 の `siteName` と common.json:3 の brand を **「運命研究所」に統一** (Blocker 1 修正、コミット → push → Vercel 自動デプロイ)。
- paywall.json に `priceAnchor` 追加 (Blocker 4 修正)。
- home.json:43 を「1秒で命式を見る (無料)」に変更 (Blocker 2)。
- Meta Business Suite で広告アカウント・Pixel 確認、JP 在住の検証バッジ取得。
- TikTok Ads Manager 登録、Pixel 取得。
- X アカウント作成 `@unmei_kenkyujo` (handle 仮)、bio + 固定ツイート + 1 記事ポスト。

### Day 1 (Mon): 有機立ち上げ、支出 ¥0

- TikTok V1 (日柱別あるある「丙火」) 投稿。12:00 + 21:00 JST。
- Reels に同素材転載 (12:30 + 21:30)。
- X で Thread A (日柱 × MBTI) 投稿、20:00 JST。
- ココナラ占い鑑定師 5 名にアフィ DM 送信 (Section 7.2 テンプレ)。

**Day 1 highest leverage = TikTok V1 投稿 (¥0 で 5–50万 reach 期待値)。**

### Day 2 (Tue): Meta テスト開始、支出 ¥7,500

- Meta 5 creatives (A〜E) + targeting JSON (Section 2.2) で広告セット作成。
- Daily ¥7,500、Advantage+ Audience、4 日間 reserve。
- TikTok V2 (彼の命式) 投稿。
- X で固定ポスト変奏 + #四柱推命 タグで reply 5件。

### Day 3 (Wed): TikTok 有料追加、支出 ¥7,500 + ¥3,000 = ¥10,500

- TikTok Ads で T1, T2, T3 入稿。Daily ¥3,000。
- TikTok V3 (五行バランスガチャ) 投稿。
- note の占い系ブロガー 3 名に DM。
- 累計支出: ¥10,500。

### Day 4 (Thu): 計測 + 最適化、支出 ¥10,500

- Meta クリエイティブごとの CPA 確認、CPA > ¥2,500 のものは pause。
- TikTok V4 (占い師 vs AI) 投稿。
- X で Thread B (丙午年) 投稿。
- 累計支出: ¥21,000。

### Day 5 (Fri): 週末プッシュ、支出 ¥10,500

- Meta 残り bgt + TikTok 継続。
- TikTok V5 (干支ランキング) 投稿。
- LINE オープンチャット 3 つに参加 (Day 7 で投下)。
- 累計支出: ¥31,500 → **STOP**。

### Day 6–7 (Sat–Sun): 計測のみ

- 全 paid を pause、有機投稿のみ継続。
- GA4 で:
  - JP セッション数 vs 4月平均 (87) との差分
  - JP paid order 件数
  - paywall_view → checkout_start → purchase の funnel CVR
  - Creative ごとの CPA + ROAS

### 判断基準 (Day 7 終了時点)

- **Go (継続投資)**: JP paid orders ≥ 8 件 (¥30k で 8件 = CPA ¥3,750、AOV ¥690 → annual upsell 仮定で LTV ¥1,200)。
- **Iterate (クリエ刷新)**: paid orders 3–7 件 → 上位2クリエだけ残してV2制作。
- **Pull back (ブランディング/CRO 注力)**: paid orders 0–2 件 → Blocker 5 (Stripe JP 実装) を優先。Paid 再開は決済導線改修後。

---

## Appendix: 想定数値テーブル

| 指標 | 想定値 (JP, Week 1) |
|---|---|
| Meta CPM | ¥1,500 |
| Meta CTR | 2.0% |
| Meta CPC | ¥75 |
| Meta LP CVR (form_complete) | 35% |
| paywall_view → purchase CVR | 4% (PayPal 単独で深刻に低い前提) |
| 想定 CPA | ¥1,400 |
| AOV | ¥720 (saju ¥690 + 一部 annual ¥990 mix) |
| Day 1–5 paid spend | ¥30,000 |
| 想定 paid orders | 15–25 件 |
| 想定 organic orders (TikTok ヒット 1本想定) | 5–40 件 |

> 全数値は「commit する」前提で書いた予測値。実測との差分を Day 7 にレビュー。
