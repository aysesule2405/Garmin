# Watch face design reference

Two things in here: (1) creative briefs for the fandom-inspired designs, written for you to take into Figma/Canva — original names, palettes, motifs, no trademarked material; (2) a grounded reference for what user-facing controls Connect IQ actually supports and where each one shows up. The controls section is verified against the installed SDK's `resources.xsd` and template files (`~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0.../bin/resources.xsd`), not guessed.

---

## Part 1 — Design briefs

One naming note before the list: keep the "inspired by" framing internal (this doc, your own notes). Store listing copy, tags, and descriptions should describe the design on its own terms ("pixel-art farm sim watch face," "dark academia analog face") rather than naming the franchise it's evoking — describing a similar vibe is fine, but pointing at the source by name in a for-sale listing invites exactly the association risk we're avoiding.

### Harvest Pixels — *(built, in the Bench)*
Farm-life feeling. 8-bit scene: sky, hills, tilled crop rows, small farmhouse, seasonal palette swap.
- **Palette** — Spring `#8FD3E8 #7BBF6A #F6A5C0` · Summer `#4FB3D9 #4F9A4A #F2C94C` · Autumn `#E08A4F #A86A35 #C1440E` · Winter `#33475B #DFE8EC #9FD6E0`
- **Motifs** — tilled soil rows, farmhouse silhouette with one lit window, drifting pixel clouds, wooden sign board for the time
- **Type** — chunky pixel/block numerals for time, small mono caption font for day counter and stats

### Spellbound — *(built, in the Bench)*
Magic-academy feeling. Candlelit radial glow, twin tower silhouettes, flickering candle hour markers, astrolabe ring.
- **Palette** — 4 selectable accents: Ember `#C9622F/#F2A65A` · Azure `#3A6EA5/#7FB2E0` · Verdant `#3F7D4A/#84C98F` · Amethyst `#7A4FAE/#B98EE8`, all on near-black ink `#0C0714`
- **Motifs** — candle-flame hour ticks, twin towers with lit windows, astrolabe ring, diamond-tip hour hand
- **Type** — warm serif for date/labels, no display font needed (dial-based, not numeral-based)
- **Avoid** — "Hogwarts," house names (Gryffindor/Slytherin/etc. — use Ember/Azure/Verdant/Amethyst instead), lightning-bolt scar, wand-and-sparks logo, Deathly Hallows symbol, actual typefaces licensed to the films

### Wayfarer's Oath — epic-fantasy quest feeling
A worn map-and-beacon aesthetic instead of a single hero/ring.
- **Palette** — parchment `#E8D9B5` · forest `#2F4A3D` · iron `#4A4A52` · ember gold `#C9962B` · dusk indigo `#2B2A4A`
- **Motifs** — a beacon-chain of hour markers (small torch/flame glyphs, echoing signal-fire relay chains rather than one ring), a mountain-and-tower horizon, a compass-rose center cap, a worn-map texture band at the base
- **Type** — a chunky humanist serif for numerals, small caps for labels
- **Avoid** — the LOTR logo (mountain ring + flame), the One Ring, Tengwar/Elvish script, the words "Middle-earth," "Mordor," "Shire," any named character or the specific font used in the film titles

### Windwood — whimsical nature feeling
Soft painterly nature scene, nothing character-driven.
- **Palette** — sage `#7FA36B` · cream `#F3E9D2` · coral `#E8927C` · sky `#9FC7D9` · ink `#33362E`
- **Motifs** — drifting dandelion-seed particles, rolling hill silhouette, a single soft round lantern-glow marker (not a creature), watercolor cloud daubs
- **Type** — rounded soft sans for numerals, a hand-lettered-feel (but original/licensed) display face for labels
- **Avoid** — any specific creature silhouette recognizable as a studio's character, the studio name, film titles, the studio's logo

### Voltside — steampunk-noir city feeling
Neon-lit industrial skyline, gear and voltage motifs.
- **Palette** — acid teal `#29E0C9` · violet `#7B3FA0` · brass `#B98A3D` · soot `#14131A` · hazard amber `#F2A33E`
- **Motifs** — exposed-gear hour ticks, a jagged "voltaic arc" second hand, brass pipe texture accents, rain-streak overlay lines
- **Type** — industrial condensed sans for numerals, stenciled utility font for labels
- **Avoid** — the show's title wordmark, city names ("Piltover," "Zaun"), any character silhouette, the League of Legends crest

### Rift Arena — abstract MOBA-arena feeling
A minimap-lane motif abstracted into the dial, not a specific game's UI.
- **Palette** — navy `#0B1C26` · gold `#C89B3C` · cyan `#0AC8B9` · crimson `#C8404A` (accent only) · void purple `#4C2A6B`
- **Motifs** — three converging "lane" paths as background linework, a pulsing core at center reacting to heart rate, hex-rune hour ticks
- **Type** — sharp geometric sans, small-caps labels
- **Avoid** — "League of Legends"/"LoL" wordmark, champion names or splash art, the Riot logo, "Summoner's Rift"

### Last Bloom — post-apocalyptic survival feeling
Overgrown ruins, not a specific game's characters.
- **Palette** — moss `#4C5B3A` · rust `#A6532A` · concrete `#6E6E68` · faded denim `#4A5A66` · warning yellow `#D9A93A` (sparing)
- **Motifs** — cracked-concrete base band, ivy creeping up the bezel edge, a flickering flashlight-glow hour hand, static-textured second hand
- **Type** — distressed stencil/utility numerals, plain mono for data labels
- **Avoid** — the game's logo/wordmark, character likenesses, any "clicker"-style creature design lifted from the source

### Ashen Oath — Norse mythic feeling
Norse mythology itself is public domain — runes, wolves, ravens are all fair game. What's not: the specific game's marks.
- **Palette** — ash `#3A3A3E` · ember red `#B33A22` · bronze `#9C7A3C` · ice blue `#6FA8B3` · raven black `#17161B`
- **Motifs** — historic Younger Futhark-style rune glyphs as hour markers (real runic alphabet, not the game's stylized ones), a glowing ember-axe-shaped second hand tip, a wolf/mountain horizon silhouette
- **Type** — chiseled slab serif for numerals
- **Avoid** — the specific Leviathan Axe silhouette, Kratos's red facial paint pattern, the game's logo, the letters "GOW" as a mark

### Jelly Dash — bouncy battle-royale feeling
Playful obstacle-course energy without the bean character.
- **Palette** — bubblegum `#FF6FA5` · lemon `#FFD23F` · sky `#4FC3E8` · grape `#9B5DE5` · mint `#4ADE9A`
- **Motifs** — a wobbly, slightly squished progress ring instead of a straight arc, chunky rounded blob-shaped numerals, a finish-line flag motif at the base
- **Type** — chunky rounded bubble numerals, playful but legible
- **Avoid** — the bean/crewmate-style character and its eyes (the single most recognizable protected asset here), the game's crown-trophy icon, the wordmark

### Airlock Watch — spaceship social-deduction feeling
Panels and corridors, not the character.
- **Palette** — void `#0B0E14` · hull white `#E7ECEF` · panel red `#D64545` · panel cyan `#3FC7D6` · panel green `#4CC26A` (selectable "crew color" accent)
- **Motifs** — abstract vent/control-panel line art as background texture, a blinking task-light second hand, a control-panel-button hour marker style
- **Type** — techy monospace numerals, stenciled small labels
- **Avoid** — the bean-shaped crewmate silhouette (critical — InnerSloth actively protects this specific shape), the emergency-meeting/kill-button icons, the wordmark

### Idol Neon — *(built, in the Bench)*
Concert stage-light feeling. Gradient stage background, glowing lightstick marker, crowd horizon with twinkling lights, neon-glow digits, a pulsing "fandom" energy bar.
- **Palette** — 3 selectable stage themes: Magenta Dream, Electric Blue, Gold Rush (see Bench source for hexes)
- **Motifs** — lightstick-shaped 12 o'clock marker, scalloped crowd silhouette, sparkle particles, HR-driven pulse bar
- **Avoid** — any real group's logo, member likeness, agency name, or fandom name (no "ARMY," "MOA," etc. as literal labels)

### Ink & Halo — general anime line-art feeling
Medium-wide stylistic devices, not one series.
- **Palette** — ink `#16151A` · paper `#F5F3EE` · action red `#E8384F` · sky cyan `#3FB8D6` · sun yellow `#FFC93C`
- **Motifs** — bold black linework hour ticks, manga-style speed-lines radiating from the time on the hour, a halftone-dot shading band, a "power aura" ring that brightens with heart rate, speech-bubble-shaped data callouts
- **Type** — bold condensed display numerals, clean sans labels
- **Avoid** — any specific series, character, or studio name/logo — speed-lines, halftone dots, and aura glows are generic medium-wide stylistic devices, not owned by one franchise

### Terrace Clock — football/matchday feeling
Pitch and scoreboard, not a real club or league.
- **Palette** — pitch green `#2E7D46` · chalk `#F4F4F2` · scoreboard amber `#F2B705` · night navy `#101C2C` · crowd red `#D6392C` (selectable accent)
- **Motifs** — pitch-line hour markers (center circle/goal box abstracted into the dial), scoreboard-style digital time block, a ball-stitch second-hand tip, floodlight glow at the top
- **Type** — bold condensed "scoreboard" numerals, utility sans labels
- **Avoid** — FIFA wordmark/trophy, any real club crest or kit-as-identity, league logos, real player names or numbers

---

## Part 2 — Controls you can add

Connect IQ has **two separate systems** for user-facing controls. They're not interchangeable — pick based on where you want the control to live.

| | Settings (`settings.xml`) | Native Watch Face Config (`watchface-config`) |
|---|---|---|
| Edited from | Garmin Connect Mobile app, and on-device **Settings → Apps → [face] → Settings** on capable devices | On-device **long-press face → Edit/Customize** screen, the same flow as Garmin's own built-in faces |
| Good for | curated option lists, numbers, toggles, text | accent color swatches or a full color wheel, letting the user assign *any* real Garmin complication to a data slot, named style variants |
| Proven in this repo | yes — `minimalist-face` already uses this (`resources/settings.xml` + `Application.Properties`) | not yet used in either project; schema-valid in the installed SDK but no template scaffold shipped, so budget time to test it against your actual target devices before relying on it |

### Settings (`settings.xml`) — verified control types

From the SDK's `resources.xsd`, `<settingConfig type="...">` accepts: `list`, `boolean`, `numeric`, `alphaNumeric`, `array` (growable list), plus `phone`/`email`/`url`/`date`/`password` (not really relevant to a watch face). Common attributes: `min`, `max`, `maxLength`, `required`, `readonly`, `errorMessage`, `helpUrl`.

**list** — dropdown of fixed options. What `minimalist-face` uses for accent color, background, and complication choice.
```xml
<setting propertyKey="@Properties.AccentColor" title="@Strings.AccentColorTitle">
    <settingConfig type="list">
        <listEntry value="0">@Strings.ColorGold</listEntry>
        <listEntry value="1">@Strings.ColorOcean</listEntry>
    </settingConfig>
</setting>
```

**boolean** — a native on/off toggle, no listEntry children needed (confirmed from the SDK's own watchface template).
```xml
<setting propertyKey="@Properties.ShowSeconds" title="@Strings.ShowSecondsTitle">
    <settingConfig type="boolean" />
</setting>
```

**numeric** — a number input/spinner, bounded by `min`/`max`. Good for a step goal, a threshold, an offset.
```xml
<setting propertyKey="@Properties.StepGoal" title="@Strings.StepGoalTitle">
    <settingConfig type="numeric" min="1000" max="50000" />
</setting>
```

**alphaNumeric** — free text, bounded by `maxLength`. Good for a custom label ("MY FARM," a nickname).
```xml
<setting propertyKey="@Properties.CustomLabel" title="@Strings.CustomLabelTitle">
    <settingConfig type="alphaNumeric" maxLength="12" />
</setting>
```

**array** (growable list) — user adds/removes multiple entries of the same shape. Niche for a watch face; more common in data field apps.

Settings can be grouped under a `<group id="..." title="...">` for a nested menu instead of one flat list — worth doing once you pass ~5-6 settings.

### Native Watch Face Config (`watchface-config`) — schema-valid, verify per device

This is the system behind the on-device "Edit" screen you get on Garmin's own faces. Three pieces, all optional:

- **`accentColors`** — either a curated swatch list or `allowAny="true"` for a full color wheel:
  ```xml
  <watchface-config>
      <accentColors allowAny="true">
          <color default="true" label="@Strings.ColorGold">0xC9A84C</color>
      </accentColors>
  </watchface-config>
  ```
- **`data`** — lets the user assign a *real* system complication (any HR source, weather, calendar, etc.) to a numbered data slot in your layout, instead of you hardcoding a fixed metric list:
  ```xml
  <data>
      <complication id="1" allowAny="true">
          <type default="true">HEART_RATE</type>
      </complication>
  </data>
  ```
- **`styles`** — named layout/style variants the user can flip between (e.g. "with seconds" / "no seconds") without a full settings menu.

Because there's no template in this SDK for it and neither existing project uses it, treat it as an experiment: build one small test face with it before committing a design to it, and confirm the target devices actually render the Edit screen (older or lower-end devices may not).

### On-face interaction (secondary option)

A watch face's `getInitialView()` can return `[view, delegate]` just like a full app, where `delegate` is an `InputDelegate` handling taps — used in the wild for "tap to cycle displayed stat" patterns on touch-capable devices. Device- and touchscreen-dependent, so treat as a bonus interaction layer, not the primary settings mechanism.

### Quick recommendation

| You want the user to... | Use |
|---|---|
| pick from a curated set of accent themes (like Spellbound's 4) | `settings.xml` `list`, or `watchface-config` `accentColors` if you want a free color wheel |
| toggle something on/off (seconds, night-dimming) | `settings.xml` `boolean` |
| set a numeric goal/threshold | `settings.xml` `numeric` |
| choose which stat shows in a data slot | `settings.xml` `list` of your curated metrics (simplest, proven), or `watchface-config` `data` if you want *any* real Garmin complication |
| type a short custom label | `settings.xml` `alphaNumeric` |
| cycle a stat by tapping the face | on-face `InputDelegate` (touch devices only) |
