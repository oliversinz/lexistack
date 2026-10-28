# LexiStack5 — Six-Phase Feature Roadmap v1.0

## Execution model

- **P0** is a one-time planning/setup prerequisite; **F1–F6** are the six autonomous implementation runs, tentatively all executed by Codex on Windows.
- Each run implements only its stated phase, does its **own checks**, commits meaningful work, and reports evidence. A subsequent **independent review** can accept the gate or request a targeted correction run; the next phase must not start before acceptance.
- All six phases share `product-contract.md` and `architecture.md`. A future feature's absence is not a failure of an earlier gate; regressions of earlier accepted requirements always are.
- The coding agent is explicitly prohibited from silently editing the contracts, inventing terminal results, fabricating screenshots or copying source code from LexiStack3/4. **Frozen reference JSON is the deliberate exception.**
- Maintain a short, single gate log rather than a large handover dossier. Record observed tests, git commits, environmental blockers, review decisions and corrective prompts.

## P0 — Baseline and contract readiness (planning/setup, outside six runs)

**Goal:** Freeze both the product contract and the experimental inputs so F1 is not making policy decisions.

**Deliverables:** (1) this documentation set; (2) confirmed Flutter/Android toolchain baseline; (3) Content Studio's minimal `lexistack_content_contract` Dart package, published at a pinned Git commit; (4) immutable 40-level reference content locked to LexiStack3 commit `8b84f2d6c75cb807fba9db19cba707f963e02020`, with source blob IDs in `reference-content-lock.md`; (5) agreed acceptance matrix and scorecard.

**Preflight gate:** Contract package resolves on Windows, its own parser/validator tests pass, reference data provenance is reproducible, and the F1 prompt refers to the real Studio package URL and pinned SHA. If not, F1 is **blocked**, not provisionally passed. Full editorial review is *not* a prerequisite for engineering-fixture use.

## F1 — Foundation & Android baseline

**Goal:** Start a real Flutter application and prove platform/toolchain viability early.

**Scope:** Scaffold the Flutter project (`lexistack`), minimal app shell/navigation, themes/assets/font licensing baseline; integrate the pinned pure-Dart contract; import **unchanged `pack1.json`** from the locked reference; minimal asset loader and thin validator CLI; first analyzer/Widget and content tests; first Android APK/launcher smoke. No game logic beyond what is required to load/display a level entry.

**Depends on:** P0 fully ready.

**Acceptance:** Clean package resolution; no Flutter imports in the content package; correct schema v2 parsing; `--partial` succeeds for a genuinely valid present pack and strict mode correctly reports incomplete catalog; `dart analyze`, tests and `flutter build apk --debug` succeed; launcher-started app renders a real screen on the Windows Android emulator, with screenshot/log evidence.

**Independent gate F1:** ARC-01–04, CNT-01, CNT-03, UI-01, PLT-01–02. Confirm no fake complete-catalog claims. Record cold/warm launch observations without an arbitrary time limit.

## F2 — Pure-Dart rules and playable vertical slice

**Goal:** A playable level by the end of F2, not a mockup.

**Scope:** Pure-Dart engine; status transitions; selection, drag-additive behavior, correct/incorrect/One Away/duplicate submissions, deterministic shuffle, hints' deterministic *effects* (purchasing is integrated in F3), stars and pure share formatter; a real Board screen with selection/submit/feedback/group reveal and simple navigation, using a frozen pack1 level. Use in-memory controller state for the slice; no production recovery/economy yet.

**Depends on:** F1 accepted; pack1 present and validated.

**Acceptance:** Independent *two-fresh-instance* rule oracle; fifth-tile and solved-tile protections; explicit pending loss with zero spoiler; correct full victory; repeatable seeded tile order and golden vectors; Android tap and drag solve behavior (not just widget tests). No direct UI copies of scoring/state transitions.

**Independent gate F2:** ENG-01–12, UI-02, PLT-03. If emulator touch gestures are blocked by environment, document and classify as provisional; do not equate a widget gesture test with Android device proof.

## F3 — Progression, economy, Daily, persistence

**Goal:** Make the playable game state durable and the money model correct.

**Scope:** Starting coins, all three booster payments/rejections, first-win/replay practice rewards, best stars, campaign unlock/continue/replay, daily civil-date selection and streaks; import unchanged **`daily.json`**; statistics and finalized share/reward metadata; `shared_preferences`-based versioned progress, injection of memory store and clock, write ordering, partial recovery, save failure reporting and content-fingerprint checks.

**Depends on:** F2 accepted; frozen Daily pool.

**Acceptance:** No double rewards/charges across restart, capped practice payouts, stars based on mistakes after rescues, daily one-attempt-per-date and DST/leap cases, current/best streak logic, pending loss still concealed on reload. Adversarial restore of duplicate or missing tile IDs rejects **only affected attempts** while preserving valid coin/history data.

**Independent gate F3:** ECO-01–09, DAY-01–06, PER-01–09. Verify one Android restart with restored state, in addition to deterministic in-memory tests.

## F4 — Complete UX and interaction integration

**Goal:** Reach feature-complete screens and tactile, accessible gameplay on the available verified content.

**Scope:** Home, pack/level select, Board, result/pending-loss, stats, settings; boosters in actual UI; share-to-clipboard, reset confirmation, theme and haptics toggles, animations, solved banners and red-herring explanations. Mobile/desktop layouts, semantic labels, touch targets, reduced-motion behavior. The four-pack final catalog is *not* asserted until F5; test all pack-navigation cases with controlled catalog fixtures and real available assets, not fake production content.

**Depends on:** F3 accepted.

**Acceptance:** Real-app widget flows and Android gameplay; `360x640` at text scale `1.3`, `390x844` and wide desktop frame without overflow; no solution disclosure at pending loss; controls are functional; saved settings survive restart; visually inspected production-state screenshots for key screens.

**Independent gate F4:** UI-03–12, PLT-03–04 plus regression of all prior gates.

## F5 — Full frozen catalog and content-import hardening

**Goal:** Complete the 40-level production benchmark dataset and prove the shared import/validator pipeline.

**Scope:** Import unchanged `pack2.json`, `pack3.json`, `pack4.json` from the locked source; full final manifest, correct pack order, catalog-driven UI; strict cross-file validation and candidate replacement/addition checks; tests on real JSON; regression of navigation, Daily and saved progress; detect content identity changes without silently rewriting history. The agent does **not** invent or edit new riddles.

**Depends on:** F4 accepted and all six source files retrievable at their locked commit.

**Acceptance:** Exactly **32 campaign + 8 daily**, 160 categories, 640 tile positions, zero errors/warnings in strict validation; installed JSON byte identities match the frozen snapshot (or differences are documented and explicitly approved *before* comparison); all 40 levels technically solvable by intended categories, all four packs appear and unlock correctly. Editorial ambiguity remains a separately documented limitation.

**Independent gate F5:** CNT-01–11, CAT-01–04, regression of prior gates, an editorial *spot check* recorded separately without rewriting benchmark assets.

## F6 — Android release candidate and independent audit

**Goal:** Produce a verifiable technical release candidate and evidence-based final report, not a new feature sprint.

**Scope:** Fix discovered defects, final lint/tests, full Android debug + web builds, emulator smoke (launcher start, tap, drag, hints, loss/rescue, save/restart), browser-compiled PRNG equivalence, six real Flutter screenshots, packaging/assets/icons/licenses. Build a release APK when the Windows toolchain permits and report signing/distribution limitations accurately. Do not add new gameplay features.

**Depends on:** F5 accepted and all critical defects closed.

**Acceptance:** Exit codes and logs captured for `flutter pub get`, validator strict, `dart analyze`, `flutter test`, `flutter build web`, `flutter build apk --debug`, and any attempted release APK. Actual browser execution of golden PRNG tests. Actual emulator tests and visual screenshot inspection; note first cold vs warm start and debug vs release. At least the six expected screenshot states and viewport sizes. No unreported critical rule/reward/recovery defects.

**Independent gate F6:** PLT-01–08, UI-01–12, ENG/ECO/DAY/PER/CNT regression and the complete independent 100-point scorecard. The gate cannot be marked passed solely from agent narrative.

## After Experiment E (explicitly outside the technical score)

Run a **separate content-quality experiment** with new Studio-generated/reviewed packages. Compare the unchanged technical engine against the locked and newly curated sets using independent editorial scoring. The timing, production prompts and review of new content are not part of F1–F6.

## Correction and intervention policy

A failed gate triggers a **narrow corrective prompt** tied to named acceptance IDs, not a new Genesis. Re-run impacted tests plus prior core regressions. If the agent needed mid-run user rescue, preserve the pre-rescue checkpoint and label that run assisted. Distinguish product bugs from Gradle/PowerShell/Git/browser/emulator failures. Do not penalize the agent for problems that are demonstrably outside its source changes, but do count inability to recognize/report them accurately.
