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
