# LexiStack5 — F2 Autonomous Implementation
## Pure-Dart Engine & Playable Android Vertical Slice

You are Codex Desktop, acting as the implementation engineer for **Experiment E / F2 only**. Implement, test, debug, document the evidence and commit a real playable vertical slice in the existing Windows repository. Do not stop at planning, and do not continue into F3.

### 1. Verified handoff and repository context

- Working directory: `C:\Codex\LexiStack`
- Actual GitHub repository: `https://github.com/oliversinz/lexistack`
- Accepted F1 base commit: `0db340691267896f636daa8fcc92b9edeb7a13c6`
- F1 independent review: **PASS** (28 October 2026). No targeted F1 correction run is required.
- F1: 25 Flutter tests passed, `dart analyze` clean, Android debug APK built, and real Pixel_10 / Android 16 launcher startup verified. These results are documented in `docs/gate-log.md` and `docs/evidence/f1/`; do not treat them as substitutes for your own new verification.
- Frozen content currently installed: original `assets/levels/pack1.json` from LexiStack3 commit `8b84f2d6c75cb807fba9db19cba707f963e02020`, Git blob `5efa3c88c769f74eee872860766681f5c2cc1c64`. The incremental manifest lists only `pack1.json`.
- Shared pure-Dart package: `lexistack_content_contract`, Git URL `https://github.com/oliversinz/lexistack-content.git`, immutable commit `d9acbd52de0e198dd109a4859299318db3f465f5`, package path `packages/lexistack_content_contract`. Preserve the existing `pubspec.yaml` pin and `pubspec.lock`; use the published models and parser, do not reimplement them.
- Development platform: Windows 11 / PowerShell, Flutter 3.47.8, Dart 3.13.7, Android SDK 36.1.0, Pixel_10 Android 16 emulator at F1. Inspect actual versions and available emulator before acting rather than assuming nothing has changed.

Read `AGENTS.md` and its prescribed documents, especially `docs/product-contract.md` sections 3, 4.4, 7 and 9; `docs/architecture.md`; `docs/feature-roadmap.md` F2; `docs/acceptance-matrix.md` ENG-01–12, UI-02, PLT-03; `docs/reference-content-lock.md`; and `docs/experiment-e-protocol.md`. The contracts determine the behavior; this prompt determines the work for **this phase**. Do not silently change contract rules or acceptance criteria.

First inspect `git status --short`, `git rev-parse HEAD`, branch, remotes, installed tools and existing F1 tests. Do not overwrite unexpected user changes. Use a dedicated local feature branch such as `codex/f2-engine-vertical-slice` from the accepted F1 state when safe. Commit coherent checkpoints and leave a clean working tree. **Do not push, merge, force-push or rewrite history.** The user handles GitHub publication for the independent review.

### 2. Exact F2 deliverable and boundaries

Deliver a **genuinely playable Flutter puzzle**, using the real first level of the frozen `pack1.json`, reachable through the existing Home → Collection → Level navigation. The player must be able to select tiles, submit guesses, receive correct/incorrect/One Away/duplicate feedback, solve all four groups, reach a win, exhaust lives, choose pending-loss rescue or explicit final reveal, and see real category/trivia/result information only when allowed.

Build the underlying domain logic for all eight installed `pack1` levels; the UI may expose preview play for those levels without implementing F3 unlock/progression. It is sufficient that the Android vertical slice proves at least level 1 end to end. Clearly label any phase-limited preview behavior. Never present in-memory F2 progress as durable.

**In scope:** pure-Dart rules/state machine, seeded PRNG, score/star calculations, evaluated-guess history, deterministic booster *effects* with legal rejections, spoiler-free pure share-text formatter, minimal in-memory game controller, functional board and pending/final result UI, Android tap/drag behavior, tests, emulator verification, evidence, and a narrowly scoped documentation correction.

**Not in scope:** coins, booster purchases/charging, initial wallet, first-win/practice/daily rewards, campaign unlock/progression, daily content or streaks, statistics, settings, persistence/`shared_preferences`, content-fingerprint restore, complete F4 screen polish, full catalog, production clipboard integration, F5 content import, or F6 browser PRNG verification. Do not add empty placeholder implementations for those future phases. Do not modify `LexiStackContent`, other repositories, or production JSON. Do not copy Flutter, engine or test source from LexiStack3/4.

### 3. Core design: deterministic and Flutter-independent

Create cohesive pure-Dart modules under `lib/core/` (for example `game.dart`, `prng.dart`, `scoring.dart`, `share.dart`), using types from `lexistack_content_contract`. Core code must not import Flutter, `dart:io`, `shared_preferences`, network APIs or platform services. Game transitions must be independently unit-testable without widgets.

**Tile and board semantics**

- Use `Tile.id` from the shared contract as the stable identity, not display text, tile index after shuffle, or a homemade competing identity scheme.
- A fresh game starts in `playing`, with 16 unique tiles, four unsolved groups, four lives, zero mistakes and a documented deterministic shuffled order. Shuffling may occur repeatedly, free of cost, without changing tile identity, selections, guesses or lives.
- Choose and document an explicitly cross-platform integer PRNG. Its seed/state and shuffle order must be stable on Dart VM, Android and JavaScript-compiled Dart; do not assume `Random(seed)` guarantees cross-platform equality. Avoid arithmetic that relies on VM-only integer overflow or non-exact JavaScript number multiplication. Store or expose enough deterministic RNG state to support F3 recovery later, but **do not build persistence now**.
- Tapping toggles an eligible unsolved tile. The selection contains at most four distinct tile IDs. Selecting a fifth changes nothing. Deselect clears it. Solved tiles cannot be selected again.
- Additive drag onto another tile selects the dragged tile and the target tile (within the same four-tile cap). Dropping onto the selection tray selects the dragged tile. Dragging and tapping feed the same domain transitions; prevent a gesture from unintentionally toggling a tile twice.

**Guess evaluation and state transitions**

- `Submit` is legal only for exactly four distinct unsolved selected IDs in `playing`. Invalid calls return a typed rejected outcome and change **nothing**.
- Check the unordered signature of a previously evaluated **wrong** four-tile set first. Repeating it in any order returns `alreadyGuessed`, with no extra life loss, mistake, combo change or new guess-history row.
- An exact remaining category match solves and locks that category, removes its tiles from the unsolved board, clears the selection, preserves lives, increments consecutive-correct combo, and returns a typed solved outcome. The fourth solved category transitions once to `won`.
- A wrong guess with three tiles from one remaining group is `mismatch(isOneAway: true)`; otherwise `mismatch(isOneAway: false)`. Deduct exactly one life, increment lifetime mistakes, add the unordered wrong signature, reset combo, and **retain** the selected tiles for editing.
- Preserve a chronological record of evaluated guesses only, with the actual selection order, each tile's true difficulty tier and correctness. Invalid and duplicate submissions never appear in this history.
- At zero lives enter `lostPendingDecision`, **not** `lostFinal`. Do not automatically reveal unsolved groups, answers, titles or trivia. Explicit `Reveal / Accept Loss` transitions to `lostFinal` and permits final solutions; it is irreversible. `won` and `lostFinal` reject additional game mutations.
- Rescue by Extra Life from pending loss must resume **the same** attempt, seed, board order, solved categories, selection and guess history at one life. A completed loss cannot be rescued. Four lives is the maximum. This is a domain effect in F2; the purchase and sufficient-coins check belong to F3.
- Stars derive from **lifetime actual wrong submissions**: 0 → 3 stars, 1–2 → 2, 3+ → 1, regardless of restored hearts. Prevent any accidental double finalization within the engine; reward settlement remains F3.

Use clear typed outcomes and explicit `playing`, `won`, `lostPendingDecision`, `lostFinal` statuses. Do not make Flutter animation callbacks authoritative over the game state.

**Booster domain effects (no F2 wallet or charges)**

- **Pair Magnet:** Reveal a stable pair in one unsolved category. Prefer the category of the most recently selected tile when it does not already have a pair, including that selected tile; otherwise choose the lowest-tier eligible unsolved category. Ineligible/repeated actions are rejected without state changes.
- **Category Peek:** Reveal only the title of the lowest-tier unsolved, unpeeked category. Never reveal its tile assignment merely because it was peeked.
- **Extra Life:** Restore one life up to four; from `lostPendingDecision` resume `playing` with one life. Reject at four lives and from terminal outcomes.
- Core effects must be deterministic, independently testable and represented in the session state so F3 can later serialize them. No price/currency deduction in F2. If effects are exposed through the F2 UI, clearly say they are **preview effects without coin charging**; never imply a successful purchase.

**Pure share formatter**

Implement the exact spoiler-free text format specified in product-contract section 4.4. Support both campaign and Daily headers in a pure function even though Daily gameplay is not integrated yet. Produce the exact stars or `n/4 groups`, mistake count, and one tier-emoji row per evaluated guess in selection order (🟨/🟩/🟦/🟪 for tiers 1–4). No tile names, category titles or trivia in share text. No share output before `won` or `lostFinal`; pending-loss must be rejected. This is only the formatter: actual clipboard UI is F4.

### 4. Playable vertical-slice UI

Extend the existing real Flutter app rather than replacing it with a second app or a mockup. Preserve F1 Home/Collection navigation and asset handling. Add a coherent `BoardScreen` and only the minimal related widgets/controller required to play. Keep the content loading/controller, domain engine and Flutter widgets separated. A small `ChangeNotifier` board controller is sufficient. No BLoC/Riverpod/state-management framework.

- From a real `pack1` level's detail page, provide a working `Play` action. Starting that level creates or resumes an in-memory F2 attempt. A fresh attempt/replay is explicit; do not invisibly overwrite an unfinished attempt on navigation.
- Display the 4×4 starting board of 16 shuffled **real** tiles, selected state, four heart indicators, selection count/tray, Shuffle, Deselect and Submit, plus clear correct, mismatch, One Away and Already Guessed feedback. Submit is inactive unless exactly four eligible tiles are selected. Solved categories become noninteractive banners showing their **actual** title, four tiles and trivia. The unsolved grid adjusts as tiles are solved.
- Implement actual Flutter touch drag from tile to another tile and tile to tray, not a visual animation standing in for an engine transition. Selection must respect the four-tile cap and no double toggling on release.
- Show a meaningful `won` result with stars, mistakes, categories, trivia and red-herring explanations. Pending loss must be an explicit **spoiler-free decision** with `Rescue / Extra Life (F2 preview: no coins)` and `Reveal / Accept Loss`; the latter alone permits display of unsolved answers, titles, trivia and red herrings. A completed loss cannot return to the pending state.
- Prefer legible mobile portrait first. Target at least 48×48 logical-pixel interactive areas; provide clear selected/disabled states and semantic labels. Verify no framework overflow at 360×640 with 1.3× text scale, at 390×844, and in a wide centered layout. Scroll where necessary; never hide Submit or the pending-loss decision behind clipping. Reduced-motion/high-contrast refinements can follow in F4, but F2 must remain functional and usable.
- Minimal restrained feedback/animation is welcome, but correctness, touch behavior, legibility and testability take precedence over elaborate motion. All visible buttons must function. Do not introduce fake coin counters, fake daily navigation, decorative nonfunctional booster purchases, or claims that progress survives an Android process restart.

### 5. Required F2 tests and independent acceptance probes

Preserve all passing F1 tests. Add genuinely behavioral **pure-Dart** engine tests and **real-app** widget tests. Do not test rules solely by constructing expected values from the same implementation under test. The canonical acceptance IDs are `ENG-01` through `ENG-12`, `UI-02`, and `PLT-03`; identify any partial coverage honestly (browser execution for ENG-11 belongs to F6; clipboard integration for ENG-12 belongs to F4).

**Mandatory two-instance oracle:** Build a four-group synthetic fixture using the shared content models, including category A `MARS, VENUS, SATURN, JUPITER` and category B `MERCURY, LEAD, GOLD, IRON`. Use two **separate fresh** game instances:

1. Instance 1: submit the four category-A IDs → solved A, 16→12 unsolved, four lives, selection cleared.
2. Instance 2, with A unsolved: submit `[MARS, VENUS, SATURN, MERCURY]` → One Away, 4→3 lives; submit the same **ID set reversed** → alreadyGuessed, still three lives and no extra evaluated row; submit `[MARS, VENUS, MERCURY, GOLD]` → normal mismatch, 3→2 lives.

Do not reuse instance 1 after solving A for instance 2's wrong guesses.

Additionally verify selection/fifth/solved guardrails; shuffle reproducibility and zero life/mistake effect; additive drag semantics; correctness and chronological tier-order history; combo reset; four solved groups and idempotent terminal statuses; four distinct wrong guesses into pending loss; no pre-reveal spoilers; rescue on same attempt and loss finalization; rejected illegal boosters; pair targeting and peek ordering; star ratings after rescues; exact campaign/Daily/share strings and finalized-only behavior.

Include **fixed PRNG golden vectors** for known seeds and at least one documented board-order reference. Obtain/validate the expected vectors independently of the production PRNG method (do not compute an assertion's expected values by simply calling that same method). Run the golden tests on the Dart VM now. Browser-compiled runtime comparison is explicitly deferred to F6; record this as deferred, not passed.

Pump the **actual F2 app** against the installed `pack1.json`: navigate to Play, select four tiles, submit a real group, check the precise category title and trivia, test One Away and duplicate-warning behavior, verify pending loss hides the full solutions, and prove the pending rescue and final reveal flows. Provide widget tests exercising drag input through the actual UI interaction surface. Verify compact/enlarged layouts do not throw overflow exceptions. Synthetic fixtures are legitimate for edge cases; they must not replace production content in the actual-app acceptance tests.

### 6. Android proof and phase regression

Run the relevant tests on Windows, capturing actual commands, stdout/stderr and **exit codes**. Minimum:

```powershell
flutter pub get
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
flutter build apk --debug
```

In F2, the unqualified **strict** validator is still expected to fail because only `pack1.json` is installed and Daily is absent. Report this as an expected nonzero result, not as a passing full catalog.

Install the built APK on the existing Android emulator if available. Open it from the Android launcher (not only with `flutter run`). Actually interact with the playable board: select four tiles by touch, submit a correct group, and demonstrate **at least one real drag gesture** from tile to tile or tray resulting in a visible selection change. Prefer testing both drag targets. Verify that incorrect guesses and pending-loss decision can be reached on the device. Save unedited real screenshots of the F2 board (including selected tiles), a solved group, and pending loss; collect concise Android observations/log evidence. A widget-test gesture by itself is **not** an Android drag proof. Do not fabricate screen states or screenshots.

If the Android emulator or gesture instrumentation is obstructed, diagnose from process/output evidence, continue with all unaffected checks, and explicitly mark `PLT-03` as blocked/provisional rather than passing it. Do not impose arbitrary timeouts or label a long cold start as an application defect without evidence. Process close/reopen persistence is F3, not a claim for F2.

### 7. Small documentation and prompt-provenance corrections

These documentation changes are **explicitly authorized**, despite the general ban on silently modifying contracts:

1. In `docs/experiment-e-protocol.md`, correct the **Experiment E GitHub repository reference** from the planned/nonexistent `oliversinz/LexiStack5` to the actual `https://github.com/oliversinz/lexistack` (or `oliversinz/lexistack`). Mark E as **in progress**, not a future repository. Preserve the C and D references and historical comparison results. The game/project may still legitimately be called **LexiStack5**; do **not** rename the game/product to fix a repository locator.
2. In `docs/gate-log.md`, record the externally communicated **F1 independent reviewer decision: PASS, 2026-10-28**, linked to F1 final commit `0db340691267896f636daa8fcc92b9edeb7a13c6`. Preserve F1's original run evidence and clarify this is a later **independent** gate decision, not an agent self-awarded pass. Add a concise separate F2 run section with **reviewer decision: PENDING**.
3. Archive the complete, exact F2 execution prompt as `prompts/F2-engine-vertical-slice.md` if the prompt file is supplied. Compute and report its SHA-256. Do not invent an exact prompt hash if the complete prompt was not available as a file; state the limitation. Preserve the prompt verbatim rather than paraphrasing it to obtain a convenient hash.
4. Update `README.md` only as needed to describe what actually works in the F2 playable preview and how to run/test it. **Do not** rewrite `docs/product-contract.md`, `docs/architecture.md`, `docs/feature-roadmap.md`, `docs/acceptance-matrix.md`, the content lock, or the CS0 package. If you find a substantive conflict, report it rather than silently changing acceptance criteria.

Keep evidence concise: use `docs/gate-log.md` and a focused `docs/evidence/f2/` directory for raw command evidence and real screenshots. Preserve genuine failed attempts/corrections that matter to the experiment; avoid creating a large speculative handover report.

### 8. Execution discipline and final report

Work autonomously within F2: inspect, implement, run tests, debug and make commits without requesting routine approvals. Keep shell commands compatible with PowerShell on Windows; do not mask failed exit codes or claim a skipped check succeeded. Differentiate toolchain/environment failures from application defects and report all manual interventions (expected: zero if execution remains autonomous). Do not launch F3, introduce economy or persistence scaffolding, modify Git history, or push anything.

Finish with an evidence-based summary containing:

- F2 status: complete / partial / blocked; working branch; starting F1 SHA; final full commit SHA; `git status --short`.
- Files/modules and principal technical decisions (PRNG algorithm, public engine API, controller/UI boundaries, drag implementation, preview rescue semantics).
- Acceptance ID coverage `ENG-01–12`, `UI-02`, `PLT-03`; specifically distinguish passed, deferred F4/F6 parts, failed and environment-blocked.
- Real command results, exit codes and test totals; expected strict-validator failure; F1 regression outcomes; immutable package pin and `pack1.json` blob identity.
- Actual Android emulator/device actions, touch and drag findings, screenshot paths and relevant platform logs. State explicitly if a particular interaction was not verified on Android.
- Any discovered bugs, autonomous fixes, unverified claims, known limitations and human interventions.
- Concise F2 gate-log entry marked **PENDING independent review**. Do not declare your own gate PASS.

**Begin F2 implementation now. Deliver a functional playable vertical slice and stop after F2; await independent review before F3.**
