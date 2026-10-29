# F5 implementation evidence — PENDING independent review

These are implementation-agent executions on Windows, not independent acceptance.
Only F5 was assigned. No F6 browser execution, canonical six-screen capture,
release packaging, main integration, or production editorial revision was done.

## Reproduction and provenance

- Approved clean starting main: `8b07d01443277b6c1af0201d481c9a1174412093`.
- Branch: `codex/f5-full-frozen-catalog`.
- Initial implementation checkpoint: `827892b28c1690e0385ce502596ba90089d2467b`.
  The subsequent shelf correction and evidence commit is the submission commit
  containing this report; its exact published SHA is in the final chat report.
- Source: `oliversinz/LexiStack3` at `8b84f2d6c75cb807fba9db19cba707f963e02020`.
  Only locked JSON blobs were read. Python `subprocess.check_output(git cat-file
  blob ...)` and `Path.write_bytes` installed manifest/pack2/pack3/pack4.
  Pack1 and Daily were compared and left untouched.
- Content package pin and resolved Git checkout:
  `d9acbd52de0e198dd109a4859299318db3f465f5`,
  `packages/lexistack_content_contract`. Lockfile unchanged; no new dependency.
- Supplied attachment `Pasted text.txt` was copied to
  `prompts/F5-full-frozen-catalog-regression-hardening.md`. Attachment, working
  file and committed blob are byte-identical. SHA-256:
  `e34cf2a1e1d982287deff36e94bce745a23b11ef3e703bef48c7facc569b454f`.
  This asserts identity with the supplied file, not reconstructed chat text.
- Agent: Codex / GPT-6 family; exact model revision, reasoning effort, token cost
  and reviewer time are not exposed. Human rescue/repair interventions: **0**.
- First recorded preflight timestamp: **2026-10-29 09:22:07 +01:00**.
  This is the recorded execution window, not a claim of total turn runtime.
- Windows 11 `10.0.26300.9711`; PowerShell; Flutter **3.47.8**, Dart **3.13.7**;
  Android SDK **36.1.0**, emulator **37.2.12.0**, Java **25.0.3**.
  Pixel_10 / `emulator-5554`, Android 16 API 36, 1080×2424 at 420 dpi.

See [preflight](preflight.txt), [doctor](doctor.txt),
[provenance](provenance.txt), and [Git checks](git-checks.txt).

## Production content and candidate previews

Every Campaign pack (`pack1`–`pack4`) and Daily has **8 levels, 32 categories,
128 tile positions**: **32 Campaign + 8 Daily = 40 levels, 160 categories,
640 tile positions**. Manifest order is pack1, pack2, pack3, pack4; Daily is
`daily.json`. Strict and partial runs both report **0 errors, 0 warnings**.
Strict minimum and initial benchmark both report **PASS**. Partial output is
explicitly labelled PARTIAL. Warning counts are asserted separately from exit
codes, including an advisory-warning fixture whose CLI-compatible exit is 0.

| File | Verified Git blob SHA-1 |
|---|---|
| manifest.json | `6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d` |
| pack1.json | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| pack2.json | `32ca5e922e3da3e2b22a42716de87a63e53492f8` |
| pack3.json | `fc88352362ea575e7c0f38670b0c7e81c24ec070` |
| pack4.json | `54c09ae4c2f0a5d07b95addc42e80eacac33d2c6` |
| daily.json | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

[Identity report](content-identities.txt), [strict](validator-strict.txt),
[partial](validator-partial.txt), and [APK asset inspection](apk-assets.txt)
provide filesystem and packaged-byte evidence. `loadAssetCatalog(rootBundle)`
tests use the actual registered Flutter bundle and strict runtime validation.
There is no fallback content or second production validator.

- Unchanged pack2 candidate: **REPLACEMENT**, names `pack2.json` as replaced,
  preview only, **40 levels**, exit 0, no errors/warnings.
- Valid synthetic eight-level candidate: **ADDITION**, preview only, **48 levels**,
  exit 0, no errors/warnings. Mechanical schema data only; not editorial content.
- Conflicting new-ID copy: **ADDITION**, exit **1 expected**, 82 actionable
  cross-catalog errors (including titles, overlapping groups and duplicate boards).
- [Before](candidate-hashes-before.txt) and [after](candidate-hashes-after.txt)
  hashes are identical for all six files. Production manifest still has five packs.
  Recreate temporary candidates with
  `dart run test/support/candidate_fixture.dart "$env:TEMP/lexistack-f5-candidates"`.

## Behavioral coverage and changes

All earlier tests are retained. Production fixture inventories now derive from
the parsed manifest; explicit incomplete fixtures retain partial-vs-strict tests.
Missing pack1, pack2 and pack4 bundled assets still produce named UI errors.
Existing pack1 navigation tests explicitly target the first of four pack cards.
The typography audit checks every rendered element, including shared const labels.

- **CNT-01–11:** schema/parser mutations, missing fields/files, duplicate IDs,
  invalid counts/tiers/pack references, tile forms and repetitions, normalized
  titles, overlaps/duplicate boards, trivia boundaries/warnings, red-herring
  references/notes, candidates, exact manifest and all production identities.
  Every one of 40 boards is solved through stable IDs, preserving four lives,
  zero mistakes and three stars; 40 level IDs and 640 tile IDs are globally unique.
- **ECO-03/05/06:** all eight stages in each real Campaign pack independently
  unlock; replay loss/lower stars preserve unlocks and best stars across restart.
  Continue follows all 32 levels in manifest order, prefers the most recently
  entered unfinished attempt including pending loss, and opens the shelf after
  completion. Explicit replay remains available; Daily is excluded.
- **PER:** `test/fixtures/f4-progress-v1.json` was generated by the existing
  controller using the pre-F5 two-file manifest, frozen pack1/Daily and injected
  dates October 27–29. It is a deterministic test fixture, not a user's account
  export. The test regenerates and compares its complete decoded document.
  Restoration into the full catalog preserves **195 coins, five settled results,
  best stars, consumed practice payout, two Daily wins/streak, three Campaign
  attempts, today's hinted Daily, settings, counters, selection/order/guesses,
  solved categories, pairs/peeks and a pending loss**. Loading performs no writes
  or payouts. Rescue charges exactly 60; an already-paid replay grants zero.
- Same-ID material trivia change in a test-only catalog discards only the
  affected unfinished attempt; all other serialized sections, historical
  results and existing reward locks are retained. No migration was needed.
- Existing **F3-R01**, malformed-section salvage, duplicate settlement/reward
  farming, queued write ordering, economy/Daily, haptic/clipboard, semantics,
  contrast, reduced motion and prior engine regressions run in the full suite.
- **UI:** actual-bundle navigation and group solves cover all four packs. New
  long group labels are exercised with actual fonts at **360×640 / 1.3×**,
  **390×844 / 1×** and **1280×800 / 1×**, with a centered 460 px frame.
  The earlier light/dark typography and layout matrices remain in the suite.

One production defect was found during native verification: the existing
`PacksScreen` route did not listen for progress updates. A win persisted and
unlocked the next stage, but returning to that shelf showed the old solved count.
[Before-fix native evidence](android-stale-shelf-before-fix.png) and
[failing regression](tests-shelf-reproduction.txt) reproduce it. Wrapping that
screen in the existing `ListenableBuilder` pattern refreshes cards immediately.
This is a **UI-03 / F5 progress-display correction**; engine, economy, persistence,
themes, fonts and protected contracts are unchanged.

## Command record

Commands ran from `C:\Codex\LexiStack`; each linked log records literal commands,
output and exits. CLI candidate paths are expanded literally inside their logs.

| Command | Exit | Evidence |
|---|---:|---|
| `flutter pub get` | 0 | [pub-get.txt](pub-get.txt); unchanged lockfile |
| `dart run tool/validate_levels.dart --partial` | 0 | [validator-partial.txt](validator-partial.txt) |
| `dart run tool/validate_levels.dart` | 0 | [validator-strict.txt](validator-strict.txt) |
| `dart run tool/validate_levels.dart assets/levels/pack2.json` | 0 | [replacement](candidate-replacement.txt) |
| `dart run tool/validate_levels.dart C:\Users\olive\AppData\Local\Temp\lexistack-f5-candidates/valid-addition.json` | 0 | [addition](candidate-valid-addition.txt) |
| `dart run tool/validate_levels.dart C:\Users\olive\AppData\Local\Temp\lexistack-f5-candidates/invalid-addition.json` | 1 expected | [rejected addition](candidate-invalid-addition.txt) |
| `dart analyze` | 0 | [final analysis](analysis-shelf-fixed.txt), no issues |
| `flutter test --reporter expanded` | 0 | [baseline](tests-baseline.txt), 155 passed; [final](tests-shelf-final.txt), 195 passed |
| `dart run tool/check_prng.dart` | 0 | [VM goldens](prng-vm.txt); no browser execution claimed |
| `flutter build apk --debug` | 0 | [final APK](apk-final.txt) |

Focused commands and earlier corrective reruns are retained in `tests-*.txt`.
Initial new-test failures: expected internal fingerprint exception wording rather
than the public recovery notice; matched both feedback and reveal text; typography
finder matched shared const widgets; misplaced shelf assertion briefly failed
compilation. Corrections changed test targeting, not existing behavior assertions.
The real stale-shelf defect then failed a valid test before the production fix.
An `avoid_print` informational lint in the fixture exporter was corrected to
`stdout.writeln`. Initial plain Git whitespace checking flagged the exact CRLF
prompt; the required original bytes were preserved and the entire committed diff
passes with `git -c core.whitespace=cr-at-eol diff --check`.

## Native Android observations

The established emulator was started early. Before the import, its pre-existing
installed app displayed a finalized loss and had **5 coins, two results, one
Campaign win, dark theme and haptics off**. Its installed APK provenance was not
assumed to equal the accepted source commit. After the first F5 `install -r` and
actual launcher-icon tap, the entire DataStore file remained byte-identical:
SHA-256 `70773ff86fc85889df86df80c1d58367e276a7e3f1128a975f27f1502188d3cc`.

1. Inspected all four titles/descriptions on the Campaign shelf. Entered all
   three newly installed packs and their first real boards.
2. In Science & Nature, dragged **MARS onto VENUS**, tapped SATURN/JUPITER and
   submitted the actual group. Solved the remaining three groups with taps:
   **four lives, zero mistakes, three stars, +50**, wallet **5→55**. Stage 2
   became ready while later stages stayed locked.
3. Returning to the existing shelf exposed the stale counter described above.
   After the source fix, full regression and rebuilt/reinstalled APK, solved
   all four groups of World History & Myth's **Echoes of Empire**. Wallet
   **55→105**, another three-star result, stage 2 ready. The existing shelf
   immediately showed **1/8** for pack3, retained **1/8** for pack2 and **0/8**
   for pack4. No relaunch was needed for that counter update.
4. Entered Pop Culture & Wordplay's **Opening Night**. Selected DOROTHY, bought
   Pair Magnet and Category Peek, then shuffled. Wallet **105→75→35**.
5. Captured the persisted document and force-stopped the process. `pidof`
   changed from **23374** to no process (exit **1 expected**). Relaunched by
   launcher icon: new PID **24631**, pre-kill DataStore bytes unchanged,
   SHA-256 `10ca7e15ebd14b972f6a7a994eaf133d2ec35dbd69e80f8c028b5b259afefdb8`.
   Continue restored the same attempt ID and complete game snapshot (order,
   selection, pair, peek). Original two results/pack1 achievement/settings were
   unchanged; four results total, 35 coins, no repeated charge/reward. Only the
   normal entry counter advanced on Continue.

[Native commands and exit codes](android-commands.txt),
[save comparisons](android-save-compatibility.txt), pre-upgrade and pre-kill JSON
snapshots, screenshot XML companions, and [final-process logcat](android-logcat-final.txt)
are retained. The screenshots are unedited Android PNGs, not mockups or F6
canonical screenshots. Visually inspected examples:

- [Upgraded Home](android-upgraded-home.png) and [all new pack titles](android-campaign-bottom.png).
- [Actual drag/tap solve](android-pack2-solved-group.png), [pack2 victory](android-pack2-won.png),
  [pack2 unlock](android-pack2-unlock.png).
- [Pack3 board](android-pack3-fresh.png), [pack3 victory](android-pack3-won.png),
  [pack3 unlock](android-pack3-unlock.png), [live corrected shelf](android-shelf-fixed.png).
- [Restored pack4 board with selection and paid hints](android-pack4-restored.png).

Final debug APK SHA-256:
`8ba58f3ae780a6a22559cd2206639d9905fdad15d7810769d810b15dcb4a31e4`.
APK binaries and emulator state are not committed. Final native verification
ended **2026-10-29 09:51:38 +01:00**.

No unresolved application defect or required environment-blocked probe was
observed. Tooling issues were recovered without human intervention: `adb` was
not on PATH (absolute SDK path used); an initial read looked for legacy
`shared_prefs` rather than the plugin's DataStore; two navigation attempts ran
before the intended UI transition was ready; one overlapping UIAutomator dump
failed when a second probe was started before the previous command completed.
The overlap was an agent coordination error; remaining native probes were run
sequentially. Failed probes and corrective runs are retained. No data reset or
save-file injection was used. Java native-access warnings were nonfatal.
Visual Studio is absent, so Windows desktop compilation is unavailable and not
required for this F5 assignment. Browser, release and canonical F6 audits remain
unperformed; editorial review and gate acceptance remain independent.

## Independent editorial review readiness

CAT-01–04 judgments remain for independent assessment. These ten source levels
span all five files and multiple Tier 4 groups for a reproducible review sample:

| Level ID | Title | Tier 4 connection |
|---|---|---|
| pack1_lvl01 | Table Talk | PAIRS WITH JAM |
| pack1_lvl08 | Hidden in Plain Sight | FOLLOW BLACK |
| pack2_lvl01 | Other Worlds | BEFORE CELL |
| pack2_lvl08 | Natural Doubles | BOTH SCIENCE AND EVERYDAY VERBS |
| pack3_lvl01 | Echoes of Empire | BEFORE AGE |
| pack3_lvl08 | Names Outlive Empires | BEFORE MARK |
| pack4_lvl01 | Opening Night | BEFORE STAR |
| pack4_lvl08 | Encore, Encore | CAN FOLLOW DOUBLE |
| daily_lvl01 | First Light | BEFORE WALK |
| daily_lvl08 | Look Again | REVERSE TO MAKE A DIFFERENT WORD |

The locked JSON retains all facts and red-herring notes for those IDs. Technical
solvability and zero mechanical warnings do not prove semantic uniqueness, fact
accuracy, editorial fairness or diversity; no editorial certification is claimed.
