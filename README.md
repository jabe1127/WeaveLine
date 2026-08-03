# Jabe's TBC Hunter WeaveLine

A shot-timing display for Hunters in TBC Classic (Anniversary realms).

WeaveLine answers one question continuously: **what should I be doing right
now, and how long have I got?** It is a reading aid, not automation — every
input is still yours.

---

## The display

### Upper lane — what you are doing

A state display that fills and drains. It does not scroll, so it cannot
drift out of sync with your real shots.

| State | Meaning |
|---|---|
| *spell name* | Casting, counting down to completion. Named, with its own icon and real hasted duration. |
| *name* **CLIP +n** | This cast will delay your auto by n ms. Shown **while you are still casting**, not after. |
| *name* (blue) | Channelling — Volley, Rapid Fire. |
| *name* (grey) | Just finished. Held briefly so short casts like Multi-Shot register. |
| **MOVE** | Free to move, and a swing will land while you are in there. Worth the trip. |
| **DOWNTIME** | Free, but no swing lands. Nothing to collect by going in. |
| **AUTO SHOT** | Auto animating. Moving now delays the shot. |
| **AUTO LATE +n** | Shot is overdue by n ms and waiting on you. Caps at 3s. |

Works as a general cast bar too — herbing, mining, mounting, a res all appear
with their name and duration, target or not.

### Lower lane — melee swing timer

Fills right to left as your swing recharges. Green when Raptor Strike is off
cooldown, grey when it is not.

### Icons

Multi-Shot, Arcane Shot and Kill Command, each with real cooldown numbers.
Kill Command glows and **pulses** when castable — it is proc-gated as well as
off the GCD, so its readiness is read from the game directly rather than
inferred from a cooldown.

Every icon is its own frame: shift-drag each one anywhere, independently.

### Range finder

Distance estimate from a ladder of item-range probes, dead-reckoned between
crossings using your real movement speed, with the melee boundary as an exact
anchor. Reports distance and travel time to melee.

### Border

Selectable: lights when **Kill Command** is castable, shows **range** as a
colour, or **off** entirely. The range text is unaffected either way.

---

## Timing model

Ported from **Bouk's Hunter Castbar**, whose numbers are the reference:

- Cast times are the tooltip value **divided by haste**. `GetSpellInfo`
  returns the unhasted figure, so using it directly draws every window too
  narrow.
- Haste includes **quiver haste**, which `GetRangedHaste()` omits entirely.
  Quivers are identified by item ID and multiplied in by hand; without this
  every derived timing is 10–15% out.
- An auto shot is a reload of `eWS - 0.5/haste` followed by a hasted cast.
- The auto is blocked by **casts only**, never by the GCD — which is why
  Multi costs clip and Arcane, being instant, does not.

Sanity check: quiver 1.15 x Serpent's Swiftness 1.20 = 1.3800, and a 2.9
speed bow at 2.10 eWS implies 1.3810. Agreement to four digits.

**Rhythm learning.** The auto grid runs at your *measured* auto-to-auto
interval rather than a theoretical one, so it tracks the rotation you
actually produce rather than one you never hit. Phase corrections are
low-passed and bled in over time, so nothing visibly jumps.

---

## Options

A standalone window — movable, resizable, and it scrolls. Open it from
Esc > Options > AddOns > Jabe's WeaveLine, or `/wl options`.

**Display** — toggle the melee lane, range finder, each icon individually,
eWS readout, clip readout, icon outlines, and never-fade.

**Style** — 10 skins, a font dropdown that previews each font in itself, and
a size slider plus colour swatch for each of the four readouts.

**Positions** — click an element, click one of 8 anchor points around the
bar. Or free-position them and shift-drag each anywhere.

**Size** — bar length, overall scale, icon size, icon scale, Kill Command
glow strength, icon outline thickness.

**Colours** — 18 editable colours covering every state the bar can show.

Everything persists. 27 settings saved, 95 tunable values, 64 slash commands.

### Skins

Default, Muted, High contrast, Minimal, Slim, Chunky, Amber, Ice, Mono, Dark.
Each sets colours *and* layout — border thickness, lane height, spacing — so
they change the shape of the bar, not just its palette.

### Fonts

Reads **LibSharedMedia**, so every font any of your addons has registered is
available by name. Falls back to a built-in list if LSM is not installed.

---

## Diagnostics

`/wl` lists all 64 commands. The ones worth knowing:

| Command | Does |
|---|---|
| `options` | Open the settings window |
| `check` | eWS, haste, cast times, measured rhythm, phase error |
| `range` | Every range probe individually, including which items you lack |
| `cd` | Cooldown lookups by name vs by ID |
| `font` | Which font paths load and whether LSM was found |
| `apis` | Which options APIs this client exposes |
| `why` | Why the bar might be blank |
| `sync` | Restart the sequence from now |

---

## Known limitations

- **The range finder cannot resolve inside 5-7 yards.** Every probe in the
  ladder sits outside that band, and no API reports which *direction* you are
  moving — only speed. Between the melee boundary and the 7-yard rung the
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
- **Clip warnings are not user-colourable.** The Clip swatch controls the
  "clean" state only; an actual clip stays red. A red warning going
  user-coloured would hide the one thing it exists to signal.

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
- **ElvUI and LibSharedMedia** — for the fonts.
