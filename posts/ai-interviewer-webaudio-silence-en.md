---
title: "Why I measure interview silence with WebAudio, not the Speech API"
published: true
description: "STT event timings lie about when you stopped talking. Why I measure voice-interview silence from the waveform with WebAudio instead."
tags:
  - webaudio
  - javascript
  - webdev
  - ai
---

**TL;DR** — In a browser voice app, "did the candidate stop talking?" is a real-time signal you cannot reliably get from speech-to-text. STT event timings are polluted by network latency, buffering, and the recognizer rewriting its own guesses, so they will report a pause while someone is mid-sentence. I measure silence acoustically with a small WebAudio graph, add hysteresis so it doesn't flap, and split a "thinking pause" from "done answering" with two thresholds. The live filler-word counter comes along almost for free — from the transcript, not the waveform.

## The signal I actually needed

I'm building a browser-based voice mock interviewer where three AI interviewers take turns and the whole point is an honest rehearsal — it names the reason you'd get rejected before it says anything nice. Voice-first, no subscription, first interview free. That's the thing I'm building at [preterview.com/en](https://preterview.com/en).

Voice-first means the engine constantly has to answer one boring, load-bearing question: *have you finished your answer, or are you just thinking?* Get it wrong in one direction and an interviewer talks over you mid-sentence. Get it wrong in the other and you sit in dead air waiting for a bot that thinks you're still going. Everything downstream — when a follow-up fires, when the turn hands off — hangs on that call.

The naive version reaches for the transcriber, because the transcriber is already running. That instinct is the bug.

## Why STT event timing lies

I use the browser's Web Speech API for transcription: `continuous` and `interimResults` on, and I flip `recognition.lang` between `en-US` and `ko-KR` depending on the session so the same engine handles English and Korean rehearsals. It's good at turning speech into text. It is not a clock.

If you try to infer silence from the gaps between `onresult` events, you inherit three problems at once:

- **Network latency.** Cloud-backed recognizers round-trip audio. The gap between events reflects *when results came back*, not when the person went quiet.
- **Buffering.** The recognizer batches audio and emits in chunks, so words arrive in bursts with quiet stretches between them even while someone is talking steadily.
- **Interim churn.** With `interimResults`, the recognizer revises its guess. You'll get a flurry of events that are the *same* words being rewritten, which looks like activity that isn't speech and masks silence that is.

The result is exactly backwards from what you want: a candidate mid-sentence looks stalled, and a candidate who genuinely froze looks busy because a late result just landed. I chased phantom "you paused" triggers for a while before accepting that STT timing is the wrong sensor.

## Ask the audio about the audio

Silence is a physical property of the microphone signal. So measure the signal. A tiny WebAudio graph taps the mic stream and reads the waveform, and silence becomes a real acoustic measurement instead of an inference from a lossy proxy.

```js
// Simplified, not from the repo. Silence is read from the waveform.
const analyser = audioCtx.createAnalyser();
analyser.fftSize = 2048;
micSource.connect(analyser);

const buf = new Float32Array(analyser.fftSize);

function rms() {
  analyser.getFloatTimeDomainData(buf);
  let sum = 0;
  for (const s of buf) sum += s * s;
  return Math.sqrt(sum / buf.length); // ~0 = quiet, higher = speech
}
```

`getFloatTimeDomainData` hands you the raw waveform, and root-mean-square collapses a frame of it into one loudness number. The transcriber now does exactly one job — turn sound into words — and the waveform owns everything about timing. That split is the whole trick.

## Making it not flap

A raw threshold on `rms()` is a mess in practice, because real rooms are never silent and human speech has gaps inside it. Two things fix it.

**Calibrate a noise floor.** "Quiet" is relative to the room. A laptop fan, an air conditioner, street noise through a window — all of it sits above absolute zero. Sample the ambient level for a moment before the answer starts and set the silence threshold *relative* to that floor, rather than shipping one magic constant that's wrong in half the world's bedrooms.

**Add hysteresis, and use two thresholds.** Speech has micro-gaps — between words, between clauses, the little catch before a hard consonant. If a single quiet frame flips you to "silent," the signal chatters. So I accumulate quiet time and require it to cross a duration before it means anything, and I keep two different durations:

```js
// Simplified, not from the repo. Two thresholds, accumulated over time.
let quietMs = 0;

function onFrame(dtMs) {
  const speaking = rms() > noiseFloor * SPEECH_MARGIN;
  quietMs = speaking ? 0 : quietMs + dtMs;

  if (quietMs > THINKING_MS && quietMs <= DONE_MS) {
    // short gap: they're composing. Do nothing, hold the floor.
    showThinkingHint();
  } else if (quietMs > DONE_MS) {
    // long gap: the answer is complete. Let the interviewer respond.
    endOfAnswer();
  }
}
```

The short threshold is a *thinking pause*: the candidate is composing a sentence, and the correct behavior is to do nothing and not step on them. The long threshold is *done answering*: now the turn can advance. Collapsing those two into one number is how you build something that either interrupts people or feels sluggish — there's no single value that's both patient and responsive, because they're different states.

One more reason to own the frame loop yourself: it makes barge-in cheap. If the candidate starts talking again while an interviewer is speaking, `rms()` crosses the speech margin instantly and you can react on the next frame, no transcript required.

## The filler-word counter you get for almost free

The rehearsal shows a live count of "um" and "uh" ticking up while you talk, so you watch the habit form in real time instead of reading about it in a report afterward. People assume that comes from the audio graph. It doesn't — a bare RMS meter can't tell "um" from "on," you'd need actual recognition for that. Fillers come from the *transcript*.

What's free is the plumbing. The same per-frame loop already running to paint the silence meter is where I also surface the filler count, so there's no second render path — silence from the waveform, fillers from the interim transcript, both updating in the same tick.

The one gotcha worth stating out loud: don't count fillers off interim results. Interim hypotheses get rewritten constantly, so a naive regex over the live string double-counts and flickers as the recognizer changes its mind. Count only on finalized segments — the ones where `result.isFinal` is true — and run the locale-aware "um"/"uh" match there. Same audio session, two independent metrics, one render loop, and neither sensor is asked to do a job it's bad at.

## What it bought me

Three things generalized well past this project.

- **Measure the physical signal when you can.** Silence is physics; don't infer it from a lossy text proxy that was built for a different purpose.
- **Give a real-time signal hysteresis and states.** One threshold makes a system that's either rude or slow. Separate "thinking" from "done" and the behavior stops fighting the user.
- **Let each sensor do one job.** The waveform owns timing, the recognizer owns words. Everything got simpler the moment I stopped making one of them pretend to be the other.

The uncomfortable version of the lesson is that the "smart" component — the LLM, the recognizer — is rarely where the hard engineering lives. The hard part is the boring plumbing that decides when it's someone's turn to speak. If you want to poke at where this ended up, it's at [preterview.com/en](https://preterview.com/en).

*(Code snippets above are simplified for illustration, not lifted from the repo.)*
