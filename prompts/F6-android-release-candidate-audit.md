# LexiStack5 — F6: Android Release Candidate & Final Verification

## Role and Mission

You are Codex Desktop, acting as the autonomous Flutter/Dart implementation and verification engineer for **Experiment E, Feature Phase F6**.

This is the sixth and final implementation phase of LexiStack5.

Your mission is to turn the accepted F5 application into a **fully verified Android-first release candidate**, complete the outstanding platform acceptance requirements, produce authentic visual evidence, and prepare a reproducible technical record for the final independent audit.

This is **not a new feature-development sprint**.

F1–F5 have passed their independent quality gates. Preserve their accepted behavior, architecture, design, reference content, and regression coverage.

Complete the assigned implementation, verification, corrective work, evidence capture, commits, and feature-branch publication autonomously.

**Do not ask for intermediate approval. Do not self-award F6 PASS. Do not merge into main.**

The independent reviewer will evaluate your submitted F6 branch and conduct the final Experiment E comparison separately.

---

## 1. Repository and Approved Starting State

### Flutter application

Working directory:

`C:\Codex\LexiStack`

Repository:

`https://github.com/oliversinz/lexistack`

**Approved F5 acceptance / starting main commit:**

`9aec6c82f5fd2e5d86ed4a98dcdf3e799c9ac873`

Required F6 feature branch:

`codex/f6-android-release-candidate`

### Content Contract

Repository:

`https://github.com/oliversinz/lexistack-content`

Immutable Git dependency:

`d9acbd52de0e198dd109a4859299318db3f465f5`

Package:

`packages/lexistack_content_contract`

### Frozen reference content

Source:

`https://github.com/oliversinz/LexiStack3`

Immutable reference commit:

`8b84f2d6c75cb807fba9db19cba707f963e02020`

The complete five-pack production catalog is already installed and accepted.

### Existing verification baseline

F5 recorded:

- 195 passing Flutter tests.
- Strict content validation: zero errors and warnings.
- Full 40-level benchmark.
- Clean Dart analyzer.
- Successful Android debug APK.
- Real Android gameplay and process-death recovery.
- Preserved version-1 savegame compatibility.
- Accepted Paper Arcade visual design.
- No unresolved F5 engineering defects.

Reproduce this baseline before modifying production code.

---

## 2. Mandatory Repository and Contract Preflight

Read `AGENTS.md` and then the authoritative documents in their prescribed order:

1. `docs/product-contract.md`
2. `docs/architecture.md`
3. `docs/feature-roadmap.md`
4. `docs/acceptance-matrix.md`
5. `docs/reference-content-lock.md`
6. `docs/experiment-e-protocol.md`
7. `docs/gate-log.md`

Also inspect the current README, Flutter platform metadata, source modules, test suites, screenshot tooling, Android configuration, font licensing, and existing evidence conventions.

### Git preflight

Before implementation:

- Inspect current branch and working-tree status.
- Fetch `origin`.
- Confirm local and remote `main` equal the approved SHA exactly.
- Confirm the working tree is clean.
- Confirm F5 is accepted in the Gate Log.
- Create `codex/f6-android-release-candidate` from the approved main.
- Verify the immutable Content Contract pin and resolved package revision.
- Record Git, Flutter, Dart, Java, Android SDK, Gradle, emulator and browser versions.

If the repository has diverged or contains unexpected user changes, do not overwrite or discard them.

### Prompt provenance

Archive this assignment as:

`prompts/F6-android-release-candidate-audit.md`

Use the exact supplied prompt bytes if available. Record SHA-256 and provenance. Do not claim byte identity with reconstructed chat content unless actually verified.

Preserve the existing `prompts/*.md` byte-retention policy.

### Execution boundaries

Do not:

- Change gameplay rules or economic constants.
- Generate or modify any reference puzzles.
- Change the Content Contract package pin.
- Integrate Content Studio output.
- Modify LexiStack3 or LexiStack4.
- Copy source code from previous experiments.
- Introduce a backend, telemetry, ads, billing, authentication, audio, runtime AI or network-dependent gameplay.
- Adopt a new state-management architecture.
- Rewrite accepted Product, Architecture or Acceptance Contracts.
- Reset user progress to simplify verification.
- Begin post-experiment Content Studio work.

Production changes are permitted only to resolve demonstrated F6 defects or complete explicitly required platform, packaging, accessibility or verification capabilities.

---

## 3. F6 Execution Strategy

Work through the following checkpoints autonomously.

### A — Baseline and environment audit

Verify the accepted F5 state, tools, assets and existing test suite.

### B — Web platform readiness and browser verification

Complete the missing web platform, build the real Flutter web application, and execute the PRNG golden vectors inside an actual browser.

### C — Final Android and offline verification

Build and exercise the application on the Android emulator, including cold/warm lifecycle, offline gameplay, boosters, loss/rescue and persistent state.

### D — Six canonical Flutter screenshots

Capture all six required genuine application states at their specified viewport sizes, with real bundled fonts.

### E — Packaging, maintainability and documentation audit

Verify release build, icons, assets, licenses, architecture and README accuracy. Fix only confirmed issues within F6 scope.

### F — Full regression, evidence and publication

Re-run the entire acceptance suite, archive actual outcomes, commit coherent checkpoints and push the F6 branch.

Proceed without interactive approval between checkpoints.

If a test is blocked by an external environment issue, diagnose and report it accurately. Continue unaffected work. Do not invent results or silently convert a blocked verification into a PASS.

---

## 4. Initial Baseline Verification

Before production edits, execute and record:

```powershell
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build apk --debug
```

Capture actual stdout/stderr and native process exit codes.

The expected F5 baseline is 195 passing Flutter tests, but use the actual observed result rather than assuming it.

Confirm:

- 4 Campaign packs × 8 levels.
- 8 Daily levels.
- 40 total levels.
- 160 categories.
- 640 tile positions.
- Strict zero errors and zero warnings.
- Initial benchmark PASS.

Check all six frozen Git blob identities against `docs/reference-content-lock.md`.

Do not modify the reference files to repair a discrepancy.

---

## 5. Web Platform Completion and Runtime Verification

**Known repository finding:** The accepted F5 repository currently has Android scaffolding but no committed `web/` platform directory.

F6 must establish a genuine Flutter web target.

### Web scaffolding

Inspect `.metadata` and existing Flutter configuration first.

Add only the missing Flutter web platform files using the installed Flutter SDK's supported scaffolding mechanism, such as a carefully scoped `flutter create --platforms=web .` operation.

Before retaining generated changes:

- Inspect the complete diff.
- Preserve existing Android configuration.
- Preserve application source and dependencies.
- Preserve the actual package name.
- Do not overwrite customized application files.
- Avoid unrelated platform scaffolding.
- Do not add a custom HTML application in place of Flutter.

The final web application must use the same production Flutter widgets, content and game engine as Android.

### Required web build

Execute:

```powershell
flutter build web
```

Record the complete output and exit code.

Inspect generated web artifacts, asset manifest and availability of the five production level files and two bundled font families.

A successful build alone is **not** sufficient to establish web runtime acceptance.

### Real browser smoke test

Run the actual Flutter web application in a real browser, preferably installed Chrome on Windows.

Verify at minimum:

- Home screen renders.
- Production fonts and icons render.
- All four Campaign packs are available.
- A real Campaign board opens.
- Tap selection works.
- Four selected tiles enable Submit.
- A correct group can be submitted.
- Actual category title and trivia are shown.
- No material Flutter framework error occurs.
- No production asset fails to load.
- Desktop-width framing is centered and functional.
- Browser storage behaves according to documented capabilities.

Record the browser version, actual invocation, browser-side observations, screenshots if useful, and console or runtime errors.

Web requires initial static-asset loading. Do not claim offline repeat-visit support unless actually tested and supported by the browser's storage and cache behavior.

Do not introduce network services or a backend.

---

## 6. Browser-Executed PRNG Golden Vectors — ENG-11 / PLT-06

This is a **mandatory F6 gate**.

The existing PRNG is defined in:

`lib/core/prng.dart`

It uses Park–Miller with:

- Multiplier: `16807`.
- Modulus: `2147483647`.
- Descending Fisher–Yates shuffle.
- Integer arithmetic intended to remain exact on Dart VM and JavaScript.

The existing oracle is:

`tool/check_prng.dart`

The existing wrapper test is:

`test/core/prng_test.dart`

### Required proof

Execute the actual production `StableRandom` implementation in browser-compiled Dart code.

Prefer a genuine browser test using the installed Chrome test platform, for example:

```powershell
flutter test --platform chrome test/core/prng_test.dart --reporter expanded
```

Verify that this command truly runs the test within Chrome.

If this exact test-runner path is unavailable or incompatible, create a minimal test-only browser harness that compiles and executes the same production PRNG implementation in a real browser.

Do not replace browser execution with Node.js, Dart VM execution, PowerShell simulation or a successful web build.

### Required golden values

Check all existing fixed oracle seeds:

- `1`
- `42`
- `20261028`
- `2147483646`

Compare the actual eight generated values per seed against the fixed expectations in `tool/check_prng.dart`.

Also verify the fixed 16-tile initial shuffle:

```text
11,15,6,0,12,13,1,7,14,8,5,3,9,4,2,10
```

Expected final generator state:

`1470087647`

Use fixed independent expected values rather than comparing two executions of the same potentially defective algorithm.

Preserve the existing VM test and compare its output with the actual browser result.

### Required evidence

Record:

- Browser name/version.
- Actual browser executable or runner.
- Actual command.
- Browser-executed test output.
- Exit code.
- All seed-vector results.
- Shuffle-order result.
- Final PRNG state.
- Any compatibility workaround or limitation.

Do not alter the PRNG algorithm merely to make a browser test pass. If a genuine cross-platform discrepancy exists, diagnose and correct it with focused tests and preserve the previous failing evidence.

**ENG-11 and PLT-06 must not be called PASS based solely on Dart VM output.**

---

## 7. Six Canonical Flutter Screenshots — PLT-07 / UI-12

Create six authentic screenshots under:

`docs/screenshots/`

Use the existing Flutter widget-test capture infrastructure where practical.

The accepted repository already has useful capture patterns in:

- `test/ui/f4_d01_test.dart`
- `test/ui/f4_d02_test.dart`

Reuse these idioms rather than introducing a separate rendering framework.

### Required files and scenarios

| Filename | Exact viewport | Required actual state |
|---|---|---|
| `01_home.png` | 390×844 | Production Home/dashboard |
| `02_board_selected.png` | 390×844 | Four selected tiles, booster controls and Submit dock |
| `03_board_solved.png` | 390×844 | At least two solved groups with their actual category information and facts |
| `04_result.png` | 390×844 | Final victory, stars, awarded coins, facts and red-herring information |
| `05_packs.png` | 390×844 | Real Campaign pack/level selection |
| `06_desktop_frame.png` | 1280×800 | Actual centered mobile game frame on wide desktop viewport |

### Screenshot requirements

- Capture real Flutter widget trees, not mockups.
- Use the production `LexiStackApp` and actual frozen JSON content.
- Use legitimate game/controller transitions to establish selected, solved and finalized states.
- Use deterministic in-memory storage and a fixed clock as appropriate.
- Explicitly load bundled Fraunces, DM Sans and required Flutter icon fonts.
- Use correct font weights and ThemeData.
- Render real tile words, category titles and trivia.
- Preserve the Paper Arcade styling.
- Capture PNG image bytes from a genuine render boundary or equivalent Flutter capture API.
- Verify output dimensions independently.
- Verify the screenshots are not blank, clipped, stale or rendered with missing-glyph boxes.
- Do not fabricate a result screen by manually drawing text onto a bitmap.
- Do not assemble several screenshots into one image and present it as a single application viewport.
- Do not silently crop or resize images to conceal layout defects.

The screenshot-generation test should assert the intended underlying application state before capturing.

For the selected Board, verify exactly four tiles are selected and Submit is actionable.

For the solved Board, verify two categories are solved and their actual facts have been revealed.

For the result screenshot, verify finalized victory, correct star rating, settled reward and accessible red-herring explanations.

If some result details require scrolling, retain the genuine viewport and capture the relevant content honestly. Additional supporting screenshots may be created when needed, but they do not replace the six canonical files.

### Visual inspection

Open and inspect every generated screenshot using available image-viewing tools.

Do not rely only on PNG existence or nonzero file size.

Check:

- Text legibility.
- Proper font rendering.
- Tile spacing and word wrapping.
- Actual viewport dimensions.
- Correct color contrast.
- No unexpected clipping.
- No fake or placeholder content.
- Visible and usable controls.
- Centered desktop frame.
- Consistent branding.

Where a layout problem is found, make the smallest defensible correction, rerun affected tests and regenerate affected captures.

Document any screenshot limitation that could not be resolved.

---

## 8. Android Device and Offline Verification — PLT-02/03/04/08

Android remains the primary target.

Use the established Pixel_10 Android emulator when available.

At the beginning of verification:

- Inspect emulator identity, OS/API and resolution.
- Inspect the installed application state.
- Preserve or back up existing saved progress as appropriate.
- Avoid clearing data, uninstalling the application unnecessarily, or resetting progress.
- Use a disposable emulator profile or snapshot if destructive test scenarios require isolation.
- Distinguish baseline state from newly generated test progress.

### Build and install

Build the current debug APK and install it using the actual Android SDK tools.

Verify the installed package is the intended LexiStack application.

Package ID:

`de.cloudwards.lexistack`

Launch from the genuine Android launcher, not exclusively through `flutter run` or an explicit activity command.

### Required Android gameplay smoke

Exercise real native touch interactions covering:

1. Home and Campaign navigation.
2. All four Campaign pack entries.
3. Opening an actual production board.
4. Tile selection by tap.
5. Additive selection through long-press drag to another tile.
6. Drag to the selection tray.
7. Four-tile Submit.
8. Correct group solve and reveal.
9. Incorrect guess and One Away feedback.
10. Duplicate wrong-guess protection.
11. Paid Pair Magnet and Category Peek.
12. Wallet updates and booster eligibility.
13. Four mistakes reaching `lostPendingDecision`.
14. No automatic solution/trivia spoiler in pending loss.
15. Extra Life rescue when legitimately affordable.
16. Explicit final Reveal/Accept Loss.
17. Finalized result and navigation.
18. Correct reward/statistics behavior.
19. Clipboard-sharing action, where supported.
20. Settings theme and haptic toggle behavior.

Use actual gameplay and real content.

If some scenario cannot be completed on the current save without affecting user data, use an isolated test environment or record the exact limitation. Never silently inject arbitrary progress into the user's saved profile.

### Process-death recovery

Perform a real restart test:

- Establish an unfinished attempt.
- Make a nontrivial selection.
- Purchase an eligible hint.
- Shuffle the board.
- Record wallet, attempt ID and relevant game state.
- Wait for persistence to complete.
- Record the current process ID.
- Stop the app process using Android tools.
- Confirm the process is absent.
- Relaunch via the actual launcher.
- Confirm a new process ID.
- Resume the previous unfinished attempt.
- Verify the same board order, selection, hints, lives, mistakes and wallet.
- Verify no second booster charge, win reward or settlement.

Also verify existing theme/haptic settings survive process death.

Capture before/after screenshots, accessibility hierarchy or equivalent state evidence, commands and exact exit codes.

A warm foreground resume must not be represented as process-death recovery.

### Offline Android verification

Explicitly establish an offline emulator state after APK installation.

Disable available emulator network connectivity in a controlled, reversible way.

With the application offline, verify:

- Cold launcher start can load local assets.
- Home and all Campaign pack metadata are available.
- An actual board loads and can be played.
- A group can be solved.
- Bundled fonts and icons render.
- Daily content is available from the bundled pool.
- Progress persists locally.
- No runtime server or network response is necessary.

Record how offline status was established, the observed results and any exceptions.

Restore the emulator's original connectivity settings afterward.

Do not claim a fully offline test merely because no network command was intentionally issued.

### Startup observations

Record and distinguish:

- First cold launch after installation.
- Later cold launch after force-stop.
- Warm foreground resume.
- Debug-build behavior.
- Release-build behavior if actually tested.

Use Android system logs and observed UI readiness where possible.

Do not invent launch times. Do not label slow emulator tooling as a game defect without evidence.

---

## 9. Release APK, Packaging, Assets and Signing Audit

Attempt:

```powershell
flutter build apk --release
```

Record exact exit code and output.

### Important signing limitation

The accepted Android configuration currently uses the Flutter template's debug signing configuration for release builds.

Inspect the actual Gradle configuration before building.

If a release-mode APK is successfully produced using the debug key, clearly report it as:

**Release-mode compiled, debug-signed verification APK — not a production-signed Play Store release.**

Do not describe it as ready for store publication.

Do not create, request, expose or commit real signing credentials.

Do not add speculative production signing infrastructure merely to make a release build appear commercially distributable.

If a properly signed production release is impossible because no signing configuration exists, document that limitation accurately.

Record release APK size, SHA-256, package ID, version metadata and signing status where tools permit.

### Launcher and web icons

**Known finding:** The current Android launcher icon is still the stock Flutter logo.

The application already contains a custom Paper Arcade `PuzzleMark` in `lib/ui/common.dart`.

Create a restrained, original LexiStack application icon consistent with that existing mark and established palette.

Prefer reusing the existing visual geometry rather than inventing a new brand.

Generate the required static Android density resources and relevant web icons using an appropriate reproducible build-time workflow.

Do not introduce a runtime graphics dependency.

Verify icon legibility at small sizes, appropriate safe-area padding and correct appearance on the Android launcher.

Preserve the accepted in-app Paper Arcade design; this is packaging polish, not a UI redesign.

Record icon provenance and the files generated.

### Fonts and licenses

Inspect the actual bundled font files:

- `assets/fonts/fraunces.ttf`
- `assets/fonts/dmsans.ttf`

Inspect their associated OFL license texts.

Verify both fonts are present in the relevant builds and no runtime font download is required.

Maintain the accepted typography:

- Fraunces: LexiStack wordmark and Home hero only.
- DM Sans: functional UI and all other text.

Do not remove or replace the fonts without a demonstrated defect.

### Packaging audit

Check:

- Android manifests.
- Launcher icon resources.
- App display name and package identifier.
- Version metadata.
- Bundled JSON assets.
- Bundled fonts and licensing.
- Web platform metadata and icons.
- Platform-specific permissions.
- Unintended runtime network requirements.
- Generated artifacts accidentally tracked by Git.
- Debug-only assumptions in release behavior.

Fix only demonstrated issues within the F6 release-candidate scope.

---

## 10. Final Architecture and Maintainability Audit

Inspect the accepted application against the Architecture Contract.

### Required boundaries

**Pure Dart core**

- Game rules.
- Scoring.
- PRNG.
- Daily civil-date arithmetic.
- Share formatter.
- Snapshot validation.

**Application/controller**

- Game transitions.
- Campaign progression.
- Economy and booster charging.
- Exactly-once rewards.
- Daily settlement and streaks.
- Versioned persistence.
- Recovery and write sequencing.

**Infrastructure**

- Preferences storage.
- Asset loading.
- Platform adapters.

**Flutter UI**

- Home.
- Campaign and level selection.
- Board.
- Result and pending loss.
- Statistics.
- Settings.

**External content contract**

- Models.
- Parsing.
- Content diagnostics.
- Strict/partial/candidate validation.

Verify that implementation continues to respect these boundaries.

### Specific regression risks

Inspect and preserve:

- F3-R01 failed-storage-read protection.
- Partial salvage of corrupt or orphaned attempts.
- Genuine permutation checks on restored board IDs.
- Content fingerprint invalidation.
- Serialized asynchronous writes.
- Exactly-once campaign and Daily settlement.
- One-time +5 practice reward cap.
- Independent Campaign pack unlocking.
- F5 Campaign shelf progress refresh.
- Pending-loss spoiler protection.
- Daily date arithmetic across DST.
- Duplicate-guess protection.
- Stable PRNG behavior.
- Drag semantics and persistent Submit dock.

Do not conduct a speculative large refactor.

If no material architectural defect is observed, report that no change was needed.

If a real critical defect is discovered, add a failing regression first where feasible, fix it narrowly and rerun the affected acceptance matrix plus full tests.

Do not introduce new packages without a compelling need.

---

## 11. Complete Regression and Accessibility Pass

After all necessary corrections, execute the full test suite.

**All previously accepted tests must remain passing.** The F5 baseline was 195 tests.

New targeted F6 verification tests may increase the count.

Do not delete, skip, rename away or weaken earlier tests merely to achieve green results.

### Required coverage

- ARC-01–04.
- CNT-01–11.
- ENG-01–12.
- ECO-01–09.
- DAY-01–06.
- PER-01–09.
- UI-01–12.
- PLT-01–08 where applicable.

Include:

- Two-fresh-instance rule oracle.
- Strict production catalog checks.
- All 40 intended-group solves.
- Cross-pack progression.
- Replay/coins/reward protections.
- Daily and streak regressions.
- Savegame corruption and compatibility.
- F3-R01.
- Paper Arcade typography and accessibility.
- Native clipboard and haptic behavior.
- Reduced-motion handling.
- Browser-executed PRNG.
- Android offline and restart evidence.

### Layout matrix

Run real-app widget checks at:

- 360×640 with 1.3× text scaling.
- 390×844.
- 1280×800 with centered maxWidth 460.

Check both light and dark appearances.

Verify:

- No framework overflow.
- Essential controls remain reachable.
- Minimum interaction target approximately 48×48 logical pixels.
- Normal text contrast targets 4.5:1.
- Accessible tile and action semantics.
- No category identification relying on color alone.
- No essential content permanently hidden by the Submit dock.
- Correct display of long real production tile/category titles.

Actual screenshots must support, not replace, executable layout checks.

---

## 12. Final README and Documentation Accuracy

The current README contains some historical statements from earlier phases.

Update it to describe the actual F6 release candidate.

In particular, correct:

- The previous reference to only eight Campaign levels.
- The installed full catalog totals.
- Current F5 acceptance status.
- Actual Fraunces/DM Sans bundled font usage and licenses.
- Android and web build commands.
- Browser PRNG verification method.
- Actual release APK and signing limitations.
- Genuine offline Android support.
- Browser offline/cache limitations.
- Final screenshot locations.
- Reproducible Windows verification instructions.

Keep the README concise and useful for a solo developer.

Do not rewrite historical gate records.

Do not claim F6 PASS in documentation before independent review.

---

## 13. Required Evidence and Final Command Matrix

Create the main F6 evidence index:

`docs/evidence/f6/README.md`

Retain concise underlying logs and genuine captures under:

`docs/evidence/f6/`

Store the six canonical product screenshots separately in:

`docs/screenshots/`

### Required final commands

Record literal command lines, start/end times where possible, stdout/stderr and actual exit codes for:

```powershell
flutter pub get
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build web
flutter build apk --debug
flutter build apk --release
```

Also record the successful or attempted browser-compiled PRNG test and actual Android smoke commands.

The release APK build must be attempted when the environment supports it; if an environment or signing issue prevents completion, identify the precise blocker.

Only run `flutter build windows` if `flutter doctor -v` confirms an available Windows desktop C++ toolchain. Its absence is not an Android release blocker.

### Mandatory final source identities

Verify that these exact production Git blobs are unchanged:

| Asset | Git blob SHA-1 |
|---|---|
| `manifest.json` | `6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d` |
| `pack1.json` | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `pack2.json` | `32ca5e922e3da3e2b22a42716de87a63e53492f8` |
| `pack3.json` | `fc88352362ea575e7c0f38670b0c7e81c24ec070` |
| `pack4.json` | `54c09ae4c2f0a5d07b95addc42e80eacac33d2c6` |
| `daily.json` | `5ab06b73921c4a9992e6c9fe8c099ba4e2a2e6` |

If any file hash differs, investigate before continuing. The authoritative table is `docs/reference-content-lock.md`; do not use a transcribed prompt value to override it.

The Content Contract pin must remain:

`d9acbd52de0e198dd109a4859299318db3f465f5`

### Evidence integrity

Retain:

- Initial failed commands.
- Corrections and reruns.
- Final successful commands.
- Actual test totals.
- Browser execution logs.
- Android commands and process IDs.
- Offline status evidence.
- Before/after persistence observations.
- Genuine screenshots.
- APK hashes and signing classification.
- Platform/compiler warnings.
- Known unresolved issues.

Classify failures as:

- Application defect.
- Agent/tool coordination.
- External environment/toolchain.
- Unclassified when evidence is insufficient.

Do not erase unsuccessful attempts from the history.

---

## 14. Final Experiment E Audit Readiness

The ultimate comparison will cover:

**C — LexiStack3 / Codex One-Shot**

`8b84f2d6c75cb807fba9db19cba707f963e02020`

**D — LexiStack4 / Claude Code One-Shot**

`9029748`

**E — LexiStack5 / Codex Six-Phase Sequence**

The final accepted F6 commit, to be determined after independent review.

The existing `docs/experiment-e-protocol.md` defines the technical 100-point scorecard:

| Dimension | Weight |
|---|---:|
| Engine, Scoring & Economy | 25 |
| Architecture & Maintainability | 20 |
| Persistence & Recovery | 15 |
| UX & Accessibility | 15 |
| Automated Verification | 15 |
| Android & Web Verification | 10 |
| **Total** | **100** |

### Your responsibility

Prepare sufficient reproducible evidence for an independent reviewer to evaluate the scorecard.

You may produce a factual engineering self-audit and list remaining concerns.

Do **not**:

- Award yourself an independent score.
- Declare the overall Experiment E winner.
- Modify the historical C/D repositories.
- Copy C/D application source or tests into E.
- Rewrite past outcomes or intervention histories.
- Treat additional test counts as proof of superior product quality.

The independent reviewer will perform the actual C/D/E comparative assessment, including applicable baseline reproduction on the same Windows toolchain.

Include a short independent-review handoff identifying:

- Final candidate SHA.
- Acceptance IDs and evidence references.
- Commands the reviewer can reproduce.
- Unverified or environment-blocked probes.
- Material architecture changes, if any.
- Residual technical risks.
- Known scope limitations.
- The six canonical screenshot paths.

Keep editorial Content Studio evaluation separate.

---

## 15. Gate Log and Intervention Tracking

Append an F6 implementation section to:

`docs/gate-log.md`

Mark the decision:

**PENDING independent review**

The section should identify:

- Starting accepted F5 commit.
- F6 implementation branch.
- Main implementation checkpoint(s).
- Final submission commit.
- Toolchain versions.
- Prompt identity.
- Actual commands and exits.
- Browser PRNG result.
- Android and offline observations.
- Canonical screenshot evidence.
- Build/signing results.
- Defects and corrective changes.
- Agent/tooling issues.
- Human intervention count.
- Remaining limitations.

Record any correction performed inside the autonomous F6 run as an internal self-correction, not as a later human-requested corrective run.

Preserve all previous F1–F5 acceptance and correction history.

Do not edit the established experimental scoring methodology.

---

## 16. Final Git Workflow

Complete all F6 work on:

`codex/f6-android-release-candidate`

Make coherent commits for implementation, packaging, tests, screenshots and evidence.

Before publication:

1. Run final verification on the final source state.
2. Verify all required outputs.
3. Confirm frozen content hashes and dependency pin.
4. Check the complete source/documentation diff.
5. Check Git whitespace and line endings.
6. Ensure no generated build directories, APK binaries, emulator data, credentials, signing keys or caches are tracked.
7. Confirm the accepted starting main remains an ancestor.
8. Ensure the working tree is clean.
9. Confirm only expected F6 files changed.

Push the finished F6 branch to `origin`.

Confirm local and remote feature-branch SHAs match.

Confirm `main` remains unchanged at:

`9aec6c82f5fd2e5d86ed4a98dcdf3e799c9ac873`

**Do not merge to main. Do not force-push or rewrite history.**

Stop after publishing the completed feature branch.

---

## 17. Required Final Response

Deliver a concise, evidence-based report with these sections.

### 1. Implementation status

Complete / Partial / Blocked.

Starting commit, feature branch, final SHA, Git publication and worktree status.

### 2. Platform readiness

Actual Android and web support, packaging changes, icon changes and signing limitations.

### 3. Browser PRNG verification

Exact browser, test method, golden vectors, observed results and exit code.

### 4. Canonical screenshots

All six paths, exact dimensions, capture method, visually verified states and any limitations.

### 5. Android verification

Emulator identity, cold/warm startup, real gameplay, paid boosters, pending loss/rescue, process-death restore and offline gameplay.

### 6. Complete verification matrix

Literal final commands, exit codes, total passing tests, strict validator status, analyzer, web build, debug/release APK builds and asset identities.

### 7. Architecture and regressions

Actual defects discovered, targeted fixes, new tests, unchanged accepted behavior and remaining risks.

### 8. Experiment evidence

Model/version/effort if available, timestamps, tool problems, autonomous self-corrections and human interventions.

### 9. Independent-review handoff

Evidence index, acceptance coverage and any genuinely unresolved or blocked gate requirements.

**The implementing agent must not declare F6 PASS.**

---

## Final Instruction

**Start F6 implementation and verification now.**

Work autonomously through all authorized checkpoints.

Prioritize actual runnable evidence over speculative documentation.

Do not fabricate browser or Android results.

Do not change the frozen benchmark catalog or established game rules.

Do not implement post-experiment Content Studio functionality.

Publish only `codex/f6-android-release-candidate`.

Leave `main` unchanged.

**Stop after the final implementation report and await independent F6 review.**