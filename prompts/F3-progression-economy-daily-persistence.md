# LexiStack5 — F3 Autonomous Feature Assignment

## Progression, Economy, Daily & Defensive Persistence

**Executor:** Codex Desktop on Windows / PowerShell  
**Repository:** `C:\Codex\LexiStack` → `https://github.com/oliversinz/lexistack`  
**Accepted starting `main` commit:** `9928bd5895e9258bdadb79580bc41497482181d9`  
**Feature branch:** `codex/f3-progression-economy-persistence`  
**Required final state:** Complete F3; publish the feature branch for independent review; **do not merge to or push `main`**; **do not start F4**.

### 1. Mission and execution contract

Implement **only Phase F3** from the approved six-phase LexiStack5 roadmap. F1 (foundation) and F2 (pure-Dart engine and playable Android vertical slice) have passed independent review. Your mission is to turn that in-memory playable game into a durable, economically correct offline game with campaign progression, eight Daily puzzles, finalized results/statistics, and defensive local recovery. Deliver a genuine playable and restartable Android app, not a storage proof of concept disconnected from the UI.

Work autonomously: inspect the repository, make the implementation, test it, fix your own defects, build and verify Android, retain evidence, create local commits and **push the dedicated completed feature branch** to `origin` for review. Publication of the feature branch is **not gate acceptance**. Do not seek routine approval or continue into F4. No force-push, rebase/history rewrite, or unapproved changes to `main`.

Read `AGENTS.md` and all referenced documents before coding, in its prescribed order. In particular, use:

- `docs/product-contract.md` §§3, 4.1–4.4, 8 and 9 (authoritative behavior);
- `docs/architecture.md` §§2–6 (boundaries, save/recovery, Git workflow);
- `docs/feature-roadmap.md` F3 (scope and gate);
- `docs/acceptance-matrix.md` **ECO-01–09, DAY-01–06, PER-01–09**, **PLT-04** and preceding F1/F2 regression IDs;
- `docs/reference-content-lock.md` (frozen content identity);
- `docs/experiment-e-protocol.md` and `docs/gate-log.md` (evidence and independence).

The product contract controls semantics; this assignment controls F3 implementation scope. Report a genuine ambiguity rather than quietly changing a product invariant. Make small, evidence-based decisions where the contract delegates implementation detail; document only materially important ones.

**Preflight before implementation**

1. Inspect `git status --short`, branch, `git rev-parse HEAD`, `git remote -v` and `origin/main`. Verify accepted `main` is exactly `9928bd5895e9258bdadb79580bc41497482181d9`. If a supplied untracked F3 prompt file exists, preserve it; do not mistake it for an unwanted edit. Do not overwrite other unexpected user changes. Create the named F3 branch from accepted `main`.
2. Inspect Flutter/Dart/Android/emulator versions and the F2 implementation, especially `lib/core/game.dart`, `prng.dart`, `scoring.dart`, `share.dart`, `lib/app/board_controller.dart`, `catalog_controller.dart`, and the real board/navigation/widget tests.
3. Confirm `lexistack_content_contract` remains pinned to Git commit **`d9acbd52de0e198dd109a4859299318db3f465f5`** (including `pubspec.lock`). Do not fork or modify its parser/validator. Run F1/F2 baseline tests before changes; record results.
4. Do not inspect or copy application source from LexiStack3/LexiStack4. Frozen JSON fixtures only are explicitly permitted.

### 2. Precisely bounded F3 scope

**Implement:** versioned progress; actual paid boosters; coins and once-only campaign/Daily rewards; best stars and one-time practice payouts; campaign unlock, Continue, resume and explicit replay; Daily selection/date rollover/streaks; finalized-result histories and computed statistics; saved settings defaults and reset; resilient asset/content linking; deterministic clock and in-memory storage; serial, observable storage writes; minimal real UI integration; F3 tests and Android process-restart evidence.

**Do not implement:** the three remaining campaign JSON packs (`pack2.json`–`pack4.json`), final production manifest, new puzzles, editorial content, F4's fully redesigned Home/Packs/Stats/Settings screens, final animations/haptics/accessibility polish, production clipboard UI, F6 browser PRNG validation, a backend, accounts, analytics, ads, billing, runtime inference, database or generalized state-management framework. Existing functional F2 touch/drag and board flows must remain intact.

The current F2 preview has free boosters, in-memory attempts and a fixed preview campaign seed. Those are intentionally transitional: replace the *user-facing* free-preview semantics with the real F3 controller/economy. Do not preserve free rescue as a back door. Adapt earlier UI tests to the now-correct F3 behavior without deleting the underlying behavioral assertions; document any legitimate test adaptation.

### 3. Frozen Daily content and current manifest

Install the **exact unchanged** `daily.json` from LexiStack3 at:

- Source commit: `8b84f2d6c75cb807fba9db19cba707f963e02020`;
- Source path: `assets/levels/daily.json`;
- Expected Git blob SHA-1: **`5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6`**.

Existing `pack1.json` must remain byte-identical to Git blob **`5efa3c88c769f74eee872860766681f5c2cc1c64`**. The F3 temporary `assets/levels/manifest.json` must list **only** installed content, keeping campaign order: `campaign: ["pack1.json"]`, `daily: "daily.json"`. Update Flutter asset registration to include `daily.json`. Do not install other campaign packs and do not copy or reserialize the final locked production manifest yet.

Run the shared validator in partial mode across both installed packs; expect **16 levels, 64 groups and 256 tile positions, zero errors and warnings**. Unqualified **strict** validation still **must fail** (expected nonzero) because only one campaign pack is installed; the Daily file must no longer be reported missing. Record exact exit codes and outputs. Verify both asset blob IDs after all work.

### 4. Domain/application separation

Preserve and extend F2's small architecture, dividing responsibilities by behavior rather than arbitrary file length:

- **Pure Dart `core`** continues to own legal game transitions, immutable content references, PRNG state, scoring, share text, stable identity, and calendar-day arithmetic; it must not import Flutter, I/O or platform plugins.
- **Application/controller** owns wallet balance, progression, reward settlement, Daily attempt policy, streaks/statistics, attempt identity, and coordination of state changes and saves. It must not duplicate guess evaluation or deterministic hint targeting.
- **Progress codec and recovery** own one versioned document and strictly validated reconstruction of unfinished games against the current content. Restoration can use `Game`'s explicit domain-level snapshot API/constructor rather than private-field mutation by UI or controller. Keep validated boundaries narrow.
- **Infrastructure** supplies a small injected asynchronous read/write interface, a `shared_preferences` implementation, and a deterministic in-memory/failure-injection fake for tests. Use the appropriate Flutter-compatible plugin; no new database.
- **UI** shows controller-derived state and invokes controller operations; a single modest `ChangeNotifier` or closely related existing controllers suffice. Avoid a second global state framework or a parallel shadow wallet.

Preserve the **Park–Miller PRNG** algorithm and F2 golden sequences; never silently change shuffle semantics. Snapshots must retain both seed and current RNG state for exact resumption. Use canonical stable `Tile.id` from the pinned content contract, not display strings or shuffled positions.

A clean F3 implementation should be comprehensible to a future feature agent without another large handover document.

### 5. Campaign progression, coins and exactly-once settlement (ECO-01–09)

Use the exact product rules:

- Fresh balance: **150 coins**.
- First **campaign-level win**: **+50** (3 stars), **+30** (2 stars), **+15** (1 star); only on that level's first winning completion.
- Explicit winning **replay**: the **first successful replay win** for a previously won level grants **+5 practice coins once total for that level**. All subsequent winning replays grant **+0**, including after app relaunch. Failed replays do not consume that first successful-replay payout. Replay may raise but never lower `bestStars`.
- Daily first win for its **civil date**: star-based reward **plus +25 Daily bonus**, once per date; **no practice coins**, even when an eight-level Daily board repeats on a later date.
- No other coin sources. Booster prices: **Pair Magnet 30**, **Category Peek 40**, **Extra Life 60**. Successful legal applicable use charges once; an unaffordable, inapplicable, rejected or terminal action changes **neither** balance **nor** game state. Do not spend first and discover rejection afterward.
- `Extra Life` restores one life up to four in `playing`; at `lostPendingDecision` it costs 60 and returns the **same** attempt to `playing` with one life. If unaffordable, do not offer a free rescue; explicit Accept Loss must remain usable. A finalized loss cannot be rescued. Booster effects and charges survive reload without repeating.
- Stars continue to derive **only from lifetime wrong submissions**, including after any number of rescues. A replay with fewer mistakes may improve best stars without re-paying the initial reward.

**Settlement design:** Each finalized attempt must have a durable, unique identity and at most one associated settlement/history record. Perform in-memory game finalization, reward/charge/progression update, history insertion and snapshot creation as one coherent application transition, then queue the persisted snapshot. Never award/charge based on rebuilding a result screen, reacting twice to a widget lifecycle callback, or reopening a finalized game. Double tapping, background/resume, reloading or replay navigation must not create duplicate history or coins. A persistence write failure must not be described as a successful durable settlement.

**Campaign unlock/Continue:** The first level in **each installed campaign pack** is initially unlocked; stage `n+1` unlocks after winning `n` of the same pack. Other packs are independently progressable when later installed. Keep a single unfinished attempt per campaign level. `Continue Campaign` selects the most recently entered unfinished campaign attempt, including pending-loss; otherwise the earliest unlocked never-won level in manifest pack/level order. If all installed campaign levels have been won, open the selector rather than silently replaying an old win. Replaying a finished level always requires an explicit action and a new attempt identity. Verify two-pack independence with synthetic catalog fixtures **without shipping additional production packs**.

### 6. Daily civil dates, streaks and statistics (DAY-01–06)

Use a small, **injectable local-date/clock provider**, so all tests are deterministic without waiting for the clock or depending on the test host's timezone. The user-facing date is the local **civil date `YYYY-MM-DD`**; convert calendar components to UTC midnights for day-index arithmetic, never elapsed local 24-hour durations.

- Daily epoch: **2026-01-01**, index zero.
- Daily index: integer number of civil days since epoch. Select the level at normalized `dayIndex % 8` in the installed, separate daily-only pool. Handle negative modulo consistently if pre-epoch dates are tested.
- Derive a deterministic **valid Park–Miller seed** from the civil date, explicitly documenting the formula/range and fixed golden cases. A second entry on the same local date must give identical level/seed/board after a fresh process. Preserve the order/RNG state of an existing unfinished Daily attempt.
- Allow **one Daily attempt per date**, no manual replay after `won` or `lostFinal`. Opening a finalized Daily again shows its stored result and shareable data (actual clipboard action belongs to F4) and cannot trigger another reward. The same pool level appearing eight days later is a new date and a separate attempt.
- At a date transition, discard the **previous day's unfinished Daily** without finalizing or counting it. Prevent stale controllers/screens from submitting old-day guesses or purchasing boosters after midnight. Trigger checks on Daily entry and relevant mutations/resume, without adding unnecessary background services.
- Streak: count consecutive **finalized Daily wins** ending today, or ending yesterday when today's Daily has no finalized win/loss. Today's finalized loss yields current streak zero. Missing a day breaks the streak. Preserve `bestDailyStreak` independently across dates and app restarts.
- `gamesPlayed` counts **all finalized attempts** (`won` or `lostFinal`), not mere opens or rescue-pending losses. Provide wins, win rate, zero-mistake perfect wins and win-mistake buckets **0, 1, 2, 3, 4+** (the last reachable through rescues). Compute/retain statistics from stable finalized-result summaries independent of future catalog removal.

Cover same-date reopen, date rollover while app remains open, Europe/U.S. DST boundaries as civil calendar cases, leap day **2028-02-29**, prior-day pending attempts, a finalized Daily loss followed by a new date, streak gap, and repeated eight-board pool cycles. Keep calendar logic pure Dart. Do not advertise the eight-level rotation as unlimited unique puzzles.

### 7. Persisted document, safe recovery and write ordering (PER-01–09)

Persist **one versioned JSON document under one storage key** using `shared_preferences`, behind an injected `Future<String?> read()` / `Future<void> write(String)`-style interface (or equivalently small interface). It must include, with defensively typed/range-checked fields:

- wallet, per-level best stars, campaign first-win state, one-time practice payout flags and other minimal progression metadata;
- unique finalized attempt summaries sufficient for statistics, repeat-proof reward settlement and later spoiler-free share data, even if their content is no longer installed;
- current Daily outcomes indexed by civil date plus best-streak basis;
- one unfinished attempt per campaign level and today's unfinished Daily attempt (attempt ID, level/date, seed, PRNG state, board order, selection order, evaluated guesses with tiers/IDs/correctness, solved categories, mismatch signatures, lives, lifetime mistakes, combo, rescue count, hint pairs, peeked categories and result status);
- settings defaults (theme and haptics) for F4, plus any small version/counter fields required to generate stable unique attempt identifiers.

**Exact restoration:** Reload of an unfinished campaign/Daily board must preserve the true board permutation, current selection, guessed-set history, solved groups, pair/peek effects, lives/mistakes, rescue-pending decision, RNG state and next-shuffle determinism. A restored pending loss remains spoiler-free; do not inadvertently reveal even a previously peeked unsolved title. Reopening a finalized result must not recreate an active attempt or credit a reward again.

**Adversarial restore validation:** Treat save bytes as untrusted. Check numeric bounds, IDs, supported status and cross-field invariants. In particular:

1. Compute the expected unique **unsolved** tile-ID set from the installed level and solved groups. Restore `order` **only if it is an exact one-to-one permutation** of that set: correct length **and no duplicates** **and no missing IDs** **and no extras**. A list of the correct length containing two copies of a known ID and omitting another known ID **must fail**. This is the mandatory independent regression for the LexiStack4 gap (PER-04).
2. Validate selection uniqueness/cap and membership in the currently unsolved set, solved category uniqueness/validity, hint references and pair membership, wrong-signature equivalence, guessed tiles/order/tier/correctness, lifecycle chronology (e.g. no guesses involving already solved groups), accumulated mistakes and current combo, lives/rescue arithmetic and terminal-state consistency. Be mindful that hints on now-solved categories may remain in a **legitimate** snapshot. Do not discard valid states solely because a past hint's category was subsequently solved.
3. Defend against duplicate finalized attempt IDs, repeated reward flags or inconsistent saved settlement metadata. No invalid record can legitimately create a fresh payout on reload.
4. Store a **deterministic semantic content fingerprint** for each unfinished attempt. An unchanged level/ID restores; if the same level ID now refers to changed tiles, categories or other meaningfully relevant content, discard or quarantine **only that incompatible attempt**. Do not use runtime `hashCode` or a platform-unstable hash. Keep the fingerprint documented and test mutation of content under unchanged IDs.
5. A wholly unreadable document, unsupported root version or wholly wrong root type may reset safely with a clear non-crashing notice. Otherwise **salvage valid sections independently**: an invalid single attempt must not erase valid wallet, best stars, other attempts, finalized summaries or Daily outcomes. If a level is removed/renamed, discard only the affected *unfinished* attempt and retain historical achievements/statistics.
6. Ensure a corrupt or invalid individual section never crashes the app or is misrepresented as valid. Document which valid values are retained and what is reset.

**Write serialization and failures:** Construct a JSON snapshot at the moment of a meaningful state transition and queue writes **in order** so a slower earlier write can never overwrite a newer snapshot. Expose a flush/drain operation for tests and Android verification. Deliberately use delayed/reordered fake storage to prove ordering. A failed write must be caught, surfaced unobtrusively and not called persisted; subsequent writes should remain possible rather than leaving a permanently broken queue. Do not promise hard power-loss atomicity beyond what a single `shared_preferences` key actually provides. Avoid timers, polling loops and excessive save churn where a direct mutation-to-snapshot approach suffices.

**Reset:** Restore the exact fresh state (150 coins, empty attempts/history, zero stats, empty Daily results, default theme/haptics, no pending rewards). Require a user confirmation before destructive reset. F3 may provide a minimal confirmation affordance; the complete Settings UX is F4. Test both cancelled and confirmed reset, including a reopen after the successful reset, and exercise storage-failure reporting.

### 8. Minimal but actual F3 Flutter integration

Extend the existing Home → Collection → Level → Board flow **without a parallel fake demo application**:

- Show actual wallet balance and campaign state. Locked stages cannot be entered via normal UI; replay is an explicit action when eligible. Provide working `Continue Campaign` and navigation back to the selector on all-won. Where only pack1 exists, do not suggest that four campaign packs were delivered.
- Integrate **real booster prices, affordability and eligibility** with the existing Board UI. A successful hint changes the existing board and wallet; rejected actions never charge. Remove F2's “preview: no coins” claims. Pending loss offers paid Extra Life when eligible, otherwise explicit final reveal. Keep all spoiler protections.
- Provide a discoverable **Daily** entry for the installed eight-board pool. Show today's correct board/state or saved finalized outcome, and a minimal streak indicator. Existing F2 tap/drag/submission flow works for Daily as well. Do not add full F4 menu, visual polish or clipboard integration yet.
- Show result stars and awarded coins once, with a minimal statistics summary from actual history. Expose enough UI to test navigation/reopen and basic Reset confirmation/storage warning. Complete Stats and Settings screens remain F4.
- Display a nonintrusive but legible failure/recovery notice where appropriate. Show honestly when progress has not been saved; do not silently claim success. Keep Android portrait usable and test 360×640 at 1.3x text, 390×844 and 1280×800 with centered mobile width.

When changing F2 controllers and UI tests, retain the existing engine's typed transitions and `LongPressDraggable`/`DragTarget` behavior. Avoid multiple listeners or pathways that settle a win twice. No duplicate action on gesture release. Preserve accessibility semantics and F1 navigation where still valid.

### 9. Required automated acceptance tests

Create **independent, adversarial** pure-domain, controller, storage and real-app widget tests. Include fixtures whose expected values are derived from product constants and controlled inputs, not from the same production function being asserted. Test full state and wallet snapshots when verifying rejected actions.

**Economy / campaign (ECO-01–09):** fresh 150 coins; 50/30/15 first-win cases; zero/one/two/three/four-plus mistakes and rescue-based stars; a higher-best replay and a worse replay; exactly one successful +5 practice payout despite subsequent replays/restarts; normal first-stage unlock and n+1 progression; independent synthetic packs; Continue priority including pending loss; all-won fallthrough; exact 30/40/60 paid boosters with insufficient funds, no-eligible, max-life, terminal and wrong-state rejection; no double charge after restore.

**Daily and statistics (DAY-01–06):** civil-date indexing (2026-01-01, 2026-01-09, 2026-10-28, DST days, leap day); stable board/seed for the same date; pool rotation; same-day one-attempt and reward-once; previous unfinished board abandoned at midnight; stale screen cannot charge/complete; win/loss/skip streak sequences; best streak; shareable finalized-result data; finalized-only `gamesPlayed`, perfect wins, win rate and all win-mistake buckets including `4+`, surviving a restart.

**Storage/recovery (PER-01–09):** true round-trip plus next shuffle matching uninterrupted game; pending loss and hinted state round-trip; targeted coin/history/best-stars preservation across malformed attempts; **known-duplicate + missing Tile ID** corruption fixture as PER-04; duplicate selection, solved groups, guessed-set IDs, invalid tiers, impossible lives/rescues/status, tampered reward ledger and orphaned IDs; changed-content fingerprint under unchanged level ID; malformed root/version; deliberate delayed-write ordering, write failure/retry, surfaced warning, cancellation/confirmation of Reset and exact fresh defaults.

**Widget/integration regression:** Pump the actual production app using injected memory storage and clock. Exercise first campaign win, real coins on booster use, pending unaffordable rescue and explicit reveal, a working paid rescue with no solution leak, app/controller reconstruction preserving a partial attempt and paid hint state, Daily result/reentry and repeat protection, a date advance, a small-screen workflow, and visible save-failure notice. Keep the previously accepted F1/F2 domain or UI behaviors covered. Existing test *wording* tied to free F2 previews may legitimately change; record why and do not weaken/remove behavior checks merely to get green tests.

### 10. Android proof and regression verification

Use the real Windows Android emulator (`Pixel_10` / Android 16 if still available). Install the **built APK** and open the app through its Android launcher. A `flutter test` or `flutter run` alone is not sufficient evidence of Android lifecycle behavior.

Perform and document a focused realistic scenario:

1. Open an unlocked campaign level, make at least one selection and paid booster purchase, then leave and re-enter the same attempt. Verify board state, hint state and wallet.
2. **Force-stop the app process** (e.g. `adb shell am force-stop de.cloudwards.lexistack`), relaunch from the **launcher**, and verify a **new process** restores the same in-progress board and wallet. Do **not** substitute a Home-key warm resume for process-death persistence. If possible log original/new PID and an unedited before/after capture.
3. Finalize a campaign win, record payout and best stars, force-stop/relaunch and reopen its result; verify neither coins nor `gamesPlayed` increase again. Start a deliberate replay to prove it is a new attempt.
4. Open Daily, verify displayed date/puzzle and same-date re-entry; where meaningful, use clock-injected widget tests for midnight/DST rather than changing the physical emulator clock in a way that undermines evidence.
5. Revisit an existing F2 touch/drag selection path and the pending-loss concealment. Where practical, capture a paid-rescue scenario; do not invent Android evidence if it was only tested in Dart/widgets.

Keep **a small number of genuine unedited PNG screenshots** of campaign state, Daily, wallet/booster effect, and persisted resume, plus relevant ADB logs/observations. If emulator tooling blocks the process-restart proof, record precise commands and symptoms, classify PLT-04 as BLOCKED/PROVISIONAL and complete all unaffected automated checks. No fabricated screenshots, success or process-kill claims.

Minimum command sequence (PowerShell-compatible, record *actual* exit codes and output):

```powershell
flutter pub get
dart run tool/validate_levels.dart --partial
dart run tool/validate_levels.dart
dart analyze
flutter test --reporter expanded
dart run tool/check_prng.dart
flutter build apk --debug
git hash-object --no-filters assets/levels/pack1.json
git hash-object --no-filters assets/levels/daily.json
```

`--partial` **must** succeed with 16 levels and zero errors/warnings; the unqualified strict validator is **expected to return nonzero** because `pack2`–`pack4` are intentionally not yet installed. F2 PRNG golden vectors must remain unchanged. Verify that the pinned package resolves to the exact content-contract SHA. Build and install the actual APK and capture a genuine launcher/process-restart observation.

### 11. Evidence, prompt provenance and Git publication

- Preserve this **exact** execution prompt in `prompts/F3-progression-economy-daily-persistence.md` (if supplied); compute and report its SHA-256. Do not rewrite or reformat it for convenience. If the file was already supplied locally, use those bytes. Honor `.gitattributes` prompt line-ending preservation. If the complete original prompt is missing, disclose that rather than fabricating a hash.
- Add **one concise F3 section** to `docs/gate-log.md` marked **`PENDING independent review`**. Record starting/ending commits, model/version/effort if visible, timestamps, changes to existing tests, command lines with exit codes, initial failures and autonomous fixes, the installed asset identities, Android observations, unverified portions and **human intervention count**.
- Store relevant raw command outputs and selected genuine screenshots under `docs/evidence/f3/`; keep it practical, not an elaborate reporting framework. Retain meaningful failure traces instead of cleaning the audit trail.
- Update `README.md` minimally to explain the actually working F3 economy, Daily rotation, persistence/recovery limitations and Windows run/test commands. Do **not** silently modify Product Contract, architecture, roadmap, acceptance matrix, Git workflow or locked content data. Do not update a shared Content Studio package or another repository.
- Commit coherent source/test/evidence checkpoints on **`codex/f3-progression-economy-persistence`**. Once completed and verified, **push this feature branch to `origin`**, set upstream if needed and verify remote HEAD equals your final full commit SHA. **Never merge or push `main`**, even if you believe every test passed. No force push/history rewriting. Stop after F3 and leave quality-gate acceptance to independent review.

### 12. Final implementation report

Report succinctly but precisely:

1. F3 status (complete / partial / blocked), branch, **accepted starting main SHA**, full final feature-branch SHA, remote branch URL/remote SHA and clean/dirty Git state.
2. Module layout, persisted document/version, storage implementation, clock/date rule, stable Daily seed formula, content fingerprint and exactly-once reward mechanism.
3. Outcomes for **ECO-01–09, DAY-01–06, PER-01–09 and PLT-04**. Explicitly distinguish PASS, FAIL, BLOCKED or deliberately deferred F4/F6 UI features; include earlier-gate regressions.
4. Exact command results, exit codes, test count and evidence paths; `--partial` content totals, expected strict nonzero result, frozen JSON blob IDs, unchanged package pin, PRNG regressions.
5. Real Android lifecycle and gameplay operations, process/PID changes when observed, screenshots and any tests performed only in Dart/widgets.
6. Known defects, warnings, machine/toolchain problems, autonomous corrections, human interventions, documentation/prompt SHA and the gate's **PENDING** status.

**Begin the F3 implementation autonomously. Deliver the working persistent Android experience, publish only the F3 feature branch for review, and do not start F4.**
