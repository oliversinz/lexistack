# LexiStack5 — F4-D01: Complete Visual Identity & Gameplay Ergonomics Redesign

**Codex Desktop / Windows / independent F4 design-review correction run**  
**Working repository:** `C:\Codex\LexiStack`  
**Existing review branch:** `codex/f4-complete-ux-interaction`  
**Reviewed baseline commit:** `cac39ad9697a52f480168222ddb6848fe2f40fd7`  
**Accepted `main` (F3):** `ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`  
**New work:** F4-D01 only. **F4 is still PENDING independent review. Do not start F5.**

## 1. Mission: make LexiStack look and feel like a distinctive mobile puzzle game

F4's underlying implementation is strong: real navigation, saved campaign/Daily progress, paid boosters, exact clipboard sharing, accessible controls, light/dark themes, haptics, animations and Android interactions. However, **the independent visual review did not accept its product aesthetic**. The existing screens are recognizable as a generic Material-style, green-on-ivory content application: many uniform rounded cards, oversized heading/description regions, conventional outline buttons and limited game personality. The active puzzle board also gives too much vertical space to explanatory/status material; the primary **Submit** action falls below the initial viewport during normal play.

Your assignment is a **complete, implemented visual redesign** of the existing F4 UI, not a presentation, proposal, recolor, spacing tweak or new mock app. Aim for a recognizable, commercially credible premium casual word-puzzle experience with a distinct design signature. Preserve the working application, not its current visual template.

**Non-negotiable creative rule:** Do not produce another green-and-white Material demo. Avoid simply changing `ColorScheme.fromSeed`, shadows, or border radii while retaining the same large card/list/dashboard composition. Make deliberate changes to layout, typography, hierarchy, geometry, colors, tile appearance, progression affordances and the perceived reward of solving a puzzle.

**Do not pause to request routine design approvals.** Make clear decisions, implement them, review actual screenshots, correct your own visual defects, test and publish the same feature branch for external re-review.

## 2. First inspect the real repository and visual evidence

Before changing code:

1. Read `AGENTS.md`, `docs/product-contract.md` (particularly §§3, 4, 7, 8, 9), `docs/architecture.md`, `docs/feature-roadmap.md` (F4 and F5 boundaries), `docs/acceptance-matrix.md` (UI-03–12, PLT-03/04), `docs/reference-content-lock.md`, and `docs/experiment-e-protocol.md`.
2. Read the implemented UI modules under `lib/ui/`, especially `home_screen.dart`, `catalog_screens.dart`, `board_screen.dart`, `theme.dart`, `common.dart`, `stats_screen.dart`, `settings_screen.dart`, and `share_button.dart`.
3. Review unedited F4 Android screenshots in `docs/evidence/f4/`: light and dark Home, pack/level selection, initial/selected board, two solved groups, pending loss, victory/loss results, Stats and Settings. This visual evidence is your **before** baseline. Do not rely on unit tests as a proxy for visual quality.
4. Inspect actual Git status/branch/remote refs and confirm that `origin/main` is the accepted F3 baseline and the existing `codex/f4-complete-ux-interaction` branch points at the reviewed F4 commit above. If a user change or unexpected divergence exists, protect it and report rather than overwriting.
5. Run the current baseline tests before extensive edits and retain the result. The current F4 suite was reported as **150 passing tests**; this is a reported baseline, not permission to delete or weaken tests.

The original F4 prompt, F4 code and F4 evidence are already archived. This new F4-D01 request is an **independent-review-triggered design correction**, not a new experiment or an opportunity to reimplement F1–F3.

## 3. Fixed art direction: “Paper Arcade” / editorial tabletop puzzle

Create a coherent identity: **an elegant contemporary word-puzzle magazine meets a tactile tabletop game**. It should feel intelligent, playful, warm and crafted. It should **not** feel like a fintech dashboard, a conventional CRUD app, a corporate SaaS, neon arcade gambling UI or a children's candy game.

Use **one integrated visual language** across every screen. The following concrete design direction is intended to prevent generic defaults, while allowing small justified refinements after visual testing:

### Light mode

- Canvas: warm paper/sand, approximately `#F6F0E7` rather than white.
- Primary text/structural ink: midnight blue-charcoal, approximately `#1B2433`.
- Raised paper/tile faces: near-cream, approximately `#FFFDF6`, with deliberate borders and subtle tactile offset depth.
- **Primary action/brand:** a bold violet/indigo such as `#694BD6`; light text on this tone has usable contrast. **Do not use forest green as the main brand/CTA color.**
- Secondary lively accent: warm coral, approximately `#F5826C`, with dark ink for text/icons where contrast requires it.
- Secondary graphic accents: muted periwinkle, ink rules, small puzzle-grid or corner-mark motifs used sparingly.

### Dark mode

- Deep midnight backdrop around `#151924`; raised surfaces around `#242A3A`; light warm text around `#F8F2E9`.
- Primary accent: legible lilac around `#B39BFF`; secondary: warm coral around `#FF9D89`.
- Cards/tiles must still feel tactile and clearly separated. Avoid flat near-black-on-near-black blocks and indiscriminate mint-on-black outlines.

### Difficulty/category colors

**Preserve the semantic tier sequence** yellow / green / blue / purple, as required by the Product Contract and share emojis. You may refine the existing pastels (roughly `#F1D582`, `#B8D6AA`, `#B9D3EF`, `#D9C4EB`) while preserving readable ink and distinctly recognizable four-tier identities. Never change the actual tier mapping, scoring or emoji correspondence. Tier identity must also be conveyed by labels/position, not color alone.

### Typography, iconography and components

- Create a recognizable LexiStack title/wordmark treatment and a small, original geometric puzzle emblem/mark (Flutter vector shapes or a very small custom painter is fine). Avoid generic app logos, random stock photos and decorative controls that look clickable but do nothing.
- Use a strong editorial display hierarchy, a readable compact game-UI hierarchy, meaningful number/stage typography and consistent letter spacing. **Do not use huge multi-line headlines that monopolize the phone's first viewport.**
- Prefer a legitimately redistributable **bundled offline font pairing** if it materially improves identity and you can verify the authoritative license/source; commit the required OFL/license files. Do not fetch fonts at runtime or invent licenses. If external font acquisition/licensing is blocked, use a carefully styled SDK/system fallback and state that limitation. Do not make font availability a blocker for the redesign.
- Use a small set of purposeful reusable design tokens/components in `lib/ui/`; no general design-system package, dependency explosion, CSS/WebView, image-backed UI or giant decorative framework.
- Avoid uniform default Material `Card` + `ListTile` + full-width `OutlinedButton` everywhere. Different content roles deserve different compositions: game tile, level stage, Daily challenge, pack identity, wallet, primary CTA, result celebration and informational settings.
- Favor intentional visual rhythm, compact spacing, subtle asymmetry, small original graphics and tactile cues. Do not add gratuitous gradients, glassmorphism, emoji decoration everywhere, dozens of shadows or arbitrary color themes.
- Normal text must meet **>=4.5:1 contrast** against its actual background. Existing 48×48 logical-pixel target and accessible semantic requirements remain binding.

**Self-check:** A reviewer looking at an uncropped Home screenshot must immediately recognize this as a word/puzzle game, *not* mistake it for another Codex-generated green Material content app.

## 4. Screen-by-screen redesign requirements

### 4.1 Home — a game launchpad, not a dashboard

Redesign the entire above-the-fold composition:

- Distinct compact LexiStack masthead/wordmark plus readable coin wallet, Stats and Settings affordances.
- Short inviting headline/subline — existing copy may be retained and tightened, but reduce the current oversized typographic block and excessive vertical whitespace.
- Primary **Continue Campaign** CTA visually dominant yet compact, with a sense of current progress. Do not obscure the true action behind purely decorative imagery.
- Today's Daily as a visually distinct, slightly special game challenge: date, exact saved status, current/best streak and `Play/Resume/View result` action. Clearly disclose the **eight-board offline rotation** without making it the visual headline.
- The Campaign area should suggest a collection of puzzles, not an accounting list. Use the real currently installed pack; do not invent or expose three noninstalled packs. It must gracefully expand to four packs at F5.
- At 390×844 in light mode, the first viewport should show brand identity, the primary Continue action and a meaningful Daily entry; users should not have to scroll past a giant slogan to discover the game.
- Use real saved progress/stars, never arbitrary sample values in production UI.

### 4.2 Campaign/pack/level progression — a game trail

- Replace uniform overlarge list tiles with a distinctive **level trail**, compact stage cards or a clear modular stage grid — choose one coherent approach that reads at a glance and remains accessible with longer titles.
- Clearly differentiate `locked`, `ready`, `in progress`, `pending decision`, `won`, and explicitly replayable results using a combination of status text, icons, framing and best-star markers. Do not depend on color alone.
- Visible level numbers and earned 0–3 stars should feel like gameplay progress; locked stages must remain genuinely disabled. Keep replay explicit and separate from viewing a saved result.
- Packs should have recognizable visual identity or motif drawn from their real metadata, without fabricated illustrations/content.
- Test the full four-pack configuration with synthetic **test-only** catalogs, preserving independent unlock rules. Production still installs one Campaign pack plus Daily until F5.
- Avoid large empty vertical space when only one pack is installed.

### 4.3 Board — the highest-priority interaction redesign

**This is the most important requirement in the whole correction.** The present Android screenshot shows the 4×4 grid while **Submit is below the first screen**. During repeated play that creates an undesirable scroll-up/down loop. Do not preserve that structure with cosmetic changes.

Design the board around one fast, natural interaction loop: **inspect words → select up to four → Submit → see precise feedback → continue**.

Required behavior/layout:

1. Give the puzzle an intentional compact top region: stage/pack identity, four heart indicators, mistake count and coin wallet without large spacer blocks. Four group slots/tiers should be compact, recognizable and accessible.
2. Give the 16 tiles center stage. Use visually tactile, deliberately designed rounded-rectangle or printed-token tiles with ink borders/soft offset depth, distinct selection, revealed Pair Magnet cues, and clear focus/disabled states. Preserve legible long words and word-boundary wrapping (never split a word mid-token). Keep semantic Tile IDs and Flutter gesture handlers unchanged in meaning.
3. **At 390×844, 1.0× text, on a fresh board, all 16 tiles AND the primary Submit action must be in the visible initial viewport together**, with no vertical scroll required to submit a four-tile selection. This is a new ergonomic design acceptance target; write a layout/visibility test that checks actual widget geometry, not merely `ensureVisible`.
4. **At 360×640 with 1.3× text, Submit must remain reachable/visible without scrolling away from the selected tiles**, preferably in a SafeArea-aware anchored bottom action dock. Secondary content can scroll; scrolling must never cause Submit to be clipped or covered. Provide a real test of this interaction rather than a mere no-overflow check.
5. Design a compact **persistent action dock** with selection count and the primary Submit control; intelligently place Shuffle/Deselect nearby (or in a clear secondary row) without crowding. Preserve the selection tray and both drag-to-tile and drag-to-tray semantics. If an anchored dock and tray are separate, make their relationship unambiguous.
6. Make paid boosters (Pair Magnet 30, Category Peek 40, Extra Life 60) immediately discoverable, but they need not occupy the same permanent row as Submit. A well-designed compact booster bar, sheet or clearly labeled drawer is acceptable if it shows prices, availability and disabled reasons and keeps the current board/selection intact. Avoid hidden pay actions or extra taps for every ordinary Submit.
7. When categories are solved, reveal tier-color banners/titles and actual trivia in a satisfying, readable way. Previously solved groups may take a condensed presentation when necessary, but their full facts must remain available and the newly solved group's fact must actually be shown. A two-solved-groups state must retain a usable word board and anchored action dock. Do not silently delete the contracted trivia reveal to gain room.
8. Preserve the existing ~120 ms selection response, ~300 ms wrong-guess feedback and ~350 ms solve reveal, or comparably restrained, measurable alternatives. Respect reduced motion and ensure settlement happens exactly once irrespective of animation/rebuild/dispose.
9. Maintain Tap and both native Android long-press drag targets. Do not introduce double toggles, selection-order corruption, lost focus or an input layer that intercepts gestures. Ensure scrolling and long-press dragging coexist.
10. Apply the same layout language in light and dark modes; at least one real screenshot of a fresh board, four selected tiles with actionable Submit, and a two-solved state must be captured after redesign.

Keep the engine pure Dart and the `BoardController`/`ProgressController` authority unchanged. A **presentation-level** component split or small UI interaction refactor is allowed where needed for the anchored dock; no rewriting the rules or reward ledger.

### 4.4 Victory, loss and pending decision — a small game ceremony

- Transform the result header into an emotionally satisfying outcome presentation: strong star/score treatment, earned coins, a clear success/failure message, next/replay/back, and a distinct share action.
- Winners should feel rewarded for finding connections. Use a restrained celebratory moment and crafted visual composition, **not** particle-library dependencies or noisy fireworks. Star count and coins must be the real settled values, including 1-star wins after rescues.
- Solved categories, all exact tiles and trivia facts plus prioritized red-herring notes remain visible/accessible below the primary result summary.
- A pending loss must remain a conspicuously distinct **spoiler-free decision state**: affordable Rescue / Extra Life (60) and irreversible Reveal / Accept Loss. Do not show unrevealed titles, tiles, facts or red-herring explanations in **either visual text or accessibility semantics** before final reveal.
- Finalized Daily may be viewed/shared but not replayed on the same date. Clipboard text must remain **byte-for-byte contract exact**, with success shown only after the platform call succeeds and no duplicate payout when reopened or copied.
- Normalized grammar (`1 mistake`, `1 star`, `1 win`) belongs in visible UI. **Do not change** the exact plain-text share format, which intentionally uses `<n> mistakes` per Product Contract.

### 4.5 Stats and Settings — quieter, still coherent

- Refresh both screens to match the same visual identity and typography; do not spend more time here than on the Home and Board.
- Stats must display the real finalized-only performance, win-mistake buckets (0,1,2,3,4+), win rate and current/best Daily streak. Use compact, honest graphics with no fake sample numbers.
- Settings must provide persisted System/Light/Dark theme and Haptics On/Off, clear offline-storage messaging and confirmed Reset. The controls must be recognizably interactive and accessible.
- Preserve the F3-R01 read-error state: failed storage read hides wallet/game/Settings/Reset/save-retry controls, exposes **Retry load**, and must never write unknown stored data. A design overhaul must not reopen this high-severity regression.

## 5. Architectural and experimental guardrails

**These are hard constraints, not suggestions.**

- Scope is **F4-D01, visual identity and gameplay ergonomics**. Do not implement F5 content, invent campaign levels, modify the JSON schema, replace the content validator or start F6 packaging.
- Keep `assets/levels/pack1.json` (blob `5efa3c88c769f74eee872860766681f5c2cc1c64`) and `assets/levels/daily.json` (blob `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6`) byte-identical. Keep the existing temporary incremental manifest. Full Strict validator is expected to fail until F5 installs the missing campaign packs.
- Keep the Content Studio Git dependency pinned to `d9acbd52de0e198dd109a4859299318db3f465f5` and preserve the lockfile identity unless a reviewed issue makes that impossible.
- Do not change Game status semantics, tile identity, PRNG/golden sequences, star scoring, wrong/duplicate/One-Away rules, paid boosters, first-win or +5 practice rewards, Daily calendar/streak rules, one-attempt-per-day, historical results, save format or defensive recovery.
- Do not silently change pure core, application progress, storage, Daily or content-contract code. If a genuine logic defect is uncovered, document the independent reproduction and isolate the smallest necessary fix; do not mix speculative refactoring into this design pass.
- Retain the single small Flutter `ChangeNotifier` architecture. No BLoC/Riverpod overhaul, external backend, online fonts/assets, telemetry, ads, billing, plugin system or unrelated dependencies. Avoid splitting into dozens of one-use files; split UI by clear screen/component responsibility.
- Preserve current functionality: taps, both drags, disabled booster logic, hints, rescue, navigation back/forward, replay, Reset, Settings, accessibility, clipboard and crash-safe UI.
- `ThemeMode.system` remains the default. The goal is **distinctive light AND dark themes**, not forcing dark mode as an aesthetic shortcut.
- Do not copy LexiStack3/4 app implementation source. Those repos are only technical comparison baselines; the original reference JSON is the explicit permitted data exception.

## 6. Tests and measurable new design acceptance

Existing F1–F4 tests must remain passing, including the currently documented **150 tests**. Update *only* tests whose presentation-level widget identities/text/layout legitimately changed; do not delete or weaken behavioral checks to make a UI redesign green. Keep functional acceptance IDs UI-03–12 and PLT-03/04 covered.

**Add focused tests for the design's previously missing ergonomic behavior:**

- **Above-fold normal-play test, 390×844, 1× text:** fresh Board has all 16 tiles rendered, Submit visible in the viewport and tappable without an `ensureVisible`/scroll, and selection of four actual tiles enables Submit while the board remains in view. Verify widget rectangles and relevant SafeArea bounds; a screenshot alone is not sufficient.
- **Small-phone action test, 360×640, 1.3×:** visible/reachable anchored Submit while interacting with the real tiles and tray, no overlap with OS insets or hidden/clipped primary controls. Check after one/two solved groups as well. Scrolling secondary content is permitted.
- **Compact-screen long-title test:** long category names, two-word and 10-letter tiles, enlarged text, group/trivia expansion, pending loss dialog, and result. No RenderFlex exceptions or unreachable gameplay buttons.
- **Visual identity consistency:** actual theme tokens for canvas/ink/CTA must be used by key screens; primary CTA must not silently fall back to former green Material styling. Contrast checks >=4.5:1 on real foreground/background pairs, including tier banners and selected tiles.
- **Interaction regression:** Tap, 4/4 selection cap, Submit, two drag targets, shuffle/deselect, One Away, duplicate protection, hint eligibility/charging, final outcome/Share and error/disabled feedback.
- **State regression:** all F1–F3 tests, F3-R01 read-failure no-overwrite, PER-04 duplicate Tile ID, ordered saves, payout caps, Daily date/streak boundaries, result idempotence. Theme/haptic changes must not replace board handles or reset game state; Reset invalidates stale screens/handles.
- **Share/haptics/motion:** exact platform-channel clipboard golden payloads, awaited copy/error feedback, persisted haptic toggle and real method mapping, reduced-motion animations, no duplicate settlement when animation is interrupted.
- **Four-pack fixture:** prove the redesigned Campaign/Level UI works with four independent test packs; production content remains one installed campaign pack until F5.

The accepted F4 tests permit scrolling important buttons into view. This correction adds the *stricter above-the-fold gameplay target* for usability; do not claim it passed solely because a tester helper successfully scrolls to Submit.

## 7. Mandatory real Android review: before/after, not test-count theater

On the Windows Pixel_10 Android 16 emulator if available, install the built APK and start from the **actual Android launcher**, not just `flutter run`. Exercise real tap and held long-press drag-to-tile/tray. Show the selected-tile state with actionable Submit, real booster price/feedback, a win, pending loss and final result. Force-stop/relaunch with a changed PID and verify an unfinished board, wallet, hint and saved dark theme/haptics setting still recover correctly. Record what was actually observed.

Save **unedited actual Android PNG screenshots** under `docs/evidence/f4-d01/` (do not overwrite the F4 baseline screenshots), covering at minimum:

1. `home-light.png` and `home-dark.png` — redesigned brand/dashboard, real saved content.
2. `campaign.png` and `levels.png` — redesigned pack/stage progression.
3. `board-fresh.png` — 390×844 fresh 16-tile board with visible primary Submit, no scrolling.
4. `board-selected.png` — four real selected tiles with Submit in the same visible screen.
5. `board-small.png` — compact 360×640 / 1.3× text **widget/device evidence** with pinned Submit; label clearly if this is a widget-test capture rather than an emulator screenshot.
6. `board-two-solved.png` — two solved groups with accessible facts and still-usable gameplay actions.
7. `board-dark.png` — dark palette in actual puzzle play, not only Settings.
8. `pending-loss.png`, `victory.png` and `finalized-loss.png` — outcome states and visual reward/decision hierarchy.
9. `stats.png` and `settings.png` — coherent supporting screens.

If an exact 390×844/360×640 virtual viewport is verified through Flutter widget testing rather than the native emulator's device resolution, state the difference precisely; **do not claim an emulator PNG was captured at a viewport it did not use**.

Perform an explicit visual review of each real artifact using image viewing tools available in your environment. Compare the **before** F4 screenshots and **after** F4-D01 screenshots for: branding, layout hierarchy, above-fold gameplay, tile affordance, distinct color, visual reward, dark theme and legibility. Do not declare victory based on a passing test suite. If the redesign still looks like generic mint/green Material cards or the Submit action is not actually visible on a fresh reference board, correct it before publishing.

A short before/after design rationale in the F4-D01 gate-log subsection is sufficient; no new design-theory report or elaborate slide deck.

## 8. Mandatory commands and audit evidence

Run applicable commands from the Flutter repository root. Save actual PowerShell command lines, exit codes, test totals and meaningful error/recovery logs under `docs/evidence/f4-d01/`:

```powershell
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build apk --debug
git hash-object --no-filters assets/levels/pack1.json
git hash-object --no-filters assets/levels/daily.json
```

`dart run tool/validate_levels.dart` **must still exit nonzero for the expected missing Campaign packs**; this is not a new failure or a complete-catalog pass. Partial must validate both installed packs without warnings/errors. Do not change frozen reference data or import F5 assets to make Strict pass.

Keep the already accepted F4 functional evidence immutable. Retain meaningful new initial failures and autonomous corrections. Distinguish Windows/Gradle/emulator/PowerShell environment issues from code defects. Do not invent command results, screenshots, font licenses, Android checks, test passes or performance improvements.

## 9. Git discipline, prompt provenance and completion

- Work **on the existing** `codex/f4-complete-ux-interaction` branch from reviewed F4 commit `cac39ad9697a52f480168222ddb6848fe2f40fd7`. This is a distinct F4-D01 review correction, **not** a branch from F3 `main` and not F5.
- The exact prompt file `prompts/F4-D01-paper-arcade-redesign.md` is supplied by the user. Read it in full, do not rewrite/normalize it; report the actual file SHA-256 (preserve its exact bytes in Git, subject to existing `.gitattributes`). Treat an untracked supplied prompt file as an intentional input, not an unknown user edit to delete.
- Make coherent UI/tests commits; add a concise `docs/gate-log.md` subsection **F4-D01, PENDING independent re-review**, including current SHA, design rationale, acceptance evidence, full test results, screenshot links, corrections, actual human interventions and remaining limitations.
- Commit the exact prompt and evidence. **Push the completed existing feature branch to `origin` and verify remote SHA matches local HEAD.** Do not merge into, fast-forward or push `main`. Never squash/rebase/force-push/rewrite history.
- Leave **F4 PENDING**, do not mark your own redesign accepted, and do not start F5 or F6.
- In the final report: identify the before/after visual changes by screen; prove the two above-the-fold gameplay assertions; show tests/build/Android exit codes, clean Git state, branch/remote SHA, immutable content and dependency identities, actual screenshot paths, outstanding defects and human interventions. Mention any inability to acquire a suitable licensed font honestly.

## 10. Quality bar and final self-critique

Before ending, compare actual finished screenshots to these five design questions:

1. Does **LexiStack** now have a recognizable visual identity beyond default Material/green-on-white?
2. Does the Home screen read as the launchpad to a premium word game rather than a general-purpose content app?
3. Can a player naturally select four tiles and Submit on a normal Android phone **without repeated scrolling**?
4. Do category solves, stars, coins and results feel satisfying while preserving all genuine data and spoiler rules?
5. Do the light and dark interfaces feel related, polished and accessible rather than separately styled demos?

If any are clearly not met, perform another internal visual correction within this autonomous run. **A functioning prototype is not enough: this run exists specifically because the earlier functional F4 UI did not reach the desired visual standard.**

**Implement the redesign now, test it rigorously, publish only the F4 review branch and stop for independent design/technical re-review.**
