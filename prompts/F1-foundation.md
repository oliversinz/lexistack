CS0 has been completed and independently reviewed. The Content Studio contract is published and approved for the F1 dependency.

Repository: https://github.com/oliversinz/lexistack-content.git

Immutable commit: d9acbd52de0e198dd109a4859299318db3f465f5

Package path: packages/lexistack_content_contract

Core import: package:lexistack_content_contract/lexistack_content_contract.dart

CLI import: package:lexistack_content_contract/cli.dart

Use this exact Git commit for the F1 dependency. Verify that `flutter pub get` resolves it successfully and commit the resulting lockfile.

The CS0 tests (72 passing), analysis and reference-catalog strict validation were reported successful by the implementing agent. They have not been independently rerun. Verify all required F1 acceptance checks with actual command output.

Proceed with F1 only, following the existing F1-foundation.md and repository contracts. Do not implement F2.

# LexiStack5 — Codex Feature Run F1: Foundation & Android Baseline

**Status:** PREPARED DRAFT; **DO NOT EXECUTE UNTIL P0 IS COMPLETE.** This is a single autonomous F1 implementation task only, not an instruction to build LexiStack5 in one shot. English agent prompt for the future new `LexiStack5` repository on Windows.

## Objective and authority

Act as a senior Flutter/Dart engineer and autonomous coding executor. Deliver **F1 — Foundation & Android Baseline** from `docs/feature-roadmap.md`, satisfying F1 acceptance IDs in `docs/acceptance-matrix.md` and leaving the repository usable by the next F2 run.

Before changing any code read, in order, `AGENTS.md`, `docs/product-contract.md`, `docs/architecture.md`, `docs/feature-roadmap.md`, `docs/acceptance-matrix.md`, `docs/reference-content-lock.md`, and `docs/experiment-e-protocol.md`. The **product contract defines the final game**; F1 only implements the explicitly scoped first phase. Do not start F2 or produce fake complete gameplay.

## Hard P0 preflight — stop if unmet

Confirm before implementation:

1. You are in the intended new LexiStack5 repository; `git status --short` is understood and clean or its existing modifications accounted for. Do not create another repo.
2. The actual Content Studio Git repository exists with a resolvable **pure-Dart** `packages/lexistack_content_contract` package. Its exact URL and **full immutable commit SHA** are supplied through the repo's agreed P0 configuration; do not invent values or substitute a mutable branch. Resolve with `flutter pub get` and verify the package's tests when feasible.
3. The frozen source for benchmark JSON is accessible at `oliversinz/LexiStack3` commit `8b84f2d6c75cb807fba9db19cba707f963e02020`, and its `pack1.json` Git blob matches `reference-content-lock.md`. Do not inspect or copy source code from that app.
4. Windows Flutter, Dart, Android SDK and an emulator are installed or their missing capabilities are recorded accurately. An unavailable emulator is an environment blocker for launcher evidence, **not** permission to invent a smoke test.

If **either** the contract package URL/commit or the reference file provenance cannot be verified, report the exact blocker and leave the task as **BLOCKED BY P0** without creating a duplicate/fallback validator. Do not ask unnecessary questions about requirements already settled by the contracts.

## F1 implementation scope

- Inspect `flutter --version`, `dart --version`, `flutter doctor -v`, Git state and available Android emulators; record actual versions and toolchain limitations.
- Scaffold a genuine Flutter application with Dart 3 and internal package name `lexistack`, Android as primary target. Do not add backend, cloud services, runtime content fetching, audio, advertising or payments.
- Create an idiomatic small app shell with real Home/entry navigation, a consistent theme and bundled or SDK fonts. It may show the loaded pack/level metadata but must not pretend to be a finished Board or economy system.
- Wire the pinned `lexistack_content_contract` Dart package, **without forking its parser or validator logic**, into a minimal asset catalog loader. Import only the exact frozen `pack1.json` required by this phase, and use a truthful *partial manifest*, e.g. `{ "campaign": ["pack1.json"] }` while Daily is absent; reserve the source's exact final manifest including Daily for F5.
- Add the minimal Windows-compatible `tool/validate_levels.dart` wrapper, supporting strict, partial and candidate modes. During F1 `--partial` should pass and strict should correctly fail because the production content is intentionally incomplete.
- Create only the minimal modular source/test layout justified by actual F1 code, preserving the future pure-Dart core/app/UI boundaries without placeholder files for features not yet implemented.
- Add meaningful parser/content and actual-app widget tests for F1; verify real pack metadata reaches the UI. Include negative tests showing malformed assets cause actionable diagnostics.
- Build a debug APK and verify starting the app from the Android emulator **launcher**, not solely via `flutter run`. Capture a real screenshot, emulator identity and logs. If first cold start is slow, record observed cold and warm behavior rather than impose an arbitrary timeout or claim it was fixed without evidence.
- Write a short practical README containing real local commands, troubleshooting notes and currently available features. No giant spec duplicate or fabricated completeness claims.

## Required verification and artifact integrity

Use actual commands and keep outputs/exit codes for at least:

```powershell
flutter --version
dart --version
flutter doctor -v
git status --short
flutter pub get
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test
flutter build apk --debug
```

**Expected:** strict content validation fails during F1 because the catalog is incomplete; report it as an expected incomplete-phase condition, not a successful final validation. If a command fails unexpectedly, identify the cause, correct in-scope defects, rerun and report final and relevant initial failures. Never mask exit codes.

Use real platform evidence for an emulator smoke test if available; otherwise distinguish `APK compiled` from `Android launcher verified`. Do not claim that F1 verifies the final six-screen product, 40 levels, production economy, full persist/recovery or Daily mode.

## Version control and autonomy

Operate as one self-contained autonomous **F1 run**. Make meaningful local commits and return the exact final Git SHA and worktree state. No push, force-push, history rewrite, or edits to other repositories. Do not alter contracts, modify frozen benchmark JSON, copy LexiStack3/4 Flutter code, or start F2. If a true P0 dependency is missing, report the blocker without inventing a substitute.

## End-of-run report

Return concise evidence covering F1 scope/deliverables; code boundaries and package commit; actual environment versions; `--partial` success versus expected strict non-success; analyzer/test/APK exit codes and test counts; launcher behavior with screenshot evidence; commit SHA/status; unresolved issues, interventions and environment blockers. The **independent reviewer** will apply gate F1 (ARC-01–04, CNT-01–04, UI-01, PLT-01–02); do not self-declare the gate accepted.
