---
title: "Codex Image Gen Saved My White Pixels as Transparent"
published: false
description: "Codex image generation saved a white monitor glow with alpha 1. How I measured it, fixed the pastel sprites with a flood fill, and kept two themes."
tags:
  - ai
  - gamedev
  - python
  - codex
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/07-cover.png"
---

The white glow on my pixel-art monitor came back from Codex's image tool as RGBA (22, 34, 44, 1). That is dark gray at 1/255 opacity. On a white page it looked perfect. On a dark background, the same file showed a black hole in the middle of the screen.

Refmade is a desktop app I'm building that reads your Claude Code and Codex session logs and draws them as a small pixel office. It is an independent project, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction. I wrote the specs, chose what stayed and rejected what looked wrong. This is part 7 of the series, and it covers 27 September, the day the office sprites were drawn twice, once in game style and once in pastel. The UI is Korean right now; that changes later in this series.

## 22 sheets, 69 files

On 27 September I asked for every office resource to be drawn with Codex CLI's built-in image generation. Each batch was a JSON spec and one `codex exec` call (`office-v2/assets-prompts/run_p3.sh` in the repo). Twenty-two raw sheets came back.

A second script, `integrate_p3.py`, cut them into 69 files: 12 characters in four poses each (standing, two walking frames, sitting), four rugs, a door open and closed, seven lounge props, a wall strip with a completion board on it, and a few more pieces such as the desk, chair, monitor and floor. The raw sheets are never edited. The script crops and shrinks them, and for the pastel versions it runs the fix described below, so running it again gives the same output.

## Five palettes in a row

The same day I was also redesigning the product site, and I rejected five palettes in a row.

| Proposal | My answer |
|---|---|
| Sky blue | Colors feel off |
| Butter yellow | Colors feel off |
| Sky-blue background | Colors feel off |
| White background | Colors feel off |
| The previous colors | Colors feel off |

The agent asked me what exactly was wrong. I ticked three boxes: background and card color, the wood and brown tones inside the pictures, and button and accent color. That is nearly everything, so it did not narrow anything down.

What I gave it instead was a rule: lighter pastel everywhere, a dot-style typeface (Galmuri, a pixel font under the SIL Open Font License), and no navy as the main color. The 22 office sheets were redrawn in pastel that afternoon (the file timestamps put the 22 new sheets between 16:00 and 16:09), and at 16:30 the whole site was unified in pastel. The pastel sheets are where the transparency problem showed up.

## The hole

Open one of the pastel sheets on a white background and it looks right. Put the same file on a dark background and the lightest areas turn into holes.

I measured one sheet while writing this post: `p-illus-monitor-v1.png`, 1536 x 1024.

- Pixels with alpha 255: 0. The maximum alpha in the file is 254.
- The blue screen: alpha around 250, for example RGBA (146, 186, 227, 241).
- The cream bezel: RGBA (253, 247, 243, 254).
- Inside the white glow: alpha 1 to 4, for example RGBA (22, 34, 44, 1). Composited on white, those pixels come out as (254, 254, 254).

A maximum of 254 is harmless by itself. The game-style monitor sheet from the same run also tops out at 254, but it has no near-white pixels, so nothing in it turns into a hole. In the pastel sheet, cream and pastel colors stay at alpha 252 to 254, while the areas that were pure white, the glow and the background, came back at alpha near 0. My guess is that the image tool treats pure white as background and cuts it out. I have not verified that.

![Three renderings of the same pixel-art computer monitor. Left: the raw file on a white background, the screen shows a white glow. Middle: the raw file on a dark background, the glow is a dark hole. Right: after the fix, on a dark background, the glow is white again.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/07-sprite-alpha.png)

*One raw sheet, three renderings. Left: on white, it looks correct. Middle: the same file on a dark background, with the glow punched through. Right: after `unmatte.py`. The image is the monitor sprite only, with no UI text.*

## The fix: composite on white, then decide what is "outside"

The intended picture was drawn on white, so the colors are only correct once the sprite is composited onto white. That restores the glow. The second problem is that the real background around the sprite must stay transparent, and the white glow inside the monitor must not.

`unmatte.py` does it in two steps. It composites on white, then it flood-fills from the four edges over every pixel with alpha below a threshold. Whatever the fill reaches is "outside" and becomes transparent. The dark outline that pixel art has anyway acts as a wall, so the glow inside the screen survives.

```python
white = Image.new('RGBA', im.size, (255, 255, 255, 255))
comp = Image.alpha_composite(white, im).convert('RGB')   # colors as drawn, on white
mask = im.getchannel('A').point(lambda v: 255 if v < thr else 0)
for xy in border_pixels:                                 # abridged: all four edges
    if mask.getpixel(xy) == 255:
        ImageDraw.floodfill(mask, xy, 128, thresh=0)     # 128 = reached from outside
alpha = mask.point(lambda v: 0 if v == 128 else 255)
out = comp.convert('RGBA'); out.putalpha(alpha)
```

*Abridged from `office-v2/assets-prompts/unmatte.py` (default threshold 110). I ran the original file for the images in this post, not this shortened version.*

Three notes. The third panel above still has a few stray specks along the top edge of the monitor, and `unmatte.py` does not remove them. Later, `integrate_p3.py` paints the monitor's whole blue screen area with one flat color anyway, because the page lights the screen with CSS. And two files took a different route. The spec for the wall strip and for the completion board says "fully opaque". The wall strip has a flat grey bottom that the script crops off. The board was drawn on flat magenta, and `integrate_p3.py` keys the magenta out (red above 190, blue above 190, green below 120). I did not write down why I chose that over `unmatte.py` for those two.

## The stretched pictures

While the site was being redrawn, the pictures on the three-step cards came out stretched vertically. I told the agents not to let broken aspect ratios slip through again, and they wrote `aspect-audit.mjs`.

It opens the page at 360, 390, 768, 1024 and 1440 px wide. For every `<img>` it compares the rendered ratio with the file's natural ratio. If the image uses the default `object-fit: fill` and the ratios differ by more than 2%, the audit fails. The last run on 27 September printed 0 distorted images.

The audit is a short Playwright script. I only said the problem must not come back, and the agent turned that into something that fails loudly.

## Two themes

Then I asked for two themes: the pastel look and the earlier game-style dots, with only the theme different. `integrate_p3.py` got a `--theme game` flag that skips the pastel sheets and builds the original art into a separate folder. By 17:30 the office page switched between them with a `data-theme` attribute. At 19:20 the characters grew department outfits: 21 characters, 24 topic stickers, 12 emblems.

![Two vertical panels of the team office view. Left, pastel theme: cartoon characters at desks under a label reading 'Work team'. Right, game theme: blocky characters at wooden desks on a gray floor.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/07-two-themes.png)

*The same office panel in both themes, from the current build (not the 27 September one). The data is public demo data: the task "Sort out customer inquiry replies" and its team are invented. Visible Korean text, plus the English tag "Codex": "Work team", "Sort out customer inquiry replies", "My answer is needed", "Waiting for my answer", "Team lead", "Business team", "Drafting reply · thinking", "Organizing FAQs · thinking".*

## What I would check next time

- Look at generated sprites on a dark background before wiring them in. A white page hides this bug.
- Read the alpha channel of one file. The numbers in this post came from a few lines of Python with PIL.
- Keep the raw sheets untouched and make the integration script rerunnable. I used that to build both themes from the same sheets.
- Turn "this must not happen again" into a check that exits non-zero.

If you generate sprites or icons with an image model, how do you catch alpha problems before they reach your UI? I have not built a check for this yet. One idea is to render every sprite on a dark background in the integration script and fail on any hole larger than a few pixels.
