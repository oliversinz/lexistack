# LexiStack5 — Instructions for Coding Agents

Read **in this order** at the beginning of every phase:

1. `docs/product-contract.md` — final user-facing requirements, not a one-shot task.
2. `docs/architecture.md` — permanent software and content boundaries.
3. `docs/feature-roadmap.md` — active phase's scope, dependencies and quality gate.
4. `docs/acceptance-matrix.md` — objective tests and regression IDs.
5. `docs/reference-content-lock.md` — immutable JSON benchmark provenance.
6. `docs/experiment-e-protocol.md` — evidence, interventions and review.

You are implementing **only the phase explicitly assigned in the current user prompt**. Do not continue autonomously into another phase. Do not modify the Product Contract, acceptance criteria, other repositories, or immutable reference JSON as a way to make a test pass. Explicitly report any inconsistency/blocker instead of inventing policy. Never copy LexiStack3/4 application source; their **locked JSON assets only** are authorized as benchmark fixtures.

Environment is **Windows / PowerShell**, with Android as primary target and Flutter/Dart. Early emulator verification is mandatory when available. Keep core game rules pure Dart and content parsing in the pinned external `lexistack_content_contract` package. Use minimal standard Flutter state management (`ChangeNotifier`) and few justified dependencies. No unrequested backend, analytics, ads, billing, runtime LLM/network or content authoring.

Before acting: inspect actual Git state, installed tools, active phase and pinned content package. During the phase: implement autonomously, commit coherent checkpoints, run focused and earlier-gate regressions. Follow the Git workflow below. Do not state that a skipped or environment-blocked test passed.

At the end: report commit SHA, clean/dirty tree, exact commands and exit codes, tests, actual emulator/browser evidence, remaining defects, environment issues and human interventions. Independent review—not your report—decides whether the phase gate has passed.

## Git workflow for F3–F6

- Start each feature phase from the latest accepted `main`, with a clean working tree, and create a dedicated `codex/fN-*` feature branch.
- Complete implementation, tests, evidence and local commits autonomously on that branch.
- Push the completed feature branch to `origin` for independent review.
- Never merge into or push `main` before explicit independent quality-gate approval.
- After explicit approval, fast-forward `main` to the accepted feature commit using `git merge --ff-only`, then push `main`.
- Never force-push or rewrite history.
- Do not start the next feature before the previous gate is accepted; acceptance alone does not assign the next phase.
