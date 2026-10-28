# LexiStack5 — F4-D02 Typography Refinement Pass

## Role and authorization

Act as the Flutter UI engineer and typography/design-system implementer for LexiStack5. This is a **narrow, independent-review-triggered F4 typography correction**, following the successful F4-D01 *Paper Arcade* redesign. **This is not a new feature phase, not a new visual redesign, and not permission to start F5.**

- Windows / Codex Desktop repository: `C:\Codex\LexiStack`
- Existing review branch: `codex/f4-complete-ux-interaction`
- Expected starting F4-D01 review commit: `fa1ba33b2a00b67dcbf28420cfcc68fd72b5300c`
- Accepted `main` baseline (must remain unchanged): `ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`
- F4 quality gate: **PENDING independent review**
- Maintain the existing Content Studio Git dependency pin: `d9acbd52de0e198dd109a4859299318db3f465f5`

Work **in the existing F4 branch and preferably this existing F4-D01 session**. Read `AGENTS.md`, `docs/product-contract.md` (especially UI and accessibility), `docs/architecture.md`, `docs/feature-roadmap.md`, `docs/acceptance-matrix.md`, and the F4-D01 gate record. Check `git status`, local HEAD and remote refs before editing. If the branch, baseline, or working-tree assumptions have changed, stop and report rather than silently moving commits. Do not rebase, reset, force-push, squash, or change `main`.

## 1. Independent review finding — typography role mismatch

The F4-D01 redesign has been accepted as a **substantial visual and ergonomics improvement**, subject to this limited correction. Preserve its Paper Arcade direction: warm paper and midnight surfaces, ink/navy text, violet/lilac primary actions, coral editorial accents, four tier colors, original puzzle mark, tactile tiles, stage trail, result treatment, and the persistent selection/Submit dock.

**Issue:** The bundled **Fraunces** serif font is over-applied to functional screen titles, dates and statistics, making text such as `Daily 2026-10-28`, `Campaign`, `Statistics`, `Settings` and level titles unnecessarily decorative and visually heavy. In `lib/ui/theme.dart`, Fraunces currently flows through the general headline/title styles and `AppBarTheme.titleTextStyle`.

**Objective:** Rebalance the typographic system by making the already-bundled **DM Sans** the default for all functional UI text and headings, while keeping Fraunces **only as an intentional, tightly limited editorial brand accent**. The UI should feel like one coherent modern puzzle game, not a mixture of an ornate book cover and standard interface labels.

## 2. Binding typography specification

| Role | Font | Guidance |
| --- | --- | --- |
| `LexiStack` branded wordmark in the Home app bar | **Fraunces**, explicit brand-only text style | Preserve distinctive masthead; no global app-bar inheritance |
| Home hero `Good words. Great company.` | **Fraunces**, explicit hero-only style | Retain editorial character; check mobile wrapping and hierarchy |
| `Daily YYYY-MM-DD`, dates, streaks and numeric indicators | **DM Sans** | Medium/Bold as appropriate; clean and readable digits, tabular figures where useful |
| All functional AppBar page titles (`Campaign`, pack titles, level/board title, `Statistics`, `Settings`, etc.) | **DM Sans**, semibold/bold | Clear navigation; long titles remain ellipsized only where necessary |
| All other section headlines (`The puzzle shelf`, `Follow your curiosity.`, `Every connection counts.`, `Daily rhythm`, etc.) | **DM Sans**, semibold/bold | No accidental Fraunces through generic theme slots |
| Statistics metrics, stage numerals, level counters, coin balance, reward values | **DM Sans**, bold/extra-bold as appropriate | Use consistent number spacing and, if helpful, `FontFeature.tabularFigures()` |
| Result headline, pending loss, action labels, buttons, boosters, tiles, facts, settings, body copy | **DM Sans** | Match existing functional hierarchy; keep size, contrast and semantics correct |

Implement these roles **explicitly in the theme and limited call sites**. A sensible approach is to set `ThemeData` and generic `TextTheme` (`displaySmall`, `headlineMedium`, `headlineSmall`, `titleLarge`, etc.) to DM Sans, along with `AppBarTheme.titleTextStyle`, and add two named/small local brand styles for the wordmark and Home hero. Avoid repeated per-widget font overrides or an elaborate typography framework.

**Non-negotiables:**

- Do not replace the Paper Arcade palette, branding emblem, illustrations, stage layout, or card/tile geometry.
- Do not introduce or download a third font. Both existing font files and both OFL license texts remain bundled and unchanged; do not rename their families unnecessarily.
- Avoid applying Fraunces to `Daily 2026-10-28`, functional navigation, numbers or Stats cards via inherited `TextTheme` styles.
- Preserve exact on-screen product wording and localization scope except for a necessary visual/accessibility correction. **Do not change any byte of the contract-exact clipboard/share string.**
- Keep typography readable at 360×640 / 1.3× text scale, 390×844 and 1280×800. No essential controls clipped, obscured or shrunk into illegibility.
- Do not alter existing gameplay, progression, rewards, date arithmetic, persistence, state snapshots, or the Content Studio contract.

## 3. Implementation focus

Inspect the current uses of `TextTheme`, explicit `TextStyle(fontFamily: ...)`, `AppBarTheme.titleTextStyle`, direct `GoogleFonts` or default-font assumptions in `lib/ui/`.

Change only what is needed to enforce the intended roles. Likely touch points are `lib/ui/theme.dart`, `lib/ui/common.dart` (LexiStack wordmark), `lib/ui/home_screen.dart` (hero and Daily), and any other screen with an explicit serif override. Keep modifications to `lib/ui/*` and relevant UI tests/evidence unless a concrete blocker requires a small justified addition.

Preserve:

- Home hierarchy, violet Continue CTA, Daily card, campaign progress and puzzle shelf.
- Numbered Campaign/level trail, lock and star semantics, navigation/replay.
- Board status, tier badges, tile touch/drag behavior, sticky SafeArea-aware selection/Submit/Shuffle/Deselect/Boosters dock.
- Expandable solved facts, paid-booster states, pending-loss concealment, result rewards and share buttons.
- Settings Theme/Haptics/Reset state and F3-R01 failed-read safety.
- All light/dark surfaces and accessibility contrast targets.

**UI ergonomics are invariants, not optional goals:** At **390×844 at 1×**, all 16 initially unsolved tiles and Submit must remain visible and hit-testable **without scrolling**. At **360×640 at 1.3×**, Submit must remain inside the SafeArea and the accessible fixed dock must stay usable before and after one/two solves. If typography causes overflow, adjust the local text style (size, weight, line-height, letter-spacing) with minimal layout changes rather than redesigning the screen.

## 4. Objective verification and evidence

Add focused UI tests or extend existing F4-D01 tests to assert the actual **resolved** typography on representative widgets and correct themes:

1. The `Daily YYYY-MM-DD` heading resolves to DM Sans in both light and dark modes, including its numerals.
2. Functional AppBar titles (`Campaign`, `Statistics`, `Settings`, an actual board/level title) use DM Sans, not Fraunces.
3. Functional section headers and statistics metrics use DM Sans.
4. The `LexiStack` wordmark and the Home hero alone retain Fraunces (if both kept); show that the exceptions are explicit rather than accidental global defaults.
5. No text overflows, clipping, misleading truncation or hit-test regressions at **360×640 / 1.3×**, **390×844**, and **1280×800**. Verify both brightness modes for representative screens.
6. Ensure real bundled fonts are loaded in the actual Flutter screenshot capture tests; a screenshot with fallback fonts is not valid typography evidence.

Do not write brittle tests that assert only the textual spelling of a font declaration; check the effective UI text style where possible. Preserve existing widget semantics/labels and clipboard exactness. For a targeted typography change, be selective with new tests rather than adding dozens of redundant cases.

**Before/after visual evidence:** Reuse the existing untouched F4-D01 screenshots as the "before" reference. Capture **real unedited Flutter screenshots after the change**, with actual bundled fonts, for:

- Home, light and dark (show hero and Daily card).
- `Daily YYYY-MM-DD` heading clearly visible.
- Campaign/pack or level selection.
- Board with title and sticky Submit dock.
- Victory/result screen.
- Statistics and Settings.

Save these under `docs/evidence/f4-d02/`, using clear file names and distinguishing actual Android emulator PNGs from exact-size widget captures. Inspect them visually for alignment, apparent font family, numeric readability and hierarchy. A small set of meaningful images is better than a huge catalog. Include a short before/after typography audit naming the chosen typography roles and any necessary compromises.

Run from the repository root and record the **actual commands, exits and output**:

```powershell
flutter pub get
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
flutter test test/ui/f4_d01_test.dart --reporter expanded
dart run tool/check_prng.dart
flutter build apk --debug
git hash-object --no-filters assets/levels/pack1.json
git hash-object --no-filters assets/levels/daily.json
```

The **strict** catalog validator must still exit nonzero for the expected missing campaign packs; partial must succeed with **16 levels and zero warnings/errors**. The immutable JSON blob IDs must remain:

- `pack1.json`: `5efa3c88c769f74eee872860766681f5c2cc1c64`
- `daily.json`: `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6`

Keep all prior F1–F4/F4-D01 regressions, including ENG/ECO/DAY/PER rules, F3-R01, the Android interaction/layout contract and the 153-test baseline. Additional typographic checks may raise the count. Do not weaken existing assertions to make tests pass; any legitimate presentation-only assertion change needs a short explanation.

On Android, install the new debug APK and do a concise launcher-based visual smoke for Home/Daily, campaign, Board and one result. Test theme switching or at least inspect both themes. Verify no crash or typography-related layout failure. Deep replay/booster/process-kill retesting is not required if unchanged and the existing automated regressions pass; document exactly what you did and did not rerun on device. Do not mislabel widget captures as Android images.

## 5. Git, audit trail and completion

- Retain the existing branch `codex/f4-complete-ux-interaction`; do not branch from `main` or merge the pending review branch yet.
- Preserve the original F4 and F4-D01 prompts, artifacts and evidence unchanged.
- Archive **this exact execution prompt** as `prompts/F4-D02-typography-refinement.md` before editing; report its SHA-256 and verify the committed bytes. If the prompt file is unavailable, disclose that rather than fabricating a match.
- Add a concise **F4-D02 — Typography Refinement** section to `docs/gate-log.md` with the reviewed starting SHA, changed files, typography policy, before/after screenshot links, real commands/exits, test totals, known issues, any autonomous self-corrections and human intervention count. Record this as an independent-review-triggered correction, not as a new F5 run.
- Commit code, relevant tests and selected evidence in coherent commits; push the **existing F4 feature branch** to origin for independent re-review. Verify local and remote HEAD, clean working tree, and unchanged `origin/main`.
- **No merge/push to `main`; no F5 or F6.** Leave the F4 gate **PENDING independent reviewer approval**.

### Final handoff

Report:

1. Exact final feature-branch SHA and confirmed remote HEAD; main SHA and clean/dirty status.
2. The updated font-role matrix, explicitly listing Fraunces exceptions and which functional headings now use DM Sans.
3. The affected Flutter files, with assurance of no engine, economy, persistence, content or package-pin changes.
4. Screenshot paths and concise before/after typography findings (both themes and mobile legibility).
5. Full command exits, Flutter-test total, any environment limitations and Android smoke observations.
6. Prompt SHA-256, implementation self-corrections, unresolved issues and human intervention count.

Implement this focused typography correction autonomously, **then stop for independent F4 review**.
