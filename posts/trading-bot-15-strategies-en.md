---
title: I Had AI Build 15 Trading Strategies. Only 1 Survived.
published: false
description: 'MACD, RSI, Bollinger, ATR, DI... more complexity should mean more profit, right? 180-day backtest said otherwise.'
tags:
  - ai
  - trading
  - python
  - beginners
id: 3292498
date: '2026-03-15T06:01:44Z'
---

I assumed more complex strategies would make more money.

Stack five indicators, add dynamic stop-losses with ATR, throw in a volume gate — surely that makes better decisions. So I kept asking Claude to build more strategies. V1, V2, V3... all the way to V7. With variants, that's 15 total.

I backtested all of them on 180 days of XRP 1-hour candles with 3x leverage.

The results were brutal.


---

## It Started with a 4-Indicator Voting System

The original strategy was simple. EMA crossover, RSI overbought/oversold, Bollinger Band squeeze, and multi-timeframe pullback. Each indicator votes "long", "short", or "neutral." Two or more votes in the same direction triggers an entry.

But EMA crossover had a problem. It's slow. By the time the signal fires, the trend is already halfway done.

So in V1, I replaced EMA crossover with MACD histogram momentum. Crossover tells you "the trend changed." MACD histogram tells you "momentum is accelerating." Much faster.

```python
# EMA crossover: already late
if ema20 > ema50 and prev_ema20 <= prev_ema50:  # cross event

# MACD histogram: catches momentum acceleration
if hist > prev_hist > prev_prev_hist and hist > 0:  # consecutive rise
```

Once V1 worked, I got greedy. "What if I improve it further?"


---

## I Spawned 6 Variants

I built variations on V1. V1a catches MACD signals in just 1 bar instead of 2. V1b only enters when volume exceeds 1.2x average. V1c adds DI direction as a 5th indicator. V1d uses ATR for dynamic SL/TP. V1e loosens the RSI and ADX thresholds. V1f combines everything.

My gut said V1f would crush it. Volume filter + DI direction + ATR dynamic exits. Maximum information, maximum edge.

180-day backtest results:

```
V1  (MACD base)     →  70 trades  44.3% WR  PF 1.45  +6.78%
V1e (loose filters) → 101 trades  39.6% WR  PF 1.19  +4.13%
V1a (1-bar fast)    →  78 trades  42.3% WR  PF 1.22  +3.73%
V1b (volume gate)   →  44 trades  43.2% WR  PF 1.32  +3.36%
V1c (added DI)      → 156 trades  34.6% WR  PF 0.97  -1.42%
V1d (ATR dynamic)   →  84 trades  30.9% WR  PF 0.95  -0.88%
V1f (full combo)    → 135 trades  30.4% WR  PF 0.90  -2.56%
```

**V1f was the worst performer.** The most complex strategy lost the most money.


---

## Why Complexity Kills

V1c added DI as a 5th indicator with a 2-out-of-5 voting threshold. That threshold was too low. It traded 156 times with a 34.6% win rate. Overtrading. I didn't realize that adding one indicator breaks the "agreement ratio" of the whole system.

V1d replaced fixed 3.0% SL with ATR-based dynamic SL. Widen the stop when volatility is high, tighten when it's low. Logically perfect. But the result was a 30.9% win rate.

When ATR was narrow, the SL got so tight that random noise kept triggering it. The fixed 3.0% SL gave positions room to breathe. ATR took that breathing room away.

V1f combined the weaknesses of V1c, V1d, and V1b. Individual flaws compound when stacked. I paid for that lesson.

The takeaway is clear.

> Adding indicators doesn't add information — it adds noise.


---

## The Real Variable: Grid Search on Parameters

Strategy architecture mattered less than parameters.

When I changed SL from 2.0% to 3.0% and TP from 4.0% to 4.5%, V1's returns jumped. I ran a grid search across five parameters: SL, TP, trailing activation, trailing callback, and time exit.

At SL 2.0%, the win rate hovered around 35%. At SL 3.0%, it jumped to 44.3%. Positions that used to get stopped out by noise survived long enough to become winners.

```
SL 2.0% + TP 4.0%  → ~35% WR, PF ~1.1
SL 3.0% + TP 4.5%  → 44.3% WR, PF 1.45
```

**Widening the stop-loss by 1% was more effective than changing the entire strategy.**

Spending an hour designing a new indicator has 3x less impact on returns than optimizing a single stop-loss parameter.


---

## The Survivor

The final strategy is V1h. It's the V1 MACD momentum core with two pattern "boosters" borrowed from the top-ranked players on HuggingFace's Prompt & Dump AI Trading Arena. The boosters don't change entry conditions. When a V1 signal fires and a pattern also confirms, position size goes from 5% to 8%.

```
V1h = V1 MACD core (4-indicator voting)
    + Anchor Candle pattern (institutional accumulation candle)
    + Spring Bounce pattern (bounce after dipping below moving average)
    → pattern confirmation: confidence +1 → larger position
```

180 days, 3x leverage. 70 trades, 44.3% win rate, Profit Factor 1.45, total return +6.78%, max drawdown -1.00%.

This strategy is running live right now. XRP/USDT perpetual futures, 1-hour candles, Bybit.

What I learned from building 15 strategies comes down to one thing.

> The best strategy isn't the most complex — it's the one that survives.
