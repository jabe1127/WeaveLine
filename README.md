# WeaveLine

A shot-timing display for Hunters in TBC Classic (Anniversary realms).

WeaveLine answers one question continuously: **what should I be doing right
now, and how long have I got?** It is a reading aid, not automation — every
input is still yours.

---

## Features

**Two lanes, no timeline.** The upper lane is a state display that fills and
drains; the lower is your melee swing timer. Neither scrolls, so neither can
drift out of sync with your real shots.

**Named cast states.** Whatever you are casting appears by name with its own
icon and its real hasted duration — Steady, Multi, Aimed, and channels like
Volley. A cast that will delay your auto turns orange and shows the overrun
in milliseconds while it is still happening.

**Melee window detection.** The free stretch between your cast finishing and
your auto animating is reported as MOVE when a swing will actually land while
you are in there, and DOWNTIME when nothing will. Going in for nothing costs
position and returns no damage.

**Overdue auto tracking.** Standing in melee stops Auto Shot, so the shot
simply waits. The bar counts up the delay you are accruing, which is the
number that decides when to step back out. Caps at 3s.

**Melee swing timer.** Fills right to left as your swing recharges. Green
when Raptor Strike is off cooldown, grey when it is not.

**Multi-Shot and Arcane Shot pips** above the bar, showing real cooldowns
with a glow and a swell when they come up.

**Range finder.** Distance estimate from a ladder of item-range probes,
dead-reckoned between crossings using your actual movement speed, with the
melee boundary as an exact anchor. Colours the border and reports travel
time to melee.

**Rhythm learning.** The auto grid runs at your *measured* auto-to-auto
interval rather than a theoretical one, so it tracks the rotation you
actually produce. Phase corrections are low-passed and bled in over time so
nothing visibly jumps.

**Options panel** under Esc → Options → AddOns → WeaveLine, or `/wl options`:
toggle each element, rescale the whole addon from 50% to 200%, and recolour
any state with the standard colour picker. Everything persists.

**Shift-drag to move.** Position is saved.

---

## The upper lane

| State | Colour | Meaning |
|---|---|---|
| *spell name* | slate | Casting. Counts down to completion. |
| *name* **CLIP +n** | orange | This cast will delay your auto by n ms. |
| *name* | blue | Channelling. |
| *name* | grey | Just finished — held briefly so short casts register. |
| **MOVE** | green | Free, and a swing lands before the auto. Worth the trip. |
| **DOWNTIME** | slate | Free, but no swing lands. Nothing to collect. |
| **AUTO SHOT** | red | Auto animating. Moving here delays the shot. |
| **AUTO LATE +n** | amber | Shot is overdue by n ms and waiting on you. |

---

## Timing model

Ported from **Bouk's Hunter Castbar**, whose numbers are the reference:

- Cast times are the tooltip value **divided by haste**. `GetSpellInfo`
  returns the unhasted figure, so using it directly draws every window too
  narrow.
- Haste includes **quiver haste**, which `GetRangedHaste()` omits entirely.
  Quivers are identified by item ID and multiplied in by hand; without this
  every derived timing is 10–15% out.
- An auto shot is a reload of `eWS − 0.5/haste` followed by a hasted cast.
- The auto is blocked by **casts only**, never by the GCD — which is why
  Multi costs clip and Arcane, being instant, does not.

Sanity check: quiver 1.15 × Serpent's Swiftness 1.20 = 1.3800, and a 2.9
speed bow at 2.10 eWS implies 1.3810. Agreement to four digits.

---

## Commands

`/wl` or `/weaveline` lists all 63. The ones worth knowing:

| Command | Does |
|---|---|
| `options` | Open the settings panel |
| `check` | eWS, haste, cast times, measured rhythm, phase error |
| `range` | Every range probe individually, including which items you lack |
| `cd` | Cooldown lookups by name vs by ID |
| `apis` | Which options APIs this client exposes |
| `why` | Why the bar might be blank |
| `sync` | Restart the sequence from now |
| `lock` / `unlock` | Fix or free the frame position |

---

## Known limitations

- **The range finder cannot resolve inside 5–7 yards.** Every probe in the
  ladder sits outside that band, and no API reports which *direction* you are
  moving — only speed. So between the melee boundary and the 7-yard rung the
  estimate is dead reckoning, and it freezes rather than guess when direction
  becomes unknowable. It is exact *at* the boundaries.
- **Range probes need the items in your bags.** `IsItemInRange` returns nil
  for an item you do not carry, which is not the same as "out of range".
  Run `/wl range` to see which rungs are actually working.
- **Cast starts are not reliably reported** for hunter shots on this client.
  Multi-Shot in particular confirms only on completion, so short casts show
  retroactively rather than as a live countdown.
- **Pushback is not modelled.** Damage taken while casting extends Steady,
  which shortens your real window below what the bar draws.

---

## Credits

- **Bouk** — [rotations reference](https://boukx.github.io/rotations/) and
  Hunter Castbar, the source of the entire timing model. The quiver-haste
  handling and the cast-blocks-auto rule are both his.
- **diziet559** — [rotationtools](https://github.com/diziet559/rotationtools),
  which settled what Multi-Shot and Arcane Shot are actually *for*: filling a
  GCD where a full Steady would delay the auto.
- **Classic & TBC Hunter Discord** — Kanja for the French rotation, Antiserum
  and Sixx for weaving, and everyone in the rotationtools credits.
- **[HUNTER] Predictive Melee Weave** (Joosy edit) — the item-based range
  probe technique, and the insight that a discrete state display beats a
  precise-looking number.
- **Blizzard's Classic team** — for documenting the hidden
  [retry timer](https://eu.forums.blizzard.com/en/wow/t/classic-hunter-the-retry-timer/155679),
  without which the weave timings make no sense.
