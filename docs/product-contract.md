# LexiStack5 — Product Contract v1.0

**Status:** approved planning baseline for sequential Experiment E. **Language:** English (product + coding specification). **Source:** `lexistack-genesis-optimized-v1.md` (SHA-256 `1f30340bd11bbc7caca645ccf273f40f2d418ced1c35ac90c4f639e535e23857`).

## Purpose and interpretation

This document is a **product specification**, **not** an instruction to build the entire app in one run. Its requirements describe the **complete final product**. Only the corresponding phase's acceptance criteria apply at intermediate gates; unimplemented future features must be identified as such. Implementation order, autonomy rules, evidence and feature gates live in `feature-roadmap.md`, `acceptance-matrix.md` and `experiment-e-protocol.md`.

**Keep product parity with optimized Genesis v1.** All gameplay constants, economy values, 40-level target, offline limits, UX, persistence and final verification requirements below are retained from the Genesis. The deliberate Experiment E changes are limited to (a) sequential execution, (b) separating editorial content generation from Flutter engineering, (c) a shared pure-Dart content contract, and (d) independently reviewed quality gates. No unrelated game features are authorized.

**Scope:** Genuine Flutter/Dart 3, Android-first on Windows; responsive desktop/web Flutter experience. Entire Android game works offline. No backend, telemetry, billing, ads, runtime LLM/network access, multiplayer or audio. Bundled assets and font licenses. Prefer Flutter SDK + `shared_preferences`, minimal justified additional dependencies.

**Repository/contract hierarchy:** `product-contract.md` is authoritative for user-visible game behavior; `architecture.md` fixes technical boundaries; `feature-roadmap.md` defines phase scope; `acceptance-matrix.md` specifies executable checks. If requirements conflict, do not silently choose: report conflict and obtain a contract decision *before* modifying an invariant.

---

## 1. Product definition

Each level presents **16 distinct word/trivia tiles**, shuffled on a **4×4 board**, hiding **four disjoint groups of four**. The player selects four tiles, submits a guess, and tries to identify all four groups before exhausting four mistakes. Each group has one difficulty tier, revealed title, and short educational trivia fact:

| Tier | Role | Reveal color |
|---|---|---|
| 1 | Straightforward | Amber/yellow |
| 2 | Moderate | Emerald/green |
| 3 | Tricky/trivia | Sapphire/blue |
| 4 | Lateral/wordplay | Amethyst/purple |

Every level includes **at least one deliberate, fair red herring**: a tile plausibly suggests a different group, yet the full board strongly supports one intended solution. The game is approachable but intellectually interesting, with visible progression and a satisfying solve animation.

**Required modes:** four themed campaign packs and one date-based Daily Puzzle from a separate offline daily pool. Required features: lives, "One Away!" feedback, duplicate-guess protection, shuffle/deselect, tap and drag selection, three earned-coin boosters, stars, category/trivia reveals, red-herring commentary, daily streaks, statistics, responsive screens, shareable spoiler-free emoji result grids, settings, reset, and local persistence/recovery.

**Boundaries:** no backend, user accounts, Firebase, analytics, ads, in-app billing, runtime LLM calls, runtime network dependencies, multiplayer, or 3D engine. Native Android installations must work without any network connection; web needs an initial static-asset load and should support offline repeat visits where browser storage permits. This version uses **haptics, not audio**. Do not add an audio subsystem, ad SDK, or an unrelated shop screen. No need for an iOS build on Windows, although the project may include iOS scaffolding.

**Framework:** genuine Flutter with Dart 3, not an embedded website. Favor the Flutter SDK and `shared_preferences`. Additional packages only where clearly necessary, compatible with Android/web/Windows, and justified in the final report. Fonts/assets required at runtime must be bundled; include licenses for any non-SDK third-party fonts. Do not let optional typography downloads block the game.

---

## 2. Architecture and core data contracts

Separate **pure Dart game/content logic**, **application/controller and persistence**, and **Flutter UI**. The game rules and validation model must have **no Flutter imports** so a standalone Dart CLI and unit tests can reuse them. Keep UI state management simple (e.g., `ChangeNotifier`, `ValueNotifier`, or a small equivalent); the final report should identify the choice.

Use `assets/levels/manifest.json` to list available production content, and **one JSON file per pack**:

```json
{
  "campaign": ["pack1.json", "pack2.json", "pack3.json", "pack4.json"],
  "daily": "daily.json"
}
```

This is the **required final manifest**. During incremental development, it may temporarily list only files already implemented. The production build must not ship with missing referenced files. A later release may extend the manifest with further packs; the exact file list above is the initial experiment scope.

Every file has this root structure:

- `schemaVersion`: integer `2`.
- `pack`: `{ "id": string, "title": string, "description": string }`.
- `levels`: array of complete level objects; exactly eight entries in each of the five delivered files.

A level contains:

- `id`: globally unique stable string (campaign examples `pack1_lvl01`, daily examples `daily_lvl01`).
- `packId`: exactly the parent pack's ID.
- `title`: short, distinctive human-readable name.
- `categories`: exactly four objects, **one per tier 1, 2, 3, 4**.
- `redHerrings`: at least one object `{ "tiles": ["ON_BOARD_TILE"], "note": "Explanation..." }` per level.

A category contains:

- `id`: unique within its level.
- `title`: truthful title of the hidden connection.
- `difficultyTier`: integer from `1` to `4`.
- `tiles`: exactly four distinct uppercase real words, proper names, or common short phrases.
- `triviaFact`: exactly one factual, entertaining sentence, **40–160 characters**, directly relevant to its own category.

The following is **one complete example level object** (illustrative; include it only once if you choose to use it in production):

```json
{
  "id": "pack1_lvl01",
  "packId": "pack1",
  "title": "Table Talk",
  "categories": [
    {
      "id": "g1", "title": "BREAKFAST BAKES", "difficultyTier": 1,
      "tiles": ["TOAST", "WAFFLE", "MUFFIN", "BAGEL"],
      "triviaFact": "A bagel is traditionally boiled before baking, which helps create its chewy crust."
    },
    {
      "id": "g2", "title": "KITCHEN UTENSILS", "difficultyTier": 2,
      "tiles": ["FORK", "SPOON", "KNIFE", "LADLE"],
      "triviaFact": "A ladle has a deep bowl designed for lifting and serving liquids such as soup."
    },
    {
      "id": "g3", "title": "TENNIS TERMS", "difficultyTier": 3,
      "tiles": ["SERVE", "LOVE", "DEUCE", "VOLLEY"],
      "triviaFact": "In tennis scoring, love means zero and deuce is a tie at forty points each."
    },
    {
      "id": "g4", "title": "PAIRS WITH JAM", "difficultyTier": 4,
      "tiles": ["TRAFFIC", "PAPER", "LOG", "PEARL"],
      "triviaFact": "Logjam originated as a term for timber obstructing waterways before becoming a metaphor."
    }
  ],
  "redHerrings": [
    {
      "tiles": ["SERVE"],
      "note": "SERVE could describe offering breakfast, but the complete tennis group gives it a clearer home."
    }
  ]
}
```

All in-level tile strings are unique under trim/case normalization. Use stable tile identity independent of display strings (e.g., category ID and ordinal). Solving or dragging must not depend on accidental equality across levels. The content parser should report actionable errors rather than throwing opaque type errors on malformed JSON.

---

## 3. Pure-Dart gameplay rules

### 3.1 Board, selections and guesses

- A fresh game has four lives, four unsolved groups and all sixteen unsolved tiles.
- Shuffle with a **documented deterministic, platform-stable integer PRNG**. Identical level + seed + identical shuffle actions must yield identical tile orders on Dart VM, Android and web. Avoid relying on unspecified cross-platform behavior of `Random(seed)`. Shuffling costs nothing and never alters selected tile identities or lives.
- Tapping a tile toggles its selection; maximum four unsolved tiles. Selecting a fifth changes nothing. Deselect clears the selection. Solved tiles are not selectable.
- Dragging a tile to another tile adds both to the active selection (subject to the four-tile cap); dropping onto the tray adds the dragged tile. Both modes feed the **same** engine transitions as taps, including on touch devices.
- Submit is enabled only for exactly four distinct selectable tiles while the game is actively playable. A selection may be submitted in any order.
- A wrong guess is identified by its **unordered set of tile IDs**, so the same wrong four-tile set cannot charge two lives.

Submission precedence:

1. **Already guessed:** if the unordered set was a previous wrong submission, return `alreadyGuessed` without losing a life or appending another evaluated guess.
2. **Exact match:** all four belong to one remaining unsolved group. Solve/lock that group, remove those tiles from the board, clear selection, increment consecutive-correct combo, preserve lives, and mark victory after the fourth group.
3. **One Away:** exactly three tiles belong to the same remaining unsolved group. Return `mismatch(isOneAway: true)`, deduct one life, remember wrong set, reset combo, and retain selection for editing.
4. **Other mismatch:** maximum category overlap is at most two. Return `mismatch(isOneAway: false)`, deduct one life, remember wrong set, reset combo, and retain selection.

On reaching zero lives, enter **loss pending decision**. Do not reveal category solutions automatically. Duplicate/invalid submissions never change lives, mistakes, coins or result history.

Record every evaluated guess (but not rejected or duplicate guesses), preserving the **selection order** and true tier of each selected tile, plus correctness. Record the lifetime mistake count for star ratings and sharing.

### 3.2 Explicit result state machine

A game is one of:

- `playing` — accepts tile actions, legal boosters and submissions.
- `won` — final victory; stars and rewards settled **once**.
- `lostPendingDecision` — at zero lives; **no unsolved group titles, answers, or trivia revealed**; player may purchase Extra Life if eligible, or explicitly accept the loss and reveal the board.
- `lostFinal` — after explicit Reveal/Accept Loss, with all answers and red-herring explanations; cannot rescue this attempt.

Extra Life at zero transitions `lostPendingDecision -> playing` with **one** life; future mistakes and submissions continue the same attempt. A player navigating away from a pending loss must see the pending decision again when reopening the game. Only `won` and `lostFinal` count as completed games for statistics. Once a daily attempt reaches a final result, it cannot be replayed on that date.

A victory screen shows the full categories, four tile sets, trivia facts and red-herring notes; a loss screen shows full solutions **only after** the final reveal action. Prioritize red-herring notes whose tiles appeared in the player's wrong guesses.

### 3.3 Stars and boosters

Stars are based on **actual wrong submissions**, never restored life count:

- `0` mistakes: **3 stars**.
- `1–2` mistakes: **2 stars**.
- `3+` mistakes: **1 star** (including after one or more paid rescues).

Implement three hint boosters. **Reject without deducting coins** when unaffordable, inapplicable, or illegal in the current state:

| Booster | Price | Deterministic effect | Reject when |
|---|---:|---|---|
| Pair Magnet | 30 | Permanently reveal/highlight a pair of tiles from one unsolved group. Prefer the group of the **most recently selected** tile if it has no revealed pair; otherwise the lowest-tier unsolved group without a pair. If using the selected tile's group, include that tile in the pair. | No eligible unsolved group, or not `playing` |
| Category Peek | 40 | Reveal the title of the **lowest-tier** unsolved, unpeeked group without revealing its tiles. | No eligible group, or not `playing` |
| Extra Life | 60 | Restore `+1` life up to four; if in `lostPendingDecision`, resume `playing` at one life. | Four lives already, `won`, or `lostFinal` |

Booster effects persist and must not accidentally reapply after a reload. Coins are charged exactly once after a booster succeeds. Booster usage cannot improve the star rating by restoring lives.

---

## 4. Economy, progression, daily mode and sharing

### 4.1 Economy and campaign

- Initial balance: **150 coins**.
- First win of each campaign level: **+50 / +30 / +15** for **3 / 2 / 1** stars respectively.
- Winning a replay may improve the recorded best star rating; **only the first replay win of a given campaign level grants +5 practice coins, and later replays grant +0**. This one-time cap prevents unlimited coin farming.
- First successful completion of a Daily Puzzle for a given date: star reward **plus 25 bonus coins**, credited once. No practice payout for Daily.
- No daily login gifts, free coin claims, advertising rewards, purchases or other coin sources.
- The first level of **each** campaign pack is unlocked. Level `n+1` in a pack unlocks after winning level `n` in that pack. Other packs are independently progressable.
- **Continue Campaign** resumes the most recently entered unfinished campaign attempt, including `lostPendingDecision`; otherwise open the earliest unlocked, never-won level in manifest pack/level order. If all are won, open the pack selector rather than silently resetting an earlier win.
- The player can explicitly replay a finished campaign level. Do not overwrite best stars with a lower result. Persist one unfinished attempt per campaign level; a replay creates a new attempt only when deliberately requested.

### 4.2 Daily puzzle

- Ship a **separate pool of eight handcrafted daily-only levels**, not reused campaign boards.
- Calculate the local civil calendar date `YYYY-MM-DD`. Compute the number of civil days since **2026-01-01** using UTC calendar-day arithmetic (not elapsed local 24-hour intervals) so DST changes cannot move the date index.
- Select `dailyPool[dayIndex % 8]`, with a reproducible day-based board seed. The same local calendar date yields the same daily board on all devices using that date. The eight-board pool repeats every eight days; **do not falsely advertise unlimited unique daily content**. Design the architecture to allow adding more offline daily boards.
- One attempt per civil date. Re-entering today's unfinished game resumes the same board. A finalized daily win or loss displays the saved result and Share action rather than starting another game.
- If the date changes with a previous day's unfinished daily, discard that old unfinished board; it does not count as a win or a finalized loss. Do not allow previous-date booster/coin exploits.
- `currentDailyStreak` counts consecutive dates with finalized daily wins ending today, or ending yesterday if today's daily has not been won or lost yet. Today's finalized loss yields zero. Missed days break the streak. Maintain `bestDailyStreak` independently.
- Use an **injectable clock/date provider** so all date rules and widget flows can be tested without waiting for real calendar changes.

### 4.3 Stats

- `gamesPlayed` = total **finalized** attempts (`won` + `lostFinal`), not opened/in-progress or rescue-eligible losses.
- Show win rate (`wins / gamesPlayed`), number of perfect **zero-mistake** 3-star wins, and win mistake distribution: `0`, `1`, `2`, `3`, `4+` (the last bucket is reachable through rescues).
- Prevent double-counting when restoring saved games or revisiting result screens. Preserve completed-result summaries independently of whether future content files are removed.

### 4.4 Spoiler-free share text

Provide an actual Copy-to-Clipboard action. Exact plain-text format, with **no tile words, category titles or trivia**:

```text
LexiStack · Daily 2026-10-27
★★☆ · 2 mistakes
🟨🟨🟨🟩
🟨🟩🟨🟩
🟨🟨🟨🟨
🟩🟩🟩🟩
🟦🟦🟦🟦
🟪🟪🟪🟪
```

For campaign, line 1 is `LexiStack · <pack title> #<level number>`; for Daily, `LexiStack · Daily YYYY-MM-DD`. On a win, line 2 is filled/empty stars followed by ` · <m> mistakes`; on a finalized loss, `<n>/4 groups · <m> mistakes`. Each following line corresponds to one evaluated four-tile guess, in submitted selection order, using **🟨 tier 1, 🟩 tier 2, 🟦 tier 3, 🟪 tier 4**. Rejected duplicate/invalid attempts do not produce rows. Do not enable result sharing before a finalized result.

---

## 5. Production puzzle content and quality

The released application must ship **exactly 40 complete initial levels**, distributed as follows. In Experiment E these are imported from the frozen reference dataset; the Flutter coding agent must not write or creatively revise puzzle content:

| File | Pack ID | Pack title | Content |
|---|---|---|---|
| `pack1.json` | `pack1` | Everyday Echoes | Food, daily life, geography, household, double meanings; accessible first levels |
| `pack2.json` | `pack2` | Science & Nature | Astronomy, biology, elements, weather, inventions, scientific homographs |
| `pack3.json` | `pack3` | World History & Myth | Ancient cultures, mythology, landmarks, rulers, word origins, historic ideas |
| `pack4.json` | `pack4` | Pop Culture & Wordplay | Cinema, music, literature, anagrams, prefixes/suffixes, lateral associations |
| `daily.json` | `daily` | Daily Stack | Eight mixed-theme, independent daily-only puzzles |

Exactly **8 levels per file = 32 campaign + 8 daily = 160 groups = 640 tile positions**. Each pack should increase in difficulty across its eight levels. Content should feel handcrafted, not repetitive or generated to meet a quota.

**Non-negotiable editorial rules:**

1. **One compelling intended partition:** all 16 tiles fit their assigned four groups; each group's title is literally true of all four. Inspect tempting alternative partitions and replace ambiguous tiles when two different four-group solutions seem equally defensible. Structural validation **cannot prove** semantic uniqueness; perform an editorial self-audit and be honest about limitations.
2. **Honest red herrings:** at least one explicitly documented per level; every referenced tile occurs on that board. Its note explains the plausible cross-category lure and why the complete board resolves it. Do not use arbitrary overlap claims that aren't plausible.
3. **Trivia accuracy:** one sentence, 40–160 characters, informative beyond merely repeating the title; no claims you cannot defend. Avoid overly obscure facts, unverifiable superlatives and uncertain exact historical dates. Facts must relate to their own category.
4. **Variety across the entire catalog:** category titles must be unique ignoring case/whitespace; no two categories may share three or more of the same tile strings; any given normalized tile string appears in at most **two different levels** including Daily; no accidental duplicate boards.
5. **Tile form:** uppercase real words/names/common phrases, at most two words and at most ten letters per word. No fabricated fragments, trailing spaces, blank strings or duplicates within a board (case-insensitively).
6. **Audience and fairness:** family-friendly, general international adult audience, English. Prefer understandable concepts and genuine reasoning over trivial four-item taxonomies repeated dozens of times.

**Experiment E content workflow:** The technical implementation uses the immutable 40-level reference dataset from LexiStack3 (see `reference-content-lock.md`). The sequential feature roadmap controls staged asset import. The standalone Content Studio owns all editorial creation and revision. The agent must not regenerate, silently fix, or paraphrase benchmark JSON. A real playable vertical slice must use a genuine reference level. Every imported file must pass incremental validation, and all five files must pass strict validation at the final catalog gate.

---

## 6. Standalone content validator

Create `tool/validate_levels.dart`, using the shared pure-Dart content model; it must run under Windows with `dart run tool/validate_levels.dart` (no Flutter UI or engine process needed).

**Resolve incremental vs full validation explicitly:**

- `dart run tool/validate_levels.dart --partial` validates **all currently listed, existing files** during content construction. It enforces their schemas, eight-level file size, within-file requirements, cross-file uniqueness, red-herring references and facts. It **does not require all five final files to exist** or fail because the manifest does not yet list unfinished packs. At least one listed content file is required. It reports the partial status honestly.
- `dart run tool/validate_levels.dart` is **strict final validation**: require **at least four** campaign packs with at least eight levels each and a separate Daily pool with at least eight levels; all manifest entries must exist and pass. The **initial benchmark deliverable** must contain exactly the five prescribed files and 40 levels, while the validator must permit future catalog expansion.
- `dart run tool/validate_levels.dart path/to/candidate.json` checks a standalone candidate pack against its schema **and** the installed catalog: if its pack ID already exists, treat it as a proposed replacement of that pack for validation; otherwise treat it as an additional pack. Never modify production assets just by validating a candidate. Clearly report whether this is a replacement or addition.

**Errors (non-zero exit, file/level/category identifiers when applicable):** malformed JSON/types/schema versions, missing referenced file, incorrect count in a present file, bad or duplicate level/pack/category IDs, wrong `packId`, not exactly four groups/tiers, malformed or duplicate tiles, invalid fact length, absent/invalid red-herring notes/references, violating tile formats, duplicate category titles, repeat limits or overlapping groups, and missing final assets in strict mode. Print a useful summary by pack and totals on success.

**Warnings:** suspicious trivia naming an unrelated board tile; potential editorial issues identifiable mechanically. Deliver your production files with **zero errors and zero warnings** in final mode; a candidate may report advisory warnings without requiring a modification.

Write validator tests for valid content and representative broken fixtures, including cross-file duplicates, wrong red-herring references and the **partial-versus-final** behavior. Do not confuse a legitimate partial-build dataset with a fully passing production set.

---

## 7. Studio-quality Flutter UI and accessibility

Create a polished, distinctive casual-game aesthetic. Aim for excellent typography, intuitive information hierarchy, tactile feedback and restrained motion—not default unstyled Flutter widgets or generic business-dashboard visuals. On Android portrait screens, scrolling is acceptable when solved banners expand; **never hide essential controls behind clipped content**.

Required functional screens:

1. **Home:** Continue Campaign, Daily card/status and streak, coin balance, concise player stats, pack selection, Settings.
2. **Pack/level selection:** four themed packs, 8 stages per pack, visible locked/unlocked status, 0–3 stars and explicit replay affordance.
3. **Board:** pack/level title, coins, four heart indicators, four group slots (solved banners + optional Category Peek titles), 4×4 unsolved tile grid, visible selection tray/count, Shuffle/Deselect/Submit (active only at 4/4), three booster controls displaying costs and eligibility.
4. **Result / pending-loss sheet:** win stars and earned coins; pending loss with no spoiler, Extra Life (60) and explicitly labeled Reveal/Accept Loss; finalized outcome with all groups' titles, tiles and facts, red-herring insights, Share and Next/Back.
5. **Stats:** games played, win rate, zero-mistake perfect wins, mistakes histogram/distribution, current/best daily streak.
6. **Settings:** light/dark/system theme, haptic feedback toggle, confirmed Reset Progress to Default.

Game feel:

- Tile press: clear selected visual state and a smooth ~120 ms scale/elevation response; ensure gestures don't accidentally toggle tiles twice.
- Wrong submission: ~300 ms restrained horizontal shake of selected tiles, legible `One Away!` or mismatch feedback.
- Correct submission: ~350 ms satisfying tile-to-banner transition or a comparably polished collapse/reveal, tier color, category title and one-sentence trivia reveal.
- `Already guessed!` feedback without a lost heart; disabled buttons and boosters explain why when practical.
- When enabled, `HapticFeedback.selectionClick` on selection, `mediumImpact` on solve, `heavyImpact` on mistake, `lightImpact` on successful booster. Haptic calls must degrade safely on unsupported platforms; toggle genuinely controls them.
- Respect OS reduced-motion preference where feasible; keep content legible without animations.

Layout/accessibility acceptance:

- Mobile portrait is primary, including **360×640** and **390×844**. On viewports wider than 520 px, center a mobile interface **maxWidth 460 px** inside a refined desktop background.
- Target **at least 48×48 logical pixel** interactive hit areas. Text/background contrast should meet **4.5:1** for normal text; do not rely on tier color alone to convey meaning.
- Avoid overflow at **1.3× text scaling on 360×640**. Tile words must not break across lines; shrink carefully but keep text ≥11 logical pixels at the reference phone size when possible, or adjust tile layout/scroll to preserve readability.
- Accessible semantic labels for tiles, hearts, booster availability, selected state and navigation, with no duplicate/confusing announcements.
- Use real production assets and content. No placeholder lorem ipsum, wireframes, or nonfunctional decorative controls.

---

## 8. Offline persistence and recovery

Persist one **versioned JSON document** via `shared_preferences`, injected behind a small storage interface for tests. Include player coins, best star ratings, repeat-practice payout flags, finalized historical result summaries, daily outcomes/streak basis, unfinished campaign and today's Daily attempts (board ordering, current selection, guesses, solved groups, hints/peek/pairs, lives, mistakes, rescue-pending state), and settings.

- A reload must resume the **same** unfinished campaign/Daily attempt; it must not reroll paid hints, grant victory coins again, or count a result again.
- Version changes or a wholly unreadable document may reset to safe defaults with an explicit non-crashing behavior.
- Otherwise **recover valid parts independently**: malformed single attempts must be discarded without wiping valid coins, best stars, completed-result summaries or unrelated sessions. If a content update removes/renames a level, discard or quarantine only affected unfinished attempts; keep historical aggregate stats and ratings for unaffected IDs. Do not silently turn a missing level into a new one with the wrong ID.
- Validate loaded numeric ranges, state transitions, category/tile references and duplicate payouts. Serialize/await writes in order so an older asynchronous write cannot overwrite later progress. Surface a storage failure unobtrusively; do not pretend it was persisted.
- Settings Reset has a confirmation dialog and restores the exact fresh state, including 150 coins, zero stats, empty history, default theme/haptics and no Daily completion.

---

## 9. Automated tests and acceptance cases

Use `flutter test` for pure-Dart rules, storage/controller and real-app widget workflows. Use deterministic **in-memory progress storage** and an injectable clock in tests. Add enough tests to cover edge cases rather than only happy paths. A test that exercises the real JSON content must read the **final production files**, not a separately curated fake replacement.

### 9.1 Deterministic rule oracle — TWO different fresh game instances

For test fixtures, construct four valid groups, including:

- Category A: `MARS`, `VENUS`, `SATURN`, `JUPITER`.
- Category B: `MERCURY`, `LEAD`, `GOLD`, `IRON`.

**Game instance 1 — exact match only:** Submit `[MARS, VENUS, SATURN, JUPITER]` in any order. Verify A is solved, unsolved tiles decrease from 16 to 12, lives stay four and selection clears.

**Game instance 2 — wrong guesses in sequence (A must remain unsolved):**

1. Submit `[MARS, VENUS, SATURN, MERCURY]`: `mismatch(isOneAway: true)`, four to three lives.
2. Submit `[MERCURY, SATURN, VENUS, MARS]`: `alreadyGuessed`, still three lives, no extra history row.
3. Submit `[MARS, VENUS, MERCURY, GOLD]`: standard mismatch, three to two lives.

**Do not combine Game 1's solved category with Game 2's wrong guesses**; previously solved tiles are no longer selectable.

### 9.2 Additional domain and economy tests

- Fifth tile ignored, deselect, drag-onto-tile/tray additive selection, shuffle/no penalty, deterministic seeded order, combo reset, invalid/duplicate submission invariant, exactly four group victory, zero lives pending loss.
- Loss pending decision hides all answers; affordable Extra Life resumes playing at one life; manual reveal finalizes defeat and disallows rescue; result is finalized/counts exactly once.
- Starting coins 150; first-win rewards 50/30/15; 0/1–2/3+ mistakes yield 3/2/1 stars **even after heart restores**; improving replay best stars; one-time +5 practice payout cap; exact once-per-date Daily reward including +25.
- Pair Magnet/Category Peek/Extra Life costs and deterministic targeting; rejection causes **no** coin or game changes; persist/reload booster effects without double charging.
- Daily civil-date arithmetic across DST/leap days; daily board determinism; same-day one-attempt restriction, tomorrow's fresh attempt, stale unfinished daily discard, streak continuation/break and best streak.
- Stats exclude active or pending-loss games; unfinished games and completed results must not double-count.
- Persistence exact round-trip, corrupt root fallback, **partial** salvage of corrupt sessions or orphaned content references without wiping valid coins/stars.
- Production validator runs with all five files; test broken fixtures and `--partial` versus strict mode; every shipped level can be solved using its own intended groups.

### 9.3 Widget/integration tests

Pump the **actual app**, with in-memory storage and fixed date, and verify at least:

1. Initial home (150 coins, four packs, Daily card) and navigation into an unlocked level.
2. Active board with 16 tiles / four slots; selecting four enables Submit; solving renders banner, exact title and trivia fact.
3. One-Away deduction; duplicate wrong set is protected; fifth selection ignored; touch/drag interaction changes the actual selection.
4. Pair Magnet, Category Peek and Extra Life update the visible board/coins correctly.
5. Pending loss conceals solutions; paid rescue works; final reveal ends that attempt.
6. Persistence/restart retains progress; repeat payout doesn't farm; reset confirmation works.
7. Daily result and spoiler-free Share text reach the clipboard in the **exact format** above; daily re-entry can't earn rewards twice.
8. Small mobile viewport, enlarged text and desktop frame render without framework overflow exceptions.

Where an Android emulator is already available, run a real-device/emulator smoke or integration test for gameplay, touch/drag, persistence and platform plugins. If unavailable, report that distinction and verify widget flows plus APK build instead.

---

## 10. Final visual evidence and verification

Generate real **PNG screenshots from a Flutter widget-test capture** (e.g., offscreen repaint-boundary image) with bundled fonts explicitly loaded; do not generate placeholder mockups. Write into `docs/screenshots/`, including:

| File | Viewport | Actual captured state |
|---|---|---|
| `01_home.png` | 390×844 | Home/dashboard |
| `02_board_selected.png` | 390×844 | Four selected tiles, booster dock visible |
| `03_board_solved.png` | 390×844 | At least two solved groups with facts |
| `04_result.png` | 390×844 | Victory sheet showing stars, coins, facts and red herrings |
| `05_packs.png` | 390×844 | Campaign pack and level selection |
| `06_desktop_frame.png` | 1280×800 | Centered mobile frame on wide viewport |

Screenshots may require scrolling to capture a relevant section, but they must show the claimed states. Inspect each screenshot visually if your tools permit; otherwise perform available artifact/pixel/layout checks and state the inspection limitation. No fake screenshots, text boxes instead of fonts, clipped dialogs, or silent overflow.

At **F6 final verification** (not at every interim gate), run and record the **actual exit result** of:

```powershell
flutter pub get
dart run tool/validate_levels.dart
dart analyze
flutter test
flutter build web
flutter build apk --debug
```

- `dart run tool/validate_levels.dart` must finish **zero errors and zero warnings**, confirming exactly 40 complete levels in five files.
- `dart analyze` must finish **zero errors/warnings**; all available tests must pass. If a verification truly fails because of the environment, identify that condition rather than claiming a pass.
- Android is the primary target: `flutter build apk --debug` is required **when the Android SDK/Gradle toolchain is installed**. Prefer an emulator integration smoke test if one is available; describe exactly what was actually run.
- Additionally run `flutter build windows` **only if** `flutter doctor -v` confirms the Windows desktop C++ toolchain. iOS compilation is **not** required on Windows.
- Do not commit `.dart_tool/`, `build/`, `.gradle/`, emulator state, credentials or generated binaries. Commit the real source, JSON assets, font licenses, tests, README and final screenshots.

Create a concise, practical `README.md`: game rules, architecture, Windows setup/run/test/build commands, offline/persistence behavior, known Daily content-repeat limitation, and a guide to adding AI-generated pack JSON and running strict/partial/candidate validation. No speculative design docs, massive handover dossiers or unrequested roadmaps.

---

## 11. Experiment E integration rules (addition, not new game mechanics)

1. Content schema remains **v2**. The pure-Dart content models, parser and catalog validator are supplied by a single version-pinned `lexistack_content_contract` package maintained in the Content Studio repository. The Flutter repo owns a minimal `tool/validate_levels.dart` wrapper; do not fork validators.
2. The frozen benchmark assets are taken from `oliversinz/LexiStack3` at commit `8b84f2d6c75cb807fba9db19cba707f963e02020`; see `reference-content-lock.md`. This is *fixture reuse*, not reuse of application implementation. Do not change reference text, IDs or file contents to make validation pass; raise a documented blocker if any source anomaly is discovered.
3. Store and validate stable tile IDs independent of visible words. A restored unsolved tile order **must be a permutation of the expected unique IDs**, not just a list of expected length with recognized IDs. Duplicate IDs, missing IDs, invalid selection, illegal state/guesses or inconsistent reward metadata invalidate only the affected recoverable attempt wherever possible.
4. As part of PRNG evidence, provide fixed-seed golden outputs and execute them in a **real web-compiled test runtime** as well as Dart VM by the final gate. A `flutter build web` alone is not proof of cross-platform equivalence.
5. External quality gates are independent of the implementing coding agent's own claim of success. The agent supplies source commits and command evidence; the reviewer decides gate acceptance.
6. Long-running tool commands are diagnosed by evidence and process progress; do not impose arbitrary cutoffs or invent success. Account separately for environmental blocks (emulator, Gradle, PowerShell, Git, browser) and implementation defects.
7. No code from LexiStack3/4 is to be copied into LexiStack5; public framework idioms and documented findings can inform architecture. Content copied as frozen fixture is the explicit exception.
8. New editorial Content Studio releases **must not be integrated before the technical comparison is complete**. This keeps sequential-development effects separate from semantic puzzle-quality improvements.
