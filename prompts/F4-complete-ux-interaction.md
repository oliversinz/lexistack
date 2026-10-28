# LexiStack5 — F4 Implementation Prompt

## Complete UX & Interaction Integration

You are Codex Desktop on **Windows**, acting as senior Flutter game engineer, mobile UX implementer, accessibility reviewer and test engineer. Implement **only Phase F4** of sequential Experiment E in the existing Flutter repository. Work autonomously within this bounded feature run; **do not implement F5 or F6**.

**Product goal:** Transform the real, functioning F3 game into a cohesive, polished, tactile and accessible casual puzzle experience, while preserving every accepted rule, payout, Daily, save/recovery and Android behavior. This must be a real Flutter application with functional actions, not a mock-up or an unrelated redesign.

### 1. Immutable starting point, context and work protocol

- Working directory: `C:\Codex\LexiStack`.
- GitHub repository: `https://github.com/oliversinz/lexistack`.
- **Accepted `main` / F3 gate-integration commit:** `ecd08104d0d54bd2ae23d063c2f3f7e0ba45f06e`.
- Accepted substantive F3 implementation/correction: `7e03eaad8ee8731c57d2f4df3f3b4485ee605d1c`.
- Content contract Git pin: `d9acbd52de0e198dd109a4859299318db3f465f5`, package `packages/lexistack_content_contract` from `https://github.com/oliversinz/lexistack-content.git`. **Keep this exact pin and its resolved lock identity**.
- Only installed content: untouched `pack1.json` and `daily.json`, schema v2, with temporary manifest listing campaign `pack1.json` plus Daily. The expected raw Git blob IDs are `5efa3c88c769f74eee872860766681f5c2cc1c64` (pack1) and `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` (Daily). The other campaign packs come **only in F5**.
- Last reviewed F3 regression baseline: **122 Flutter tests**, including F3-R01 read-failure protection. This is reference evidence, not permission to reduce test coverage or assert a future run has passed.

At the start, read the exact F4 prompt file in full and then `AGENTS.md` and its referenced documents in order. In particular: `docs/product-contract.md` sections 3, 4, 7, 8 and 9; `docs/architecture.md`; `docs/feature-roadmap.md` F4; `docs/acceptance-matrix.md` **UI-03 through UI-12 and PLT-03/04**; `docs/reference-content-lock.md`; `docs/experiment-e-protocol.md`; and the F1–F3 records in `docs/gate-log.md`.

Check actual working tree, HEAD, `origin/main`, remotes, emulator availability and installed Flutter/Dart toolchain before acting. Start **`codex/f4-complete-ux-interaction`** from the exact accepted `main`, subject to the current `AGENTS.md` Git rules. If the user has placed this prompt under `prompts/` as an expected untracked file, preserve it exactly and include it in the F4 branch; do not misclassify that expected input as an unrelated dirty source change. Stop and report any unexpected baseline changes instead of silently overwriting/stashing them.

**Required Git handoff:** Commit implementation, tests, prompt and evidence to the feature branch, **push the completed feature branch to `origin`**, verify the remote branch SHA matches local HEAD, and leave a clean worktree. **Do not merge or push `main`, rebase, force-push or rewrite history.** F4 remains `PENDING independent review` until the external reviewer accepts it. Do not start F5.

### 2. Scope and architectural non-negotiables

F4 is the **complete functional UX and interaction phase**, not a new game-engine or content-production phase. Reuse the working F3 state and controllers, preferably with small cohesive UI/component extractions rather than a new application framework.

**In scope:** Proper Home, Campaign/Pack/Level, Board, Result/Pending Loss, Statistics and Settings experiences; actual Share-to-Clipboard; persisted theme/haptics controls; restrained meaningful animations; complete booster and selection feedback; spoiler-safe result/recovery UI; responsive and accessible presentation; F1–F3 regression preservation; Android visual/touch/process-restart proof.

**Out of scope:** New packs, replacement levels, changing game/economy/PRNG/streak rules, new content schema, rewritten content validators, AI content authoring, backend, cloud sync, user accounts, ads, payments, telemetry, audio, in-app LLM, general state management packages, database or migration framework, full F5 import, F6 release packaging, F6 browser-executed PRNG verification or claiming final release readiness. Only `pack1.json` and `daily.json` may be installed in this phase.

Preserve pure-Dart domain/core, the existing single `ProgressController` settlement/state authority, injected clock and storage, `SharedPreferencesAsync` document, **F3-R01 `ProgressLoadStatus`/Retry load write blockade**, immutable content identity, ordered writes, exactly-once rewards, lost-pending spoiler protection and actual drag semantics. Never put coin arithmetic, unlock rules, date rotation or status transitions into a widget. The UI invokes existing typed actions and reacts to returned results.

Do not modify authoritative contracts (`docs/product-contract.md`, `docs/architecture.md`, `docs/feature-roadmap.md`, `docs/acceptance-matrix.md`, `docs/reference-content-lock.md`) to make acceptance easier. Report contract conflicts if found. Existing test assertions may be updated for *legitimate UX/copy/navigation changes*, but their behavioral coverage may not be weakened or removed. Do not copy LexiStack3/4 Flutter application source. Keep technical dependencies minimal and justified.

### 3. Product experience and design direction

Deliver an **original, cohesive word-association game identity** rather than an out-of-the-box Material showcase or corporate dashboard. The existing warm ivory, deep green and difficulty-tier palette may be refined, not arbitrarily discarded. Use an intentional typographic hierarchy, generous but efficient spacing, deliberate card/tiles, meaningful status treatment, distinct touch targets, restrained color and responsive composition. Prefer a warm, clever, approachable casual-puzzle character; no gratuitous visual effects or complicated graphics pipeline.

Create a consistent design system in a small number of reusable theme tokens/widgets only where it improves cohesion: light/dark surfaces, accent, tier colors, status colors, spacing, corner radii, tile/selection states, elevation, focus style and typography. Do **not** build a general-purpose design system package. If you choose non-SDK fonts or illustrations, bundle the exact, legitimately redistributable assets **and their required license/attribution files**. No runtime font/image downloading or web dependencies. If licensed font assets cannot be obtained/verified, use a thoughtful offline SDK-font fallback and explicitly report that limitation; never invent licensing or replace text with image screenshots.

Build polish around the genuine F3 app and its actual data. Avoid placeholder controls, fake coin counters, fake results or fake locked campaign packs. Current content only has one Campaign pack and one Daily pool: show the real installed pack and, if helpful, understated honest wording such as “More collections planned”; do **not** advertise four selectable production packs before F5. The widget/layout architecture must nevertheless scale cleanly to **four real themed packs of eight levels** when F5 installs them. Exercise multi-pack layout/unlock behavior using controlled test catalog fixtures, not fabricated shipping JSON.

**Copy/editing correction:** Ensure dynamic grammar, e.g. “1 mistake” versus “2 mistakes”, and “1 game played” versus “2 games played”. Preserve the **contract-exact** share-text formatting, which intentionally uses `<number> mistakes` as already specified even when one; do not silently alter that golden sharing contract.

### 4. Required end-to-end screens and navigation (UI-03)

**Home:** Clear primary action `Continue Campaign`, separate Daily entry showing actual civil date, win/finalized/unfinished status and current/best streak, visible coin wallet, concise performance summary, discoverable Campaign pack selector, Stats and Settings. Prioritize the next meaningful action; do not swamp the initial viewport with raw counters. If Continue has no remaining unlocked never-won board and no unfinished attempt, route to Campaign/Pack selection (including when all levels in the installed collection are complete) without starting an unintended replay. Display the actual eight-board repeat limitation honestly. Offer clear empty states and loading/failure states.

**Campaign / Pack / Level selection:** Real installed packs in manifest order; preserve independent per-pack unlocking (first level unlocked; next after prior win), 0–3 best stars, finished/pending/active/locked distinctions, contextual `Play`, `Resume`, `View Result` and **explicit** `Replay`. Locked levels must not open or become actionable through a visually enabled surface. Level titles/metadata must not reveal the hidden category solutions. When the four-pack catalog arrives in F5, this layout/navigation must handle it without replacing the screens.

**Board:** Actual selected and unsolved tiles; four hearts; four category slots/solved banners or peeked titles; selection count/tray; visible Shuffle, Deselect and Submit controls; three real booster actions **Pair Magnet 30 / Category Peek 40 / Extra Life 60** with live prices, available balance/eligibility and clear disabled reasons where practical. Show 4×4 tiles before solves and respond coherently as tiles disappear. The board must still be usable with expanding solved groups, a longer category name, a two-word tile, increased text size and a compact screen. Important controls may require deliberate scrolling, but may not be clipped or impossible to reach. No double-trigger on gesture release. Real tap and both additive drag targets remain functional.

**Result / Pending Loss:** At `lostPendingDecision`, show remaining-life decision and affordable paid Extra Life or explicit `Reveal / Accept Loss` **without leaking any unsolved tiles' answers, category titles, trivia, red-herring explanations or category details**. Guard both visual text and accessibility semantics. After rescue return to the *same* board/order/selection/guesses and show the correct post-payment wallet. A finalized win shows earned stars, actual reward, category tiles/titles/facts, red-herring explanations prioritized using prior wrong guesses, appropriate Next/Back and a functioning Share action. A finalized loss shows full answers **only after** explicit acceptance, plus available Share and navigation. Daily final results cannot replay on the same date. Saved-result fallback must remain usable if its board/details are no longer recoverable, with spoiler-free saved share metadata still available where supported.

**Statistics:** Implement a dedicated, discoverable Stats screen showing **finalized-only** games played, wins, win rate, perfect zero-mistake wins, win-mistake distribution `0, 1, 2, 3, 4+`, current Daily streak and best Daily streak. A compact labeled bar graph/buckets is welcome if meaningful; do not require chart packages. Use data already computed by `Progress`/`ProgressController`, not UI-side settlement or recomputation from unfinished states. Provide a legitimate empty-state presentation.

**Settings:** Dedicated, discoverable Settings screen with `System`, `Light` and `Dark` theme selection, a functional Haptic Feedback toggle, clearly described offline storage/reset behavior, and **confirmed Reset Progress**. Reflect persisted settings on launch and after process restart. Cancel does not reset anything. Confirm restores exactly the fresh state (150 coins, zero stats, no attempts/history, default theme/haptics, no Daily outcome); ensure old board handles or navigation cannot continue mutating the reset state. If a read has failed and initialization is blocked (F3-R01), keep gameplay/Settings/Reset/save operations unavailable and surface **Retry load**, not an accidental defaults-based application.

**Navigation:** Standard back/up behavior, usable focus and route lifetimes, no dead ends; transitions never create attempts merely to view a result. When theme changes, do not recreate the progress controller, re-read and overwrite unsaved progress, discard current board state, issue duplicate rewards or lose navigator state. Avoid memory leaks and listener duplication when screens are revisited.

### 5. Real share-to-clipboard (UI-08)

Convert the existing pure finalized-result share data (`FinalizedResult.shareText`, or existing equivalent authoritative pure formatter) into an actual `Copy result` / `Share` action using Flutter `Clipboard.setData` or a minimal injectable clipboard adapter. Do not add a share plugin unless explicitly justified.

- Clipboard content **must match the existing golden formatter byte-for-byte**: campaign/Daily header, stars or loss `n/4 groups`, mistake count, and evaluated guess rows in true selection order using 🟨/🟩/🟦/🟪. No title, tile, fact or solution text in copied content. The UI may show categories outside that copied text only at finalized states.
- No copy control before `won`/`lostFinal`; no sharing from `lostPendingDecision`, even after app restore. Saved finalized fallback uses persisted exact share metadata, not a reconstructed screen-body text.
- Display unobtrusive success feedback **only after** clipboard transfer has actually succeeded. Handle clipboard/platform failure without claiming success.
- Test actual platform-channel payload (mock MethodChannel or injected fake) for a won Campaign, finalized loss and Daily result. Include one exact golden string and repeat-copy/no-new-payout assertions. Ensure navigating away/reopening does not re-credit coins.

### 6. Theme, haptics and motion (UI-06/09/12)

**Theme:** Build complete light/dark themes, connected to the persisted `Progress.theme` values `system`, `light`, `dark` and device brightness. Use `MaterialApp` theme/darkTheme/themeMode or equivalent. A theme selection must update already visible screens **immediately** while preserving gameplay and navigation, then survive real process restart; resetting returns to System. Ensure color contrast on all four tier banner colors in both themes and visible selected/disabled states.

**Haptics:** Wire the existing persisted `Progress.haptics` flag to **real** platform feedback, ideally through a tiny injectable haptic service or controllable platform-channel seam for deterministic tests. Required mapping: `HapticFeedback.selectionClick` for successful selection changes; `mediumImpact` on correct solve; `heavyImpact` on evaluated wrong guess; `lightImpact` on a successfully applied/charged booster. No haptics for rejected/duplicate actions, disabled controls, no-op operations, failed purchases, or when haptics is disabled. The `lostPendingDecision` rescue is a successful booster. Respect unsupported platforms and catch/report platform exceptions without corrupting game state or coin settlement. Invoke effects from **action outcomes**, never build/rebuild callbacks, storage load/replay, or listener notifications. Tests must prove enabled mapping and actual suppression when disabled, including persistence after controller reconstruction.

**Motion:** Meaningful feedback around the Product Contract's approximate targets: tile select ~120 ms scale/elevation; evaluated wrong guess ~300 ms restrained shake; solved category ~350 ms collapse/reveal/banner; result entry restrained. Keep animation independent of authoritative engine transitions: submit and settlement complete exactly once even if the animation is interrupted, widgets dispose, app pauses, screen rebuilds or reduced motion is enabled. Implement an OS-preferred reduced-motion path (`MediaQuery.disableAnimations` or a suitable Flutter accessibility signal) with minimal or zero ornamental motion but identical usability. Avoid janky repeated animation on every `notifyListeners()` and no haptics from animation frames. Test outcomes, basic transitions and reduced-motion fallback where feasible.

### 7. Accessibility, responsive layout and visual quality (UI-10/11/12)

**Viewport matrix (mandatory):** 360×640 at 1.3× text, 390×844 at 1× and 1.3× where practical, and 1280×800 desktop-width widget frame. At widths >520, center a mobile interface constrained to **maxWidth 460 px** within a deliberate surrounding background. On compact viewports use scrollable sections or a clear sticky action region; ensure critical controls are reachable. No framework overflow errors or clipped dialogs. After two or more groups solved, result detail expansion must not hide essential controls.

**Touch/keyboard:** Aim for >=48×48 logical-pixel interactive hit targets on tiles, action buttons, booster controls, navigation and settings. Interactive disabled states must be visually obvious and include labels/reasons as appropriate. Maintain correct Android touch long-press drag tile-to-tile and tile-to-tray. Provide visible focus feedback and standard keyboard accessibility where practical; no shortcut may circumvent locked levels or spend coins without authorization.

**Semantics:** Proper accessible labels and states for tiles (text, selected/unselected, optional Pair Magnet), hearts/lives, group slots, booster price/eligibility, category tier plus title, daily date, buttons, completion results and settings. Ensure a `Semantics` wrapper and gesture widget do not cause duplicate spoken controls. A pending-loss screen's semantic tree must not contain unrevealed answers/facts. Color is not the sole category/tier or selected-state cue; use label/position/shape as well. Aim for **4.5:1 normal-text contrast** with real theme colors (include focused contrast checks or auditable palette calculations where practical). Two-word tiles may wrap **between** whole words, not break a word mid-token; target text >=11 logical pixels at the reference phone size.

**Visual review:** Capture and inspect actual UI evidence (no synthetic drawing or fabricated screenshots). Focus on the Home hierarchy, pack/level affordances, board selected+booster controls, solved group animation end state, pending loss, finalized result with trivia/red herrings, Stats and Settings in both modes. Screens should feel game-like rather than generic business tables. If screenshots expose a material readability/layout defect, correct it within F4 and repeat the relevant validation.

### 8. Testing: mandatory F4 gate + regressions

Preserve the passing F1/F2/F3 tests and add independent **actual-app** widget tests with an injected `MemoryProgressStorage` and clock, plus focused deterministic UI seam tests. Do not equate a golden snapshot alone with working navigation or gameplay. Tests must cover these acceptance IDs with real assertions:

- **UI-03:** navigate Home → Campaign/pack → unlocked/locked level → Board → finalized Result; Home → Daily; Home → Stats; Home → Settings; back; no dead UI buttons; first/replay/Continue semantics and all-won fallback. Use **synthetic catalog fixtures** for four-pack layout/navigation cases without adding shipping packs.
- **UI-04:** four hearts, real group slots/peek state, selectable board, tray/count, submit enabled exactly at 4/4, Shuffle/Deselect, booster controls with actual prices and correct disabled states. Two solved groups still allow working scroll/submit and correct count.
- **UI-05:** Pair Magnet 30, Category Peek 40, Extra Life 60; real UI updates wallet, pair/peek/heart; insufficient coins, ineligible category and terminal states leave game+wallet unchanged; booster controls explain rejection where practical.
- **UI-06:** visible One Away, mismatch, Already Guessed without double loss, correct reveal of exact real title+fact, animation timing targets/reduced-motion basic check, no animation-triggered duplicate settlement.
- **UI-07:** pending loss hides every unsolved answer/title/fact/red-herring visually **and in semantics**, even after previewed category/peek, navigation away, controller reconstruction or process-restart-like widget recreation; paid rescue returns identical attempt; explicit Reveal leads to final loss and cannot be reversed.
- **UI-08:** clipboard mock/fake verifies exact final Campaign, Daily, loss strings and absence of pre-final sharing; disabled/failed clipboard never indicates success; copy/reopen never modifies payouts.
- **UI-09:** theme `system/light/dark` changes displayed MaterialApp mode and survives reconstructed app; persisted haptics toggle truly suppresses calls; confirmed/cancelled Reset; reset restores theme/system, haptics-on, 150 coins and zero stats; no stale board changes after reset.
- **UI-10:** viewport/layout matrix above, 1.3× scaling, long words/two-word tiles, scrolling after solved groups, pending and full result, no overflows/clipped decision controls; 1280×800 centered layout <=460.
- **UI-11:** >=48 logical-pixel controls, appropriate semantic labels and selection state, no duplicate controls, contrast checks or carefully documented contrast evidence, tier not color-only.
- **UI-12 (F4 portion):** actual haptic mapping/suppression with fake or method-channel interception; reduced-motion behavior; local fonts/assets/licensing if added. **Six final F6 canonical PNGs are not required to claim F4 acceptance**; capture useful real intermediate screens now.
- **PLT-03/04:** Android tap + at least one real long-press drag target, booster/wallet and pending/result path; genuine force-stop (`adb shell am force-stop`) and launcher relaunch with a **different PID**, demonstrating selection, purchased hint, wallet and saved settings (theme/haptics) survive. Do not present a Home-key warm resume as process-death proof.

**Critical regressions (explicit):** Repeat the two-fresh-instance ENG oracle, PRNG goldens, one-time first-win and +5 Practice reward scenarios, Daily same-date/rollover/streak behavior, pending-loss spoiler protection, duplicate tile-ID restore rejection **PER-04**, serial write order and the F3-R01 **failed storage read never writes defaults** test. In an actual-app test, a failed read must show only safe Retry load and must **not** expose Play/Settings/Reset, wallet default, or save retry. A successful retry must restore existing progress, and dark theme/haptics must then use recovered settings.

Do not modify F3 domain/persistence code merely to simplify UI tests. If a source defect is genuinely discovered, isolate and document the minimal fix and its adversarial regression. Re-running tests after UI changes must not silently weaken F1–F3 coverage. Record test counts and actual exits; a passing output from the implementing agent is evidence, not independent gate acceptance.

### 9. Windows/Android execution and evidence

Run all applicable commands **from the Flutter repository root**, with real PowerShell stdout/stderr and exit codes, and retain concise evidence under `docs/evidence/f4/`:

```powershell
flutter --version
dart --version
flutter doctor -v
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

**Expected validator semantics:** Partial validation must pass for the two installed files with **16 levels, 64 groups, 256 tile positions, 0 errors/warnings**. The unqualified strict validator is **expected to exit 1** because `pack2.json`–`pack4.json` are not installed; Daily should **not** be reported missing. Do not interpret this expected F4 strict failure as successful F5 validation, or auto-import missing packs to make the command green.

Use the existing Windows Android emulator (last verified `Pixel_10`, Android 16 / API 36) if available, but inspect its actual identity. Build/install the APK, launch it **from the actual Android launcher**, interact with the real app, collect unedited PNG captures and relevant ADB/logcat evidence. Verify visual polish in light and dark mode, actual touch/drag, copy-to-clipboard when feasible, hints and successful paid rescue, spoiler-free pending loss, saved active attempt and settings across **force-stop and launcher restart**. A screenshot of selected controls is not proof that a tap/drag path succeeded; document actual operations. If Android-specific tests cannot be completed, report the precise blocker and affected PLT criteria instead of inventing success. Do not modify Android clocks to manufacture a Daily boundary; test date edges using injected clocks.

Keep F4 screenshot evidence practical. If convenient, also create preview captures using real Flutter widget-test rendering for the contract's six canonical screenshot states; clearly distinguish **F4 preview evidence** from the final F6 deliverable, which will include exactly the required states/sizes after full catalog import. Inspect actual resulting images at their native resolution where possible and correct obvious visual defects. Do not use image-generating mocks as substitutes for real app captures. Keep license files for any bundled visual/font assets.

Do not run `flutter build windows` unless `flutter doctor` confirms Visual Studio/C++ prerequisites. No iOS build is expected on Windows. F6 browser-compiled PRNG execution and release APK audit are explicitly deferred. Keep build caches, `.dart_tool`, `.gradle`, credentials and emulator state out of Git.

### 10. Documentation and prompt provenance

- Preserve this **complete exact F4 execution prompt** at `prompts/F4-complete-ux-interaction.md`. Compute its **SHA-256** on Windows and report it; do not reword/normalize it merely to obtain a convenient hash. The user supplies it before execution. `.gitattributes` should protect prompt bytes; if it does not, report the discrepancy.
- Update `README.md` concisely for what F4 actually delivers, especially settings, Share, offline fonts/assets, UX navigation, current 1 Campaign + 8 Daily limitations, and current run/test commands.
- Append **one** F4 implementation section to `docs/gate-log.md`, marked **`PENDING independent review`**. Record accepted starting SHA, branch/final commit, prompt SHA, environment, acceptance IDs, test commands/exit codes, Android process restart and touch evidence, screenshots, autonomous defects/fixes, known limitations and human interventions. Preserve F1–F3/F3-R01 evidence; do not rewrite prior historical records.
- Include relevant command logs and representative actual screenshots in `docs/evidence/f4/`. Avoid redundant huge debugging transcripts, large new ADRs or speculative feature specifications.
- Do not modify Content Studio, any other repository, frozen content files or the product contract. Report if required assets/fonts cannot be legitimately acquired or licensed; do not fabricate attribution.

### 11. Stop condition and final report

Complete F4 autonomously without requesting routine approval. If unavoidable platform problems arise, diagnose and complete all unaffected work, clearly label blocked checks. Commit coherent source/test and evidence changes to `codex/f4-complete-ux-interaction`, push **that feature branch only** and verify local/remote SHA equality. `main` remains at the accepted F3 baseline. Leave F4 **PENDING independent review** and **do not start F5**.

Your final response must provide:

1. F4 complete/partial/blocked; exact accepted starting SHA; feature branch, local HEAD and verified remote HEAD; clean/dirty status.
2. Screens/components implemented, settings/theme/haptic strategy, clipboard path, animation/reduced-motion/accessibility decisions and local font licensing, if any.
3. Explicit results for **UI-03–12 and PLT-03/04**, with each marked PASS / FAIL / BLOCKED / NOT YET APPLICABLE; list any F6-deferred portions honestly.
4. Commands, actual exits, final Flutter test count, PRNG probe, Android debug APK results, expected incomplete strict validation, package pin and both immutable JSON blob IDs.
5. Android device/real tap-drag/process-restart observations, copy behavior as actually verified, unedited screenshots and known platform differences.
6. Regressions of F1/F2/F3 and F3-R01, defects fixed during the run, unresolved issues, and count of **human interventions during the F4 run**.
7. Exact prompt-file SHA-256, Git remote URL to the review branch and confirmation that `main` is unchanged.

**Begin F4 implementation now. Deliver a genuinely polished and functional UX, publish the F4 feature branch for independent review, and stop before F5.**
