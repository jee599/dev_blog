---
title: "Eight Languages in One Day: Localizing a Korean-Only App"
published: false
description: "How Refmade went from Korean-only to eight languages on October 10: Korean as data, goldens, a register slip, leaky safety lists and a final review."
tags:
  - i18n
  - electron
  - ai
  - testing
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/15-cover.png"
---

At 08:23 on October 10 I asked for the site and the app's internal features to support many languages. That evening Refmade 0.4.0 shipped for Mac in eight: Korean, English, Japanese, Simplified Chinese, Spanish, Brazilian Portuguese, German and French. Translating was not the main problem. The app stored finished Korean sentences on disk and later used them to decide what to do.

This is post 15 of "Building Refmade". Refmade is a desktop app that reads the logs Claude Code and Codex already write and draws them as a pixel-art office. It is an independent app, not affiliated with Anthropic or OpenAI. Claude agents (Sonnet and Opus) did most of the work at my direction: I set the plan, made the calls and reviewed the results. Dozens of agents ran at once, more than 100 launches in all.

## Korean sentences were a data contract

Every event the app records goes into an `events.jsonl` file, and the record holds a finished Korean sentence, for example one that says a file is being deleted. Later, code decides what kind of job that was, or whether it was a delete, by running regular expressions over that Korean sentence. Translate the sentence and the decision breaks without any error message.

So the Korean text could not be touched. The design instead:

- Korean stays byte-for-byte what it was, stored and shown.
- Next to it, each event gets a language-free record, an "IR": which action, on which object, in which place.
- A Korean window shows the stored sentence. Any other window renders the IR in its own language. Old events with no IR show the stored sentence.

A catalog entry for one action in three languages looks like this (from `app/renderer/locale/{en,de,ja}/card.mjs`):

```js
"card.act.delete.what": "Deletes {obj} {adv}",         // en
"card.act.delete.what": "Löscht {obj, np} {adv}",      // de
"card.act.delete.what": "{obj}を{adv}削除します",        // ja
```

The classifier keeps reading the stored Korean in every window language. Only the display changed.

To prove nothing moved, the agents first built golden corpora from the code as it was before the change, then compared the new output byte by byte: 4,576 approval cards, 6,099 activity-log rows, 8,900 office-view items and 20 workroom stretches. The comparison ran throughout the work and stayed identical. It is what let me hand agents this much rewriting in one day.

## The register slip

The model instructions were moved into English with one line added at the end: write in Korean, friendly "haeyo" style. A comparison on real runs showed that plans, review notes and questions, which used to come out in the formal "hapnida" or plain style, had turned into haeyo.

The language line had overridden the register that the original Korean prompts asked for in specific places. The fix: the language line now only picks the language ("Write every user-facing sentence in Korean."). Wherever the old Korean prompt demanded a specific register, that demand moved to the same place in the new prompt. In the workroom, the register ratio came out 6 of 17 against 10 of 17 originally. A statistical test can't tell the two apart, and I'm not claiming they're identical.

Nothing failed and no test went red. It showed up only when real runs were compared side by side.

## Translating without a native speaker

No native speaker checked any of these translations, and the site says so. The process had four parts:

1. **Glossary first.** For each language, one glossary of 120 to 200 terms: button and menu names, the safety verbs, the app's own nouns.
2. **Two passes.** Three translators split the areas between them. Pass one: workroom, office, site, menus, rules. Pass two: approval cards, logs, runner messages, screens.
3. **Back-translation.** Four reviewers per language, different agents from the translators, translated the result back into English before looking at the original, then compared.
4. **A second review of safety wording.** 266 safety keys per language (delete, overwrite, send and similar) plus the automatic decision rules.

The two reviews together fixed 40 keys in Japanese, 29 in Simplified Chinese, 30 in Spanish, 69 in Brazilian Portuguese, 49 in German and 49 in French. Among the safety keys, 1 to 10 per language needed a fix. No yes/no button was flipped anywhere.

The final catalog has about 4,700 keys per language (4,434 for the app, 301 for the site), out of roughly 6,000 strings the first survey found.

![German approval card: "In welchem Ton sollen wir dem Kunden antworten?" with a recommended option marked KI-Empfehlung](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/15-german-decision.png)
*Refmade 0.4.0 in German, public demo data. The card asks "In which tone should we answer the customer?" and marks "Friendly and short" as the AI's recommendation. The cafe and task names are invented sample data.*

![Japanese approval card in the game-style theme with the same question](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/15-japanese-decision.png)
*The same card in Japanese with the game-style theme, public demo data.*

## The safety rules leaked, per language

The app has an auto mode with an "AI decides" option. It is off by default. When it is on, it answers light choices (tone, title, color, font) with the AI's recommendation and still asks a person about anything involving payment, deletion, sending, installing, passwords, legal, medical, investment or hiring. The classifier is a list of words per language. If the language or script is unknown, it asks the person.

The second safety review put 40 risky Japanese questions through it. 22 were decided automatically. In Chinese, 21 of 32. The lists lacked ordinary expressions such as 送って, 払って, 发朋友圈 and 升级.

A final adversarial pass had agents write new risky questions and attack the lists again. 76 of 240 slipped through. The fix added words, and a structural check: one question may hold one action, so a question with "before doing X" or "while doing Y" gets asked. After that, 0 of the 240 were decided automatically. The fixes were written against those very questions, so that number proves little. The same pass showed that the Korean rules from 0.3.9 had been letting 26 of 30 risky questions through, so the fix covered Korean as well.

Then an agent that had never seen the earlier questions wrote 200 new ones: 0 decided automatically. When light phrases such as "in a round font" were attached to risky questions on purpose, 5 got through, among them a Discord announcement worded as "firing it off", a customer's address and the French slang "virer". Those were closed on the spot. The price: roughly 30% to 70% of light design questions now go back to the person.

The limit is built in. A word list sees only the words it has. A new expression will leak again, and I don't have a number for when.

## What the final adversarial review caught

Before release, a last adversarial review found bugs in non-Korean windows. The goldens came from the old Korean-only code, so they could not cover those:

- In a non-Korean window, a team run's one-line result vanished and a Korean "request finished" appeared. The result sentence was judged by a Korean-only rule.
- Typing "Remove memory leak" in English was parsed as a "delete memory" command. The command pattern is now as strict as the Korean one.
- The safety regex ran in quadratic time on long Chinese, Japanese and Korean sentences: 7.1 seconds for 2,000 characters, now under 50 ms.
- "Get new version" opened the Korean download page in every language.
- The terminal command `refmade run --lang` accepted only four languages. It now takes eight.

## Layout, fonts and existing users

German, French and English overflowed the header buttons in an 880 px window. The fix applies only to non-Korean windows, so the Korean screen stays pixel-identical.

For fonts, the Chinese pixel font is a Fusion Pixel 12 px subset covering GB2312 level 1 for Simplified Chinese (136 KB). Extended Latin letters come from the variable Pretendard font. Japanese and Chinese body text uses system fonts.

The website's screenshots are regenerated for each language with that language's UI and example data, 30 per language, 240 in total.

People who already have 0.3.9 open 0.4.0 in Korean on first launch, whatever their system language. A fresh install follows the computer's language. View > Language switches it.

![French setup cards for Claude Code and Codex, showing "Prêt" and "Connexion requise"](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/15-french-setup.png)
*French setup cards, public demo data: Claude Code shows "Ready", Codex shows "Sign-in required".*

![English result card: "Please check the result" with two files](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/15-english-result.png)
*The English result card, public demo data. The file names are sample data.*

## The session that died

The terminal window closed in the middle of the day and the working session died with it. A handoff note listed what was finished. A new session read the note and did only the remaining work. Nothing finished got redone.

## Where this leaves it

The goldens, the back-translation and the two safety reviews are the checks with numbers behind them. The translation quality itself is unverified by native speakers, and the safety rule is a word list with a known limit.

The link to the app comes in the last post.

If you've localized an app that stored its own UI strings as data, how did you find every place that was reading them?
