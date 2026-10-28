# LexiStack — Experiment E Evaluation Protocol v1.0

## Research question

Does a bounded **six-phase, independently reviewed sequential coding workflow**, combined with a fixed product contract and separate content production, produce a more verifiable, maintainable Flutter game than the earlier Optimized Genesis one-shot results?

This is a **practical workflow comparison**, not a controlled causal estimate of the effect of prompt length alone. The new process intentionally changes task decomposition, checkpoints and review cadence; these are a bundled intervention.

## Baselines and provenance

| Run | Agent | Original workflow | Immutable app commit | Autonomy interpretation |
|---|---|---|---|---|
| C | Codex | Optimized Genesis v1, autonomous one-shot | `oliversinz/LexiStack3` `8b84f2d6c75c` | One uninterrupted completed run, as historically reported |
| D | Claude Code | Optimized Genesis v1, originally one-shot | `oliversinz/LexiStack4` `9029748` | Assisted final run with interventions/restarts; model effort changed during run |
| E | Codex (in progress) | Product Contract + F1–F6 autonomous feature runs and independent gates | `https://github.com/oliversinz/lexistack` (in progress) | Determine separately per feature run and for the full project |

The historical **73 (C)** and **72 (D)** tests are developer-reported counts, not proof that the independent matrix passes. Re-run independent probes whenever toolchains and source availability permit. Do not treat repo size, screenshot count or code verbosity as a quality score.

The original four-run experiment protocol remains the historical record; it is not retrospectively rewritten. A/B are contextual rather than equivalent technical scorecard baselines because their prompt and completion conditions differ. Experiment A's 32-level original commit must not be conflated with its later 80-level extension.

## Technical quality scorecard (100 points; separate from agent autonomy and content)

| Dimension | Weight | Indicative rubric |
|---|---:|---|
| Engine, Scoring & Economy | 25 | Guess/state correctness (11); deterministic boosters (5); first-win/replay/reward protections (5); Daily/streak rules (4) |
| Architecture & Maintainability | 20 | Domain/UI isolation (8); replaceable storage/clock + tests (5); change locality/cohesion (5); appropriate dependencies (2) |
| Persistence & Recovery | 15 | Exact round-trip (5); idempotence (4); partial salvage including duplicate tile IDs (4); writes/failure handling (2) |
| UX & Accessibility | 15 | Complete functional flow (4); touch/drag/feedback (4); small screen/accessibility (5); visual quality (2) |
| Automated Verification | 15 | Independent behavior oracle (7); genuine widget/regression coverage (5); validator/cross-file checks (3) |
| Android & Web Verification | 10 | Real command/build evidence (3); Android device/emulator workflow (4); browser-compiled PRNG check (3) |
| **Total** | **100** | Verified observable behavior only |

Score each subdimension using the same rubric and evidence bar for C, D and E. Separate **quality** from **evidence coverage** (observed/unobserved). Environment-blocked probes must not be called passes; explicitly state when a fair score could not be assigned. Avoid false precision from a single run.

### Process outcome measures (reported separately, not secretly added to 100)

- **Autonomous completion:** C as one long attempt; E as six feature runs (report `completed_without_intervention / attempted` and whether all gates reached final acceptance without intervention).
- **Corrections:** number of narrow corrective prompts, defects found at gates, defect severity, regressions introduced after previously accepted gates, and time from defect discovery to verified fix.
- **Human review:** active reviewer time by phase (reading/verification, emulator, reproducing defects, writing corrective prompts); exclude idle time.
- **Tool reliability:** classify failures as agent coordination, application defect, external environment, or unclassified; record intervention and recovery behavior. Do not equate a slow Gradle cold start with faulty reasoning.
- **Execution:** wall-clock runtime, agent model/effort/tool versions, retries, credits/tokens when available. Secondary—not ranking defaults.
- **Evidence completeness:** exit codes/logs, Flutter and Android builds, real screenshots, browser execution, reproducible commit, clean worktree, content provenance.

## Content evaluation: held out from the technical score

Experiment E uses the **frozen LexiStack3 40-level JSON dataset** (full source lock in `reference-content-lock.md`). A separate editorial sheet can score structural validity, intended partition ambiguity, red-herring fairness, trivia truth and diversity. Do not attribute changes in this sheet to E's coding workflow. C and D ran on different contents; technical cross-run test fixtures should be normalized wherever possible. The future Studio-produced replacement corpus is a separate experiment.

## Independent acceptance review

1. Define/pin acceptance IDs in `acceptance-matrix.md` *before* implementation. Exercise the same rule-oracle and corruption fixtures against C, D and E to the extent their test entry points permit. Record mapping/adaptation; do not quietly waive failures for one implementation.
2. Snapshot the implementing agent's prompt, exit status, first/last Git commit, dirty worktree, installed SDK and shell characteristics, and tool actions. Do not reconstruct a pre-intervention checkpoint from the final repaired code.
3. At each E gate: inspect changed files and dependencies; run actual automated tests and focused independent mutations; check platform requirements; record evidence and pass/fail classification.
4. Re-run previous accepted behavior checks whenever major app, controller or storage code changes. A green new-feature test with a broken earlier gate is not accepted.
5. During F6, reproduce all possible baseline probes on C and D in the same Windows environment and toolchain as E. Record any incompatibilities instead of changing historical source.
6. Keep a concise gate record (one rolling `docs/gate-log.md` with headings F1…F6 is sufficient) containing commit, acceptance IDs, commands and exit codes, screenshots, known defects, corrections and reviewer decision.

## Gate record template (copy as a short section, not a new report system)

```text
Gate: F<phase> | reviewer decision: PASS / FAIL / BLOCKED
Repository commit: <full SHA> | worktree: clean / dirty (list)
Agent/model/effort: <exact version> | Windows/Flutter/Android: <versions>
Prompt identity/hash: <SHA-256> | started/ended: <timestamps>
Included acceptance IDs: <IDs> | Passed: <IDs> | Failed: <IDs> | Blocked: <IDs>
Commands: <literal command, exit code, test count, log path>
Android/browser: <device, actual operations, evidence artifacts>
Defects and fixes: <severity, exact reproducible steps, corrections>
Interventions: <number, before/after snapshots, environment vs agent>
Reviewer sign-off: <date + reasoning>
```

## Causal interpretation guardrails

- One implementation per condition is insufficient for generalized model rankings. A Codex-sequential improvement over C could arise from more detailed QA or architecture instructions, not just phased prompts.
- E's reference JSON matches C but not D. Remove editorial content from the technical score, and rely on shared synthetic rule fixtures for direct engine comparison.
- New tests may catch real old bugs; do not claim old versions failed until probes actually run on their fixed commits.
- Corrections accepted by a human between E phases are a designed part of the workflow; mid-phase rescue is not. Both must be counted transparently for total cost.
- Report both final technical product quality and total implementation/review effort. Avoid treating the lower-cost result as automatically better or the higher score as the only relevant outcome.
