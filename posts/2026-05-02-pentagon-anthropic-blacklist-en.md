---
title: "Pentagon Blacklisted Anthropic From 8 Classified AI Deals"
published: true
description: "DoD signed IL6/IL7 classified AI contracts with 8 firms but locked out Anthropic over a refused usage clause — here is the trade-off behind it."
tags:
  - ai
  - opensource
  - news
  - business
cover_image: https://r2.jidonglab.com/blog/2026/05/pentagon-anthropic-blacklist-hero.jpg
canonical_url: https://spoonai.me/posts/2026-05-02-pentagon-anthropic-blacklist-confirmed-en
---

The most safety-focused AI lab on the planet just got blacklisted by the Pentagon for being too safe. On May 1, the U.S. Department of Defense signed IL6/IL7 classified AI deals with eight companies. Anthropic — the one that publishes its safety policy — was not on the list.

IL6 and IL7 are the Pentagon's classified-data tiers: IL6 covers Secret-level data (operational plans, weapons specs), IL7 covers Top Secret and Special Access Programs. They are the highest commercially-accessible authorization levels in U.S. government cloud, and getting cleared costs years and tens of millions per vendor.

I have been tracking this since the "supply chain risk" label leaked in February, and the May 1 announcement closes the loop in a way that should change how you think about building on frontier AI. The reason Anthropic is locked out is not technical. It is a single contract clause — and Anthropic filed a federal lawsuit rather than sign it.

## The eight that signed, and what they shared

The Pentagon's roster reads like a who's-who of vendors who already accepted the rules of engagement. The big three cloud providers were locks because they already operate IL6 environments for the rest of the federal government. Google's inclusion is the headline of full rehabilitation: a company that walked out of military AI in 2018 after the Project Maven revolt is back inside the classified perimeter.

OpenAI's presence is the most striking shift. As recently as January 2024 its usage policy explicitly forbade military applications. The company quietly removed that restriction, accepted the Pentagon's "all lawful purposes" language, and two years later it is sitting at the classified AI table. That made OpenAI the template every other vendor was measured against.

Here is the half of the roster with the deepest defense roots:

| Company | Defense role | Why they were a lock |
|---|---|---|
| Microsoft | Azure Government Secret/Top Secret + AI | JWCC holder, existing IL6 |
| AWS | GovCloud IL6 + Bedrock AI | Operates the CIA's C2E cloud |
| Oracle | OCI Government cloud + database | Long-running DoD ERP operator |
| Nvidia | Training/inference GPU + software | De facto DoD AI infra standard |

The other four describe a strategic bet rather than a compliance default. Google brings Gemini back into classified rotation. OpenAI brings GPT deployment behind the SCIF wall. SpaceX brings Starshield satellite comms and edge inference for forward-deployed networks. And Reflection AI — a 2025-founded startup negotiating a $25B valuation, with no public model and no shipped product — got a classified contract anyway.

The contrast with Anthropic is brutal. Claude is one of the most capable frontier models in the world. It was excluded. A company with no model was included. The selection criteria are not about technical capability. They are about willingness to sign whatever the government puts in front of you.

{% link ji_ai/claude-opus-47-hit-876-on-swe-bench-the-story-is-what-it-didnt-charge-you-1c4b %}

## The clause Anthropic refused to sign

In 2025, the DoD started requiring AI vendors to accept an "all lawful purposes" clause. The language gives the Pentagon broad discretion to use the AI for any legally authorized purpose — including lethal autonomous systems support, targeting, and weapons platform integration. It does not mandate those uses. It just does not exclude them. It is a blank check on usage rights.

Anthropic refused. The company's Acceptable Use Policy prohibits using Claude to "cause serious harm to people" and restricts autonomous weapons applications. Signing the clause would have effectively voided that policy — the exact thing Anthropic uses to differentiate itself from OpenAI. So early in 2026, the DoD formally classified Anthropic as a "supply chain risk." That label is the procurement equivalent of being declared a national security threat, except it did not come from a technical vulnerability or counterintelligence finding. It came from a procurement office that decided a vendor who might refuse to support a specific use case mid-contract is operationally unreliable.

Anthropic responded with a federal lawsuit in March, arguing the classification is arbitrary and amounts to a permanent ban without due process. The lawsuit is active. The DoD signed the eight-company contracts anyway. Compressed timeline: OpenAI dropped its military prohibition in January 2024; the "all lawful purposes" clause appeared in 2025; Anthropic refused in late 2025; the "supply chain risk" classification landed in early 2026; the lawsuit was filed in March; Axios reported the NSA was already running Anthropic's Mythos cyber-defense model on April 19; the IL6/IL7 contracts went out without Anthropic on May 1.

```
$15B  ── annual U.S. defense AI spend Anthropic just walked away from
$900B ── valuation Anthropic might land at next month
─────────────────────────────────────────────────────────────────────
The first AI company to refuse the Pentagon's terms is also the
most expensive one. That's not a coincidence. That's the trade.
```

## The Mythos paradox makes the lawsuit interesting

The strangest part of this story is that within the same federal government, the NSA — an agency that operates at the highest classification levels — is actively using Anthropic's Mythos Preview model for network intrusion detection and threat analysis. Pentagon CTO Emil Michael addressed the contradiction in a May 1 CNBC interview with one sentence: "The blacklist holds, but Mythos is a separate issue."

Translate that. The DoD will not accept Anthropic as a full partner, but it will make exceptions when a specific Anthropic tool is too good to ignore. That position is operationally rational and legally fragile. You cannot simultaneously argue that a company is a supply chain risk to national security while running its model inside your signals intelligence agency. Well — you can argue it, Emil Michael just did, but it is not a position that holds up under judicial scrutiny.

This matters because Anthropic's lawsuit now has unusually clean evidence. If a federal court rules the "supply chain risk" classification was arbitrary, the DoD may be forced to revisit the contract structure and the precedent will reach far beyond Anthropic. It would set a limit on how governments can condition AI procurement on usage terms.

{% link ji_ai/stellantis-just-outsourced-its-ai-moat-to-microsoft-expect-gm-ford-and-vw-to-follow-578 %}

## What this means if you are building on Claude

Three trade-offs are locking in at once. First, frontier AI procurement is now a usage-rights negotiation, not a capability evaluation. The Pentagon did not benchmark Claude against GPT and Gemini and decide Claude lost. It did not evaluate at all. The selection ran on contract acceptance. If you plan to sell into government, design your AUP knowing the "all lawful purposes" clause exists and pick a side before customers force you to. Retrofitting later is what got Anthropic into court.

Second, AI safety as a brand has become measurably more expensive. Anthropic's stance might still be the right long-term bet, but the short-term cost is a $15B/year market and a credibility hit at the worst possible moment in its fundraising cycle. The counter-bet is that this stance compounds into enterprise trust in regulated industries — healthcare, finance, EU public sector — that the contract-signers cannot match. Both bets are live.

Third, the trade-off developers feel first. If your project depends on the Claude API and your work touches federal, defense, or adjacent regulated domains, the ground has shifted. Commercial API access is unaffected today. But the "supply chain risk" label travels — once a federal agency uses it, primes start asking whether their own vendors are exposed. Build a contingency plan: know your migration path to the closest non-Anthropic substitute and price dual-vendor architecture before procurement asks.

If you want a way into the defense AI market itself, the door is more open than six months ago. Reflection AI's inclusion proves you do not even need a shipping product. You do need FedRAMP High, DISA STIGs, and the architecture differences between commercial cloud and Azure Government / AWS GovCloud — that experience is in genuinely short supply.

{% link ji_ai/symphony-why-openais-prs-jumped-500-in-3-weeks-5b9i %}

## So who is actually right here

Both sides have a coherent argument and that is exactly why this is hard. Defense hawks see Anthropic as naive: if you want government contracts, you play by government rules. OpenAI, Google, and Microsoft understood that. Anthropic chose principle over pragmatism and the bill came due.

AI safety researchers see the same situation as a stress test of whether responsible AI development means anything once the customer is the most powerful military on earth. If a frontier lab folds the moment the Pentagon offers a check, the entire concept of an Acceptable Use Policy becomes performative.

The Pentagon is operationally rational. Anthropic is philosophically coherent. This is not a case where one side is clearly wrong — it is a structural tension the industry has not resolved. History is kind to companies that held lines, but surviving as a $900B company without your own government's trust is harder than it looks.

> The first AI vendor to refuse the Pentagon's contract terms is also the most expensive one — that is the new shape of AI sovereignty.

If you are shipping production workloads on Claude in a regulated industry, does Anthropic's Pentagon stance change your bet — or does it become the reason you double down?

Full Korean analysis on [spoonai.me](https://spoonai.me/posts/2026-05-02-pentagon-anthropic-blacklist-confirmed-ko).

---

**Sources:**
- [DefenseScoop](https://defensescoop.com/2026/05/01/dod-expands-classified-ai-work-with-8-companies-excluding-anthropic/)
- [CNBC](https://www.cnbc.com/2026/05/01/pentagon-anthropic-blacklist-mythos-michael.html)
- [Breaking Defense](https://breakingdefense.com/2026/05/pentagon-clears-7-tech-firms-to-deploy-their-ai-on-its-classified-networks/)
- [Defense News](https://www.defensenews.com/news/pentagon-congress/2026/05/01/pentagon-freezes-out-anthropic-as-it-signs-deals-with-ai-rivals/)
