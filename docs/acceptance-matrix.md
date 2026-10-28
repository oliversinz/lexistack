# LexiStack5 — Acceptance Matrix v1.0

**Test baseline:** Optimized Genesis v1 behavior. **Applicability:** An ID is a blocking gate only from its stated first phase onward (unless marked editorial observation). Every later phase must preserve previously accepted behavior. Full final acceptance is F6. Evidence is actual command output, executable tests, emulator screenshots/observations or independently inspected code—not a README assertion or test count alone.

Test fixtures must contain correct, unambiguous synthetic boards; real-content tests must use the frozen reference assets. Mandatory independent oracle uses **two fresh game instances** to avoid testing already-solved tiles in the mismatch path.

## A. Architecture and reproducibility

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| ARC-01 | F1 | Content contract and core game rules contain no Flutter imports; CLI works without Flutter engine process | Source dependency inspection + Dart tests |
| ARC-02 | F1 | `lexistack_content_contract` resolves from immutable Git SHA and package subdirectory; lockfile committed | `pubspec.yaml` + `pubspec.lock` + resolved commit |
| ARC-03 | F1 | Application uses distinct pure core, application/controller, UI and infrastructure boundaries; no copied LexiStack3/4 Flutter source | Independent architecture inspection |
| ARC-04 | F1/F6 | No backend/runtime LLM, telemetry, ads, billing, audio, accounts or network-required Android gameplay | Dependency/source inspection; offline Android smoke by F6 |

## B. Content contract and validation

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| CNT-01 | F1 | Production schema version **2**; manifest preserves campaign order; strict final requires Daily, while interim partial manifest may omit not-yet-present Daily | Parser fixture + partial catalog report |
| CNT-02 | F1 | Per level: four groups of four distinct tiles, tiers 1–4 exactly once, stable IDs, correct `packId`, one valid trivia sentence per group | Valid + mutated fixtures |
| CNT-03 | F1 | `--partial` accepts fully valid present files (at least one), including temporary campaign-only manifest; strict mode rejects incomplete catalog or missing final Daily | CLI exit codes and output |
| CNT-04 | F1 | Malformed JSON/types/IDs lead to actionable locations, not opaque runtime exceptions | Negative parser/validator cases |
| CNT-05 | F5 | Final manifest exactly `pack1.json`–`pack4.json` + `daily.json`; **8 levels each**, 32+8 total, 160 groups, 640 tile positions | Strict CLI summary, zero errors and warnings |
| CNT-06 | F5 | Reject duplicate pack/level/category IDs, invalid tiers, missing files, invalid `packId` and missing required schema keys | Negative fixtures including cross-file |
| CNT-07 | F5 | Reject normalized duplicate category titles, any tile in >2 different levels and category pairs overlapping on ≥3 tiles | Catalog-wide mutant fixtures |
| CNT-08 | F5 | Reject repeated board words, illegal uppercase/spacing/word length and duplicate boards; tile identity never depends only on display string | Negative fixtures + model inspection |
| CNT-09 | F5 | Red herrings reference only board tiles, have a meaningful note; trivia 40–160 characters and validator warnings are reported; final zero warnings | Negative fixtures + strict report |
| CNT-10 | F5 | Candidate pack can replace matching pack ID or add new pack; no mutation of installed assets; decision reported clearly | Before/after asset hashes + CLI output |
| CNT-11 | F5 | All 40 frozen levels technically solvable via intended groups, and source JSON matches locked reference blob IDs | Production-level tests + source identity report |

## C. Game-engine oracle

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| ENG-01 | F2 | Fresh game: 16 tiles/4 groups/4 lives; shuffled deterministically | Pure-Dart test |
| ENG-02 | F2 | Selection toggles; fifth selection ignored; Deselect clears; solved tile is unselectable | Pure-Dart test |
| ENG-03 | F2 | Tap and additive drag-to-tile/tray result in equivalent selected-ID transitions, max four | Pure-Dart transition + F2 Android gesture |
| ENG-04 | F2 | **Fresh instance 1:** solve `[MARS, VENUS, SATURN, JUPITER]`; lives=4, 12 unsolved tiles, selection empty | Independent two-instance rule oracle |
| ENG-05 | F2 | **Fresh instance 2:** `[MARS,VENUS,SATURN,MERCURY]` => One Away, 4→3 lives; reversed identical set => already guessed, still 3, no extra row | Independent rule oracle |
| ENG-06 | F2 | Same instance 2: `[MARS,VENUS,MERCURY,GOLD]` => normal mismatch, 3→2 lives | Independent rule oracle |
| ENG-07 | F2 | Four evaluated mistakes cause `lostPendingDecision`, not immediate reveal; invalid/duplicate guesses do not change money, mistakes, life or history | Domain transition tests |
| ENG-08 | F2 | Pending loss can be rescued to same board at one life when eligible; explicit Reveal/Accept Loss => `lostFinal`, cannot rescue | Domain transition tests |
| ENG-09 | F2 | Fourth solved group => `won`; finalization occurs exactly once; all result states reject illegal submissions | Domain transition tests |
| ENG-10 | F2 | Correct guesses increment combo, wrong guesses reset it; guess history preserves submission order and tier colors | Domain tests |
| ENG-11 | F2/F6 | Seed + identical shuffle operations yields identical order and documented golden PRNG values; **real browser compilation/execution required F6** | Golden vectors in VM and web runtime |
| ENG-12 | F2/F4 | Share string uses correct tiers/order and finalized-only availability; win stars and loss `n/4 groups` formatting match contract exactly | Pure share oracle + clipboard widget |

## D. Economy, progression, boosters

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| ECO-01 | F3 | Fresh 150 coins; campaign first win grants **+50/+30/+15** for 3/2/1 stars | Separate fresh-win cases |
| ECO-02 | F3 | 0 mistakes=3 stars; 1–2=2; 3+=1 even after heart restore or multiple rescues | Mistake-counter oracle |
| ECO-03 | F3 | Replay may improve best stars but never replace higher best with lower result | Progress tests |
| ECO-04 | F3 | First *winning replay* grants **+5 practice coins once per campaign level**; later replay wins +0 | Multi-replay tests + reopen |
| ECO-05 | F3 | Campaign pack stage 1 unlocked; n+1 after win n; packs progress independently | Unlock/continue tests |
| ECO-06 | F3 | Continue resumes most recent unfinished campaign including pending loss, otherwise earliest unlocked never-won; all-won opens selector | Controller tests |
| ECO-07 | F3 | Pair Magnet **30**: selected-tile group if eligible (include it), else lowest-tier eligible group; hint persists | Deterministic targeting/round-trip |
| ECO-08 | F3 | Category Peek **40**: lowest-tier unpeeked unsolved group; Extra Life **60**, capped at four and legal in pending loss | Deterministic transition tests |
| ECO-09 | F3 | Inapplicable, unavailable or unaffordable boosters reject without charging/mutating state; no booster charges twice on reload | Negative tests + persistence test |

## E. Daily mode, statistics and payouts

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| DAY-01 | F3 | Civil-day UTC-calendar arithmetic from **2026-01-01**; DST and leap days do not skip/duplicate indexes | Injected-clock date tests |
| DAY-02 | F3 | Eight separate Daily levels; `dayIndex % 8`; same local civil date yields same board seed and puzzle | Same-day reopen/golden cases |
| DAY-03 | F3 | One Daily attempt/date; finalized result not replayable; unfinished prior-day board discarded without counting win/loss | Cross-midnight tests |
| DAY-04 | F3 | Daily first win/date grants star reward **plus 25** once, no practice payout or second daily reward | Two-reopen payout tests |
| DAY-05 | F3 | Current streak ends today or yesterday if no result today; today's loss or missed day breaks streak; best streak persists | Win/loss/skip sequence tests |
| DAY-06 | F3 | `gamesPlayed` counts only `won` or `lostFinal`; perfect zero-mistake wins, win rate, buckets `0/1/2/3/4+` and history survive reopen | Controller/statistics tests |

## F. Offline persistence and defensive recovery

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| PER-01 | F3 | One versioned JSON document with injected store and separately recoverable player, history, attempts, settings and daily data | Encode/decode round-trip |
| PER-02 | F3 | Reload retains exact unsolved board order, selection, guesses, solved groups, hints, lives, mistakes, status and Daily date | Controller reload tests |
| PER-03 | F3 | Missing/renamed levels invalidate only their unfinished attempts; retained finalized results, valid coin balance and unrelated best-stars survive | Orphan-level corruption case |
| PER-04 | F3 | Restored board `order` must be a one-to-one permutation of expected unsolved IDs; duplicate known ID + missing ID must be rejected | **Adversarial regression for LexiStack4 defect** |
| PER-05 | F3 | Reject invalid selection, duplicate solved groups, impossible state, malformed guesses, double payouts and invalid tile/category references | Property-style malformed fixtures |
| PER-06 | F3 | Wholly malformed/version-incompatible root resets safely; a corrupt single attempt is discarded without global-progress wipe | Partial-salvage tests |
| PER-07 | F3 | Content fingerprint mismatch under same level ID invalidates only the incompatible unfinished attempt | Fixture update + restore |
| PER-08 | F3 | Asynchronous writes cannot allow older state to overwrite newer snapshots | Deliberately reordered fake-store completion |
| PER-09 | F3 | Storage failures are surfaced and must not be reported as persisted; Reset confirms and restores precise fresh defaults | Failure-injection + UI workflow F4 |

## G. Flutter UX and accessibility

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| UI-01 | F1 | Actual Flutter app renders a real shell (not image/mock website) and navigates to genuine content | Widget + emulator first launch |
| UI-02 | F2 | 16-tile board supports tap/drag interaction, selected state and submit; correct solve visibly reveals the real title/fact | Real-app widget + Android touch |
| UI-03 | F4 | Functional Home, Packs, Board, Results/Pending Loss, Stats and Settings; links/buttons work | Real-app navigation tests |
| UI-04 | F4 | Board has four heart indicators and group slots, selection count/tray, Shuffle/Deselect/Submit, visible booster prices/eligibility | 390×844 screen interaction |
| UI-05 | F4 | Three boosters apply real effects and update coins/UI, including disabled reason when practical | Widget transitions |
| UI-06 | F4 | One Away/Already guessed feedback, correct solve reveal, appropriate restrained motion and visual hierarchy | Interaction + visual inspection |
| UI-07 | F4 | Pending loss conceals **all** unsolved answers/trivia until explicit final reveal; rescue returns same board | Widget + restore navigation test |
| UI-08 | F4 | Result Share copies contract-exact spoiler-free emoji string to clipboard only after final result | Clipboard fake + exact text |
| UI-09 | F4 | Theme light/dark/system, haptics toggle (genuinely suppresses haptics), confirmed Reset and restored defaults | Widget + storage tests |
| UI-10 | F4 | 360×640 at 1.3× text, 390×844 and 1280×800 centered maxWidth 460; no essential controls clipped or overflow | Layout tests + visual checks |
| UI-11 | F4 | ≥48×48 logical-pixel target, normal-text contrast target 4.5:1, meaningful semantics/labels, category cues not color-only | Widget/accessibility inspection |
| UI-12 | F4/F6 | Haptic call mapping, reduced motion, bundled real fonts/assets; 6 specified genuine screenshots visually inspected by F6 | Tests + real PNG inspections |

## H. Real platform and delivery evidence

| ID | First gate | Contract / independent probe | Required evidence |
|---|---|---|---|
| PLT-01 | F1 | Record Windows, actual Flutter/Dart/SDK versions, `flutter doctor -v`, Git state and emulator identity | Timestamped command outputs |
| PLT-02 | F1 | `flutter build apk --debug` succeeds; app launches from Android launcher on emulator, not just `flutter run` | APK command exit code, emulator observation |
| PLT-03 | F2/F4 | Physical emulator tap/drag gameplay works, not inferred from a widget-only test | Android observation and/or integration-test logs |
| PLT-04 | F3/F4 | Android process close/reopen restores active attempt and settings | Android lifecycle smoke log |
| PLT-05 | F6 | Real exit codes: `flutter pub get`, strict validator, `dart analyze`, `flutter test`, `flutter build web`, debug APK | Commands + exit codes + test totals |
| PLT-06 | F6 | PRNG golden values actually executed in browser-compiled Dart/Flutter code | Browser runtime evidence (not only build) |
| PLT-07 | F6 | Real PNG captures: home, board selected, board solved (2 groups), result with facts/red herrings, packs, 1280×800 desktop frame | Six inspected files at exact scenario sizes |
| PLT-08 | F6 | Android fully offline with bundled assets; release build attempted where tooling supports it; cold/warm startup differences documented; no fabricated Play-signing claims | Offline Android smoke + APK/build metadata |

## I. Editorial observations (separate score; not blockers for unchanged benchmark assets)

| ID | First review | Editorial question | Required evidence |
|---|---|---|---|
| CAT-01 | F5 | Manually inspect **≥8 levels** across all 5 JSON files, including multiple Tier 4 groups | Review sheet with level IDs |
| CAT-02 | F5 | Is every grouping title literally true for its four words, with no equally compelling alternate full partition? | Explicit counterexample search |
| CAT-03 | F5 | Are trivia facts verifiable, relevant, informative and well formulated? | Fact-check notes / sources where needed |
| CAT-04 | F5 | Are documented red herrings fair and resolved by the board, and are levels varied in theme and difficulty? | Editorial assessment |

**Interpretation:** CAT findings evaluate the fixture's editorial quality and are reported separately, without giving LexiStack5's Flutter engineering a different dataset. If an unchanged source fixture is editorially weak, record it; do not silently edit it to pass the technical F5 gate. Separately review any broken **structural** fixture before F1/F5 and document the methodology decision.

## How to review a gate

For each relevant ID mark `PASS`, `FAIL`, `BLOCKED BY ENVIRONMENT`, or `NOT YET APPLICABLE`, attach concrete evidence and reference the commit tested. An unexecuted or unobserved probe is not PASS. Regression failures block advancement even when the new feature works. Only independent review, not the implementing agent's own summary, accepts a gate.
