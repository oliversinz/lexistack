# F6 — Android release candidate and final verification

**Decision: PENDING independent review.** This is the implementing agent's
evidence record, not an independent gate decision or Experiment E score.

Accepted starting main: `9aec6c82f5fd2e5d86ed4a98dcdf3e799c9ac873`.
Branch: `codex/f6-android-release-candidate`. Source/packaging/capture checkpoint:
`d5a83f3d0e2cc72cd491e0cc386e5237ce95169a`. The final submission is the commit
containing this index and the appended F6 gate record; resolve it with
`git rev-parse origin/codex/f6-android-release-candidate`. Its exact SHA and
post-push status are also supplied in the final chat report. Main must remain
at the accepted starting SHA. No PR, merge, force-push or next phase is authorized.

## Provenance and environment

The attachment `2b46f43d-850d-4fa4-9b58-e98b5177a32b/Pasted text.txt` was copied
byte-for-byte to [the archived prompt](../../../prompts/F6-android-release-candidate-audit.md).
Both SHA-256 values are
`21d8c0ef46f8722a33fefb893475a96db7621546b8dcd20d8d29302983d6adfc`.
Its original CRLF is preserved under `prompts/*.md -text`.

Execution: October 29, 2026, Europe/Berlin (UTC+1). Recorded baseline starts
11:16; final full command sequence is 11:41:36–11:44:47; native restoration is
11:58, followed by documentation/publication checks. Individual logs include
actual timestamps. Android system-clock timestamps are device observations,
not interchangeable with host elapsed time. Agent: Codex, GPT-6 family;
exact serving revision and reasoning-effort value were not exposed. No delegated
agents; **zero human rescue interventions** during F6.

| Component | Observed version |
|---|---|
| Host | Windows 11 26H2, build 10.0.26300.9711; PowerShell 7.6.5 |
| Git | 2.55.0.windows.1 |
| Flutter / Dart | 3.47.8 stable, framework `737ba8f885`; Dart 3.13.7 |
| Android build | SDK/build-tools 36.1.0; Gradle 9.3.1; Android Studio JBR 25.0.3 |
| PATH Java | 25.0.1 (distinct from Flutter's selected JBR) |
| Emulator | Pixel_10, Android 16/API 36, x86_64, 1080×2424; emulator 37.2.12 |
| ADB | 37.0.1; serial `emulator-5554` |
| Browser | Installed Google Chrome 156.0.8078.73, headless via Playwright CLI |

Sources: [preflight](preflight.txt), [doctor](baseline-doctor.txt),
[Flutter](baseline-flutter-version.txt), [Dart](baseline-dart-version.txt),
[platform tools](platform-tools.txt), [Android identity](android-initial.txt).
The Windows registry product-name field says Windows 10 Home; the actual build
and doctor identify Windows 11. Visual Studio C++ tooling is absent, so no
`flutter build windows` was attempted. This does not block Android/web.

## Commands and regression results

All nine required baseline commands ran before production edits. The
`baseline-*.txt` files preserve stdout/stderr, timestamps and native exits:
`flutter --version`, `dart --version`, `flutter doctor -v`, `flutter pub get`,
`dart run tool/validate_levels.dart`, `dart analyze`,
`flutter test --reporter expanded`, `dart run tool/check_prng.dart`, and
`flutter build apk --debug` all exited **0**. Baseline: **195 passing tests**,
strict **40 levels / 160 categories / 640 tile positions**, zero errors and
warnings, initial benchmark PASS; analyzer clean.

The final source is the implementation checkpoint above. Only documentation
and recorded evidence follow it. Final literal command matrix:

| Command | Exit | Actual result / complete log |
|---|---:|---|
| `flutter pub get` | 0 | [Pinned dependencies resolved](final-pub-get.txt) |
| `dart run tool/validate_levels.dart` | 0 | [40/160/640; zero errors/warnings; benchmark PASS](final-validator.txt) |
| `dart analyze` | 0 | [No issues](final-analysis.txt) |
| `flutter test --reporter expanded` | 0 | [197 passed, no skips/failures](final-tests.txt) |
| `dart run tool/check_prng.dart` | 0 | [Four fixed vectors and shuffle/state](final-prng-vm.txt) |
| `flutter build web` | 0 | [Real Flutter application](final-web.txt) |
| `flutter build apk --debug` | 0 | [Debug APK](final-debug-apk.txt) |
| `flutter build apk --release` | 0 | [Release-mode APK](final-release-apk.txt) |
| `flutter test test/ui/f6_capture_test.dart --dart-define=CAPTURE=true --reporter expanded` | 0 | [Two real-app capture tests](canonical-captures-final.txt) |
| `flutter test tool/generate_icons.dart` | 0 | [Production mark rendered at all sizes](icon-generation.txt) |
| `dart compile js tool/check_prng.dart -o build/prng/check_prng.js` | 0 | [Unmodified oracle compiled for browser](browser-prng-compile.txt) |

The 195 accepted tests remain unchanged; two capture/state assertions raise the
suite to 197. No test was deleted, skipped or weakened. The icon generator's
separate build-time test is not included in that 197 count.

## Actual browser execution — ENG-11, PLT-06

The preferred command
`flutter test --platform chrome test/core/prng_test.dart --reporter expanded`
exited **1**: the browser runner's virtual test root could not resolve
`../../tool/check_prng.dart`. See [original failure](browser-prng.txt).
A temporary wrapper with the fixed values compiled but its runner did not
start tests: attached Chrome reported a CanvasKit 404 and a Windows test-path
error. [Runner output](browser-prng-fixed.txt), [actual process](browser-prng-process.txt)
and [browser errors](browser-prng-runner-errors.txt) are retained. That hung
attempt was interrupted (exit 1); the temporary wrapper was removed. The
production PRNG and original VM test/oracle were never changed.

Successful fallback: compile the unchanged oracle above; copy
`tool/prng_browser.html` to `build/prng/index.html`; serve it using
`python -m http.server 8766 --bind 127.0.0.1 --directory build/prng`; execute:

```powershell
npx --yes --package @playwright/cli playwright-cli -s=f6oracle open http://127.0.0.1:8766 --browser chrome
npx --yes --package @playwright/cli playwright-cli -s=f6oracle eval "() => ({userAgent:navigator.userAgent,result:document.body.dataset.result,output:document.querySelector('pre').textContent})"
```

Both CLI commands exited 0. The installed executable was
`C:\Program Files\Google\Chrome\Application\chrome.exe`; its headless user
agent reports Chrome 156. [Browser output](browser-prng-runtime.txt) has
`data-result=pass`, with every fixed number checked inside compiled Dart:

| Seed | Eight actual values (all match fixed expectations) |
|---|---|
| 1 | 16807, 282475249, 1622650073, 984943658, 1144108930, 470211272, 101027544, 1457850878 |
| 42 | 705894, 1126542223, 1579310009, 565444343, 807934826, 421520601, 2095673201, 1100194760 |
| 20261028 | 1224681370, 1736512742, 1266892064, 354559643, 1964283123, 440342930, 614976948, 78772025 |
| 2147483646 | 2147466840, 1865008398, 524833574, 1162539989, 1003374717, 1677272375, 2046456103, 689632769 |

Shuffle: `11,15,6,0,12,13,1,7,14,8,5,3,9,4,2,10`;
final state **1470087647**. These are identical to the independent fixed
expectations in the preserved VM oracle; this is actual Chrome execution,
not a VM/Node substitute or inference from a web build.

## Real Flutter web smoke

The SDK generated only the missing web target using
`flutter create --platforms=web --project-name=lexistack --no-pub .`.
Generated sample-test/lockfile churn was discarded and Android metadata retained.
See [scaffold output](web-scaffold.txt) and [initial diff](web-scaffold-diff.txt).
The app ran from `build/web` on a local static server at `127.0.0.1:8765`.

Observed Home with real fonts/icons, all four Campaign names, actual Table Talk
board, four tap selections enabling Submit, two correct groups with original
titles/facts, centered desktop frame, and persisted board after reload.
[Interaction log](browser-final-interaction.txt), [runtime evidence](browser-final-evidence.txt),
[Home](browser-home.png), [restored board](browser-restored-board.png).
A fresh browser session loaded all **19 requests from localhost with HTTP 200**,
including all six JSON files, fonts and CanvasKit; **zero console errors or
warnings**: [final local-asset log](browser-fresh-local-assets.txt).

The original SDK web defaults fetched CanvasKit/Roboto remotely. The bootstrap
now points to packaged CanvasKit and a Roboto family alias reuses DM Sans.
Missing share-square glyphs also no longer trigger a Noto network fallback.
Browser local storage preserved order/selection/solves/wallet across reload.
With the browser context explicitly offline, reload failed with
`net::ERR_INTERNET_DISCONNECTED`: [offline attempt](browser-offline-repeat.txt).
The Playwright CLI itself returned 0 despite reporting that operation error;
this is **not a successful offline reload**. Restoring online mode recovered
the saved board: [recovery](browser-online-restore.txt). No service-worker or
offline browser repeat-visit claim is made.

## Android native/offline/lifecycle evidence

[The command transcript](android-commands.txt) records literal ADB commands,
host timestamps, stdout/stderr and per-command exit codes. PNGs are direct
`adb exec-out screencap -p` frames; XML files are actual accessibility dumps.
Actions used native `input tap` and long-press `input motionevent DOWN/MOVE/UP`
at bounds observed in those hierarchies. No arbitrary wallet or save injection.

Before mutations, the existing profile was saved in emulator snapshot
`f6-before-verification`, with a raw DataStore backup outside Git.
[Backup record](android-backup.txt); [original JSON](android-original-save.json).
Initial profile: 35 coins, four results/three wins, three Campaign stages won,
unfinished pack4 level1, dark theme, haptics off. The final debug APK was
installed using `adb -s emulator-5554 install -r ...`; launch used the genuine
Pixel launcher icon, not `flutter run` or an activity-start substitute.

Offline controls were `shell cmd connectivity airplane-mode enable`,
`shell svc wifi disable`, and `shell svc data disable`. System connectivity
reported **Active default network: none**, also during the release run:
[release connectivity](android-release-connectivity.txt).

| Native scenario | Observed outcome and evidence |
|---|---|
| Cold Home / four packs offline | [Home](android-offline-home-ready.png), [upper packs](android-offline-packs-top.png), [lower packs](android-offline-packs-bottom.png) |
| Additive long-press tile drag / tray drag / tap | [Two confirmed selections](android-drag-two-confirmed.png), [four confirmed selections](android-four-confirmed.png), genuine Submit |
| Solve and fact reveal | [Film Genres revealed](android-solve-confirmed.png); completed pack4 level1, 0 mistakes, 3 stars, +50: [victory](android-pack4-victory.png) |
| Clipboard | Native Copy result produced [Result copied confirmation](android-copy-result.png). Exact payload is covered by existing widget tests; cross-app paste was not separately tested. |
| Daily offline | Real Oct 29 pool entry `daily_lvl06`, [board](android-offline-daily.png), [3-star win](android-daily-victory.png), +75; wallet 35 → 85 → 160, six results/five wins |
| Wrong / duplicate | pack1 level2: [One Away](android-one-away.png); [same guess rejected without charge/life loss](android-duplicate-guess.png) |
| Paid hints / settings | Pair 30 and Peek 40: wallet 160 → 130 → 90; [settings changed to light/haptics on](android-settings-changed.png); shuffle retained selection |
| Pending loss | [Four mistakes, zero lives](android-pending-loss.png); no categories or facts present in pending XML, no result settlement |
| Extra Life | [Same attempt rescued](android-rescued.png), 90 → 30 coins, one life, still four lifetime mistakes; order/selection/hints/guesses unchanged |
| Eligibility / final loss | Peek/Extra Life show insufficient funds at 30. Fifth distinct mistake returns to [pending](android-pending-after-rescue.png); explicit Reveal produces [final loss](android-final-loss.png), +0 coins, seven results/five wins |
| Haptics | Toggle persisted; [Android vibrator service](android-haptics-system.txt) records app touch/haptic effects. This is emulator service evidence, not physical tactile assessment. |

The failed first `draganddrop` gesture exited 0 but did not add the intended
selection. Files `android-drag-two-selected`, `android-four-selected`, and
`android-first-solve` preserve those unsuccessful intermediate states despite
their optimistic filenames. Only the later **confirmed** files above prove
the successful drag/solve. Early launcher captures sometimes preceded readiness;
they are not claimed as rendered Home.

**Process death:** attempt `a16`, 90 coins, three lives, one mistake, four
selected tiles, paid Pair/Peek, shuffled order. PID **26424** was force-stopped;
`pidof` returned empty with exit **1** (expected process absence). A genuine
launcher restart created PID **28079**. The complete persisted document before
and immediately after cold launch was byte-identical (DataStore SHA-256
`4f4a6c3e39ce3dba1829a92b55a38a407f8f8470867d2fd6b73adf76016862ba`).
Continue changed only entry-recency metadata 16 → 17; game state, wallet,
history and light/haptics settings remained identical. No repeated charge or
reward. [Before](android-before-process-death.png), [after](android-restored-board.png),
[comparison](android-recovery-comparison.txt), [assertions](android-recovery-check.txt).

**Startup distinctions:** Android [system logs](android-startup-system.txt)
report Displayed/Fully drawn **4.926 s** on the first cold launcher start after
installing the corrected debug build (11:39), **4.458 s** after later force-stop
(11:46), and **1.433 s** for the release APK (11:56). An earlier packaging build
reported 5.195 s. These are single emulator observations, not benchmarks or
physical-device performance claims. Warm foreground return retained PID
**28079**, the same final-loss screen and identical persisted data; no cold
startup time is assigned to it. [Warm screenshot](android-warm-resume.png),
[final transition assertions](android-final-checks.txt).

The actual final release APK installed successfully over debug (same signer).
Offline [release Home](android-release-cold-home.png) and [saved Daily result](android-release-daily-result.png)
rendered with wallet 30 and unchanged seven-result/five-win totals; process PID
29305. [Installed release package](android-release-package.txt) records its
non-debuggable release flags. A new full gameplay session was not repeated in
release mode; full touch/gameplay coverage above used debug mode.

**Preservation completed:** the snapshot was loaded after testing, restoring
the original profile, then the final debug APK was reinstalled without clearing
data. The raw original and restored DataStore SHA-256 both equal
`ef99d01130b7781ed28a0903c5facffc37c3271d42c455be626335d29536eb9a`.
Original connectivity was restored: airplane 0, Wi-Fi 1, mobile data 1.
[Restoration record](android-restoration.txt), [restored JSON](android-final-original.json).
The final debug launcher start again preserved this exact hash at 12:05:
[after-launch check](android-restoration-after-launch.txt) and
[original dark Home](android-final-preserved-home.png).
The backup/snapshot remains local and is not committed; no reset or uninstall
was used. All added test progress was confined to the reversible snapshot run.

## Six canonical captures — PLT-07 / UI-12

The new [capture test](../../../test/ui/f6_capture_test.dart) reuses F4's real
`LexiStackApp`, actual JSON asset bundle, memory storage and fixed Oct 28 clock.
It loads Fraunces, DM Sans, symbols/emoji and MaterialIcons explicitly, then
uses real taps/controller transitions. It asserts four selected/actionable
Submit, two solved categories/facts, finalized 3-star victory/+50/200 wallet,
one settled game and accessible red-herring text before capture. PNGs come
directly from `RenderRepaintBoundary`, pixel ratio 1; no compositing/resizing.

| Canonical file | Exact pixels | Visually inspected state |
|---|---|---|
| [01_home.png](../../screenshots/01_home.png) | 390×844 | Production Home, Fraunces hero, wallet, Daily, shelf |
| [02_board_selected.png](../../screenshots/02_board_selected.png) | 390×844 | Four selected real words, boosters, actionable dock |
| [03_board_solved.png](../../screenshots/03_board_solved.png) | 390×844 | Two actual solved groups with both facts expanded |
| [04_result.png](../../screenshots/04_result.png) | 390×844 | Final victory, three stars, +50, facts beginning below |
| [05_packs.png](../../screenshots/05_packs.png) | 390×844 | Actual Campaign collection selector |
| [06_desktop_frame.png](../../screenshots/06_desktop_frame.png) | 1280×800 | Actual centered 460-wide board/dock |

Independent PNG-header dimensions and APK/web asset comparison are in
[packaged-assets-and-dimensions.txt](packaged-assets-and-dimensions.txt).
Every canonical image was opened visually. Genuine scrolling remains visible
at the viewport edge. All result facts/red herrings cannot fit with the victory
header on one phone: [lower facts](../../screenshots/04_result_facts.png) and
[red herrings/share grid](../../screenshots/04_result_red_herrings.png) retain
the same viewport (these two captures happen to reach the same lower position).
[Level selector](../../screenshots/05_packs_levels.png) supplements the shelf.
The fourth pack is below the canonical shelf fold and verified by tests/native
scroll evidence. These extra captures do not replace the six required files.

## Packaging and demonstrated corrections

- Added missing SDK web scaffold/metadata; no Android configuration overwrite.
- Replaced stock Flutter launcher icon with the actual existing `PuzzleMark`.
  [Generator](../../../tool/generate_icons.dart) produces Android mdpi–xxxhdpi
  48/72/96/144/192 pixels and web 32/192/512 pixels. The 280/512 mark fits the
  maskable safe circle. [Real launcher](android-packaged-launcher.png) was
  visually inspected; no runtime graphics package or new brand design.
- Original APK bundled the two font files but omitted their OFL texts from
  assets and notices. Both existing licenses are now explicit bundled assets.
- Real captures exposed missing stars/check/share-square glyphs: preserved
  [before-result](capture-before-symbols-result.png) and [before-solved](capture-before-symbols-solved.png).
  Added only seven needed glyphs via tiny OFL-licensed subsets (5,916 + 3,584
  bytes) and one ThemeData fallback line. Fraunces/DM Sans are unchanged.
  [Reproduction script](../../../tool/generate_symbol_fonts.py) pins upstream
  URLs and SHA-256s: Noto Sans Symbols 2 at Google Fonts commit
  `7b6724ac7ececc713e9ba93af309f7520c9a80a3`, Noto Color Emoji tag `v2.051`.
  Derivative family names are LexiStack Symbols/Emoji; embedded copyright and
  license metadata plus both OFL files are retained. Fonttools 4.68.0 is an
  optional local build-time tool, not an app dependency.
- Local CanvasKit and the DM Sans Roboto alias remove demonstrated remote
  fallback requests. Final fresh-browser request evidence confirms the result.

[APK metadata](apk-metadata.txt), [signature verification](release-signature.txt),
[SHA-256 output](apk-hashes.txt): package `de.cloudwards.lexistack`, display
LexiStack, version **0.1.0+1**, min SDK 24, target/compile SDK 36, three ABIs
arm64-v8a/armeabi-v7a/x86_64. Release manifest has **no INTERNET permission**;
the app-local dynamic-receiver permission is generated. Debug has Flutter's
development-network permission. No runtime network-dependent gameplay exists.

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| Debug APK | 190556440 | `3b90c8da1f35401e0b5d87d3f258a6f4ff9410c4587efdcb11356c348c228ef4` |
| Release APK | 51256737 | `d837a9bddc06bceb212855229452b726aa3ff15048a36e3048b85b1dc56f79a0` |

**Release-mode compiled, debug-signed verification APK — not a
production-signed Play Store release.** `apksigner verify --print-certs` exits 0;
signer CN=Android Debug, certificate SHA-256
`e8303f43f63283012bbe9d1b78689be3d6591c19811ae37a3130900e7519f8f3`.
No real signing credentials were created, requested or committed. APKs remain
ignored build outputs. PowerShell `Get-FileHash` has no native-process exit code;
the blank EXIT field in its log means not applicable, not an unrecorded pass.

## Frozen identities and architecture/regression handoff

[Final identity check](final-identities.txt): all six match the authoritative
reference lock, and APK/web copies are byte-identical to working-tree assets.

| File | Git blob SHA-1 |
|---|---|
| manifest.json | `6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d` |
| pack1.json | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| pack2.json | `32ca5e922e3da3e2b22a42716de87a63e53492f8` |
| pack3.json | `fc88352362ea575e7c0f38670b0c7e81c24ec070` |
| pack4.json | `54c09ae4c2f0a5d07b95addc42e80eacac33d2c6` |
| daily.json | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

The prompt's transcribed Daily hash differs; the actual file matches the
authoritative lock and was not changed. Content Contract ref/resolved-ref/cache
HEAD remain `d9acbd52de0e198dd109a4859299318db3f465f5`, package subdirectory
`packages/lexistack_content_contract`. `pubspec.lock` has no final diff.

Source inspection found no material boundary defect requiring a refactor.
Core is pure Dart; app controllers own transitions/money/Daily/settlement and
capture snapshots before serialized writes; infrastructure only adapts assets
and preferences; UI renders/dispatches actions. Parsing/models/diagnostics
remain in the pinned external package. No production core/app/infrastructure
code changed. The only `lib/` diff is the font-fallback line.

| Acceptance coverage submitted | Evidence / retained regression location |
|---|---|
| ARC-01–04 | Source/dependency inspection, thin CLI, unchanged pin, offline native run |
| CNT-01–11 | Strict validator, `content_test.dart`, `f5_content_test.dart`; all 40 intended-group solves; blob/package comparisons |
| ENG-01–12 | `test/core/game_test.dart`, two-fresh-instance rule oracle, original VM oracle and actual Chrome vectors above |
| ECO-01–09 | `test/app/economy_test.dart`, cross-pack progress tests; native paid hints/rescue/+50/+75/+0 |
| DAY-01–06 | `test/app/daily_test.dart`, civil-date/DST/streak/reward regressions; bundled native Daily |
| PER-01–09 | Persistence/load-recovery/catalog tests; F3-R01 failed-read guard, salvage/orphans, true permutations, fingerprints, serialized writes, reward/practice caps, version-1 fixture; real force-stop recovery |
| UI-01–12 | Existing F4/F5 board/progress/layout/catalog tests, exact clipboard payload/haptic mappings, reduced motion, contrast, semantics and new capture assertions |
| PLT-01–08 | Timestamped environment/build exits; real native tap/drag/launcher/offline/restart; actual browser and inspected canonical captures |

The complete 197-test run includes the real-app layout matrix: 360×640 at 1.3×,
390×844, 1280×800 centered at maxWidth 460, light/dark, long titles/words,
reachable controls/dock, ≥48-pixel targets where asserted, 4.5:1 normal-text
contrast checks, accessible semantics, tier titles independent of color.
The F5 shelf refresh and all named F3/F4/F5 regressions remain exercised.
This table is an evidence map for review, not an independent PASS designation.

## Failures, limitations and independent review

Internal self-corrections, with no human-requested corrective run:

| Classification | Finding and resolution |
|---|---|
| Application/packaging defects | Missing web target, stock icon, omitted font-license assets, missing symbol glyphs and remote web fallback assets; corrected narrowly as above |
| External toolchain | Preferred Chrome runner import failure; temporary runner CanvasKit/path failure; actual Chrome oracle fallback succeeds. No Windows C++ toolchain. |
| Agent/tool coordination | Native Git/rg wildcard expansion on Windows failed (128 / OS error 123); explicit enumeration/filter fixed reads. Generated scaffold sample/lockfile churn removed. Initial draganddrop did not select; observed long-press events corrected it. Some launcher operations ran before drawer/readiness; repeated after hierarchy inspection. |
| Agent/tool coordination | Windows system-font capture fallback did not fix glyphs; replaced with bundled subsets. Initial upstream emoji font URLs returned 404; pinned existing v2.051 source. Two bulk terminal calls were automatically rejected as blocked by policy without a more specific reason; safe session interruption/local-server alternatives completed the work. |
| Evidence/tool caveats | Browser offline operation error despite CLI exit 0 is retained as a failure. Early optimistic screenshot filenames are identified above. Raw command output retains trailing whitespace; one upstream OFL line also has an original trailing space. Source/docs checks exclude those verbatim archival inputs rather than rewriting them. |
| Test-harness-only request | The PRNG HTML host has no favicon, producing one favicon.ico 404; the oracle script and all fixed vectors still execute. The production app's final fresh session has no failed asset requests. |
| Build warnings | Java native-access warnings; web font tree-shaker mentions CupertinoIcons while observed app uses MaterialIcons; outdated-package notices; Wasm dry run succeeds but no Wasm runtime claim. No dependency upgrade added. |

The retained system log also contains a **09:48 pre-F6 UIAutomator service
registration crash**, whose stack is in `com.android.commands.uiautomator`,
not the LexiStack process. It predates this run and is not a new app crash.
The log was not cleared to manufacture clean evidence.

[Final Git/content/prompt/link audit](git-final-audit.txt) exits 0. Historical
gate-log content is an unchanged prefix; protected paths have no diff; prompt
bytes, PNG dimensions and complete original/restored Android JSON match.
[Full whitespace check](git-whitespace-full.txt) exits 2 on preserved upstream
license/raw-output whitespace. [Source/documentation check](git-whitespace-source-docs.txt)
exits 0 with those explicit archival exclusions and CRLF prompt handling.

No unresolved engineering defect was observed in the completed required probes.
Limits remain explicit: no production signing/store submission; no physical
device or tactile test; no offline browser reload support; Windows desktop and
the preferred Flutter Chrome runner unavailable as described. The supported
browser-harness path did execute all mandatory vectors. Clipboard action was
observed natively, while exact text is verified in tests. Shared preferences
does not guarantee hard power-loss durability. No independent score, winner,
CAT editorial judgment or C/D reproduction is claimed here: the assignment
reserves that comparison to the independent reviewer at the historical C/D
commits. Their source/repositories were not modified or copied.

Reviewer reproduction: use the root README command block, this final matrix,
the browser oracle harness and the named Android scenarios on an isolated
snapshot. Inspect the full branch diff against the accepted starting SHA,
the six PNGs, protected-file identities and submission SHA. F6 acceptance and
the C/D/E scorecard remain **PENDING independent review**.
