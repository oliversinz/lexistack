# LexiStack — F3 persistent offline game

Find four groups of four words before exhausting four lives. Tap to toggle;
hold and drag onto another tile to add both, or onto the tray to add one.
Shuffle is free. Repeating a wrong set costs no extra life; three matching
words produce **One Away!**. At zero lives, solutions stay concealed until
**Reveal / Accept Loss**. A paid rescue continues the same attempt.

The installed content is **8 campaign levels and 8 separate Daily boards**.
Campaign stage 1 is unlocked; winning unlocks the next stage in that pack.
Continue resumes the most recently entered unfinished campaign attempt,
including pending loss. Finished levels require an explicit replay.

- Start with **150 coins**. Pair Magnet costs **30**, Category Peek **40**,
  Extra Life **60**. Rejected actions do not charge or change the game.
- Stars use lifetime mistakes: **0 → 3**, **1–2 → 2**, **3+ → 1**, including
  after rescues. A campaign level's first win pays **50/30/15** coins.
- The first successful replay pays **5 once per level**; later replay wins
  pay zero. Best stars never decrease.
- Daily permits one attempt per local civil date. Its first win pays the star
  reward **plus 25**. The eight-board pool repeats every eight days.
- Finalized wins/losses count toward statistics; pending losses and abandoned
  old-day Daily attempts do not. Home shows actual statistics and streaks.

## Run and verify on Windows

Verified toolchain: Flutter **3.47.8**, Dart **3.13.7**, Android SDK **36.1.0**,
Pixel_10 / Android 16. Use PowerShell from this repository:

```powershell
flutter doctor -v
flutter pub get
flutter emulators --launch Pixel_10
flutter run -d emulator-5554
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build apk --debug
git hash-object --no-filters assets/levels/pack1.json
git hash-object --no-filters assets/levels/daily.json
```

Partial validation: **16 levels / 64 groups / 256 tile positions**, zero errors
and warnings. Strict validation **intentionally exits 1 in F3** because three
campaign packs remain for F5; Daily is installed and valid. To validate an
external candidate without changing assets:
`dart run tool/validate_levels.dart path/to/candidate.json`. Matching pack IDs
are replacement previews; new IDs are additions. Future imports must follow
the assigned phase and [reference lock](docs/reference-content-lock.md).

For an actual launcher/process-restart check:

```powershell
$adb = "$env:LOCALAPPDATA/Android/sdk/platform-tools/adb.exe"
& $adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
& $adb -s emulator-5554 shell input keyevent KEYCODE_HOME
# Open the app drawer and tap LexiStack; play and wait for Saving to clear.
& $adb -s emulator-5554 shell pidof de.cloudwards.lexistack
& $adb -s emulator-5554 shell am force-stop de.cloudwards.lexistack
# Tap the launcher icon again, then Continue Campaign.
& $adb -s emulator-5554 shell pidof de.cloudwards.lexistack
```

## Implementation and recovery

`lib/core/` contains pure-Dart rules, scoring, sharing, civil-day arithmetic,
PRNG and validated game snapshots. The pinned external content package owns
all content parsing/validation; `asset_catalog.dart` only loads assets.
`ProgressController` coordinates money, progression, Daily, results and saves;
`BoardController` forwards gestures. UI uses SDK `ChangeNotifier` listeners.

One JSON document, **version 1**, is written under **`lexistack.progress`** by
`SharedPreferencesAsync` (Android's default DataStore preferences backend).
Storage and local clock are injected; `MemoryProgressStorage` supplies delayed
writes and failures in tests. Each successful transition captures its entire
snapshot before joining the serial write queue. `flush()` waits for that queue.
Failures display **Progress not saved** and offer Retry; subsequent writes work.
This lightweight local store does **not** promise hard power-loss durability or
protection against deliberate, internally consistent save-file edits.

Unfinished attempts retain board/selection order, history, seed/current PRNG,
solved groups, hints, lives, mistakes and pending decisions. Recovery requires
a true unique permutation and checks history through the engine. The semantic
fingerprint is canonical JSON of the level's ordered IDs, titles, tiers, words,
facts and red herrings: collision-free, independent of whitespace/object-key
order, and not a runtime hash. A removed or changed level drops only its
unfinished attempt. Historical summaries, share rows and achievements survive.

Valid wallet, achievements, results, Daily outcomes and settings are salvaged
independently. Invalid individual entries are omitted with a notice; malformed
root/version resets to fresh defaults. Corrupt finalized records retain ID/date
or level reward locks to prevent fresh payouts; valid history repairs missing
progression flags. A wholly invalid history locks rewards until confirmed Reset.
Reset restores 150 coins, empty attempts/history/Daily, system theme and haptics
on. Full theme/haptics controls and clipboard integration belong to F4.

Daily index uses UTC midnights made from **local calendar components**, relative
to **2026-01-01**. Pool index is normalized `dayIndex % 8`; seed is
`(dayIndex % 2147483646) + 1`. Epoch seed is 1; 2026-10-28 is index 300, board 5,
seed 301. Campaign seeds use the new attempt's serial modulo that range, plus 1.
Park–Miller and Fisher–Yates are unchanged; VM golden vectors remain in
`tool/check_prng.dart`. Actual browser PRNG execution remains F6.

Content contract pin: **`d9acbd52de0e198dd109a4859299318db3f465f5`**;
commit `pubspec.lock`. Frozen source commit:
**`8b84f2d6c75cb807fba9db19cba707f963e02020`**. Required blobs:
`pack1.json` **`5efa3c88c769f74eee872860766681f5c2cc1c64`**,
`daily.json` **`5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6`**.
Do not edit or reserialize those fixtures. Runtime assets/SDK fonts are bundled;
there is no backend, analytics, ads, billing or runtime content network.

See [gate log](docs/gate-log.md) and [F3 evidence](docs/evidence/f3).
F1/F2 are accepted; **F3 is PENDING independent review**. F4 has not started.
Windows desktop compilation is unavailable on this host without Visual Studio;
Android builds work, with nonfatal Java native-access warnings.
