# LexiStack5 — Architecture Contract v1.0

This document defines intentionally small architectural boundaries for sequential Experiment E. `product-contract.md` is authoritative for behavior. **No Flutter implementation is authorized by this planning package.**

## 1. Repository topology and dependency direction

Two repositories only:

1. **LexiStack Content Studio** — offline editorial workflow, reviewed content releases and a pure-Dart package at `packages/lexistack_content_contract/`. No dependency on Flutter or the LexiStack5 app.
2. **LexiStack5** — the Flutter Android-first application, depending on an immutable Git commit of `lexistack_content_contract` for models, parsing and validation. No source-code dependency on the Studio's editorial tooling.

Dependency direction: `Content Studio contract package -> imported by Flutter app`. Approved JSON files move one way: `Studio release / frozen reference snapshot -> assets/levels/`. No runtime API and no runtime network. Dart package resolution at **build time** is distinct from the application's offline runtime.

**Critical P0 precondition:** The Content Studio repository must publish a resolvable, tested package commit before F1. An unversioned branch name (`main`) is not an acceptable pinned dependency. The actual URL and full commit SHA must be written to the F1 evidence; the package/lockfile must be resolvable on the Windows machine. The Studio may implement its editor/reviewer process later; only the minimal contract package is needed at P0.

Suggested Flutter `pubspec.yaml` shape (replace example placeholders with actual values in P0; do not commit placeholders):

```yaml
dependencies:
  lexistack_content_contract:
    git:
      url: <ACTUAL_CONTENT_STUDIO_GIT_URL>
      ref: <IMMUTABLE_COMMIT_SHA>
      path: packages/lexistack_content_contract
```

Commit `pubspec.lock`. Package update is a deliberate separate review, never an unnoticed mutable fetch.

## 2. JSON and validation boundary

Use the unchanged **schemaVersion 2** structure from `product-contract.md`. The production manifest is at `assets/levels/manifest.json`. A source `manifest.json` and the five JSON files are the complete benchmark assets. During F1, a valid **partial-only** manifest can be `{ "campaign": ["pack1.json"] }` (with Daily omitted because it is not installed yet). At F3 it can add `"daily": "daily.json"`. The **final strict** manifest must include all four campaign packs and the Daily string as specified in the Product Contract. The stable identifiers are `pack.id`, `level.id`, `category.id`, and derived stable per-tile IDs (e.g., category ID + slot index). Display strings must never be used as persistent identity.

A single pure-Dart package owns:

- data types for Manifest, Pack, Level, Category, Tile and RedHerring;
- tolerant parsing with actionable file/level/category diagnostics;
- catalog-wide validation (schema, IDs, tiers, formats, trivia, red herrings, repetition, category-title uniqueness and pairwise overlap);
- `ValidationMode.strict`, `.partial`, `.candidate`, with status and per-file diagnostics;
- test fixtures proving valid and invalid content behavior.

For CLI compatibility, the Flutter repo contains a **thin** `tool/validate_levels.dart` file delegating into that package. Its existing command shape is maintained:

```powershell
dart run tool/validate_levels.dart
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart path/to/candidate.json
```

- **strict:** all listed files present, minimum four campaign packs and eight daily entries; initial Experiment E target exactly four 8-level campaign packs plus one 8-level daily file. Later catalogs may expand when explicitly approved.
- **partial:** one or more already-listed files; enforce full validity of each present file and cross-file constraints; do not pretend partial means production complete.
- **candidate:** parse a proposed replacement (matching pack ID) or addition (new pack ID) against the installed catalog without writing production assets. Report which interpretation was applied.

Structural checks cannot establish a unique editorial grouping or reliable trivia facts. That requires separate Studio review.

## 3. Flutter module boundaries

A recommended target layout (guidance, not an invitation to create placeholders for every directory):

```text
lib/
  main.dart
  core/              game.dart | prng.dart | scoring.dart | daily.dart | share.dart
  app/               controller.dart | progress.dart | storage.dart
  infrastructure/    asset_catalog.dart | preferences_storage.dart
  ui/                app.dart | home_screen.dart | packs_screen.dart
                     board_screen.dart | result_view.dart
                     stats_screen.dart | settings_screen.dart | theme.dart
                     common.dart
assets/levels/       manifest.json | pack1.json ... pack4.json | daily.json
tool/                validate_levels.dart
test/                core/ | app/ | ui/ | support/
integration_test/    android_smoke_test.dart
```

**Core:** Pure Dart; no `package:flutter/` imports. Encapsulated game-state mutations (or immutable transitions if substantially simpler), typed submission outcomes, deterministic seeded PRNG and date arithmetic. No storage, widgets or platform channels.

**Application:** A single modest `ChangeNotifier` controller is sufficient; it coordinates campaign/daily attempts, economics, settings and save scheduling. Clock and persistence are injected. Do not adopt BLoC/Riverpod/redux by default.

**UI:** Flutter widgets for screens, animation and platform affordances. UI asks the controller for legal operations, shows typed outcomes and never duplicates engine rules, reward arithmetic or date selection.

**Infrastructure:** A small adapter around `shared_preferences`, asset loading and optional platform services. A test in-memory storage implementation is required; no generalized repository/service framework.

Files split by **responsibility**, not arbitrary line counts. Avoid another monolithic `ui/app.dart`, while allowing larger cohesive screens if widget extraction would decrease readability.

## 4. State, money and recovery

- Explicit statuses: `playing`, `won`, `lostPendingDecision`, `lostFinal`.
- Never reveal solution data at `lostPendingDecision`, including after app restart or UI navigation.
- The controller owns exactly-once reward settlement, finalized historical results, progression, Daily date/streak logic and booster charging. Engine owns legal transitions and deterministic booster targets.
- Persist one **versioned JSON document** with independent validated sections. Record one unfinished attempt per campaign level and today's unfinished Daily; preserve already-finalized result summaries independently of current catalog availability.
- Save a **content identity/fingerprint** with unfinished attempts as an extra defensive measure: if the meaning of a level changes under the same ID, drop only the incompatible attempt while preserving unrelated account data. This does not change visible game rules.
- On restore, require the ordered unsolved tile list to be a genuine **permutation** of the expected unique tile IDs. Verify each selection, solved group, guess record, hints, state, lives, mistakes, rescue count, and cross-references. A repeated known tile ID is still corruption.
- Queue writes in sequence. Construct a snapshot before enqueueing. On failed write, show a nonintrusive warning and do not claim persistence; later writes must never be overwritten by an older asynchronous write.
- Booster effects and payments, completion statistics, first-win rewards and one-time practice rewards must survive restart without duplicate mutation.
- `shared_preferences` is a lightweight local persistence mechanism, not a transactional database. Specify and test reasonable recovery; do not claim crash-proof durability beyond what is evidenced.

## 5. Platform constraints and testing strategy

- Development host: Windows/PowerShell. Record `flutter --version`, `dart --version`, `flutter doctor -v`, Android SDK and emulator identity at the start of F1 and relevant changes.
- Android debug build and real emulator launcher smoke test begin in **F1**; the functional tap/drag check begins in **F2**, not postponed to the final phase.
- Tests with a fixed clock and in-memory storage for deterministic rules, rewards and restore. Test actual production JSON when applicable; use controlled synthetic fixtures only for edge cases.
- PRNG: select and document a fully deterministic, VM/web-safe integer algorithm in F2; include fixed golden sequences. Actual browser-compiled execution is a **F6 requirement**; build success alone is not enough.
- Test on 360×640 (including 1.3× text), 390×844 and 1280×800. Essential controls never overflow; preserve accessibility and touch/drag semantics.
- Content/Flutter integration must not force any runtime service or network call. Asset loading and bundled fonts must work without Android connectivity.
- On emulator instability or slow cold start, capture diagnostics, debug vs release mode, first/cold vs later/warm starts. Do not turn an unexplained environment delay into a false game defect or claim it is resolved without evidence.

## 6. Agent handoff and change control

Repository sources (`AGENTS.md` -> product contract -> architecture -> roadmap -> acceptance matrix) are the only authoritative between-run memory. At the start of each phase the agent reads those files, checks the **actual Git state**, reproduces previous gate tests and implements only the phase scope. Product and architecture contracts are not silently changed by implementation agents.

**Git handoff for F3–F6:**

- Start each feature phase from the latest accepted `main`, with a clean working tree, on a dedicated `codex/fN-*` feature branch.
- Complete implementation, tests, evidence and local commits autonomously, then push the completed feature branch to `origin` for independent review.
- Never merge into or push `main` before explicit independent quality-gate approval.
- After explicit approval, fast-forward `main` to the accepted feature commit using `git merge --ff-only`, then push `main`.
- Never force-push or rewrite history.
- Do not start the next feature before the previous gate is accepted. The next phase still requires an explicit assignment.

Each phase emits one concise evidence record: version/model/effort, commit, clean/dirty tree, actual commands with exit codes, emulator observations, defects and interventions. Independent review records pass/fail. See `experiment-e-protocol.md`.

## 7. Boundaries against overengineering

No backend, network-based content workflow, in-app AI, database migration framework, generalized plugin system, custom state-management framework, multi-repo monorepo tooling, build orchestration platform or large ADR collection. Improve these boundaries only to resolve an observed blocker or a reviewed contractual change.
