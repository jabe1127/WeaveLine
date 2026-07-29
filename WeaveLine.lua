# WeaveLine

A shot-timing bar for Hunters in TBC Classic (Anniversary realms).

WeaveLine shows the optimal rotation for your current weapon speed as a scrolling
timeline, holds itself in sync with your real Auto Shots, and tells you at a
glance whether you are in range to weave. It is a reading aid, not automation —
every input is still yours.

---

## The bar

A single lane scrolls right to left. The yellow line near the left edge is
**now**; anything touching it should be pressed. Roughly three auto-shot cycles
of upcoming rotation are visible at any time.

| Colour | Meaning |
|---|---|
| **Red** | Auto Shot — its hasted 0.5s cast. Press your next Steady during this. |
| **Yellow** | Steady Shot casting |
| **Violet** | Multi-Shot |
| **Pink** | Arcane Shot |
| **Orange** | Weave window — GCD-locked with nothing to cast, so move |
| **Dim tail** | Downtime, drawn as a faded continuation of whatever is still holding you |

Downtime is deliberately not its own colour. The 413ms after a Steady is not a
separate event — it is that Steady's GCD still running — so it is drawn as a dim
version of the thing that caused it.

**Black separators** sit on the leading edge of every input, tinted to match the
ability that follows. When a separator crosses the yellow line, press what comes
after it. Auto Shot and idle get no separator, so every separator on screen is an
input cue.

---

## Rotation model

The sequence follows [boukx.github.io/rotations](https://boukx.github.io/rotations/),
selected automatically from your effective weapon speed:

| eWS | Rotation | Shows |
|---|---|---|
| ≥ 1.9 | French 5:5:1:1 | Steady, Multi, Arcane, two weaves |
| 1.7 – 1.9 | 5:6:1:1 | Steady, Arcane, Multi |
| < 1.7 | 1:1 | Steady only, weave every cycle |

So when Drums or Bloodlust land, the Multi and Arcane notes disappear on their
own and the bar becomes pure Steady plus weaves. 2:1 is deliberately omitted —
the doc has it losing to French at effectively every speed.

The French sequence, one line per auto cycle:

```
auto - steady - multi
auto - steady            <- weave
auto - steady - arcane
auto - steady            <- weave
auto - steady
```

Notes are generated once and never rewritten. Nothing you do afterwards can move
a note already on the track.

---

## Staying in sync

Two independent mechanisms, covering opposite failure modes.

**The gate** handles you being late. When the red Auto Shot block reaches the
line, the timeline **stops** and `WAITING` appears until your real shot lands.
The length of that stall is exactly how much you clipped, and it is reported as
`clip 240ms`. The plan physically cannot run ahead of an auto you have not taken.
Bounded so losing a target cannot freeze the bar, and disabled automatically when
no shot has landed for three cycles so it does not stutter while you are idle.

**Phase lock** handles you being early. Every real auto is compared against the
nearest planned one and the whole track slides to match, converging in 0.35s —
slow enough to be invisible, and wrapped to half a cycle so it corrects phase
without ever jumping you a whole cycle sideways.

`/wl sync` restarts the sequence from the current moment. Step 1 always opens
with Multi, so firing it as you press Multi realigns cleanly.

---

## Range border

The bar's outline colour is your distance to target:

| Colour | Range |
|---|---|
| **Yellow** | In melee |
| **Bright green** | Within 7 yards — one tap of W from melee |
| **Blue** | 7 to 35 yards |
| **Red** | Beyond shooting range |

Exact yardage is printed top-left (`10-15 yd`, `melee`, `35+ yd`).

Classic exposes no distance API, so this brackets the target using items of known
range (7/10/15/20/25/30/35 yd) plus two independent melee probes: Wing Clip's
range check, and whether you are inside Auto Shot's minimum range. Either one
firing counts as melee.

---

## Melee swing timer

A thin bar flush under the border fills as your swing recharges and empties when
it lands.

- **Dark green** — Raptor Strike is off cooldown, so the swing is worth stepping in for
- **Grey** — Raptor is down; a plain swing only

Raptor resets it too, since Raptor rides your next swing rather than being a
separate attack. It runs on real time, so it keeps charging while the gate holds
the timeline.

---

## Impact feedback

Every melee swing and Raptor Strike expands the whole bar by 10% and settles back,
with a grey/white pulse and a border flare riding along. Raptor is longer and
stronger than a plain swing, so you can tell them apart without looking directly
at it.

---

## Readout

```
0-7 yd                                                        clip 240ms
[============ the bar ============]
[========== swing timer ==========]
eWS 2.10     French 5:5:1:1     steady 1087ms     gap 413ms
```

- **eWS** — effective weapon speed, the number everything derives from
- **steady** — your real hasted Steady cast time
- **gap** — what is left of the 1500ms GCD once that cast finishes

`steady` and `gap` always sum to the GCD, which is why the GCD itself is not
shown: it never changes and carries no information.

---

## Visibility

Hidden with no hostile target. Dimmed to 10% when targeting out of combat, full
opacity in combat, and fades over 2 seconds when a target dies rather than
blinking out.

Shift-drag to move. Position is saved.

---

## Timing model

Ported from **Bouk's Hunter Castbar**, whose numbers are the reference:

- Cast times are the tooltip value **divided by haste** — `GetSpellInfo` returns
  the unhasted figure, so using it directly draws every window too narrow
- Haste includes **quiver haste**, which `GetRangedHaste()` omits entirely. Quivers
  are identified by item ID and multiplied in by hand; without this every derived
  timing is 10–15% wrong
- An auto shot is a reload of `eWS − 0.5/haste` followed by a hasted 0.5s cast
- The auto shot is blocked by **casts only**, never by the GCD. This is why
  Multi costs ~124ms of clip while Arcane, being instant, costs nothing

Sanity check on the haste model: quiver 1.15 × Serpent's Swiftness 1.20 = 1.3800,
and a 2.9 speed bow at 2.10 eWS implies 1.3810. Agreement to four digits.

---

## Commands

`/wl` or `/weaveline`

**Diagnostics**

| Command | Does |
|---|---|
| `check` | eWS, haste, cast times, reload, rotation, step, phase slew |
| `range` | Every range probe individually — which one is lying |
| `gaps` | Any time holes in the note queue |
| `debug` | Prints phase error per auto and impact triggers |
| `sync` | Restart the rotation sequence from now |

**Layout**

`width` · `laneh` · `linepos` · `linewidth` · `cycles` · `border` · `textgap` · `lock` · `unlock`

**Bar contents**

`seps` · `sepwidth` · `sepbright` · `sepoverhang` · `ticks` · `idle` · `idlestyle` · `idlemin` · `idleheight` · `idlealphatail` · `gloss` · `actual`

**Sync**

`gate` · `gatemax` · `phaselock` · `slewtime` · `slewrate` · `squarehaste`

**Swing timer**

`swing` · `swingh` · `swinggap`

**Impact**

`scale` · `flash` · `peak` · `pop` · `testflash`

**Range and visibility**

`meleeprobe` · `idlealpha` · `alwaysshow`

---

## Known limitations

- **Green band is 5–7 yards, not exactly one step.** The shortest range item is
  7 yards and melee is 5, so there is nothing finer to test against. Distinguishing
  6 yards from 7 would need integrating `GetUnitSpeed` over time to estimate
  position continuously.
- **`squareHaste` is on by default.** Bouk's Duration Info multiplies ranged haste
  in twice, which reads like a slip but produces the bar that visibly tracks in
  game. It changes the auto cast by ~60ms. `/wl squarehaste` toggles it.
- **Pushback is not modelled.** Damage taken while casting extends Steady, which
  shortens your real window below what the bar draws.
- **The sequence assumes you play it clean.** A missed Multi is not detected; use
  `/wl sync` to realign. Cooldown-driven placement was tried and removed — it made
  notes jump around, and a bar you cannot trust is worse than one that occasionally
  assumes too much.

---

## Credits

- **Bouk** — [rotations reference](https://boukx.github.io/rotations/) and Hunter
  Castbar, the source of the entire timing model
- **Classic & TBC Hunter Discord** — Kanja (French rotation), Antiserum and Sixx
  (weaving), and everyone in the rotationtools credits
- **[HUNTER] Predictive Melee Weave** — the item-based range probe technique
