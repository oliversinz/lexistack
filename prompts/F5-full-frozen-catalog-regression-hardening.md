# LexiStack5 — F5: Full Frozen Catalog & Regression Hardening

## Role and Mission

You are Codex Desktop, acting as the autonomous Flutter/Dart implementation engineer for **Experiment E, Feature Phase F5**.

Your task is to complete the frozen 40-level production catalog, integrate it safely into the existing Flutter application, and strengthen the content-import and regression verification.

This is **one autonomous F5 implementation assignment**, not a planning-only exercise.

Complete the scoped implementation, focused regression tests, Android verification, evidence capture, commits, and feature-branch publication without requesting intermediate user approval.

**Do not begin F6. Do not merge into main.**

Independent ChatGPT review will determine whether F5 passes its quality gate.

---

## 1. Repository, Environment and Immutable Baseline

**Application repository**

- Working directory: `C:\Codex\LexiStack`
- GitHub: `https://github.com/oliversinz/lexistack`
- Approved starting main commit: `8b07d01443277b6c1af0201d481c9a1174412093`
- Required implementation branch: `codex/f5-full-frozen-catalog`

**Content Contract repository**

- Local directory: `C:\Codex\LexiStackContent`
- GitHub: `https://github.com/oliversinz/lexistack-content`
- Immutable package commit: `d9acbd52de0e198dd109a4859299318db3f465f5`
- Package: `packages/lexistack_content_contract`

**Frozen reference source**

- GitHub: `https://github.com/oliversinz/LexiStack3`
- Source commit: `8b84f2d6c75cb807fba9db19cba707f963e02020`
- Directory: `assets/levels/`

The source repository is authorized **only for the locked JSON reference assets**. Do not copy application code, validators, tests, UI components, architecture, or infrastructure from LexiStack3 or LexiStack4.

Environment: Windows / PowerShell, Flutter/Dart, Android SDK and Pixel_10 emulator when available.

### Preflight

Before implementing:

1. Read `AGENTS.md`.
2. Read, in its prescribed order:
   - `docs/product-contract.md`
   - `docs/architecture.md`
   - `docs/feature-roadmap.md`
   - `docs/acceptance-matrix.md`
   - `docs/reference-content-lock.md`
   - `docs/experiment-e-protocol.md`
   - `docs/gate-log.md`
3. Inspect the actual local Git status, current branch, remote refs, tool versions, package pin, and existing content files.
4. Confirm that `origin/main` matches the exact approved SHA above.
5. Start F5 on the dedicated feature branch based on that commit.
6. Preserve the complete supplied F5 prompt under `prompts/F5-full-frozen-catalog-regression-hardening.md`, using the exact supplied file bytes if available. Record prompt provenance and SHA-256. Do not claim byte identity with a chat message unless verifiable.
7. Preserve existing work and user files. Do not silently discard, stash, reset, or overwrite unrelated changes.

If the approved baseline, frozen source, or package pin cannot be verified, classify this as a blocker. Do not substitute a different source or silently update contracts.

### Execution constraints

- Only F5 is authorized.
- Work autonomously through implementation and verification.
- Commit meaningful, working checkpoints.
- Push the completed F5 branch to `origin`.
- Never merge or push to `main`.
- Never force-push or rewrite Git history.
- Do not alter the Product Contract, Architecture Contract, Acceptance Matrix, reference lock, or Experiment E protocol to make tests pass.
- The rolling Gate Log may receive a factual F5 implementation record with status **PENDING independent review**.
- No new packages unless strictly necessary and justified.
- Do not change the pinned Content Contract dependency.

---

## 2. F5 Scope and Success Criteria

The current accepted F4 application already implements:

- Pure-Dart deterministic game rules.
- Four gameplay statuses, including spoiler-safe pending loss.
- Boosters, scoring and settled economy.
- Campaign progression and Daily rotation.
- Defensive versioned persistence and recovery.
- Full Flutter interaction flows.
- Paper Arcade visual design.
- Offline Fraunces/DM Sans typography.
- Android touch/drag and restart behavior.

These are accepted features, not implementation targets to redesign.

F5 must deliver:

1. Full frozen source catalog.
2. Complete production asset registration.
3. Correct four-pack application navigation and independent progression.
4. Strict production content validation.
5. Full catalog-wide identity and invariant checks.
6. Candidate replacement/addition verification.
7. Existing-save compatibility.
8. Complete earlier-gate regression verification.
9. Targeted Android evidence.
10. Traceable F5 implementation and verification records.

### Required final content totals

| Property | Required |
|---|---|
| Campaign packs | 4 |
| Campaign levels per pack | 8 |
| Campaign levels | 32 |
| Daily pool levels | 8 |
| Total packs | 5 |
| Total levels | 40 |
| Categories | 160 |
| Tile positions | 640 |
| Strict errors | 0 |
| Strict warnings | 0 |
| Initial benchmark | PASS |

The application must remain a genuine offline Flutter game.

No puzzle authoring, no new monetization, no analytics, no backend, no runtime AI, and no unrelated product development.

---

## 3. Frozen Content Import and Provenance

Import the following files from the exact LexiStack3 commit.

These are Git blob SHA-1 identities, not SHA-256 file checksums.

| Asset | Required Git blob SHA-1 |
|---|---|
| `manifest.json` | `6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d` |
| `pack1.json` | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `pack2.json` | `32ca5e922e3da3e2b22a42716de87a63e53492f8` |
| `pack3.json` | `fc88352362ea575e7c0f38670b0c7e81c24ec070` |
| `pack4.json` | `54c09ae4c2f0a5d07b95addc42e80eacac33d2c6` |
| `daily.json` | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

### Import procedure

- Verify the source commit before reading source files.
- Copy `pack2.json`, `pack3.json`, `pack4.json` byte-for-byte.
- Replace the temporary manifest with the exact locked production `manifest.json`.
- Keep `pack1.json` and `daily.json` unchanged.
- Do not parse and reserialize the production JSON during import.
- Avoid PowerShell redirection or text-writing operations that inadvertently change encoding or newline bytes.
- Preserve the repository's `.gitattributes` handling.
- Verify every installed production file using `git hash-object --no-filters`.
- Compare all six resulting blob IDs with the table above.

The final manifest must list campaign files in this exact order:

`pack1.json`, `pack2.json`, `pack3.json`, `pack4.json`

The Daily file must remain `daily.json`.

### Stop conditions

If any locked file is inaccessible, has an unexpected blob identity, or fails validation, report the exact discrepancy.

Do not repair reference JSON, change category names, rewrite trivia, adjust red herrings, or regenerate levels.

A structural reference-data failure is a fixture blocker requiring independent review.

A purely editorial weakness is documented separately, without changing the engineering benchmark.

---

## 4. Complete Flutter Asset Integration

**Important pre-identified risk:** `pubspec.yaml` currently registers only `manifest.json`, `pack1.json`, and `daily.json`.

Update the production Flutter asset declarations so that all five pack JSON files and the manifest are bundled.

Use the existing explicit asset-registration convention unless a small, justified equivalent is preferable.

Verify both independent paths:

**Filesystem validation**

`dart run tool/validate_levels.dart`

**Actual Flutter asset loading**

`loadAssetCatalog(rootBundle)`

The second check must read all manifest-listed files from the actual Flutter asset bundle, not manually read files from the repository filesystem.

Verify that the production Android APK includes and successfully loads all registered packs.

Inspect `lib/infrastructure/asset_catalog.dart`, where runtime loading currently uses partial validation. With the complete F5 production catalog installed, use strict runtime validation where consistent with the contracts. Preserve direct partial-mode testing for deliberate incomplete-catalog fixtures.

Do not hide missing assets by substituting synthetic fallback levels.

---

## 5. Strict Validator and Catalog-Wide Invariants

The pinned external package remains the only owner of schema parsing and validation.

Keep `tool/validate_levels.dart` a thin CLI wrapper.

Do not introduce an independent second production validator or change the package pin.

### Strict production checks

Run:

`dart run tool/validate_levels.dart`

Require:

- Process exit code 0.
- All five expected production files present.
- Exactly 40 levels.
- Exactly 160 categories.
- Exactly 640 tile positions.
- Zero errors.
- Zero warnings.
- Strict minimum PASS.
- Initial benchmark PASS.

**Important:** The shared CLI may return exit code 0 despite advisory warnings. Explicitly inspect and assert the warning count. Exit code alone is insufficient.

Also execute:

`dart run tool/validate_levels.dart --partial`

Partial mode must remain valid and accurately label the result as PARTIAL.

### Required structural coverage — CNT-01 through CNT-09

Test both valid production input and controlled negative mutations, including:

- Unsupported schema versions and malformed JSON.
- Missing manifest files and missing schema fields.
- Duplicate pack IDs.
- Duplicate level IDs across files.
- Duplicate category IDs within a level.
- Incorrect `packId` references.
- Wrong group counts and missing tiers.
- Duplicate board words.
- Invalid tile case, spacing, length and format.
- Normalized duplicate category titles.
- A normalized tile appearing in more than two levels.
- Category pairs sharing three or more tile strings.
- Duplicate complete boards.
- Invalid or off-board red-herring references.
- Missing or malformed red-herring notes.
- Trivia outside the 40–160 character boundary.
- Mechanically detectable warnings.

Negative fixtures must produce actionable diagnostics, not crashes or opaque type errors.

Use temporary or test-only synthetic data for negative cases. Never mutate or commit altered production reference files.

Do not weaken existing validator tests to accommodate the full catalog.

---

## 6. Candidate Replacement and Addition — CNT-10

Validate the real CLI workflow and its pure-Dart contract behavior.

### Case A — Valid replacement

Use a candidate whose `pack.id` matches an installed pack, preferably the unchanged locked `pack2.json`.

Verify:

- Classification: `REPLACEMENT`.
- The original installed pack is logically replaced for validation, not counted twice.
- Expected catalog-wide validation succeeds.
- The candidate output clearly identifies the replaced source.
- No production assets are modified.
- The manifest remains unchanged.

### Case B — Invalid addition

Create a temporary synthetic candidate with a new pack ID but deliberate cross-catalog conflicts.

Verify:

- Classification: `ADDITION`.
- Duplicate titles, repeated words, overlapping groups, or other deliberate violations are rejected with meaningful diagnostics.
- A failed candidate never mutates installed assets.

### Case C — Valid addition

Where feasible, construct a minimal valid synthetic eight-level candidate with:

- A genuinely new pack ID.
- Unique level/category identities.
- Non-conflicting tile strings.
- No cross-catalog uniqueness violations.
- Valid schema and structural requirements.

Verify classification as `ADDITION` and successful validation.

This is a **test fixture**, not authorization to produce or ship additional editorial puzzles.

Do not add a sixth pack to the production manifest.

### Candidate non-mutation proof

Record production asset identities before and after the candidate checks.

All six locked production asset hashes must remain identical.

The CLI must clearly distinguish replacement and addition and must accurately indicate that it is a preview-only operation.

---

## 7. Full-Catalog Engine and Identity Tests — CNT-11

Use the actual production JSON, not a synthetic replacement catalog.

Iterate through every installed level.

For each of the 40 levels:

1. Construct a fresh game from the parsed production level.
2. Verify 16 distinct stable tile IDs.
3. Verify four groups and exactly one tier each of 1, 2, 3 and 4.
4. Submit each of its four intended categories through the actual engine.
5. Verify each correct submission.
6. Verify the board reaches `won` after four successful groups.
7. Verify four lives and zero mistakes remain on the perfect solve.
8. Verify the expected three-star result.
9. Verify each level ID, category ID and tile ID resolves consistently.
10. Verify every intended group can be solved without relying on display-string equality alone.

Across the catalog, assert global uniqueness of level IDs and stable tile IDs.

The expected production IDs follow the locked references, including:

- `pack1_lvl01` through `pack1_lvl08`
- `pack2_lvl01` through `pack2_lvl08`
- `pack3_lvl01` through `pack3_lvl08`
- `pack4_lvl01` through `pack4_lvl08`
- `daily_lvl01` through `daily_lvl08`

Verify source ordering within each pack.

This proves technical solvability under the intended partition. It does not prove the absence of alternative editorial interpretations.

---

## 8. Four-Pack Progression and Navigation Regression

Inspect existing implementation before editing it.

Relevant components include:

- `lib/app/progress_controller.dart`
- `lib/app/catalog_controller.dart`
- `lib/ui/catalog_screens.dart`
- `lib/ui/home_screen.dart`

Current progression is catalog-driven and should remain so.

Do not invent a new progression framework.

### Required unlock tests

For each of the four Campaign packs:

- Stage 1 is unlocked immediately for a fresh player.
- Stages 2–8 begin locked.
- Winning stage 1 unlocks stage 2 within that pack.
- Winning stage N unlocks stage N+1 within that same pack.
- Winning a level in one pack does not unlock unrelated levels in another pack.
- A replay loss or a lower-star replay does not remove prior unlocks.
- Existing best stars remain attached to the correct level IDs.
- Unlocks survive save/restart.

Explicitly cover pack2, pack3 and pack4; testing only pack1 is insufficient.

### Continue Campaign

Verify:

- The most recently entered unfinished Campaign attempt is resumed first, including `lostPendingDecision`.
- With no unfinished attempts, Continue selects the earliest unlocked, never-won level by manifest order.
- After all eight pack1 levels are won, the next eligible fresh level follows the manifest policy.
- Fully completing all 32 Campaign levels does not silently restart previously won content.
- Explicit replay remains available.
- The Daily pool is never treated as a Campaign pack.

### UI checks

Verify that the actual application displays:

- All four pack titles and descriptions.
- Exactly eight stages per pack.
- Correct locked/unlocked state.
- Correct star and progress totals.
- Independent pack progress.
- Appropriate navigation into new pack levels.

Check real content with long labels, particularly:

- `World History & Myth`
- `Pop Culture & Wordplay`
- `SCIENTISTS WITH ELEMENT NAMESAKES`
- `WORDS USING ONLY ROMAN NUMERAL LETTERS`
- `BEGIN AND END WITH THE SAME LETTER`

Ensure these remain legible and do not introduce layout overflow.

Preserve Paper Arcade styling, color roles, DM Sans functional typography, and the two approved Fraunces exceptions.

---

## 9. Legacy Savegame Compatibility and Recovery

**This is a critical F5 acceptance area.**

The F5 catalog expansion must preserve existing valid F4 player progress.

Existing persistence uses:

- Versioned `Progress` document.
- Stable pack/level/category/tile identities.
- Content fingerprints for unfinished attempts.
- Catalog-independent finalized result summaries.
- Per-section recovery.
- Serialized asynchronous writes.
- Reward and settlement protections.

Do not introduce a schema migration without a demonstrated compatibility requirement.

### Old catalog → full catalog regression

Create a genuine saved document using a controlled legacy catalog containing only unchanged `pack1.json` and `daily.json`, under the pre-F5 manifest arrangement.

Then restore the same serialized document using the full five-pack F5 catalog.

Verify preservation of:

- Coin balance.
- Existing achievements and best stars.
- First-win reward status.
- One-time practice payout flags.
- Finalized historical results.
- Completed Daily outcomes.
- Daily streak data.
- Settings and haptics.
- Attempt IDs and progression counters.
- In-progress Campaign attempts.
- In-progress current-day Daily attempts.
- Ordered board state, selections and guesses.
- Hints, peeked categories and revealed pairs.
- Pending-loss state and rescue eligibility.

No reward, booster payment or game result may be duplicated merely by loading the larger catalog.

No valid unchanged `pack1` or `daily` attempt may be discarded because other packs were added.

An unchanged legacy save must not be silently reset.

### Content-fingerprint mismatch

Using test-only modified catalog models:

- Preserve the same level ID while changing material level content.
- Confirm the affected unfinished attempt is invalidated or quarantined.
- Preserve unaffected attempts.
- Preserve valid wallet, achievements, completed results and Daily history.
- Prevent a mismatched saved board from silently attaching to new content.
- Preserve previously paid rewards and reward locks.

Do not test this by editing production JSON.

### Recovery and storage failure

Regression-test F3-R01 explicitly:

- A storage read failure must not initialize writable default progress.
- Retry Save must not overwrite an unread existing document.
- Progress and payment operations remain unavailable until a valid read succeeds.
- A successful retry restores the original state.
- Later writes remain correctly ordered.
- Recoverable corruption discards only invalid portions.
- Duplicate settlements and reward farming remain blocked.

Use deterministic in-memory storage and an injectable clock.

Where available, retain a representative version-1 save document as a test fixture, with its origin clearly documented.

---

## 10. Update Existing Tests Without Weakening Coverage

The F4 repository has accepted evidence for **155 passing Flutter tests**. Preserve all previously accepted behavioral coverage.

### Known F5-sensitive test files

Inspect and update at least:

- `test/content_test.dart`
- `test/support/progress_fixture.dart`
- `test/app_test.dart`

These currently contain assumptions or asset inventories based on the two installed JSON files.

Review other tests for fixed pack counts, incomplete-manifest assumptions, or hard-coded asset lists.

### Required adaptations

- Production fixtures must load the complete final manifest and all referenced production files.
- Prefer using the parsed manifest to build test asset inventories rather than maintaining another stale file list.
- Change production strict validation expectations from expected failure to genuine success.
- Preserve negative strict-versus-partial tests by giving them controlled incomplete manifests.
- Preserve malformed-asset and missing-asset error tests.
- Add an explicit missing-pack2 or missing-pack4 bundled-asset test.
- Ensure rootBundle tests read all five real pack files.
- Retain the pure engine, economy, Daily, persistence, F3-R01, interaction and layout regression suites.
- Do not delete tests merely to obtain a green result.
- Do not substitute synthetic catalogs for tests explicitly requiring installed production content.

Add focused F5 tests under the existing test directory structure rather than introducing a parallel testing system.

---

## 11. Real Flutter UI and Android Verification

F5 is not a visual redesign.

Preserve:

- Paper Arcade light and dark themes.
- Existing font assets and licensing.
- Fraunces only for Home wordmark and hero.
- DM Sans for functional UI.
- Responsive Board and permanently reachable Submit dock.
- Touch/drag selection.
- Native clipboard-sharing behavior.
- Haptics, accessibility, reduced-motion behavior.
- Offline operation.

### Flutter layout regression

Run production-state widget flows at:

- 360×640 logical pixels, text scale 1.3.
- 390×844 logical pixels.
- 1280×800 wide viewport, centered game frame.

Verify that newly installed content does not cause clipped tiles, inaccessible buttons, overflow exceptions or unreadable group reveals.

At least one newly installed pack must be tested through real Board interactions, not just metadata rendering.

### Targeted Android verification

If the established Pixel_10 emulator is available:

1. Build and install the current F5 debug APK.
2. Launch the application via its Android launcher.
3. Open the Campaign shelf and inspect all four packs.
4. Navigate into at least one level from each newly added pack.
5. Play and solve a real group in at least one newly installed level.
6. Verify the updated pack progress and relevant unlock.
7. Confirm existing saved progress survives application restart.
8. Capture real Android screenshots or UI hierarchy evidence for the important new F5 states.
9. Record emulator identity, command exits, Android observations and any actual failures.

Avoid confusing a warm resume with proof of process-death persistence.

Use bounded commands and diagnostic output. Do not classify a slow cold start as a source defect without evidence.

Do not manufacture screenshots.

This is a **targeted F5 smoke**, not the canonical F6 release audit.

---

## 12. Mandatory Verification Commands

Run and capture literal commands, output and exit codes.

Required:

- `flutter pub get`
- `dart run tool/validate_levels.dart --partial`
- `dart run tool/validate_levels.dart`
- Candidate replacement CLI validation.
- Candidate addition CLI validation, valid and deliberately invalid cases where feasible.
- `dart analyze`
- `flutter test --reporter expanded`
- `dart run tool/check_prng.dart`
- `flutter build apk --debug`

Also verify:

- All six locked JSON blob identities.
- Exact production manifest order.
- Content package Git pin and resolved lockfile.
- No new unintended dependency.
- No unexpected changes to protected contracts.
- `git diff --check` for committed changes.
- Final clean worktree.
- Local/remote F5 branch SHA equality.
- `origin/main` unchanged.

Run focused tests during implementation, followed by the full regression suite.

Preserve initial failures and corrective reruns in the evidence rather than showing only successful final output.

Do not claim independent Windows verification: these are implementation-agent executions to be audited later.

Do not start F6-only verification, including canonical six screenshots, browser-executed PRNG testing or release-candidate packaging.

---

## 13. Evidence and Gate Record

Create a concise, auditable evidence set under:

`docs/evidence/f5/`

Use existing evidence conventions where practical.

Record:

- Starting main SHA.
- F5 implementation branch and final commit SHA.
- Source commit and immutable content package pin.
- Prompt SHA-256 and provenance.
- Agent/model/effort information when available.
- Windows/Flutter/Dart/Android versions.
- Run start/end timestamps.
- Test and validator command outputs with exit codes.
- Strict validation and benchmark status.
- Per-file Git blob identity report.
- Candidate validation classifications.
- Candidate asset non-mutation proof.
- Legacy-to-full-catalog persistence evidence.
- Android interaction observations.
- Genuine screenshots if captured.
- Remaining issues and environment-specific limitations.
- Number of human interventions during the autonomous implementation.

Keep the evidence understandable and reasonably compact. Do not create an elaborate new reporting or orchestration framework.

Append an F5 implementation entry to `docs/gate-log.md` with reviewer decision explicitly **PENDING independent review**.

Do not declare F5 PASS yourself.

Editorial CAT-01–04 judgments belong to the separate independent assessment. You may identify possible content ambiguities without changing the frozen data or declaring it editorially certified.

---

## 14. Acceptance Matrix and Quality Gate

F5 is complete for submission only when the implementation has addressed:

**Content**

- CNT-01–11.

**Editorial review readiness**

- CAT-01–04, without altering source fixtures or self-awarding editorial approval.

**Regression**

- ARC-01–04.
- ENG-01–12 within previously accepted scope.
- ECO-01–09.
- DAY-01–06.
- PER-01–09, including F3-R01.
- UI-01–12 within previously accepted scope.
- Earlier applicable Android/platform probes.

The independent reviewer will determine PASS, FAIL or BLOCKED per applicable requirement.

Any earlier accepted regression failure blocks F5 approval.

### Hard fail conditions

F5 cannot be presented as complete if:

- Any source JSON blob identity differs from the frozen reference without prior authorization.
- The manifest does not match the required initial benchmark.
- Strict validation has errors or warnings.
- The Content Contract pin is silently changed.
- Production asset registration is incomplete.
- A newly installed level cannot be solved technically using its intended groups.
- Cross-pack unlocking is incorrect.
- Valid legacy savegames are lost or incorrectly remapped.
- Reward duplication, farming or settlement regression is introduced.
- Existing accepted tests are removed or weakened to mask failures.
- Core application defects are unreported.
- Required evidence is fabricated.
- The implementation branch is merged into main before approval.

---

## 15. Expected Code and Documentation Change Scope

Changes should primarily involve:

- `assets/levels/`
- `pubspec.yaml`
- Existing content-loading integration where necessary.
- Existing catalog and progression UI only if actual F5 defects require it.
- Updated tests and focused new F5 tests.
- `prompts/F5-full-frozen-catalog-regression-hardening.md`
- `docs/evidence/f5/`
- `docs/gate-log.md`
- Small, accurate README updates if required.

Avoid modifying the game engine, economy rules, persistence codec or themes unless a reproducible F5 regression demonstrates the need.

When a modification outside the expected scope is necessary, explain the triggering defect, affected acceptance ID and regression tests.

Never rewrite the architectural contracts.

---

## 16. Required Git Publication Workflow

At completion:

1. Finish all implementation and verification tasks on `codex/f5-full-frozen-catalog`.
2. Commit coherent implementation and evidence checkpoints.
3. Verify no uncommitted changes remain.
4. Verify the approved base commit remains an ancestor of the feature branch.
5. Push the feature branch to `origin`.
6. Confirm the remote branch contains the exact final implementation/evidence SHA.
7. Confirm `main` is unchanged.
8. Stop.

Do not merge the feature branch.

Do not begin F6.

Independent review and explicit user approval are required before fast-forward integration.

---

## 17. Final Implementation Report

Return a concise, factual report with:

1. **Status:** Complete / Partial / Blocked.
2. **Git:** starting SHA, branch, final SHA, remote publication, clean/dirty tree.
3. **Scope:** content import, asset integration, tests and any necessary code corrections.
4. **Content:** per-pack counts, complete totals and exact six blob IDs.
5. **Validator:** strict/partial results, zero-error/zero-warning status, initial benchmark status.
6. **Candidates:** replacement/addition outcomes and evidence of non-mutation.
7. **Compatibility:** old savegame restore, unlocks, rewards, content fingerprints, recovery.
8. **Verification:** literal commands, exit codes, test count, Android observations.
9. **Limitations:** defects, blocked probes, environment/tooling issues and editorial caveats.
10. **Experiment:** run timestamps, model/effort if known, corrective actions and human interventions.

Distinguish developer-observed verification from independent reviewer acceptance.

**Implement F5 now, autonomously and completely. Publish only the feature branch. Stop after the final report.**