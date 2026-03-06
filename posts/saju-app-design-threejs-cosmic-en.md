---
title: "Why Googling Your Category Kills Your Design — and How I Built a Cosmic 3D Background with Three.js"
published: true
description: "Searched ‘fortune telling site design’ → garbage. Decomposed the essence → found A(i)strology → put 8,000 stars in a Three.js scene"
tags:
  - ai
  - webdev
  - threejs
  - design
---

Search “fortune telling website design” and you’ll get red backgrounds with gold text, dragon illustrations, and layouts that haven’t been updated since 2008.

I’m building a saju app — Korean four-pillar fortune telling, a system that maps your birth date and time to celestial patterns.
The frontend I wanted looked nothing like those search results.

I wanted something closer to A(i)strology’s immersive dark UI, with particles drifting through space and constellations glowing softly behind translucent cards.

The first problem wasn’t code.
It was finding references that didn’t look like free WordPress themes.

## Don’t Search by Category. Search by Essence.

The most common mistake when looking for design references is typing the category name directly into a search bar.

“Fortune site design.”
“E-commerce template.”
“Photographer portfolio.”

These queries return the most average, most template-like results in that category.

The exceptional work is buried under tags that have nothing to do with the category name.
The fix is to decompose the site’s essence first.

A saju site, stripped to its bones, does three things:

- it takes personal data as input,
- reveals results dramatically,
- and delivers a personalized interpretation.

That’s not unique to fortune telling.
Personality tests, health diagnostics, and astrology apps all share this exact pattern.

Once I had this decomposition, the search terms changed completely.

## Three Axes for Better Keywords

After decomposing the essence, I built search queries along three axes.

The **mood axis** covers the visual feeling I’m after:
`dark mystical`, `cosmic`, `neon gradient`, `spiritual`.

The **interaction axis** targets UX patterns:
`quiz experience`, `result reveal`, `card flip`, `personalized onboarding`.

The **adjacent industry axis** replaces the original category with neighbors:
`astrology app`, `personality test`, `wellness diagnostic`, `meditation`.

“Astrology app dark immersive” instead of “fortune telling website” opened up an entirely different world of results.

On Awwwards, I combined this with tag filters: Animation + Storytelling + Dark.
On Dribbble, color filters set to dark tones.
On Mobbin, I searched actual app names — Co-Star, The Pattern — to study real screen flows.

Two references locked in from this process.

## A(i)strology and Co-Star: Opposites That Complete Each Other

A(i)strology is an Awwwards Honorable Mention site built by Wix Studio.
AI-generated visuals, mouse parallax, sticky scroll, full dark immersive UI.
Scrolling triggers nebula-like visuals that morph alongside constellation interpretations.

Co-Star is the opposite.
Pure black and white. Almost no images.
One sans-serif typeface carries the entire experience.

I picked both because the saju app needs two things:

- first-impression immersion (A(i)strology)
- textual power (Co-Star)

Pull them in with visuals, hold them with interpretation.

The common thread between both references is dark UI.
Fortune telling, astrology, cosmic themes — dark backgrounds are the natural habitat.
Trying to create this mood on a white background is almost impossible.

Dark cosmic mood, confirmed.
The question became: how to build it.

## Why Full 3D Over CSS or 2D Canvas

Three approaches were on the table.

1. CSS-only gradients and blur
2. 2D Canvas particles
3. Three.js full 3D

CSS was the lightest option, but couldn’t create the sensation of drifting through space.
2D Canvas looked decent but had weak depth.

Three.js was the heaviest option, but closest to the immersive feel I wanted.
A camera inside 3D space creates natural depth as particles approach, pass by, and disappear.

The layering architecture:

```text
[Layer 0] Three.js Canvas — position: fixed, z-index: 0
[Layer 1] Glow Overlay — position: fixed, z-index: 1, pointer-events: none
[Layer 2] React UI — position: relative, z-index: 10
```

## 8,000 Stars and the Square Problem

First version: 3,000 stars using `PointsMaterial`.

```js
const starMat = new THREE.PointsMaterial({
  color: 0xffffff,
  size: 1.5,
  transparent: true,
  opacity: 0.8,
});
```

Problem: stars rendered as squares.
That instantly broke immersion.

Fix: generate a circular Canvas texture and pass it as `map`.

```js
function createCircleTexture(size, coreRatio) {
  const canvas = document.createElement("canvas");
  canvas.width = size;
  canvas.height = size;
  const ctx = canvas.getContext("2d");
  const half = size / 2;
  const grad = ctx.createRadialGradient(half, half, 0, half, half, half);
  grad.addColorStop(0, "rgba(255,255,255,1)");
  grad.addColorStop(coreRatio, "rgba(255,255,255,0.8)");
  grad.addColorStop(coreRatio * 3, "rgba(255,255,255,0.2)");
  grad.addColorStop(1, "rgba(255,255,255,0)");
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, size, size);
  return new THREE.CanvasTexture(canvas);
}
```

After that, I scaled to:

- 8,000 stars
- 1,000 nebula particles
- 500 dust particles

Star sizes use cubic weighting:

```js
starSizes[i] = 8 + Math.pow(Math.random(), 3) * 12;
```

Most stars stay small and dim, while a few become large highlights.

## The Drift: Flying Through Space

Static stars = wallpaper.
The key was z-axis drift.

```js
const driftSpeed = 16;
for (let i = 0; i < starCount; i++) {
  starPositions[i * 3 + 2] += driftSpeed * delta;
  if (starPositions[i * 3 + 2] > 2500) {
    starPositions[i * 3 + 2] = -2500;
    starPositions[i * 3] = (Math.random() - 0.5) * 5000;
    starPositions[i * 3 + 1] = (Math.random() - 0.5) * 5000;
  }
}
```

Stars approach, grow, streak past, then respawn in the distance.
That loop creates the “being pulled into space” feeling.

Dust moves 1.5× faster than stars to amplify near-field depth.

## Vignette + Glow: Guiding Attention

A uniform star field scatters attention.
I needed users focused on the center where forms and result cards live.

So I added a vignette overlay:

```css
radial-gradient(
  ellipse at 50% 50%,
  transparent 40%,
  rgba(2,2,8,0.3) 60%,
  rgba(2,2,8,0.85) 80%,
  rgba(2,2,8,1) 100%
)
```

And a subtle center glow (`rgba(200,190,255,0.15)`) for a soft focal pull.

Mouse parallax was tuned down aggressively.
At high displacement, it looked chaotic.
With lower displacement and easing, it became a subtle “felt-not-seen” movement.

## What This Prototype Confirmed

The prototype validated direction, not completeness.

Confirmed:

- dark cosmic mood fits saju
- glass UI above moving stars works
- drift + vignette + glow creates immersion without destroying readability

Still missing:

- GSAP ScrollTrigger scene transitions
- R3F postprocessing bloom
- constellation click interactions
- robust mobile strategy (dynamic particle scaling / 2D fallback)

A prototype is for choosing direction.
Not shipping perfection.

> Search by category and you’ll build the average.
> Search by essence and you’ll build something that’s yours.
