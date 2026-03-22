# Scramble Plan

Active planning for the tiling experiment program. Construction details are in
`PARTITIONS.md` Group H. Current results are summarized in `TILING.md`.

## Current scope: wiring the zoo

The immediate task is to wire the whole partition zoo into the same
geometry-only observable pipeline so the scrambles and the existing kinds can
be compared on equal footing.

### Goal

For every registered zoo kind plus the two scramble modes, produce the same
basic diagnostic bundle:

- partition rows at the target depths
- free intercept field `c*`
- residual field `g = R0(c*)`
- Stage A metrics: `corr_inf`, `corr_l2`, `nrmse_inf`, `nrmse_l2`,
  residual norms
- basis-family features (as defined in `basis_identification.sage`)
- coupling diagnostics (`rho_peak`, `mean_width_eps`)
- stable metadata suitable for joins and plotting

Do not hardcode the zoo size in the code or the analysis. Derive the registered
kind list from the executable registry in `lib/partitions.sage`, then append
the two synthetic scramble cases.

### Case identity

The unit of analysis is an executable **case**, not just a partition kind.
That matters because the two scrambles share `kind = scramble_x` but differ in
mode.

Every output table should therefore carry:

- `case_id` — stable unique identifier such as `uniform_x` or
  `scramble_x__peak_swap`
- `kind` — canonical partition kind passed to `build_partition`
- `scramble_mode` — blank for ordinary kinds, set for scrambles
- `source_kind` — blank for ordinary kinds, currently `geometric_x` for
  scrambles
- `display_name` — plotting label
- `depth`

This avoids collisions in joins, summaries, and metadata.

### Outputs

- `zoo_observables.csv`
  One row per cell per case/depth with `case_id`, geometry, `c*`,
  `g = R0(c*)`, `Δ^L`, and basis-family features.
- `zoo_case_metrics.csv`
  One row per case/depth with Stage A metrics, coupling diagnostics,
  and summary norms.
- `zoo_metadata.csv`
  One row per executable case with stable descriptors: category, group,
  density, symmetry, arithmetic, curve-aware, color, source kind, and
  resolved plotting label.

### Discipline

Current purpose:

1. make sure the scrambles run through the same pipeline as the rest
2. make it cheap to check whether an observed scramble effect is genuinely
   unusual or already present in some existing kind
3. get the data into a form that supports a later latent survey without
   deciding that survey prematurely

Explicit non-goals for now:

- do **not** rush into an all-zoo theory of correlates
- do **not** fit a grand explanatory model over N partition names just because
  the table exists

The right stopping point is: the zoo is wired, the diagnostics are comparable,
the summary visuals exist, and we pause to reflect before escalating.

### Execution steps

**1. Make `lib/partitions.sage` the executable source of truth.** — DONE

Add one cleanup step ahead of the zoo sweep: convert the executable parts of
`lib/partitions.json` into `lib/partitions.sage`, so the Sage code itself owns
the registry of kinds, default kwargs, display names, colors, categories, and
other fields needed to actually run cases.

Rule of thumb:

- if a field is needed to execute a partition or build stable sweep metadata,
  it belongs in `lib/partitions.sage`
- if a field is narrative, explanatory, or presentation-only, it belongs in
  `PARTITIONS.md` or another documentation file

This step should also resolve the current mismatch between descriptive JSON
defaults and executable kwargs. Symbolic values such as `depth+4`, `auto`, and
`inverse_golden_ratio` should become actual Sage-side defaults or helper logic
in `lib/partitions.sage`, not strings that later code has to interpret.

After this migration, `lib/partitions.json` should be treated as either:

- a generated export derived from the Sage registry, or
- a doc-facing artifact that no longer drives execution

but not the authoritative executable source.

**2. Build an explicit executable case table.** — DONE

Once `lib/partitions.sage` owns the executable registry, build a local `CASES`
table from that registry:

- ordinary cases: one case per registered kind
- synthetic scramble cases:
  `scramble_x__peak_swap`, `scramble_x__peak_avoid`

Each case row should include `case_id`, `kind`, `kwargs`, `scramble_mode`,
`source_kind`, `display_name`, `category`, and `group`.

**3. Factor out free-intercept computation from a built partition.** — DONE

`free_per_cell_metrics` accepts `partition_kind` but not arbitrary `**kwargs`,
so parameterized kinds and scrambles cannot be routed through it directly.
Factor the existing pattern into a shared helper:

`free_intercepts_from_partition(partition, p_num, q_den)`

Requirements:

- consume a pre-built partition
- compute one free intercept per cell via `optimal_cell_intercept_arb`
- infer any domain information it needs from the partition rows rather than
  baking in `[1, 2)`
- return rows in the same cell order as the partition
- expose both per-cell intercepts and a bits-keyed lookup

This helper should become the common path for `zoo_sweep.sage` and any tiling
script that needs parameterized partitions.

**4. Write `zoo_sweep.sage`.** — DONE

Single script that loops over all cases at depths `5, 6, 7, 8`
(depth `4` remains excluded from the primary summary to match the basis
identification design). For each case:

- build the partition with resolved kwargs
- compute `c*` via the shared helper from step 2
- compute `g = R0(c*)` using the existing `leading_bit_projection`
  infrastructure
- compute `Δ^L` at cell midpoints
- compute the full Stage A bundle:
  `corr_inf`, `corr_l2`, `nrmse_inf`, `nrmse_l2`,
  `residual_norm_inf`, `residual_norm_2`
- compute basis-family features:
  `eps_mid`, `eps_prime_mid`, `eps_pp_mid`, `mean_cell_eps`,
  `cell_moment1`, `cell_moment2`, `contains_mstar`,
  `dist_to_mstar`, `eps_a`, `eps_b`
- compute coupling diagnostics:
  `rho_peak`, `mean_width_eps`
- append per-cell rows to `zoo_observables.csv`
- append per-case summaries to `zoo_case_metrics.csv`

Runtime should be described in terms of case count and depth, not baked into
the plan. With the current zoo size this is still a geometry-only, single-digit
minutes sweep.

**5. Build `zoo_metadata.csv`.** — DONE

Emit one row per executable case, not one row per raw kind. This file should be
the stable join target for plots and downstream summaries.

For ordinary cases, metadata comes from the executable registry in
`lib/partitions.sage`. For scrambles, synthesize two rows with:

- `case_id`
- `kind = scramble_x`
- `scramble_mode`
- `source_kind = geometric_x`
- group/category tags consistent with Group H usage in `PARTITIONS.md`
- plotting labels and colors

If `lib/partitions.json` is still kept around after step 1, it should be
exported from the same Sage-side registry so this metadata table cannot drift.

**6. Validate the scrambles against the implementation they actually use.** — DONE

Do **not** use "scrambling uniform reproduces uniform_x" as the control. The
current `scramble_x` implementation is geometric-width-specific, not a generic
"scramble any source partition" operator.

Instead validate:

- **Width multiset preservation:** at each depth, both scramble modes have the
  same sorted width list as `geometric_x`
- **Boundary sanity:** boundaries are strictly increasing and hit the exact
  endpoints
- **Coupling inversion:** `rho_peak` and `mean_width_eps` move sharply away
  from geometric in the intended direction

These are the controls that match the current construction.

**7. Spot-check against existing results.** — DONE

Compare overlapping raw cases against existing artifacts:

- `basis_observables.csv` for the 7 already-tested raw kinds
  (4 baselines + 3 adversaries)
- Stage A metrics against the existing displacement-field outputs where the
  overlap exists

Use overlap depths only. Since the primary zoo summary starts at depth `5`,
validation should compare on `5–8` unless there is a deliberate reason to run a
separate depth-4 smoke pass.

Any discrepancy beyond floating-point tolerance is a zoo-pipeline bug.

**8. Produce a summary figure set, not a single rank plot.** — DONE

The zoo summary should include at least four compact views:

- **Depth-7 ranking panel:** side-by-side rankings for `corr_inf` and
  `nrmse_inf`, so high-correlation but badly scaled cases do not hide
- **Kind × depth heatmaps:** `corr_inf` and `nrmse_inf` across all cases and
  depths, to show stability rather than one-depth cherry-picking
- **Coupling scatter:** `rho_peak` vs Stage A fit quality, colored by group and
  sized or annotated by residual norm, to show whether scramble behavior is
  unusual in zoo context
- **Scramble control panel:** geometric vs `peak_swap` vs `peak_avoid` width
  assignment / coupling diagnostics, so the intervention itself is visible

Optional fifth view if it earns its keep:

- **Residual-norm panel:** `||R0(c*)||∞` or `||R0(c*)||₂` across depths, to
  show where the signal is large enough for correlations to matter

The summary should make it easy to answer two questions:

1. Are the scrambles actually unusual relative to the zoo?
2. Are their differences visible in more than one metric?
