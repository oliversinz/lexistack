# LexiStack — F6 Android release candidate

A local word-connection game: find four groups of four words before exhausting
four lives. The frozen catalog contains **32 Campaign levels (four packs of
eight) and eight Daily boards: 40 levels, 160 categories, 640 tile positions**.
Each pack unlocks independently. Daily rotates through the bundled pool by
local calendar date. **F1–F5 are accepted; F6 is pending independent review.**

Tap to select, or hold a tile and drag onto another tile or the selection tray.
Shuffle is free; four selections enable Submit. Repeating a wrong set costs
no extra life; three matching words produce One Away. At zero lives, answers
remain hidden until Reveal / Accept Loss. A paid rescue continues that attempt.

- Initial wallet: 150. Pair Magnet: 30; Category Peek: 40; Extra Life: 60.
- Stars by lifetime mistakes: 0 → 3, 1–2 → 2, 3+ → 1. First Campaign wins
  pay 50/30/15. The first successful replay pays +5 once per level.
- A first Daily win pays the star reward plus 25. Finalized wins/losses enter
  statistics; pending losses do not. Settlements survive restart exactly once.
- Home, collections, levels, results, statistics and settings support light/dark
  themes, haptic preferences, reduced motion and scrolling on small screens.
  Wide screens center a 460-logical-pixel app frame. Results can be copied.

Android gameplay works offline after installation, including Daily and saved
progress. The Flutter web target uses the same widgets, engine and JSON. Web
requires an initial static-asset load; browser local storage survived reload.
**Offline browser reload failed in the tested Chrome session and is not
supported by this verification.** Clearing site storage removes web progress.

## Run and verify (Windows PowerShell)

Verified: Flutter 3.47.8, Dart 3.13.7, Android SDK 36.1.0; Pixel_10 / Android 16
(API 36), Chrome 156.0.8078.73. From this repository:

```powershell
flutter doctor -v
flutter pub get
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build web
flutter build apk --debug
flutter build apk --release
```

The final suite records **197 passing tests**, strict validation with zero
errors/warnings and all 40 intended-group solves. Logs and exact observations
are in the [F6 evidence index](docs/evidence/f6/README.md).

```powershell
flutter emulators --launch Pixel_10
$adb = "$env:LOCALAPPDATA/Android/sdk/platform-tools/adb.exe"
& $adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
# Open the Android app drawer and tap LexiStack.
# Preserve existing progress with an emulator snapshot before scenario testing.
python -m http.server 8765 --bind 127.0.0.1 --directory build/web
# Open http://127.0.0.1:8765 in Chrome; stop this server with Ctrl+C.
```

Release output: `build/app/outputs/flutter-apk/app-release.apk`, version 0.1.0+1,
package `de.cloudwards.lexistack`. **Release-mode compiled, debug-signed
verification APK — not a production-signed Play Store release.** No production
signing credentials are configured. Windows desktop was not built because
Visual Studio C++ tooling is absent. Java native-access and web Cupertino-font
build warnings are retained in evidence; observed Material icons render.

## Browser PRNG and visual reproduction

`flutter test --platform chrome test/core/prng_test.dart --reporter expanded`
is incompatible with this installed runner's Windows import/test paths. The
successful fallback compiles the unchanged fixed oracle and executes the
production `StableRandom` in Chrome, rather than Node:

```powershell
New-Item -ItemType Directory -Force build/prng | Out-Null
dart compile js tool/check_prng.dart -o build/prng/check_prng.js
Copy-Item tool/prng_browser.html build/prng/index.html
python -m http.server 8766 --bind 127.0.0.1 --directory build/prng
# Open http://127.0.0.1:8766 in Chrome.
# Expect four seed lines and one shuffle/state line, all ending in OK.
```

Golden seeds are 1, 42, 20261028 and 2147483646; shuffle:
`11,15,6,0,12,13,1,7,14,8,5,3,9,4,2,10`, final state `1470087647`.
Actual browser output and the failed runner attempts are preserved in evidence.

```powershell
flutter test test/ui/f6_capture_test.dart --dart-define=CAPTURE=true --reporter expanded
flutter test tool/generate_icons.dart
```

The six canonical [screenshots](docs/screenshots/) are `01_home.png`,
`02_board_selected.png`, `03_board_solved.png`, `04_result.png`, `05_packs.png`
(all 390×844), and `06_desktop_frame.png` (1280×800). Supporting result captures
show facts/red herrings below the fold; the genuine viewport is never composited.
Icons render the existing production `PuzzleMark` at Android/web sizes.

Fraunces is bundled for the wordmark/Home hero; DM Sans supplies functional
text. Small licensed Noto subsets supply the existing stars/check/share squares.
The web engine's automatic Roboto fallback is aliased to bundled DM Sans;
CanvasKit also loads locally. All four OFL texts are packaged under
`assets/fonts/`. Optional subset regeneration uses
`tool/generate_symbol_fonts.py` (Python + fonttools 4.68.0, pinned source hashes).
No runtime font download is required.

## Implementation and saves

`lib/core/` is pure Dart. `ProgressController` owns progression, economy, Daily,
settlement and serialized saves; `BoardController` forwards UI gestures.
Infrastructure adapts bundled assets and preferences. The external content
package alone owns models/parsing/validation. UI uses `ChangeNotifier`.

One version-1 JSON document under `lexistack.progress` uses
`SharedPreferencesAsync` (Android DataStore; browser local storage). Attempts
retain tile order, selection, hints, guesses, PRNG state and pending decisions.
Restore validates permutations/history and content fingerprints, salvages valid
sections, and protects prior rewards. A failed storage read blocks mutation
until Retry load succeeds; write failures expose a retry notice. This local
store does not promise hard power-loss durability or tamper resistance.

The Content Contract remains pinned to
`d9acbd52de0e198dd109a4859299318db3f465f5`; commit `pubspec.lock`.
The six frozen JSON blobs remain identical to source commit
`8b84f2d6c75cb807fba9db19cba707f963e02020`; see the
[reference lock](docs/reference-content-lock.md). No backend, telemetry, ads,
billing, runtime AI or content service exists. Editorial replacement content
and comparative Experiment E scoring remain separate work.
