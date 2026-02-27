---
title: "44% Win Rate and Still Profitable?"
published: false
description: 'High win rate = good strategy? My bot loses 56% of trades and still makes money. Here is why.'
tags:
  - ai
  - trading
  - python
  - beginners
---

44.3% win rate. Loses 56 out of 100 trades.

This strategy returned +6.78% over 180 days. I ran the backtest three times because I thought it was broken. It wasn't. More than half the trades lose, and it still makes money.

That's when I realized: win rate tells you almost nothing about a strategy.


---

## Wins Are Bigger Than Losses

Here are the actual numbers from V1h:

```
Average win:  +4.64%
Average loss: -2.54%
```

When it wins, it takes 4.64%. When it loses, it gives back 2.54%. The reward-to-risk ratio is 1.83:1.

Run that through 100 trades. 44 wins produce +204%. 56 losses cost -142%. Net: +62%. That's what a Profit Factor of 1.45 looks like.

Profit Factor is total gross profit divided by total gross loss. Below 1.0, you're bleeding. Above 1.0, you're making money. V1h sits at 1.45. **For every dollar lost, it earns $1.45 back.**

An 80% win rate with a PF of 0.9 loses money. A 30% win rate with a PF of 2.0 prints money.

Win rate is psychological comfort. Profit Factor is reality.


---

## Why a Wider Stop-Loss Improves Everything

The original stop-loss was 2.0%. "Cut losses fast" — that's what every trading book says. But the grid search told a different story. SL at 3.0% was overwhelmingly better.

```
SL 1.5%  → ~28% WR  PF ~0.85  loss
SL 2.0%  → ~35% WR  PF ~1.1   barely break-even
SL 3.0%  → 44.3% WR PF 1.45   profit
SL 4.0%  → ~47% WR  PF ~1.25  profit but declining
```

Tight stops get clipped by noise. On 1-hour candles, XRP routinely dips -1.5% from entry and bounces back. Every time that happens with a 2.0% stop, you get stopped out — right before the move you predicted.

A 3.0% stop survives the noise zone. It only triggers when the trade is genuinely wrong.

But 4.0%? Win rate improves, but PF drops. The loss per trade gets so large that the reward-to-risk ratio breaks.

**The optimal stop-loss sits exactly where it survives noise but catches real failures.** For XRP on 1-hour candles, that point was 3.0%.


---

## The Trailing Stop Trap

When a trade goes green, every instinct says to lock in the profit. "Activate trailing stop at +2%, close if it pulls back -1% from the peak." Sounds perfect.

But activating too early kills your winners.

Trailing kicks in at +2%, price pulls back -1%, and you exit at +1%. That same trade might have reached +4.5%. You locked in a small win instead of letting it run.

The optimized trailing parameters were +3.1% activation and -2.1% callback. Let the trade run before you start protecting.

```
Trailing activation 2.0% → cuts winners early (win small)
Trailing activation 3.1% → protects after a real move (win big)
```

"Secure profits quickly" is the instinct that shrinks your profits. Completely counterintuitive.


---

## Time Exit as a Safety Net

Imagine holding a position for 48 hours and it's still in the red. Maybe the direction is right, maybe not. But if it hasn't moved in 48 hours, the market context has probably changed.

The original time exit was 48 hours. Grid search found 72 hours was optimal. A surprising number of positions that were negative at hour 48 turned positive by hour 72.

Average holding time is 30 bars — about 30 hours. Most trades end via SL (-3.0%), TP (+4.5%), or signal reversal well before the time limit. The 72-hour exit is a safety net for the few positions that just drift sideways going nowhere.


---

## The Full Picture

Here's V1h's complete 180-day backtest:

```
Total trades:     70
Won/Lost:         31W / 39L (44.3%)
Profit Factor:    1.45
Total return:     +6.78% (3x leverage)
Max drawdown:     -1.00%
Avg win:          +4.64%
Avg loss:         -2.54%
Reward/Risk:      1.83:1
Expectancy:       +0.64% per trade
```

Exit reasons break down to 26 TP hits, 22 SL hits, 17 signal reversals, 4 time exits, and 1 end-of-data. More TPs than SLs. That's the physical basis of PF above 1.0 — the SL/TP ratio is set so that price reaches take-profit before it reaches stop-loss more often than not.

Obsessing over win rate misses the point entirely.

> What matters isn't how often you win — it's how big you win when you do.
