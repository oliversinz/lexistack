# LexiStack — F1 foundation

A genuine Flutter Android app with Home → collection → level-details navigation.
This build includes **Everyday Echoes: eight level entries**, loaded from the
frozen schema v2 JSON. Gameplay, economy, saves and Daily are later phases;
there is no playable board yet.

## Run on Windows

Verified with Flutter **3.47.8**, Dart **3.13.7**, Android SDK **36.1.0** and the
**Pixel_10** Android 16 emulator. Use PowerShell from this repository:

```powershell
flutter --version
dart --version
flutter doctor -v
flutter pub get
flutter emulators
flutter emulators --launch Pixel_10
flutter run -d emulator-5554
```

Use the emulator ID shown by your installation. Flutter and Git must be on PATH.
Android licenses must be accepted (`flutter doctor --android-licenses`).

## Check and build

```powershell
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart run tool/validate_levels.dart assets/levels/pack1.json
dart analyze
flutter test
flutter build apk --debug
git hash-object --no-filters assets/levels/pack1.json
```

Partial validation passes with 8 levels / 32 groups / 128 tile positions.
Strict validation **exits 1 as expected in F1**: three campaign packs and Daily
are intentionally absent. The candidate command reports a replacement preview
and never writes assets. An external candidate path with a new pack ID is
validated as an addition against the installed catalog.

The debug APK is `build/app/outputs/flutter-apk/app-debug.apk`. To verify a
launcher start independently of `flutter run`:

```powershell
$adb = "$env:LOCALAPPDATA/Android/sdk/platform-tools/adb.exe"
& $adb devices -l
& $adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
& $adb -s emulator-5554 shell input keyevent KEYCODE_HOME
```

Open the emulator's app drawer and tap **LexiStack**. In the recorded run, the
first debug cold launch took 5.360 seconds to reach Android's fully-drawn event;
a warm launcher reopen reused the process and showed the previous screen.
If startup seems slow, inspect `adb logcat` before diagnosing an app failure.

## Boundaries and content

- `lib/infrastructure/asset_catalog.dart` reads bundled strings; the shared
  package owns all parsing, models and validation.
- `lib/app/catalog_controller.dart` uses SDK `ChangeNotifier` for loading,
  diagnostics and retry. `lib/ui/` contains navigation and the theme.
- The pure Dart content package is pinned to
  `d9acbd52de0e198dd109a4859299318db3f465f5` at
  [lexistack-content](https://github.com/oliversinz/lexistack-content),
  subdirectory `packages/lexistack_content_contract`; commit `pubspec.lock`.
  There are no game-rule placeholders; the pure Dart engine starts in F2.
- The only installed pack comes from LexiStack3 commit
  `8b84f2d6c75cb807fba9db19cba707f963e02020`. Its Git blob must remain
  `5efa3c88c769f74eee872860766681f5c2cc1c64`. Do not edit or reserialize it.
- Runtime content and SDK typography/icons are local. No font downloads or
  third-party font files are used. Flutter exposes its SDK license notices.
  There is no backend, runtime content fetching, analytics or persistence.
  Android debug manifests retain Flutter's development-tool Internet permission.
- Future imports must follow the assigned phase and
  [reference lock](docs/reference-content-lock.md). Do not add absent files to
  the partial manifest. New Studio-authored content is outside this experiment.

A missing or malformed asset shows its filename/location and a Retry action.
Restore the exact asset and rebuild; retry cannot repair a damaged APK.
Git access is needed at dependency-resolution time. Preserve the pin instead of
substituting a branch when resolution fails. This host lacks Visual Studio, so
Windows desktop builds were not attempted; F1 has Android scaffolding only.
Java/Gradle emitted native-access warnings, but the debug build succeeded.

See [F1 evidence](docs/gate-log.md), [product contract](docs/product-contract.md),
[architecture](docs/architecture.md) and [acceptance matrix](docs/acceptance-matrix.md).
The independent reviewer decides acceptance. F2 has not started.
