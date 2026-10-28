# LexiStack5 — Sequential Development Experiment E

**Repository seed / planning documents only.** This package does not contain a Flutter app, runnable tests, an Android build or a Content Studio Dart package. Those are produced in the separately approved implementation runs.

## Goal

Build the same offline Flutter Android-first game specified by the optimized LexiStack Genesis, but via six autonomous, independently reviewed feature runs. Keep technical engineering separate from level authorship and assess reproducibility, correctness, architecture and review overhead.

## Read first

- `docs/product-contract.md` — complete final game rules and UX requirements.
- `docs/architecture.md` — two-repository integration and code separation.
- `docs/feature-roadmap.md` — P0 prerequisite and F1–F6 progression.
- `docs/acceptance-matrix.md` — phase-specific independent probes.
- `docs/reference-content-lock.md` — exact frozen 40-level source.
- `docs/content-studio-handoff.md` — minimal shared pure-Dart contract required before F1.
- `docs/experiment-e-protocol.md` — comparison method and evidence.
- `AGENTS.md` — concise agent startup instructions.
- `.gitattributes` — enforce LF for benchmark JSON on Windows checkout.
- `prompts/CS0-content-contract.md` — bootstrap prompt for the separate Studio package (first technical dependency).
- `prompts/F1-foundation.md` — first app phase prompt **draft**, runnable only after P0.

## Status

- Architecture and six-phase roadmap: accepted planning baseline.
- Reference JSON source: selected, but **actual files not copied** and **full Dart validator not yet independently run**.
- Content Studio shared package URL and pinned commit: **not yet available**.
- F1: **not started**.

Do not claim Flutter tests, Android launcher checks or content strict validation were performed by this planning archive.

After F1, replace this README's planning-only status with genuine Windows setup/run/test/build instructions and retain links to the stable contracts.
