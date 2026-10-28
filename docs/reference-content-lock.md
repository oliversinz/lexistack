# LexiStack5 — Frozen Reference Content Lock v1.0

**Status:** SOURCE SELECTED, ASSET COPY/INDEPENDENT STRICT VALIDATOR PENDING at P0. This is an engineering comparison fixture, **not** an editorial certification of puzzle quality.

- Source repository: `https://github.com/oliversinz/LexiStack3`
- Immutable source commit: `8b84f2d6c75cb807fba9db19cba707f963e02020`
- Source directory: `assets/levels/`
- Required assets: the manifest and the five JSON files below, copied **byte for byte** into LexiStack5 `assets/levels/` when their stage requires them.
- No source code, tests, UI, architecture or other implementation artifacts from LexiStack3/4 may be copied. The copied JSON data is the only explicit exception.

## Source identity: Git blob SHA-1 (not SHA-256)

| File | Git blob object SHA-1 from source commit |
|---|---|
| `manifest.json` | `6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d` |
| `pack1.json` | `5efa3c88c769f74eee872860766681f5c2cc1c64` |
| `pack2.json` | `32ca5e922e3da3e2b22a42716de87a63e53492f8` |
| `pack3.json` | `fc88352362ea575e7c0f38670b0c7e81c24ec070` |
| `pack4.json` | `54c09ae4c2f0a5d07b95addc42e80eacac33d2c6` |
| `daily.json` | `5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6` |

**Verification:** Compute Git blob IDs on the actual Windows files (e.g., `git hash-object assets/levels/pack1.json`) and compare this table. Copy raw bytes rather than reserializing JSON. When using source control on Windows, normalize `.gitattributes` deliberately to prevent unintended CRLF changes.

## Initial independent mechanical spot check (2026-10-28)

The C and D candidates were both read at their named commits and checked for JSON parseability, schema v2, counts, pack IDs, four categories/tiers per level, unique board tiles, trivia character lengths, basic red-herring references, repeated normalized category titles, tile appearance in >2 levels, and ≥3-tile category overlaps. C returned: **5 packs, 40 levels, 160 groups, 640 tile positions, 0 problems in this subset**.

This check is **not the official standalone validator** and **does not establish zero warnings**, semantic uniqueness, fair red herrings or trivia accuracy. Run the production strict validator independently at P0 when the full package exists, then again at F5/F6.

## Phased usage

- **F1:** Install immutable `pack1.json` and a temporary incremental manifest listing only present content. Keep the locked production manifest as an immutable reference file if desired, but do not present absent packs as installed.
- **F3:** Install immutable `daily.json`, with an incremental manifest. Both files are subject to full cross-file checks in partial mode.
- **F5:** Install immutable `pack2.json`–`pack4.json`, and use the **exact locked production `manifest.json`**. Run strict validation, file identity verification and production-level tests.
- **F6:** Revalidate exactly the same assets; no replacements during the Experiment E technical score.

## Handling a source-data failure

If a raw file differs from the listed Git blob or fails structural validation, report it as a **P0/F5 fixture blocker**. Do not automatically repair, silently reformat or regenerate the JSON. A reviewed change must be recorded as an amendment with the old and new identities, rationale, and impact on comparability. Editorial flaws without structural violations are recorded for the separate Content Studio experiment; they do not justify quietly changing the engineering fixture.
