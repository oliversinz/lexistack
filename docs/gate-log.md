# Experiment E gate log

## F1 — Foundation & Android baseline

**Independent reviewer decision: PASS, 2026-10-28.** This later decision was
externally communicated in the supplied F2 execution prompt, linked to F1 final
commit [`0db340691267896f636daa8fcc92b9edeb7a13c6`](https://github.com/oliversinz/lexistack/commit/0db340691267896f636daa8fcc92b9edeb7a13c6).
It is not an implementing-agent self-awarded pass. The original run evidence
below is preserved, including its then-pending review status.
Scope submitted: **ARC-01–04, CNT-01–04, UI-01, PLT-01–02**. At the end of that
original run, F2 had not started.

Run: 2026-10-28, approximately 15:53–16:15 Europe/Berlin (UTC+01:00).
Agent: Codex / GPT-6; exact model build and reasoning setting were not exposed.
Initial commit: `8e81147a15ab1c28f4486deab7b96343227e08d3`, clean `main`,
matching fetched `origin/main`. Implementation and tests:
**`158f19d565fa5660223acc94a04953d74856d9fa`**. The following evidence-only
commit adds this log, raw outputs and screenshots without changing that source.
Implementation used `codex/f1-foundation`; integration is local fast-forward
only. No push or history rewrite. Final SHA and status are in the run's final
chat report.

Prompt identity: the user's CS0 handoff and full F1 request in this chat on
2026-10-28. The seed references `prompts/F1-foundation.md`, but neither it nor
the prompts directory exists. The supplied prompt was used; no file hash is
claimed for that absent file. Contracts and the original planning checksum
file remain unchanged. The roadmap's F1 summary omits CNT-02/04; both were
verified because the acceptance matrix and current request include them.

### Deliverable and provenance

Genuine Flutter application `lexistack`, Android ID `de.cloudwards.lexistack`.
Home opens the installed collection and all eight real level metadata entries.
The UI explicitly identifies the preview and does not expose fake gameplay,
coins, progression, saves or Daily. SDK typography/icons, local assets and
a small Material theme require no font downloads or additional runtime packages.

The shared package owns pure Dart models, parsing and validation. The app has
an asset adapter in `lib/infrastructure`, a `ChangeNotifier` loading controller
in `lib/app`, and widgets/theme in `lib/ui`. No engine or empty future-feature
modules were created. The seven-line Dart CLI delegates to the shared CLI.
Source/dependency inspection found no Flutter imports in the content package,
no external runtime dependencies in that package, and no runtime network,
backend, analytics, ads, payments or audio in the app. Flutter's generated
debug/profile Internet permission is retained for development tooling.

Pinned Git URL: `https://github.com/oliversinz/lexistack-content.git`, commit
**`d9acbd52de0e198dd109a4859299318db3f465f5`**, package path
`packages/lexistack_content_contract`. `pubspec.lock` records that exact
`resolved-ref`; the resolved cache checkout's HEAD was also checked.

The six JSON files were retrieved via the GitHub connector from LexiStack3
commit `8b84f2d6c75cb807fba9db19cba707f963e02020`. All raw Git blob hashes
match the reference lock. Full-reference P0 validation used temporary files
under `.git/f1-reference`; **only pack1** is installed in `assets/levels`.
Its working-file and staged blob are both
`5efa3c88c769f74eee872860766681f5c2cc1c64`. The manifest lists only pack1,
without Daily. No LexiStack3/4 application source was inspected or copied.
CS0 was tested in a temporary copy of the resolved package under this repo's
`.git/f1-contract-test`; no other source repository was edited.

### Actual commands and results

Timestamped commands, working directories, stdout/stderr and exit codes are in
[evidence/f1](evidence/f1). Only line endings and trailing whitespace were
normalized for Git; output text and exit codes are retained. All commands
below ran in PowerShell; paths beginning
`.git` are local verification scratch data, not shipped application content.

| Command | Exit | Evidence / observation |
|---|---:|---|
| `flutter --version` | 0 | `flutter-version.txt`: Flutter 3.47.8 stable, framework 737ba8f885, engine cf636b1dfb |
| `dart --version` | 0 | `dart-version.txt`: Dart 3.13.7 windows_x64 |
| `flutter doctor -v` | 0 | `flutter-doctor.txt`: Android ready; Visual Studio missing |
| `git status --short` (P0) | 0 | `p0-status.txt`: empty |
| `flutter emulators` | 0 | `emulators.txt`: Pixel_10 |
| `flutter emulators --launch Pixel_10` | 0 | `emulator-start.txt` |
| `flutter pub get` (scratch preflight, then app) | 0 / 0 | `p0-pub-get.txt`, `pub-get.txt`: exact Git dependency resolves |
| `dart pub get` (CS0 copy) | 0 | `cs0-pub-get.txt` |
| `dart analyze` (CS0 copy) | 0 | `cs0-analysis.txt`: no issues |
| `dart test --reporter expanded` (CS0 copy) | 0 | `cs0-tests.txt`: **72 passed** |
| `dart run validate_reference.dart` (P0 scratch) | 0 | `p0-reference-strict.txt`: **40 levels, 160 groups, 640 positions; 0 errors/warnings** |
| `git hash-object --no-filters ...` (six reference files) | 0 | `p0-reference-hashes.txt`: exact filenames and all locked blobs |
| `flutter create --project-name lexistack --platforms android --org de.cloudwards --no-pub .` | 0 | `scaffold.txt` |
| `dart run tool/validate_levels.dart --partial` | 0 | `partial.txt`: **8 levels, 32 groups, 128 positions; 0 errors/warnings** |
| `dart run tool/validate_levels.dart` | **1 expected** | `strict.txt`: campaign count 1 < 4 and absent Daily; **not final validation success** |
| `dart run tool/validate_levels.dart assets/levels/pack1.json` | 0 | `candidate-replacement.txt`: REPLACEMENT preview |
| `dart run tool/validate_levels.dart .git/f1-reference/pack2.json` | 0 | `candidate-addition.txt`: ADDITION preview; pack2 not installed |
| `dart analyze` (app, final) | 0 | `analysis.txt`: no issues |
| `flutter test --reporter expanded` (app, final) | 0 | `tests.txt`: **25 passed** |
| `flutter build apk --debug` (final) | 0 | `apk-debug.txt`: APK built, Gradle task 32.3 s |
| `git hash-object --no-filters assets/levels/pack1.json` (after candidate probes) | 0 | `final-asset-identity.txt`: locked blob unchanged |
| `git diff --cached --check` | 0 | `final-diff-check.txt` |

The P0 reference script only calls `runValidatorCli([], assetsDirectory:
'../f1-reference')` and returns its exit code. It is not a second validator.
App tests exercise production assets through the actual Flutter asset bundle,
schema/IDs/tiers/tiles/trivia/red-herring mutations, malformed JSON locations,
missing files, candidate behavior/cross-file duplicates, actual app navigation,
retry recovery, and 360×640, 390×844 and 1280×800 layouts at 1.3× text scaling.
They do not claim to test later-phase gameplay. No browser runtime or web build
was run in F1; desktop-size evidence is a widget test.

### Android observation

Host: Windows 11 Home **10.0.26300.9711**, PowerShell **7.6.5**, Git
**2.55.0.windows.1**. SDK/build-tools **36.1.0**, emulator **37.2.12.0**,
ADB **37.0.1-15733141**; Android Studio OpenJDK **25.0.3**. Gradle **9.3.1**,
Android Gradle plugin **9.1.0**. AVD **Pixel_10**, serial **emulator-5554**,
Android **16 / API 36.1**, x86_64, 1080×2424 pixels, 420 dpi. See doctor,
`emulator-identity.txt`, `android-avd.txt`, `adb-version.txt` and host logs.

Installed the built APK with `adb install -r` (exit 0), pressed Home, swiped
open the app drawer, and tapped the observed **LexiStack** icon at (412, 1100).
`launcher-logcat.txt` records MAIN + LAUNCHER from
`com.google.android.apps.nexuslauncher`, not `flutter run` or an `am start`.
The cold launch began at emulator time **16:07:44.021**; Android reported
Displayed/Fully drawn at **16:07:49.328**, duration **5.360 s**. The immediate
capture still showed the launcher; the later capture showed the loaded Home.
No timeout or source workaround was applied.

Tapped Explore collection, then Table Talk: real metadata rendered on-device.
Pressed Home and tapped the launcher icon again at **16:08:56.467**. The first
subsequent capture showed the same level-details screen; PID stayed **7281**.
This is a warm resume, not process-death persistence proof. No independent
warm timing measurement or release-startup claim is made. No app crash appeared
in the captured AndroidRuntime/Flutter log. All ADB operations and exits are
retained in `android-commands.txt`.

Visually inspected, unedited emulator screenshots:
[launcher](screenshots/f1-launcher.png),
[immediate cold capture](screenshots/f1-cold-immediate.png),
[loaded Home](screenshots/f1-home-cold.png),
[collection](screenshots/f1-pack.png),
[level](screenshots/f1-level.png),
[warm return](screenshots/f1-level-warm.png).
These are F1 evidence, not the six required F6 product states.
APK SHA-256: `9477F86BB80CA6A522DA50774ABBB7DEA01C6DD8F034FA089A1A4ED0B64BE93C`.
The generated APK and build caches are ignored, not committed.

### Corrections, limitations and interventions

- Initial analysis (exit 3), test compilation (exit 1) and APK build (exit 1)
  found the adapter's missing `FlutterError` import. Added the foundation import;
  removed an unnecessary test import. Initial failure outputs are retained.
- First compiled test run: 19 passed, 6 failed. Test code wrongly assumed one
  syntax diagnostic and offscreen lazy-list children were already mounted.
  Corrected diagnostic selection and actual scroll/pump actions. Next run:
  24 passed, 1 failed because SelectableText added another scrollable. Targeted
  the page scrollable; final run: 25 passed. Production parser was not changed.
- One patch call rejected a combined delete/add of the same scaffold file;
  reapplied as separate operations. An initial Git wildcard hash invocation and
  one PowerShell XML extraction failed; explicit file paths and correct XML
  extraction succeeded. These were agent tooling errors, not app failures.
- Java native-access warnings were emitted during Gradle builds; build succeeded.
  Windows desktop compilation is unavailable because Visual Studio is absent.
  No required Android test remained environment-blocked.
- **Human interventions during execution: 0.** No requirements, acceptance
  criteria or immutable JSON were altered. No unresolved F1 app defect was
  observed. Independent review is still required; no F1 PASS is self-awarded.

Also noticed: the seed's `CHECKSUMS.sha256` lists absent prompt files and the
old planning README. It remains the original seed record; it is not a current
application checksum manifest.

## F2 — Pure-Dart engine and playable Android vertical slice

**Independent reviewer decision: PASS, 2026-10-28.**
Accepted implementation/evidence commit:
[`0f3640d3cea8bd4553314d833d9ea939652aba1e`](https://github.com/oliversinz/lexistack/commit/0f3640d3cea8bd4553314d833d9ea939652aba1e).
This independent decision was communicated by the user after review; it is not
an implementing-agent self-awarded pass.

Verified scope: **ENG-01–10, ENG-11 VM portion, ENG-12 formatter portion,
UI-02 and PLT-03**. Review basis: GitHub source inspection, versioned command
evidence, Android screenshots and gesture logs, plus independent mathematical
verification of PRNG golden vectors. Flutter tests/builds were **not
independently rerun by the reviewer**.

No blocking defects or corrective run required. Browser PRNG execution remains
F6; clipboard integration remains F4. Minor UI grammar/polish findings may be
addressed in F4. F3 has not started.

### Original implementation record

The evidence below is preserved as a historical record. Its pending-review
status and Git-state statements describe the implementation run before this
acceptance and subsequent publication/integration.

**Reviewer decision: PENDING independent review. Implementation complete.**
F3 has not started. No push, merge, history rewrite, wallet or persistence.

Run: 2026-10-28, Europe/Berlin. Branch created at 16:37:32; Android verification
continued through approximately 17:03. Initial inspection/contract reading
preceded the retained command logs. Agent: Codex / GPT-6; exact model build and
reasoning setting were not exposed. Human interventions: **0**.

Starting F1 SHA: `0db340691267896f636daa8fcc92b9edeb7a13c6`, matching fetched
`origin/main`. Working branch: **`codex/f2-engine-vertical-slice`**.
Implementation commit: **`08e261ce7ec6dc819a4e735a17595689aa128cff`**.
The following evidence-only commit completes this record; its full SHA and
final clean status are reported in the final chat response. Main stays at F1.

### Deliverable and provenance

`lib/core/game.dart` encapsulates one attempt with typed outcomes, stable shared
`Tile.id` identities, ordered evaluated history, wrong-set signatures, combos,
four statuses and terminal mutation guards. `prng.dart`, `scoring.dart` and
`share.dart` provide deterministic shuffle, lifetime-mistake stars and the
contract-exact finalized-only campaign/Daily formatter. Core imports no Flutter,
I/O, storage or platform APIs. No dependencies were added.

The catalog controller retains a `BoardController` per visited level. This small
`ChangeNotifier` translates engine outcomes into feedback; the UI never writes
engine state. Home → collection → details → Play resumes the same in-memory
attempt, including pending/final results. New attempt/replay is explicit;
replacing an unfinished attempt has a confirmation. The eight installed levels
are labelled preview play; nothing claims durable progress or unlocks.

`LongPressDraggable<String>` and `DragTarget<String>` send source/target IDs to
the additive domain transition. Tap uses the same selection rules, and release
does not perform another toggle. All three deterministic hint effects are
labelled **F2 preview: no coins**. Pending loss hides unsolved solutions and
even previously peeked titles; rescue preserves order, selection and history.

PRNG: Park–Miller `state * 16807 % 2147483647`, seed range 1…2147483646;
all intermediate values are exact integers below 2^46. Descending Fisher–Yates
uses `next() % (i + 1)`. Initial F2 seed **20261028**, source indexes
**11,15,6,0,12,13,1,7,14,8,5,3,9,4,2,10**, final RNG state **1470087647**.
Four fixed-seed vectors and this board order were calculated separately with
PowerShell BigInteger, then checked by a direct Dart VM probe and the tests.
The Android starting board visibly matches the documented order.

Exact supplied F2 prompt: [prompts/F2-engine-vertical-slice.md](../prompts/F2-engine-vertical-slice.md).
SHA-256: **`B85EE92F70BBC9ABA785FC3DD5F61A21D251AB8CC477B7A73DF74E52F1419795`**.
Working bytes and committed Git blob match. `.gitattributes` disables newline
conversion for archived prompts. Both supplied, previously untracked F1/F2
prompt files were archived unchanged; the newly supplied F1 file is not a
retroactive claim that F1 originally ran from that file.

`pubspec.yaml` and `pubspec.lock` are unchanged. The resolved package cache HEAD
is **`d9acbd52de0e198dd109a4859299318db3f465f5`** at the existing
`lexistack-content.git` / `packages/lexistack_content_contract` pin.
`pack1.json` remains blob **`5efa3c88c769f74eee872860766681f5c2cc1c64`**.
Manifest, benchmark JSON, product/architecture/roadmap/acceptance/content-lock
documents and other repositories were not changed. Experiment E's repository
locator was corrected as authorized; C/D history is preserved.

### Commands and coverage

Raw commands, stdout/stderr and native exit codes are in [evidence/f2](evidence/f2).
Text-log line endings/trailing whitespace are normalized for Git; screenshots
are unedited device captures. The Android logging gap described below is not
represented as a complete command transcript.

| Command | Exit | Evidence/result |
|---|---:|---|
| `flutter doctor -v` | 0 | `doctor.txt`: Flutter 3.47.8, Dart 3.13.7, SDK 36.1.0; Windows 11 10.0.26300.9711; Visual Studio absent |
| `flutter emulators --launch Pixel_10` | 0 | `emulator-start.txt` |
| `flutter test --reporter expanded` before implementation | 0 | `baseline-tests.txt`: all **25 F1 tests** pass |
| `flutter pub get` | 0 | `pub-get.txt`; pin/lock unchanged |
| `dart run tool/validate_levels.dart --partial` | 0 | `partial.txt`: 8 levels / 32 groups / 128 tile positions, zero errors/warnings |
| `dart run tool/validate_levels.dart` | **1 expected** | `strict.txt`: one campaign pack and missing Daily; full catalog is not passing |
| `docs/evidence/f2/prng-oracle.ps1` | 0 | `prng-oracle.txt`: independent BigInteger calculation |
| `dart run tool/check_prng.dart` | 0 | `prng-vm.txt`: four fixed vectors plus board order |
| `dart analyze` final | 0 | `analysis-final.txt`: **No issues found** |
| `flutter test --reporter expanded` final | 0 | `tests-final.txt`: **47 passed** (25 F1 + 14 core + 8 actual-app workflows) |
| `flutter build apk --debug` final | 0 | `apk-final.txt`: Gradle 11.4 s; first build also succeeded |
| `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` | 0 | `android-commands.txt`: final APK installed; first install also succeeded |
| `git diff --cached --check` | 0 | Checked before source and evidence commits |

Observed F2 probes pass: **ENG-01–10**, **ENG-11 VM portion**, **ENG-12 pure
formatter portion**, **UI-02**, **PLT-03**. This is implementation evidence,
not the independent gate decision. **ENG-11 browser execution remains F6;
ENG-12 clipboard integration remains F4.** No remaining failed or environment-
blocked F2 probe. F3 economy/recovery/Daily acceptance is not yet applicable.

Tests include the required separate fresh-instance planet/metal oracle;
full-state comparisons on illegal/duplicate actions; drag cap and ordering;
terminal idempotence; pair targeting/peek order and no-eligible rejection;
same-attempt rescue, mistakes-based stars after restores; exact share strings;
and intended-group solutions for all eight real installed levels. Actual-app
tests use installed pack1 bytes, exercise navigation, taps, both drag targets,
peek/pair effects, real title/trivia, win, pending navigation/rescue/reveal and
explicit replay. Layouts 360×640, 390×844 and centered 1280×800 at 1.3× text
complete those flows without framework overflow; tile targets are ≥48×48.

### Android observations

Pixel_10, serial `emulator-5554`, Android **16 / API 36**, x86_64,
1080×2424, 420 dpi. Both APK versions were opened by tapping LexiStack in the
real Android launcher, not `flutter run`. Logcat records MAIN/LAUNCHER from
`com.google.android.apps.nexuslauncher`: first launch 16:47:54, fully drawn
**5.304 s**; final-APK launch 16:55:52, fully drawn **4.893 s**. Reinstallation
stopped the prior process; the corresponding “app died, no saved state” entry
is at APK replacement, not an observed gameplay crash. No Flutter exception or
AndroidRuntime crash appears in the captured filtered log.

Observed device sequence:

- Home → collection → Table Talk → Play. Actual initial order matches the
  default-seed reference; no solutions disclosed.
- Native pointer DOWN, 700 ms hold, MOVE, UP from VOLLEY to PEARL selects both;
  DEUCE to tray adds the third. Both were repeated on the final APK. No release
  toggling or extra life loss. `input touchscreen draganddrop` alone initially
  produced no selection change; the held pointer sequence succeeded.
- Four touch taps solve BREAKFAST BAKES and reveal its exact fact. The first APK
  was played through all four groups to a zero-mistake, three-star win. The
  final APK repeated the correct solve after one wrong guess, preserving three
  lives. Between builds only two-word tile layout and duplicate semantics were
  refined; the engine was unchanged.
- On the final APK, TOAST/WAFFLE/MUFFIN/FORK gives One Away; repeating it shows
  Already guessed with three lives. TOAST/WAFFLE/FORK/SPOON gives normal
  mismatch. Two further distinct wrong sets reach zero lives, with no solutions.
- Navigating back and reopening still shows pending loss. Rescue returns the
  same board and retained WAFFLE/SPOON/LOVE/PAPER selection at one life and four
  mistakes. A fifth wrong guess returns to pending; explicit Reveal/Accept Loss
  alone reveals all four categories, facts and red-herring text. Replay then
  starts a separate fresh attempt.

Selected inspected, unedited captures:
[final drag](evidence/f2/android-final-drags.png),
[selected correct set](evidence/f2/android-final-selected-correct.png),
[final solved group](evidence/f2/android-final-solved.png),
[full win](evidence/f2/android-win.png),
[pending loss](evidence/f2/android-pending-loss.png),
[rescued attempt](evidence/f2/android-rescue.png),
[final reveal](evidence/f2/android-final-reveal.png),
[red-herring section](evidence/f2/android-red-herrings.png).
Original screenshots and selected accessibility XML snapshots are also retained.
Booster Pair/Peek and all eight levels were tested in Dart/widgets; these two
booster buttons and levels 2–8 were **not** individually played on Android.
No browser runtime, process-restart persistence or clipboard operation is claimed.
Final APK SHA-256: **`FE3684EF831EEC71A993F53A6FC54755BB04CB80FF0D973A56DA253FD39BBE1B`**.

### Corrections and limits

- First core run: 13 passed, 1 failed. The synthetic red-herring oracle called
  OAK “unused” although a wrong row included it. Changed that test-only decoy
  to WHITE; production prioritization and frozen content were unchanged.
- First combined run: 45 passed, 2 failed. The enlarged-mobile test helper
  tried to ensure visibility of a lazily unbuilt Play button. Added actual
  scrolling before the tap; all three layout workflows then passed. No layout
  exception was reported. One patch failed to match a formatter-adjusted line
  and was reapplied; no partial source edit was lost.
- Intermediate analysis exited 0 with three informational tool-script lints.
  Changed its import to `package:` and explicitly allowed CLI printing.
  Final analysis has zero issues. Android XML also exposed duplicate empty tap
  semantics; excluded the inner gesture detector from semantics. Two-word tile
  phrases now use separate whole-word lines for legibility.
- During Android startup, an immediate UI dump returned a null root while the
  app was loading; a later dump succeeded. One screenshot command hit a
  PowerShell `-p` parameter ambiguity. Explicit argument arrays corrected it.
- A diagnostic wrapper consumed logcat `-d` as PowerShell's `Debug` parameter,
  leaving a streaming logcat process holding the evidence file. Concurrent
  commands around the first two final-APK wrong guesses emitted file-lock
  errors; their raw transcript is incomplete. Inspected the actual process
  command line, stopped only that logcat process (PID 37624), then reran the
  bounded capture with an explicit argument array. The One Away and duplicate
  operations were repeated with logging working; pending/rescue/reveal and the
  final correct solve were captured after recovery. No user intervention.
- Gradle's Java native-access warnings remain nonfatal. Windows desktop build
  tooling is absent and is not an F2 requirement. Browser PRNG comparison and
  clipboard integration are deliberately deferred. No unresolved F2 app defect
  was observed; independent review remains **PENDING**.

## F3 — Progression, economy, Daily and defensive persistence

**Reviewer decision: PENDING independent review. Implementation complete.**
No F4 work, merge, push to main, force-push or history rewrite.

Run: **2026-10-28**, Europe/Berlin; retained tool logs start **17:57:58 +01:00**;
Android observations **18:22–18:34**. Initial prompt/contract inspection preceded
the first retained command. Agent: Codex / GPT-6; exact model build and reasoning
setting were not exposed. **Human interventions: 0.**

Accepted starting main: **`9928bd5895e9258bdadb79580bc41497482181d9`**, matching
fetched origin/main. Branch: **`codex/f3-progression-economy-persistence`**.
Ending implementation commit: **`06753f8cdc92e76bb8a209186b3c6a5c323b3195`**.
Its evidence-only successor completes this record; the final full publication
SHA and remote equality are reported in the final execution response. Main
remains at the accepted starting commit. Publication is for independent review.

### Implementation and provenance

Pure `core/game.dart` snapshots replay evaluated guesses through the existing
engine and validate IDs, order, chronology, hints, counters and status.
`core/daily.dart` provides injected-clock civil-day arithmetic. `app/progress.dart`
owns the version-1 codec, historical summaries and independent section salvage;
`ProgressController` owns reward settlement, progression, Daily policy, statistics
and serial writes. Board handles forward the existing touch/drag operations;
listeners are disposed when their board route closes. No second wallet or parser.

One `SharedPreferencesAsync` key **`lexistack.progress`** (Android default
DataStore backend), with an injected asynchronous store and failure/delay fake.
Every accepted transition captures JSON before enqueueing. A failed write is
caught and shown as unsaved; Retry and later writes remain usable. `flush()`
drains queued work. No hard power-loss durability or tamper-proof storage claim.
Attempt IDs use a persisted monotonic counter. Finalization, payout, best stars,
unlocks and one unique history insertion happen synchronously before saving.
Reload/result rendering never credits money. Practice is capped per level.

Daily: UTC midnights from local civil components, epoch 2026-01-01; normalized
pool index `dayIndex % 8`, seed `(dayIndex % 2147483646) + 1`, range
1…2147483646. Goldens include epoch seed 1, 2026-01-09 seed 9, 2026-10-28 seed
301, pre-epoch seed 2147483646, DST cases and 2028 leap day. Campaign seeds use
new attempt serial modulo the same range, plus 1. Park–Miller/Fisher–Yates and
all F2 golden sequences are unchanged.

Fingerprint: canonical JSON array of stable level/category/tile IDs, source
order, titles, tiers, words, facts and red herrings. This collision-free semantic
encoding ignores source JSON whitespace/key order and uses no runtime hash.
Bad/missing/changed unfinished boards are discarded individually. Valid wallet,
achievements, unrelated attempts, historical summaries, Daily outcomes and
settings are retained independently. Bad finalized records retain ID/date or
level reward locks; valid history reconciles progression flags without payout.
A wholly invalid history locks rewards until confirmed Reset. Unsupported or
unreadable roots reset with a notice. Reset uses system theme/haptics-on defaults.

Exact prompt archived unchanged at
[prompts/F3-progression-economy-daily-persistence.md](../prompts/F3-progression-economy-daily-persistence.md).
Working and committed SHA-256 both:
**`05d19438bfa68270fd1457c217d6512407a8148fa76e6c9a35d13a2b4d9bf20d`**.
Pinned contract/cache HEAD remains **`d9acbd52de0e198dd109a4859299318db3f465f5`**.
`pack1.json`: **`5efa3c88c769f74eee872860766681f5c2cc1c64`**;
`daily.json`: **`5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6`**.
Daily was downloaded as raw bytes from the locked source commit. Only the two
installed files are listed in the temporary manifest. No other source repository,
contract, acceptance matrix or immutable JSON was changed. The only added direct
runtime dependency is `shared_preferences` 2.5.6, required by F3; its platform
packages are locked transitives.

### Commands and observed acceptance coverage

Raw outputs, literal commands for final checks, exits and unedited captures:
[evidence/f3](evidence/f3). Text evidence preserves output content; only trailing
whitespace/line endings are normalized for Git. Preliminary test files identify
their specific test command in this record; final logs include command headers.

| Command | Exit | Evidence/result |
|---|---:|---|
| `flutter --version`, `dart --version`, `flutter doctor -v` | 0 each | Flutter 3.47.8, Dart 3.13.7, SDK 36.1.0; Android ready, Visual Studio absent |
| `flutter emulators`, `flutter emulators --launch Pixel_10` | 0 each | Emulator launched before implementation |
| `flutter test --reporter expanded` before changes | 0 | `baseline-tests.txt`: **47 F1/F2 tests** |
| `flutter pub get` | 0 | `pub-get.txt`; package pin unchanged |
| `dart run tool/validate_levels.dart --partial` | 0 | `partial.txt`: **16 levels / 64 groups / 256 positions; 0 errors/warnings** |
| `dart run tool/validate_levels.dart` | **1 expected** | `strict.txt`: campaign count only; Daily no longer missing |
| `dart run tool/check_prng.dart` | 0 | `prng-vm.txt`: unchanged four vectors and F2 board order |
| `dart analyze` final | 0 | `analysis-final.txt`: no issues |
| `flutter test --reporter expanded` final | 0 | `tests-final.txt`: **117 passed** |
| `flutter build apk --debug` initial / final | 0 / 0 | `apk-initial.txt`, `apk-final.txt`: 45.7 / 13.3 seconds Gradle |
| `git hash-object --no-filters assets/levels/pack1.json` | 0 | `pack1-identity.txt`: locked blob |
| `git hash-object --no-filters assets/levels/daily.json` | 0 | `daily-identity.txt`: locked blob |
| `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` | 0 twice | `android-commands.txt`: both built APKs installed |
| `git diff --cached --check` source commit | **2** | Only four original Markdown hard-break lines in the immutable prompt |
| `git diff --cached --check -- . :!prompts/F3-progression-economy-daily-persistence.md` | 0 | Prompt preserved; all implementation changes pass |

Observed implementation probes: **PASS ECO-01–09, DAY-01–06, PER-01–09,
PLT-04**, plus prior F1/F2 regression coverage (ARC, applicable CNT, ENG,
UI-01/02, PLT-01–03). These are execution results, **not gate acceptance**.
No remaining failed or environment-blocked F3 probe. Settings toggles, full
Stats/Settings/UX, clipboard and polish remain F4; browser PRNG execution F6.

Tests independently assert 50/30/15 rewards, 0–5 lifetime mistakes, two paid
rescues, +5 once across failures/replays/restarts, independent synthetic packs,
Continue priority/all-won, full-state rejection invariants, Daily cycles/streaks,
catalog-independent statistics, exact snapshot/next-shuffle behavior, corrupt
root/sections and 31 targeted game corruptions. **PER-04 replaces one known
unsolved ID with a second copy of another known ID while preserving length**;
only that attempt is dropped. Delayed storage holds the first write and proves
later writes cannot start early. Failure/retry and cancelled/confirmed Reset,
including reopening, are exercised. Widget tests use the production app with
injected storage/clock and actual bundled JSON at all three required sizes;
360×640 at 1.3× text remains usable without overflow.

Legitimate prior-test adaptations: production content totals now include Daily;
legacy missing-Daily rejection is still checked with its own campaign-only
fixture. The all-installed-level solver now covers 16 levels. Fresh stage 8 is
asserted locked and navigation uses unlocked stage 1. Free-preview labels became
real prices, pending rescue now pays 60, and final results reopen explicitly.
The old active-attempt replacement test became same-attempt resume/explicit
finished replay; destructive global Reset now has cancellation/confirmation
coverage. No engine oracle, touch/drag assertion or layout scenario was removed.

### Genuine Android observations

Pixel_10, emulator-5554, Android 16 / API 36, x86_64, 1080×2424 at 420 dpi.
Both APKs were opened by tapping the observed LexiStack launcher icon; logcat
records MAIN/LAUNCHER from `com.google.android.apps.nexuslauncher`. Initial debug
cold launch was **5.256 s** to fully drawn; subsequent new processes were
**4.045 s**, **4.042 s**, and final APK **4.207 s**. No Flutter exception or
AndroidRuntime crash appears in the filtered log. Force-removal messages match
intentional force-stop/reinstall, not spontaneous crashes.

- Home → collection → stage 1 → Play. Held native pointer DOWN 700 ms, MOVE,
  UP from VOLLEY to PEARL selected both; tapping TOAST made three, without a
  release toggle. Pair Magnet charged 30 (150→120) and marked TOAST/WAFFLE.
  Leaving/re-entering retained the selection, hint and board.
- **`am force-stop de.cloudwards.lexistack`** removed PID **11780**; `pidof`
  returned exit **1** (no process). Launcher tap created PID **12138**.
  Continue restored the same board, ordered three-tile selection, hint and
  **120 coins**. The unedited before/after PNGs and accessibility XML agree.
- Solved all four real groups via taps: three stars, **+50**, **170 coins**,
  one finalized game. A second force-stop removed PID **12138**; launcher
  created **12529**. Selector showed best three stars and unlocked stage 2.
  Reopening stage 1's saved result retained 170 coins and one finalized game.
  Explicit replay created **a4**, distinct from completed **a1**; a read-only
  extraction of the app's actual DataStore value confirms both IDs.
- Bought Category Peek (170→130); four distinct wrong guesses entered pending
  loss. Repeating the first wrong set cost no additional life. Pending hid even
  the peeked title. Paid rescue charged **60** (130→70), kept the same attempt,
  four lifetime mistakes and selection, and restored one life.
- Daily displayed **2026-10-28**, board **5 / Keeping Time**. Same-date exit and
  re-entry yielded the same semantic tree. No physical clock manipulation.
- After installing the final APK, launcher PID **13369** restored 70 coins,
  one finalized game, the rescued campaign state and the same unfinished Daily.
  The final source differs from the scenario APK only by a fallback-result
  explanatory line; all final tests and the APK build passed.

Visually inspected, unedited screenshots:
[Home](evidence/f3/android-home.png),
[before process stop](evidence/f3/android-before-restart.png),
[after new process](evidence/f3/android-after-restart.png),
[campaign win](evidence/f3/android-campaign-win.png),
[reopened result](evidence/f3/android-result-reopened.png),
[pending loss](evidence/f3/android-pending-loss.png),
[paid rescue](evidence/f3/android-paid-rescue.png),
[Daily](evidence/f3/android-daily.png).
Final APK SHA-256:
**`47ed8d78fb743350e24086e20156efc57543a28b4f024debef82bf998570b68c`**.
Daily wins/rewards/midnight/DST, multiple replay payouts, unaffordable rescue,
Reset and injected storage failures were tested in Dart/widgets, not claimed as
manual Android scenarios. No web runtime or Windows desktop build was run.

### Corrections, limitations and interventions

- Initial partial integration analysis exited 3 for the old Level→board call
  against the new Attempt interface. Wiring the real UI fixed it. Subsequent
  brace-style informational lints were fixed; final analysis has zero issues.
  Controller tests (17), expanded recovery tests (63), initial full suite (116),
  recovery/UI follow-up (61), and final full suite (117) all exited 0.
- One combined delete/add patch was rejected before application; a separate
  write succeeded. One PowerShell replacement command had a quote parse error
  before any file changed; used a structured patch instead. A transient Windows
  mapped-file error prevented formatting one file once; retry succeeded.
- Final self-inspection tightened version typing (reject 1.0), prevented
  cross-section ID reuse, rejected restored locked-stage attempts, and disposed
  board listeners on route removal. A floating-version regression was added.
- The original prompt intentionally contains four trailing Markdown hard-break
  spaces; unrestricted diff-check reports them. They remain unchanged as
  required; the exact-prompt exclusion passes for all other changes.
- Emulator launcher transition swallowed one immediate swipe after reinstall;
  reading the actual UI and repeating it opened the app drawer. Gradle's Java
  native-access warnings remain nonfatal. Visual Studio is absent. There was no
  required F3 environment block and no user rescue.
- No known blocking F3 defect remains. Local preferences are not a database or
  a hard power-loss guarantee. Eight Daily boards rotate. Full F4 UX and F6
  browser equivalence remain deliberately unimplemented. **Gate stays PENDING.**

## F3-R01 — Post-review correction (2026-10-28)

**Independent review: CORRECTION REQUIRED (one High defect). Corrected feature
is PENDING independent re-review; no F4 work.** This is a separate correction
pass against reviewed commit `0b7a308e7e4718534d46b48cc3d74e8d009d4a25`,
on `codex/f3-progression-economy-persistence`. Accepted `main` remains
`9928bd5895e9258bdadb79580bc41497482181d9`. Original F3 evidence is retained.
Agent: Codex/GPT-6 (build/effort unavailable); Windows/PowerShell,
Flutter 3.47.8 / Dart 3.13.7; unchanged content-package pin.

A thrown storage read now leaves initialization explicitly unavailable.
Controller operations, including Reset and save retry, cannot mutate/persist
progress until loading succeeds. Home hides wallet/statistics/gameplay controls
and offers **Retry load**. Load and write errors are separate; null reads and
the existing malformed-document recovery policy still initialize normally.

The populated-save regression first reproduced the overwrite on reviewed code
([exit 1](evidence/f3-r01/regression-before.txt)). The corrected test exercises
blocked purchases/completion/settings/Reset, repeated failed reads, and exact
recovery of 205 coins, achievements, two results, campaign/Daily attempts and
settings. A subsequent paid hint persists 175 coins across reconstruction with
no duplicate results. A real-app widget test at 360×640 / 1.3× text verifies the
visible read error, absence of destructive controls and working Retry load.
The [focused run](evidence/f3-r01/regression-after.txt) passed 58 tests, exit 0.

| Exact command | Exit | Evidence |
|---|---:|---|
| `flutter pub get` | 0 | [pub-get.txt](evidence/f3-r01/pub-get.txt) |
| `dart run tool/validate_levels.dart --partial` | 0 | [validator-partial.txt](evidence/f3-r01/validator-partial.txt) |
| `dart run tool/validate_levels.dart` | **1 expected** | [validator-strict.txt](evidence/f3-r01/validator-strict.txt): incomplete campaign only |
| `dart analyze` | 0 | [analysis.txt](evidence/f3-r01/analysis.txt): no issues |
| `flutter test --reporter expanded` | 0 | [tests.txt](evidence/f3-r01/tests.txt): **122 passed**, including existing F1/F2/F3 regressions |
| `dart run tool/check_prng.dart` | 0 | [prng.txt](evidence/f3-r01/prng.txt) |
| `flutter build apk --debug` | 0 | [apk.txt](evidence/f3-r01/apk.txt) |

Android smoke: Pixel_10, API 36, emulator-5554. Updated APK installed and opened
via launcher (PID 13879, fully drawn 5.116 s). [Home](evidence/f3-r01/android-home.png)
restored 70 coins/one result; [Continue](evidence/f3-r01/android-resumed.png)
restored the rescued campaign board, peek and four selected tiles. Both original
screenshots were visually inspected. [Commands/logcat](evidence/f3-r01/android-commands.txt)
and adjacent XML retain observations; no runtime crash observed. **No injected
read failure was exercised on Android**; that proof is controller/widget only.
APK SHA-256: `42dabf498a89c5a4c0cd79a0a0e66469803603c71c21df2cc1a3e838b792f72d`.

Original prompt preserved, SHA-256:
`05d19438bfa68270fd1457c217d6512407a8148fa76e6c9a35d13a2b4d9bf20d`.
Contracts, frozen assets, dependency pin and prior evidence are unchanged.
One post-review corrective request; no mid-pass human rescue. Nonfatal Gradle
native-access warnings persist. No known remaining F3-R01 defect or required
environment block; browser execution remains outside this correction.

## F3 — Independent acceptance and main integration (2026-10-28)

**Independent reviewer decision: PASS, 2026-10-28.** This final decision
supersedes the earlier PENDING and CORRECTION REQUIRED entries above; all
original F3 and F3-R01 evidence remains preserved.

- Accepted final F3 commit: `7e03eaad8ee8731c57d2f4df3f3b4485ee605d1c`.
- Accepted scope: **ECO-01–09, DAY-01–06, PER-01–09 and PLT-04**.
- **F3-R01**, the high-priority storage-read recovery defect, is confirmed fixed.
  No additional blocking defects or correction runs are required.
- One post-review corrective run; **zero human interventions during the
  original autonomous F3 run**.
- Final implementation evidence: [122 passing Flutter tests](evidence/f3-r01/tests.txt),
  [clean analyzer](evidence/f3-r01/analysis.txt),
  [successful Android debug build](evidence/f3-r01/apk.txt), and the previous
  [Android process-restart evidence](evidence/f3/android-commands.txt), including
  [before](evidence/f3/android-before-restart.png) and
  [after](evidence/f3/android-after-restart.png) screenshots.
- Independent review examined actual GitHub source, regression tests, command
  evidence and Android screenshots. **Flutter tests were not independently
  rerun.** Storage-read failure injection was verified in controller/widget
  tests, **not on Android**.
- Integration verified a clean tree, fetched remote references, and confirmed
  local/remote `main` at `9928bd5895e9258bdadb79580bc41497482181d9` and
  local/remote `codex/f3-progression-economy-persistence` at the accepted F3 SHA.
  Local `main` was advanced with `git merge --ff-only`; this acceptance record
  is the sole change in the subsequent documentation commit. No history was
  rewritten. **F4 has not been started or assigned.**

## F4 — Complete UX and interaction integration

**Implementation complete; quality gate: PENDING independent review.**
These PASS entries are observed execution results, not independent acceptance.
No F5 work, merge, main push, rebase, force-push or history rewrite.

Run: **2026-10-28**, Europe/Berlin. Contract/prompt inspection preceded the
first retained command at **19:35:14 +01:00**; Android observations continued
through the final publication checks. Agent: Codex / GPT-6; exact model build
and reasoning setting unavailable. **Human interventions during F4: 0.**

Accepted starting local/remote main:
**`ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`**.
Branch: **`codex/f4-complete-ux-interaction`**. Initial implementation commit:
**`cc8ae21cc46fd341fc2eb6cc9c2ee863bc710726`**. This final follow-up commit
contains the verified motion/copy refinements, strengthened layout tests and
complete evidence. Its exact publication SHA and remote equality are reported
in the execution handoff (a commit cannot contain its own hash). Main remains
at the accepted F3 commit. Review branch:
[GitHub](https://github.com/oliversinz/lexistack/tree/codex/f4-complete-ux-interaction).

### Delivered behavior and boundaries

Home prioritizes Continue and separates Daily/date/status/streak, collections,
Statistics and Settings. A manifest-driven Campaign selector supports independent
packs; level entries distinguish locks, active/pending, results and explicit
replay. All-won Continue opens that selector. No fabricated shipping packs.
Stats uses finalized Progress aggregates and labels all five mistake buckets.
Settings persists System/Light/Dark and haptics, explains local storage, and
confirms Reset before clearing routes and restoring exact defaults.

The board retains actual tap and additive long-press drag, four lives and tier
slots, peek/pair feedback, selection tray, shuffle/deselect/submit and priced
boosters with disabled reasons. Final results show exact rewards, facts and
prioritized red herrings. Pending loss omits unsolved tiles/titles/facts and
sharing from both visual and semantic trees. Saved summaries still copy when
board details cannot be recovered. Flutter Clipboard.setData receives the
existing exact formatter; success appears only after completion, failure is
reported, and repeat copies/reopening cannot settle again.

MaterialApp uses persisted themeMode without recreating the shared controller
or route-owned board handles. HapticFeedback calls occur only after successful
action outcomes: selectionClick / mediumImpact / heavyImpact / lightImpact.
Disabled, rejected, duplicate and no-op actions emit none. Platform errors are
caught without affecting settlement. Motion: 120 ms selection scale/check,
300 ms selected-tile shake, 350 ms category reveal and 220 ms result entry;
OS disableAnimations removes ornament without changing transitions. Tile focus
is visible and keyboard activation uses the same action. Wide views center the
entire app at 460 px. Compact screens scroll deliberately to their controls.

SDK/platform fonts only, offline; no third-party font assets, license claims,
new dependencies or runtime downloads. The optional custom-font aesthetic was
not added. Content schema/pin/lockfile, frozen JSON, pure rules, date/economy
policy and persistence codec are unchanged. The only application-layer change
is the small stale-finalized-handle replay guard described below.

### Commands and execution results

All Flutter/Dart commands ran from `C:\Codex\LexiStack` in PowerShell.
Logs: [evidence/f4](evidence/f4). Final logs carry literal command/time/exit;
intermediate diagnostic logs are retained with their real failures. Only
trailing spaces and line endings in text logs were normalized for Git.

| Command | Exit | Observed result |
|---|---:|---|
| `flutter --version` | 0 | Flutter 3.47.8 stable, framework 737ba8f885, engine cf636b1dfb |
| `dart --version` | 0 | Dart 3.13.7 windows_x64 |
| `flutter doctor -v` | 0 | Android SDK 36.1.0 ready; Visual Studio/C++ missing |
| `flutter emulators` / `flutter emulators --launch Pixel_10` | 0 / 0 | Existing emulator launched before implementation |
| `flutter test --reporter expanded` baseline | 0 | **122 passed**, accepted F1–F3/F3-R01 baseline |
| `flutter pub get` | 0 | Exact Git pin and resolved lock identity retained |
| `dart run tool/validate_levels.dart --partial` | 0 | **16 levels, 64 groups, 256 positions; 0 errors/warnings** |
| `dart run tool/validate_levels.dart` | **1 expected** | Only insufficient campaign file count; Daily present, not missing |
| `dart analyze` final | 0 | No issues |
| `flutter test --reporter expanded` final | 0 | **150 passed**, including all 122 prior tests with UX-only adaptations |
| `dart run tool/check_prng.dart` | 0 | Four PRNG vectors and F2 shuffled order unchanged |
| `flutter build apk --debug` final | 0 | Gradle 12.3 s; debug APK built |
| `git hash-object --no-filters assets/levels/pack1.json` | 0 | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `git hash-object --no-filters assets/levels/daily.json` | 0 | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

Content package URL `https://github.com/oliversinz/lexistack-content.git`,
path `packages/lexistack_content_contract`, pin/resolved/cache HEAD:
**`d9acbd52de0e198dd109a4859299318db3f465f5`**.
Final APK SHA-256:
**`b4bdd309b319f3a1b874f686b80c494774f50eb6cbf4c0c4ce36ac3f6d92436d`**.

| Acceptance ID | Execution | Evidence |
|---|---|---|
| UI-03 | PASS | Actual-app Home/Campaign/level/Board/result/Daily/Stats/Settings/back; four-pack fixture locks and all-won fallback |
| UI-04 | PASS | Four hearts/slots, real selection, submit cap, shuffle/deselect, hints and scroll after two solves |
| UI-05 | PASS | Charged effects/wallet, exhausted Peek, unaffordable boosters, terminal guards and Android paid rescue |
| UI-06 | PASS | One Away/mismatch/duplicate, real facts, selected-only shake and interruption-safe reveal tests |
| UI-07 | PASS | Peeked pending reconstruction, complete semantic spoiler checks, same-state rescue, explicit irreversible reveal |
| UI-08 | PASS | Exact Campaign/Daily/loss platform payloads, pending absence, awaited failure/success, repeat copy and fallback |
| UI-09 | PASS | Immediate persisted themes/haptics, live route/handle identity, cancelled/confirmed reset, stale handle and F3-R01 |
| UI-10 | PASS | 360×640/1.3, 390×844/1 and 1.3, 1280×800/1.3, both themes; long category, CLOVE HITCH/SHEET BEND and ten-letter SMATTERING fixture |
| UI-11 | PASS | Unique tile semantics/selected state, tier labels, >=48 targets, keyboard action/focus, palette ratios >=4.5:1 |
| UI-12 F4 | PASS | Actual channel mapping/suppression/reconstruction/errors, reduced-motion tests and inspected Android PNGs |
| PLT-03 | PASS | Native Android taps, held-pointer tile-to-tile and tile-to-tray, purchases, pending/rescue/results |
| PLT-04 | PASS | am force-stop, absent PID, launcher new PID; exact board/hint/selection/wallet and settings restored |
| UI-12 final six PNGs / PLT-06–08 F6 portions | NOT YET APPLICABLE | No final canonical PNG set, browser PRNG execution, release packaging or release-readiness claim |

Critical regressions rerun: two-fresh-instance ENG oracle; PRNG goldens;
50/30/15 first-win and one-time +5 practice; Daily same-date/rollover/DST/leap/
streak; pending spoilers; PER-04 duplicate-known-ID rejection; ordered writes;
and F3-R01 failed read never writes defaults. Actual-app recovery hides wallet,
Play/Settings/Reset/save retry until a successful read restores dark/haptics-off.
Existing assertion changes concern Play/Resume labels, singular grammar, moving
Reset into Settings and explicitly scrolling both drag endpoints into view.
No behavioral coverage was removed. The four-pack fixture is test-only and is
not claimed to satisfy production catalog validation.

### Android and visual observations

Pixel_10 / emulator-5554, Android **16/API 36**, x86_64, **1080×2424 at 420 dpi**.
APKs installed with `adb -s emulator-5554 install -r ...app-debug.apk` (exit 0)
and launched by tapping the real launcher icon, not flutter run or am start.
[android-commands.txt](evidence/f4/android-commands.txt) records native commands,
coordinates and exits; XML companions retain actual accessibility trees.

- Held pointer DOWN 700 ms, MOVE, UP from VOLLEY to PEARL selected both; tapping
  TOAST made three. Pair Magnet and Peek charged 150→120→80 and marked the
  actual pair/title. Force-stop removed **15164** (pidof exit 1); launcher
  produced **15654**, restoring the same ordered selection/board/hints, 80 coins,
  dark theme and haptics-off. [Restored state](evidence/f4/android-restored-state.json)
  is a read-only decode of Android's real DataStore document, not injected data.
- Four distinct wrong guesses entered pending; repeating the first set left
  three lives and one evaluated mistake. Pending concealed even the peeked
  title. Reinstall/launcher retained pending. Rescue charged **80→20**, restored
  one life, and retained selection/order/guesses. Solving all groups then paid
  **15** (35 coins), one star, four lifetime mistakes and one finalized game.
  Reopened result retained the same payout. Copy result displayed successful
  platform completion on Android; exact payload bytes are independently tested
  through the Flutter platform channel, not claimed as Android clipboard reads.
- On the final APK, an explicit replay with paid pair/selection survived another
  force-stop: **18638→18975**, with pidof exit 1 between. The launcher transition
  swallowed an early drawer swipe; observing Home and opening the drawer again
  launched the app. After relaunch: same TOAST/BAGEL selection and pair, 5 coins,
  dark theme/haptics-off. A real long-press LOG→tray added exactly one tile.
- That replay then reached pending loss through four distinct wrong guesses.
  Both themes concealed answers; with 5 coins, rescue was visibly unavailable.
  Explicit acceptance revealed answers, awarded zero, and changed Statistics
  to two games / one win / 50%. Android Copy result again reported success;
  reopening retained 5 coins. Final captures verify singular star/win/mistake
  semantics and the restored haptics-off setting.
- [Logcat](evidence/f4/android-logcat.txt) confirms MAIN/LAUNCHER starts from
  nexuslauncher and both force-stop/PID sequences. The available filtered ring
  buffer contains no Flutter exception or AndroidRuntime crash. Debug fully
  drawn observations were 3.981 s for the first measured restart and 5.252 s
  for the final measured restart (8.332 s immediately after the final install).
  These are emulator debug observations, not release performance claims.
- Light/dark Home, pack/level affordances, selected board/boosters, two solved
  categories, pending loss, finalized results/facts/red herrings, Statistics and
  Settings were inspected from unedited emulator PNGs. See representative
  [Home](evidence/f4/android-home-light.png),
  [dark Home](evidence/f4/android-home-dark.png),
  [packs](evidence/f4/android-packs-dark.png),
  [two solved/light](evidence/f4/android-two-solved-light.png),
  [two solved/dark](evidence/f4/android-two-solved-dark.png),
  [pending/light](evidence/f4/android-final-pending-light.png),
  [pending/dark](evidence/f4/android-final-pending-dark.png),
  [win](evidence/f4/android-win-light.png),
  [facts/red herrings](evidence/f4/android-result-details-light.png),
  [final loss](evidence/f4/android-final-loss-copy.png),
  [Stats](evidence/f4/android-stats-final-dark.png),
  [Settings](evidence/f4/android-settings-final-dark.png),
  [before final stop](evidence/f4/android-final-before-stop.png) and
  [after final stop](evidence/f4/android-final-after-stop.png).
  Earlier intermediate screenshots may precede final grammar/selected-shake
  refinements; the final APK lifecycle and touch probes use the final binary.
  Redundant exploratory captures were omitted; retained PNGs are unedited.

### Corrections, limits and provenance

- Regression tests caught UI route builders recreating board handles on theme/
  wallet rebuilds, losing feedback/replay state. A route now constructs exactly
  one handle; a test changes themes above an active board and asserts identity.
- Inspection found an old finalized handle could call newAttempt after Reset.
  The minimal guard requires its finalized result still to exist. An actual-app
  regression resets from Settings then invokes that stale handle and asserts
  no attempt or wallet mutation. Core rules and persistence were not altered.
- Visual/semantic review corrected singular game/mistake/star/win copy and
  merged booster semantics. Motion now shakes selected tiles only. The layout
  fixture was strengthened to actually contain two-word and ten-letter tiles.
- Intermediate failures included a Category import collision, nullable test
  theme mode, semantics-handle cleanup, test scroll/focus assumptions and the
  route lifetime defect. Final analyzer and all 150 tests pass. A patch context
  mismatch changed no files; the corrected patch applied normally.
- A PowerShell wrapper initially interpreted adb `-p` as a common parameter;
  the wrapper was corrected. Android startup sometimes returned a null UI root
  until loading finished. Captures taken before a transition settled were
  replaced with settled captures; screenshots are not image-edited. Semantic
  label grouping required matching the observed full label in native probes.
  One extra Back sequence reached the launcher and opened Android Settings;
  its missing Light control stopped the probe without changing any setting.
  Relaunching LexiStack and observing each route corrected the probe.
  No human rescue or manual source/data repair was requested.
- No known unresolved F4 defect or required environment-blocked check remains.
  Emulator screenshots cannot prove subjective vibration strength; mapping and
  suppression are platform-channel tests. Daily date edges, injected storage
  failures and desktop-width layouts are automated tests, not Android-clock
  manipulations or browser execution. Visual Studio is absent; no Windows build
  attempted. Java native-access warnings remain nonfatal. Eight Daily boards
  rotate; three additional campaign packs and final release work remain F5/F6.

Exact supplied prompt preserved at
[prompts/F4-complete-ux-interaction.md](../prompts/F4-complete-ux-interaction.md).
Working and Git-blob SHA-256:
**`0aae7fcb0b7dcfecb7a0c0ef97ef1c6291a017184e80d854295af0e97d64d2a7`**.
`.gitattributes` reports prompt text unset (`-text`), protecting its original
bytes. No authoritative contract, acceptance matrix or immutable asset changed.
**Quality gate remains PENDING independent review. F5 has not started.**

## F4-D01 — PENDING independent re-review (2026-10-28)

Independent-review-triggered visual correction on the existing
`codex/f4-complete-ux-interaction` branch. Reviewed start:
`cac39ad9697a52f480168222ddb6848fe2f40fd7`; completed implementation:
**`86ea4997b218032824d69834768a4c7f0dc3f667`**. This record and its evidence are
the following evidence commit; that commit is the review tip. No history was
rewritten. Accepted `main` stays at `ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`.
This is an implementation report, not independent acceptance. F5/F6 not started.

### Design and actual visual review

Compared the original unedited [F4 evidence](evidence/f4) with the new PNGs
below using image viewing tools. The former green, rounded Material panels
and vertically stacked board status are replaced by warm paper, midnight ink,
violet/lilac actions, coral editorial edges and tactile offset tile faces.
Yellow/green/blue/purple category identities and labels remain unchanged.

- Home: original four-token emblem and Fraunces masthead, compact invitation,
  prominent Continue with real campaign progress, coral-edged Daily edition
  and a numbered collection spine. Continue and Daily are visible at 390×844.
- Campaign/levels: real collection progress and a compact, staggered connected
  stage trail with numbers, earned stars and text/icon states. Locked stages
  remain disabled; View Result and Replay remain separate actions.
- Board: compact hearts/mistakes/tiers, cream or midnight word tokens and a
  SafeArea-aware persistent selection tray/Submit/Shuffle/Deselect/Boosters
  dock. The newest solved fact opens; earlier facts remain expandable. The
  priced booster bar scrolls independently of the primary action.
- Outcomes: prominent real stars/reward and distinct Copy action; pending
  decision uses a coral edge and explicit irreversible reveal wording without
  answer leakage. Stats retain honest finalized-only numbers; Settings use
  clear theme selectors and the persisted haptic switch.
- Dark mode uses the same geometry and typography with midnight/lilac. Visual
  inspection confirms visible Submit, legible tiles and a coherent game
  identity across both themes. Premium aesthetic acceptance remains the
  independent reviewer's decision.

Fraunces + DM Sans are bundled offline, with both OFL files. Authoritative
[Google Fonts source revision](https://github.com/google/fonts/tree/9862abc066c9b83bf84c3e8ed1fc2d8d48f9bbf0/ofl)
and byte hashes are in [font-provenance.txt](evidence/f4-d01/font-provenance.txt).
No font acquisition limitation, runtime download or new package dependency.

### Commands, regression coverage and geometry

PowerShell, `C:\Codex\LexiStack`. Flutter **3.47.8**, Dart **3.13.7**,
Windows **10.0.26300.9711**, SDK **36.1.0**, Android emulator **37.2.12.0**,
Java **25.0.3**. Agent: Codex; exact model/effort, token cost and reviewer time
are not exposed. Baseline log was created at 20:32:12 CET; final Android review
finished around 21:05 CET. These are evidence timestamps, not a measured total
task-runtime claim. No browser execution or Windows build is claimed.

| Command | Exit | Result / log under `evidence/f4-d01/` |
|---|---:|---|
| `flutter --version` | 0 | `flutter-version.txt` |
| `dart --version` | 0 | `dart-version.txt` |
| `flutter doctor -v` | 0 | `doctor.txt`; only Visual Studio/C++ absent |
| `flutter pub get` | 0 | `pub-get.txt`; dependency lock unchanged |
| `flutter test --reporter expanded` baseline | 0 | **150 passed**, `baseline-tests.txt` |
| `dart run tool/validate_levels.dart --partial` | 0 | 2 packs / 16 levels / 64 groups / 256 positions, **0 errors, 0 warnings**, `validator-partial.txt` |
| `dart run tool/validate_levels.dart` | **1 expected** | Only `catalog.campaignCount`: 1 installed campaign file, minimum 4; `validator-strict.txt` |
| `dart analyze` final | 0 | No issues, `analysis-final.txt` |
| `flutter test --reporter expanded` final | 0 | **153 passed**, `tests-final.txt` |
| `flutter test test/ui/f4_d01_test.dart --dart-define=CAPTURE=true --reporter expanded` | 0 | **3 passed**, real fonts/icons and PNGs, `tests-ergonomics-final.txt` |
| `dart run tool/check_prng.dart` | 0 | VM goldens unchanged, `prng-vm.txt` |
| `flutter build apk --debug` final | 0 | `apk-final.txt` |
| `git hash-object --no-filters assets/levels/pack1.json` | 0 | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `git hash-object --no-filters assets/levels/daily.json` | 0 | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

All 150 earlier tests remain; only presentation assertions changed (collection
progress copy, Settings tooltip and disabled stage `InkWell` instead of
`ListTile`). Three new tests assert actual rectangles, hit testing, interactions
and real theme/selected-tile colors. No behavioral checks removed. Coverage:
UI-03 four independent test packs/navigation/replay; UI-04–07 tile cap, both
drags, boosters, exact charging, feedback, expandable facts and pending spoilers;
UI-08 exact clipboard payload/awaited errors/idempotence; UI-09 persistence,
Reset/stale handles and F3-R01 no-overwrite; UI-10 long categories, CLOVE HITCH,
SHEET BEND, SMATTERING, enlarged text and wide layouts; UI-11 semantics, 48 px
targets, focus and >=4.5:1 actual text colors; UI-12 haptic mapping/suppression,
reduced motion and interrupted settlement. All prior core/economy/Daily/calendar/
streak/PER-04/ordered-write regressions ran in the full suite.

Measured logical coordinates, including simulated 24 px top/bottom OS insets:

| Viewport | Tile-grid bounds | Submit bounds | Dock bounds | Observation |
|---|---|---|---|---|
| 390×844, 1× | (16,200)–(374,533) | (272.7,718)–(374,770) | (0,707)–(390,820) | All 16 tiles and Submit hit-testable; scroll offset **0** before/after real four-tile selection and submission |
| 360×640, 1.3× | (16,215)–(344,476) | (233.9,511)–(344,563) | (0,497)–(360,616) | Real long-press tray drag, four-tile Submit, one/two solves and old-fact expansion; secondary area can scroll while selected tiles and dock stay visible |

The normal-play assertion does not use `ensureVisible` or scroll. The small
test explicitly scrolls the secondary area after solves, checks every remaining
tile above the dock and checks Submit within the SafeArea. No overlap/overflow
or hidden primary action was observed.

### Android interactions and unedited screenshot index

Pixel_10 / emulator-5554, Android **16/API 36**, **1080×2424 at 420 dpi**
(approximately **411.43×923.43 logical pixels**, device ratio 2.625).
Native PNGs below are this device size, **not 390×844**. Exact reference sizes
are the explicitly labeled Flutter widget captures with bundled fonts/icons.
The emulator was available and used early; APK install and actual launcher
icon starts succeeded. [Native commands](evidence/f4-d01/android-commands.txt)
record coordinates, timestamps and exit codes; XML companions retain semantics.
Successful installation, tap/drag, screenshots, force-stop and launcher input
commands exited 0; `pidof` while stopped exited 1 as expected.

- Preserved the old installed progress across upgrade, then backed it up and
  used the real confirmed Settings Reset for this probe. The raw backup remains
  outside Git at `%TEMP%\lexistack-f4-d01-baseline-preferences.pb`.
- Tap toggling worked. Held DOWN for 750 ms then MOVE/UP from VOLLEY to PEARL
  selected exactly two; TOAST to the tray added exactly one. Solved two actual
  groups, then Pair Magnet and Peek charged **150→120→80**, marking LOVE/SERVE
  and the real tennis title. Dark theme and haptics-off were set through UI.
- Force-stop/relaunch changed PID **23280→23898**. The same unfinished game,
  ordered LOVE/PAPER selection, pair/peek hints, 80 coins, dark theme and disabled
  haptics returned. [Comparison](evidence/f4-d01/restart-comparison.txt) checks
  decoded real DataStore state before/after. Existing navigation recency counters
  advance on Continue; every game field and all other saved root fields match.
- One Away cost one life; repeating it showed Already Guessed with no extra
  loss. Four distinct wrong guesses reached pending. Native XML concealed
  unrevealed titles/tiles; Rescue charged **80→20**, preserving the attempt.
  Completing both remaining groups produced **one star / four mistakes / +15**,
  35 coins and one finalized win. Copy reported platform success.
- Explicit Replay made a fresh board. Four wrong guesses reached pending with
  unaffordable rescue (35 coins). Reveal finalized the loss, paid **0**, and
  Stats showed **2 games / 1 win / 50%**, with one win in the 4+ bucket. Copy
  again reported success. Exact clipboard bytes are platform-channel golden
  tests, not a claim of reading the Android clipboard.

Every required final artifact below was opened and visually inspected:

| Screen/state | Artifact |
|---|---|
| Home light/dark | [home-light.png](evidence/f4-d01/home-light.png), [home-dark.png](evidence/f4-d01/home-dark.png) |
| Collection / stage trail | [campaign.png](evidence/f4-d01/campaign.png), [levels.png](evidence/f4-d01/levels.png) |
| Fresh / actionable selection (native) | [board-fresh.png](evidence/f4-d01/board-fresh.png), [board-selected.png](evidence/f4-d01/board-selected.png) |
| Exact 390×844 widget capture | [fresh](evidence/f4-d01/board-fresh-widget-390.png), [selected](evidence/f4-d01/board-selected-widget-390.png), [Home](evidence/f4-d01/home-widget-390.png) |
| Exact 360×640 / 1.3× widget capture | [board-small.png](evidence/f4-d01/board-small.png), [after two solves](evidence/f4-d01/board-small-two-solved.png) |
| Two solved / dark play | [board-two-solved.png](evidence/f4-d01/board-two-solved.png), [board-dark.png](evidence/f4-d01/board-dark.png) |
| Pending / victory / final loss | [pending-loss.png](evidence/f4-d01/pending-loss.png), [victory.png](evidence/f4-d01/victory.png), [finalized-loss.png](evidence/f4-d01/finalized-loss.png) |
| Supporting screens | [stats.png](evidence/f4-d01/stats.png), [settings.png](evidence/f4-d01/settings.png) |
| Native drag and paid feedback | [tile target](evidence/f4-d01/drag-to-tile.png), [tray target](evidence/f4-d01/drag-to-tray.png), [boosters](evidence/f4-d01/boosters-paid.png), [rescue](evidence/f4-d01/paid-rescue.png) |
| Process restart / copy | [before](evidence/f4-d01/before-restart.png), [after](evidence/f4-d01/after-restart.png), [copy success](evidence/f4-d01/victory-copy.png) |

Light two-solved, drag, campaign and initial level PNGs precede the final minor
Home progress/disabled-text refinement; their depicted layouts did not change.
Fresh/selected, dark, restart, rescue, victory/loss and Stats use the final APK.
PNG files were not image-edited. Old F4 evidence remains byte-unchanged.

### Corrections, limits and provenance

- Initial implementation tests caught masthead and paired/two-word tile
  overflow, an invalid decorated SwitchListTile background and changed widget
  identities (127 passed / 23 failed, exit 1). Corrections made layouts compact
  and adapted only presentation expectations. A later 149/1 result caught
  duplicate word semantics from the tray; merged tray semantics fixed it.
- A Python Windows encoding mistake temporarily made board source unreadable
  (analyzer exit 3); UTF-8 writing repaired it. A remaining brace-style info
  was fixed; final analyzer has no issues.
- Screenshot-test image work initially hung in fake async; its own tester was
  stopped (exit 79). Moving the entire capture/IO into `runAsync` and loading
  the SDK MaterialIcons font produced the passing, inspectable final captures.
- Early Android transition/cold-start screenshots were recaptured after the
  real UI appeared; one draft transition is retained. A backup probe used an
  obsolete XML path and a denied shell-copy destination; binary `exec-out`
  captured the actual DataStore instead. Concurrent UI dumps caused a shell
  UIAutomator crash; serializing probes fixed it. The retained
  [logcat](evidence/f4-d01/android-logcat.txt) identifies **PID 23716,
  com.android.commands.uiautomator.Launcher**, with `already registered`, not an
  app crash. No Flutter exception or LexiStack process crash was observed.
- The first restart comparison incorrectly required navigation counters not
  to change (exit 1); the corrected oracle checks their exact +1 advance and
  equality of all actual game/persistence fields (exit 0). No state was edited
  to pass. Initial failure logs are retained rather than replaced by passes.
- No known unresolved required F4-D01 defect or blocked required check remains
  in this implementation report. Visual Studio/C++ is absent; no Windows build
  attempted. Gradle native-access warnings are nonfatal. Emulator evidence
  cannot establish perceived vibration strength; channel tests cover mapping.
  Browser PRNG/release checks remain F6 work. Production still has one Campaign
  pack and eight rotating Daily boards; Strict failure remains expected for F5.
- Human interventions: **one independent-review-triggered corrective assignment
  (F4-D01), zero mid-run human rescue/repair or additional approvals**. This
  correction is not counted as a new feature phase or a self-accepted gate.

Final debug APK SHA-256 (binary not committed):
`a84541646e65f2df0647eb538fb6f63cf29330fb4d414d729d5732e6e386d6ff`.
Content dependency pin/resolved-ref remains
**`d9acbd52de0e198dd109a4859299318db3f465f5`**. No core, application, storage,
reference JSON, manifest, lockfile or authoritative contract changes.
[provenance.txt](evidence/f4-d01/provenance.txt) records the unchanged paths and
pre-publication refs. The exact supplied
[redesign prompt](../prompts/F4-D01-paper-arcade-redesign.md) is preserved with
`-text`; binary comparison confirms working file equals the Git blob. SHA-256:
**`ba7937572361928f51c47c1ba5810d9a1453fcf4966ae81193b852bca3aa4dc0`**.

**F4 remains PENDING independent re-review. No merge/push to main; no F5/F6.**

## F4-D02 — Typography Refinement (PENDING independent review, 2026-10-28)

Narrow independent-review-triggered correction, continuing on
`codex/f4-complete-ux-interaction` from reviewed
**`fa1ba33b2a00b67dcbf28420cfcc68fd72b5300c`**. Local and remote starting refs
matched; the only initial untracked file was the supplied execution prompt.
`origin/main` remains **`ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`**.
The review commit is the commit introducing this section and its evidence.
No main changes, history rewriting or F5/F6 work.

### Change and typography audit

Only three production files changed: `lib/ui/theme.dart`, `common.dart` and
`home_screen.dart`. Generic heading slots and functional AppBar titles now use
DM Sans at weight 700, retaining their existing sizes, line heights and spacing.
Two named explicit styles keep Fraunces at weight 600 only for the Home
`LexiStack` wordmark (23 px) and `Good words. Great company.` hero (32 px).

| Role | Effective font |
|---|---|
| Home wordmark and hero | Fraunces, explicit exceptions |
| Daily date, all functional AppBar/section/result/pending headings | DM Sans |
| Statistics metrics, stage numerals, counters, coins and rewards | DM Sans |
| Tiles, actions, boosters, facts, settings and body text | DM Sans |

Both font binaries and OFL texts are unchanged. No wording, palette, emblem,
geometry, gameplay, economy, progression, clipboard, persistence, content,
manifest, package pin or lockfile changes. F4/F4-D01 prompts and evidence remain
untouched. No new font, dependency or typography framework.

Compared the untouched [D01 Home](evidence/f4-d01/home-light.png),
[Stats](evidence/f4-d01/stats.png), [Settings](evidence/f4-d01/settings.png) and
other prior screen captures with the after images below. All new PNGs were
opened with image viewing tools. Daily dates and metrics now have clean sans
digits; navigation and section headings match the functional UI. The two
editorial brand accents remain visually distinct in both themes. No layout
adjustment was needed. Existing single-line ellipsis for a constrained Board
title/selection summary at 360 px with enlarged text remains; it does not cover
tiles or the Submit action.

### Tests and command evidence

Commands ran in PowerShell from `C:\Codex\LexiStack`; logs in
[evidence/f4-d02](evidence/f4-d02). Flutter **3.47.8**, Dart **3.13.7** remain
installed; the existing Pixel_10 emulator was connected before editing.
Baseline testing began at 21:28:48 CET; device smoke ended at 21:36:46 CET.
These are evidence timestamps, not total task-runtime measurements. Agent:
Codex; exact model/effort, token cost and reviewer time are not exposed.

| Actual command | Exit | Result / log |
|---|---:|---|
| `flutter pub get` | 0 | `pub-get.txt`; lockfile unchanged |
| `dart run tool/validate_levels.dart --partial` | 0 | **16 levels, 0 errors/warnings**, `validator-partial.txt` |
| `dart run tool/validate_levels.dart` | **1 expected** | Only `catalog.campaignCount` (1 installed, 4 required); `validator-strict.txt` |
| `dart analyze` | 0 | No issues; `analysis.txt` |
| `flutter test --reporter expanded` before edits | 0 | **153 passed**; `tests-baseline.txt` |
| `flutter test --reporter expanded` final | 0 | **155 passed**; `tests-final.txt` |
| `flutter test test/ui/f4_d01_test.dart --reporter expanded` | 0 | **3 passed**; `tests-ergonomics.txt` |
| `flutter test test/ui/f4_d02_test.dart --dart-define=CAPTURE=true --reporter expanded` | 0 | **2 passed**, six viewport/theme combinations; `typography-captures.txt` |
| `dart run tool/check_prng.dart` | 0 | VM goldens pass; `prng-vm.txt` |
| `flutter build apk --debug` | 0 | Debug APK built; `apk.txt` |
| `git hash-object --no-filters assets/levels/pack1.json` | 0 | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `git hash-object --no-filters assets/levels/daily.json` | 0 | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

New `test/ui/f4_d02_test.dart` loads the actual bundled fonts and SDK icons,
checks merged `RenderParagraph` styles across Home, Campaign, levels, Board,
victory, Stats, Settings and Reset dialog, and asserts both explicit Fraunces
exceptions. It checks unclipped Daily/hero/metric text and hit-testable tiles/dock
at **360×640/1.3×, 390×844/1× and 1280×800/1.3× in both themes**. Existing test
files/assertions are unchanged; all ENG/ECO/DAY/PER, F3-R01, clipboard, motion,
haptic, drag, contrast and accessibility regressions remain in the full suite.

D01 geometry remains identical: at 390×844 all 16 tiles occupy
`(16,200)–(374,533)`, Submit `(272.7,718)–(374,770)`, scroll offset **0**.
At 360×640/1.3× Submit is `(233.9,511)–(344,563)` inside SafeArea `y=24..616`;
the dock stays fixed through real tray drag and one/two solves. The D02 tests
also exercise the dock in both themes. No old screenshot capture was overwritten.

### Android smoke and selected unedited screenshots

Installed with `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`
(exit **0**), then tapped the actual launcher icon. Pixel_10 / Android 16 API 36,
native **1080×2424, 420 dpi** (about 411.43×923.43 logical pixels).
[android-commands.txt](evidence/f4-d02/android-commands.txt) records successful
native commands/exits. The unchanged D01 capture helper was reused with its
output directory redirected to `f4-d02`; XML companions retain actual semantics.

Opened Home/Daily, switched Light→Dark through Settings, navigated Campaign and
the level trail, viewed the saved finalized loss, inspected Stats, then resumed
stage 2. Tapped BENCH/STOOL/SOFA/CHAIR: actionable Submit remained visible;
submission showed **Correct! SEATS AROUND THE HOUSE**, retaining the prior one
mistake and 35 coins. [android-solve.xml](evidence/f4-d02/android-solve.xml)
records the solve. The saved result retained zero payout and Stats 2 games /
1 win / 50%. Deep booster/replay/process-kill/drag probes were **not rerun on
device** in this typography-only correction; their automated regressions passed
and D01 native evidence is retained. No browser run or release build claimed.

| Inspected artifact | Capture type |
|---|---|
| [Home light](evidence/f4-d02/android-home-light.png), [Home dark](evidence/f4-d02/android-home-dark.png), including Daily heading | Native Android |
| [Level trail](evidence/f4-d02/android-levels-dark.png), [selected Board](evidence/f4-d02/android-board-dark.png) | Native Android |
| [Finalized result](evidence/f4-d02/android-result-dark.png), [Statistics](evidence/f4-d02/android-stats-dark.png), [Settings](evidence/f4-d02/android-settings-dark.png) | Native Android |
| [Home light](evidence/f4-d02/widget-home-light-390.png), [Home dark](evidence/f4-d02/widget-home-dark-390.png) | Exact 390×844 widget captures, actual fonts |
| [Small Board](evidence/f4-d02/widget-board-dark-360-1.3.png) | Exact 360×640 / 1.3× widget capture |
| [Wide Statistics](evidence/f4-d02/widget-stats-light-1280-1.3.png) | Exact 1280×800 / 1.3× widget capture, centered 460 px frame |

### Corrections, limitations and prompt identity

All new typography checks passed on the first execution; no code self-correction
or existing assertion change was necessary. One native probe requested the
nonexistent label `View Result` and stopped before input (exit 1); the observed
`View saved result` label succeeded. The initial post-launch dump still showed
the launcher; the next observation waited for the real Home before capture.
The [time-bounded logcat](evidence/f4-d02/android-logcat.txt) confirms the launcher
start and contains no Flutter exception, overflow or app crash during this smoke.
Gradle native-access warnings are nonfatal; no required check was environment
blocked. No unresolved typography defect observed; independent review is pending.

Human interventions: **one F4-D02 independent-review correction assignment,
zero mid-run rescue/repair/approval prompts** (second design correction after
D01, not a new phase). Content pin/resolved-ref remains
`d9acbd52de0e198dd109a4859299318db3f465f5`.
[provenance.txt](evidence/f4-d02/provenance.txt) records unchanged paths and APK
SHA-256 `09aea5c221f4cd398350f1fcd1a34493a8775547d3be86fb2a8a5549df0ae7b3`.
The supplied [exact prompt](../prompts/F4-D02-typography-refinement.md) was staged
before code edits; its bytes equal the Git blob under the existing `-text` rule.
SHA-256: **`1ee0d2b70ed5fe3f68f5b392344246c15cdfae122ef5be8ade3c7fa2bcebffde`**.

**F4 remains PENDING independent approval. No merge/push to main; no F5/F6.**
