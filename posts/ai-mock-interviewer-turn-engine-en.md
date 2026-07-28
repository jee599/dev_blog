---
title: "Building an AI mock interviewer that tells you why you'd fail: what the turn engine taught me"
published: true
description: "Notes from building a browser-based voice mock interviewer: why STT lies about silence, how a turn engine decides to probe or hand off, and defending against the model's bad JSON."
tags:
  - ai
  - webdev
  - javascript
  - career
---

**TL;DR** — I've been building a browser-based voice mock interviewer where three AI interviewers take turns, and the hard part was never the LLM prompt. It was the plumbing around it: detecting real silence without trusting speech-to-text timings, deciding *what an interviewer should do next* after a weak answer, and stopping the model's occasional malformed JSON from poisoning the final report. Here's the engineering, and the one interview that convinced me the design was actually working.

## The premise: a rehearsal that points at the failure first

Most interview-prep tools grade you and hand back encouragement. I wanted the opposite: an honest rehearsal that names the reason you'd get rejected *before* it says anything nice. No subscription, first interview free — the constraint was that the thing had to be useful in one sitting or not at all. That product stance turned out to shape almost every technical decision below, which is why I'm writing it up rather than just shipping quietly. It's the thing I'm building at [preterview.com/en](https://preterview.com/en).

## Speech-to-text lies about silence

The interview is voice-first. I use the browser's Web Speech API for transcription — `continuous` and `interimResults` on, and I flip `recognition.lang` between `en-US` and `ko-KR` depending on the session so the same engine handles English and Korean rehearsals.

The first instinct for "did the candidate go quiet?" is to look at the gaps between `onresult` events. Don't. Those intervals are contaminated by network latency and the recognizer's own buffering, so a candidate who is mid-sentence can look like they've stalled, and someone who genuinely froze can look busy. I got false "you paused" signals constantly.

The fix was to stop asking the transcriber about audio and ask the audio about audio. A small WebAudio graph measures the actual signal, and silence is a real acoustic measurement, not an inferred one:

```js
// Illustrative, not the production file.
// Silence is measured from the waveform, not from STT event timing.
const analyser = audioCtx.createAnalyser();
micSource.connect(analyser);
const buf = new Float32Array(analyser.fftSize);

function rms() {
  analyser.getFloatTimeDomainData(buf);
  let sum = 0;
  for (const s of buf) sum += s * s;
  return Math.sqrt(sum / buf.length);
}

let quietFor = 0;
function tick(dtMs) {
  quietFor = rms() < SILENCE_FLOOR ? quietFor + dtMs : 0;
  if (quietFor > LONG_SILENCE_MS) onLongSilence(); // real pause, VAD-confirmed
}
```

Two lessons stuck. First, treat STT as a text source and nothing more — the moment you use it as a timing source you inherit its lag. Second, the clean split pays for itself: the waveform owns timing, and the transcript stream owns words — which is where the live filler-word counter lives, ticking up "um" and "uh" while you're still talking, so you see the habit forming in real time instead of reading about it afterward.

## The turn engine: classify, then act

Three interviewers sit in the session, each with its own focus and questioning style. The interesting bit isn't the personas — it's that the system doesn't just generate the next question. Every turn runs two decisions in sequence: *classify the answer*, then *choose an action*.

Answers get sorted into a small set — `solid`, `thin`, `off_topic`, `dont_know`. Actions are a similarly small set — `discovery`, `drill`, `probe`, `pivot`, `new_topic`, `wrap_up`. Keeping both vocabularies deliberately tiny is what makes the behavior legible and testable; an open-ended "just decide what to say" prompt gave me charming but unpredictable interviewers.

```js
// Conceptual: the turn engine picks a behavior, not just a sentence.
function nextMove(answerClass, ctx) {
  switch (answerClass) {
    case "thin":      // vague answer -> same interviewer digs once more
      return { action: "probe", interviewer: ctx.current };
    case "off_topic": // didn't answer the question -> hand off
      return { action: "pivot", interviewer: ctx.other() };
    case "dont_know":
      return { action: "new_topic", interviewer: ctx.current };
    case "solid":
      return ctx.depth < MAX_DEPTH
        ? { action: "drill", interviewer: ctx.current }
        : { action: "new_topic", interviewer: ctx.next() };
  }
}
```

The two moves I lean on most are `probe` and `pivot`. A vague answer keeps the *same* interviewer on you for one more push — the way a real panelist won't let a hand-wave slide. An off-topic answer hands you to a *different* interviewer, which mirrors how a panel regroups when a line of questioning stalls. Encoding this as data (class in, action out) rather than prose meant I could reason about the interview as a state machine instead of praying the model behaved.

## Defending against the model's bad JSON

After the interview, the report is where the value lands: per-answer feedback, an example of a stronger answer for each question, and a competency radar. All of it comes back from the LLM as JSON, and LLMs will, occasionally, hand you JSON that is *almost* right — a missing field, a stray string where a number belongs, a competency array of the wrong length.

I treat model output as untrusted input. A shape-validation function checks every response before anything downstream sees it. If the shape is wrong, I regenerate — and critically, a malformed response never gets written to the cache, so a one-off bad generation can't get pinned in front of future readers.

```js
function isValidReport(r) {
  return (
    r &&
    Array.isArray(r.answers) &&
    r.answers.every(a => typeof a.feedback === "string" && a.betterAnswer) &&
    Array.isArray(r.competencies) &&
    r.competencies.every(c => Number.isFinite(c.score))
  );
}

// bad shape -> regenerate, and do NOT cache the reject
const report = await withRetry(generateReport, isValidReport);
```

The scores get a second layer of distrust. I don't let the model's self-reported total stand — the server clamps each competency into range and recomputes the total as the sum of the parts. There's exactly one source of truth for the overall score, so the model can't quietly contradict itself between the radar chart and the headline number. If you take one thing from this section: the LLM produces a *proposal*, and your code owns the *invariant*.

## The interview that convinced me it worked

The moment I trusted the design came from a session that went off the rails in a useful way. During an English QA run, some scripted answers drifted out of sync with the order the interviewers asked questions — answers were landing against the wrong prompts.

A softer system would have smoothed that over. Instead the turn engine read it consistently as a "candidate isn't listening to the question" pattern and stayed with that read across turns, and the final report surfaced it as a key risk rather than burying it. Nobody hand-coded "detect answering-out-of-order." The behavior fell out of a design that was built to name problems first — and it held in a situation I hadn't anticipated. That's the test I actually care about: not whether a system does the right thing on the happy path, but whether its stated intent survives contact with the weird case.

## What I'd tell another builder

Three things generalized well beyond this project. Measure the physical signal when you can, and don't infer physics (silence) from a lossy proxy (STT timings). Give your agent a small, closed vocabulary of moves so its behavior is inspectable instead of vibes-based. And put a hard boundary between what the model *proposes* and what your code *guarantees* — validate the shape, own the math, never cache a reject.

The uncomfortable part of building an honest-feedback product is that the honesty has to be structural. You can't bolt "tell the truth" onto a system that was architected to please. The turn engine, the score recomputation, the willingness to flag "not listening" as a risk — those aren't features on top of the idea, they *are* the idea. If you want to poke at where it ended up, it's at [preterview.com/en](https://preterview.com/en).

*(Code snippets above are simplified for illustration, not lifted from the repo.)*
