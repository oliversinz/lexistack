# Experiment E gate log

## F1 — Foundation & Android baseline

**Reviewer decision: PENDING.** This is implementation evidence, not gate acceptance.
Scope submitted: **ARC-01–04, CNT-01–04, UI-01, PLT-01–02**. F2 has not started.

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
