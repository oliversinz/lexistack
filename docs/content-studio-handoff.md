# LexiStack Content Studio — Minimal Handoff for Experiment E

**Purpose:** Define the smallest deliverable needed from the separate Content Studio before the first LexiStack5 coding phase. This is **not** a request to build a CMS or to generate 40 new puzzles.

## Stage CS0 (required before LexiStack5 F1)

Create an independent Git repository for the Studio. Inside it, add a **pure-Dart** package at `packages/lexistack_content_contract/`, with `pubspec.yaml`, `lib/`, `test/` and a short README.

The package implements **schemaVersion 2** data models, strict/partial/candidate validation, catalog-wide checks and structured diagnostics as specified in the LexiStack5 product contract. It must have no Flutter imports or UI dependencies. The package should be consumable directly by a Dart CLI and a Flutter project via Git dependency pinned to a **full, immutable commit SHA** with `path: packages/lexistack_content_contract`.

**Required CS0 tests:** valid 8-level pack, malformed JSON/type, absent/duplicate IDs, duplicate normalized board tile, invalid tiers, 40–160-character trivia boundary, missing/red-herring references, catalog-wide title/repetition/overlap violations, partial-vs-strict modes (including a temporary campaign-only manifest with no Daily entry), candidate replacement and candidate addition without changing installed assets. Report exact test commands and exit codes.

**CS0 evidence to pass into F1:** actual Studio Git URL; full package commit; Dart SDK constraints; test results; package import names and validator entry points; a manifest/pack parse sample. Pin version/commit and never change it invisibly during F1–F6.

## Stage CS1 (editorial workflow; can proceed independently after CS0)

Produce new levels with one of Claude Opus / GPT-6 and have the other independently review them. Swap creator/reviewer roles on a documented subset to assess editorial quality. Preserve creation rationale and review findings separately from the production JSON. Validate candidates with the single shared Dart contract and only release **approved immutable JSON packs**.

Recommended human-readable review dimensions: literal truth of each category, alternate full partitions, honest cross-category red herrings, trivia fact accuracy, international-English comprehensibility, difficulty/tier placement, diversity across the catalog. Structural validity is necessary but not sufficient; the final editorial decision is an explicit manual approval.

## Content release format

An immutable release contains `manifest.json`, one JSON per pack, a short release note and a list of Git/content hashes. Keep editorial provenance and reviewer comments **outside** production schema v2. Original JSON IDs remain stable across revisions unless a reviewed breaking change is justified. Document replacement effect on saved unfinished games.

## Experiment boundary

During LexiStack5 F1–F6, use only the locked existing reference dataset. Studio-generated improvements enter a **separate post-experiment evaluation**, so technical sequential-development improvements and editorial improvements remain distinguishable.

No visual level editor, backend, cloud orchestration, runtime inference, Git submodules or third repository are required for CS0/CS1.
