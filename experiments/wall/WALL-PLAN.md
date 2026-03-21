# Wall Plan

Localize, attribute, and scale the wall obstruction. All scripts live in
`experiments/wall/` and reuse `keystone_runner.sage` for solver access.

## Definitions

**Wall (global):** `gap = opt_err - free_err`. The amount of worst-case
error forced by shared structure, after optimizer quality is accounted for.
This is a single number per (kind, q, depth, exponent, layer_mode) case.

**Wall excess (per-cell diagnostic):** `wall_excess_j = cell_worst_err_j -
free_cell_worst_j`. The per-cell sharing penalty. This is NOT a spatial
decomposition of the global wall. The global wall is `max(shared_j) -
max(free_j)`, while `max(wall_excess_j) = max(shared_j - free_j)`. These
are only equal when the relevant maxima land on the same cell. Wall excess
is an upper-envelope local diagnostic showing where the sharing constraint
hurts most and how concentrated or distributed the penalty is.

Summary statistics on wall excess:
- `max_excess`: the worst per-cell penalty; a candidate contributor to the
  global wall, not necessarily equal to it
- `top_quartile_share`: fraction of total excess mass carried by the
  top 25% of cells (concentration measure; stable, interpretable)
- `max_over_median`: max excess / median excess (spread measure; stable
  even when some cells have near-zero excess)

**Candidate types:** The solver's `worst_candidate_type` per cell is one of:
- `endpoint`: the worst error occurs at a cell boundary
- `H`: the worst error occurs at an H-grid crossing (Day's breakpoint)
- `D`: the worst error occurs at a D-candidate (interior stationary point)

These labels come from `cell_logerr_arb` in `lib/day.sage` and are already
present in keystone percell CSVs. In practice, the current seed data may be
overwhelmingly `endpoint` with some `D` and possibly no `H`. The
candidate_phase_barcode should degrade gracefully to a two-phase picture
if that is the case.

## Seed inventory

Existing data to mine before launching new sweeps:

- `../keystone/results/wall_surface_2026-03-18/` — 200-case grid
  (4 kinds x 5 q x 5 depths x 2 layer modes, exponent 1/2)
- `../keystone/results/partition_2026-03-18/` — broader zoo seed
- `../keystone/results/h1a_gap_vs_q.csv` — gap vs q at fixed depth
- `../keystone/results/h1b_depth_scaling.csv` — gap vs depth at fixed q
- `../keystone/results/h1c_layer_dependent.csv` — LI/LD comparison
- `../alternation/` — sign/run-length tooling and cached sign sequences

## Execution order

### Phase 1: Infrastructure from existing data (no new sweeps)

**1. `enrich_summary.sage`** — DONE

Read keystone summary CSVs, compute derived columns, and write a single
enriched table that all downstream scripts read from.

Derived columns:
- `n_cells = 2^depth`
- `n_params`: `1 + 2*q` (LI) or `1 + 2*q*depth` (LD)
- `param_to_cell_ratio = n_params / n_cells`
- `gap_over_free = gap / free_err`
- `gap_over_opt = gap / opt_err`
- `worst_cell_x_mid` (from worst_cell_x_lo/x_hi if present)
- `worst_cell_plog_mid` (log-coordinate position; more revealing than raw x
  for cross-kind comparison)

Output: `results/enriched_summary.csv`.

This is the data contract for Phase 3: `gap_collapse` and all later
analysis scripts read from enriched_summary, not from raw keystone CSVs.

**2. `join_layer_modes.sage`** — DONE (104 paired cases, gap reduction median 43.9%)

Pair LI and LD rows for the same (kind, q, depth, exponent) from the
enriched summary. Output a derived table with:
- `gap_li`, `gap_ld`, `gap_reduction = 1 - gap_ld / gap_li` (set to NaN
  when `gap_li < 1e-12` to avoid division by near-zero in shallow/high-q
  cases where the LI wall is already negligible)
- `worst_cell_x_mid_li`, `worst_cell_x_mid_ld`
- `worst_cell_shift = |x_mid_li - x_mid_ld|`

Output: `results/joined_layer_modes.csv`.

**3. `worst_cell_map.sage`** — DONE

Panel grid colored by worst-cell position. x-axis = q, y-axis = depth,
color = normalized worst-cell midpoint, one panel per (kind, layer_mode).

Question: does the worst cell migrate with (q, depth, layer_mode)?
Stability or migration is evidence for (not proof of) cell-difficulty vs
sharing-geometry readings. Pair with wall-excess concentration from step 4
and the LI-to-LD worst-cell shift from the joined table to strengthen any
interpretation.

Input: enriched summary. No new solver runs needed.

**4. `wall_excess_ribbons.sage`** — DONE

Per-cell ribbon showing free error, shared error, and wall excess for one
case. LI and LD as separate rows.

Anchor case: q=3, depth=6, exponent=1/2, geometric_x — matching the
compatibility benchmark in KEYSTONE.md §4 so the wall work and keystone
story stay visibly coupled.

Free-cell error is recomputed from `free_cell_intercept` via
`cell_logerr_arb` (cheap, no optimizer — just evaluate the error at the
known free intercept already in the percell CSV).

Summary annotations on each ribbon: max_excess, excess_ratio, n cells
above median excess.

### Phase 2: Non-1/2 robustness sweep

**5. Exponent robustness sweep** — RUNNING

This is a robustness check, not a scaling pass. It tests whether the wall
decomposition and residual LD wall survive away from exponent 1/2. A wider
q-grid for actual q-scaling claims belongs in a later phase.

Grid:
- kinds: uniform_x, geometric_x, harmonic_x, mirror_harmonic_x
- depths: 4, 5, 6, 7, 8
- q: 3, 5
- exponents: 1/3, 2/3 (1/2 already exists in seed data)
- layer modes: LI, LD

Cases: 4 x 5 x 2 x 2 x 2 = 160 new cases. At ~40s each = ~1.8 hours
serial. Parallelizable across kinds.

Output: `results/exponent_robustness/summary.csv` and `percell.csv`.

Run `enrich_summary.sage` again after this sweep to incorporate the new
data into the enriched table.

### Phase 3: Analysis

**6. `gap_collapse.sage`** — DONE (seed data; re-run after sweep completes)

Scatter plot: x = `param_to_cell_ratio`, y = `gap` or `gap_over_free`,
color = partition kind, marker = LI vs LD.

Input: `results/enriched_summary.csv` (must include both seed data and
exponent robustness sweep).

Question: can the wall be organized by rho = n_params / 2^depth? If the
points collapse onto a curve, that is a scaling law. If they don't, the
wall depends on more than the ratio. Either outcome is informative.

**7. `candidate_phase_barcode.sage`** — DONE

Per-cell strip colored by `worst_candidate_type` (`endpoint`, `H`, `D`).
Overlay the worst cell and cells with large wall excess.

Question: does the wall concentrate at endpoints or at interior competition
points? Does the candidate phase change between LI and LD?

**8. Alternation-to-wall correlation (E5)**

Cross-reference wall excess per cell with sign-sequence run structure from
`experiments/alternation/`.

This should predict something numeric, not just "correlate." Target
response variables:
- `max_excess` per case
- `gap_reduction` (LI to LD)
- worst-cell migration distance

Candidate predictors from the sign sequence:
- run count
- sign-change count
- sandwich vs non-sandwich
- dominant-sign fraction
- nearest transition distance to worst cell

Question: does the spatial sign structure predict wall size, concentration,
or the benefit of layer-dependent parameterization?

## Initial findings (Phase 1 + Phase 3 on seed data)

**Worst-cell map:** Uniform's worst cell is consistently pinned near
plog ≈ 0 (x ≈ 1, left endpoint) across almost all (q, depth) under both
LI and LD. Geometric's worst cell moves substantially — it wanders across
the grid, suggesting the wall is shaped more by sharing geometry than by
fixed cell difficulty. Harmonic and mirror-harmonic show intermediate
behavior.

**Wall excess ribbons (geometric, q=3, d=6):**
- LI: large wall excess distributed across cells, top-quartile share ~42%,
  max/median ~2.0. The penalty is broad.
- LD: smaller total excess but more concentrated — the sandwich structure
  from alternation is visible (excess drops near center, peaks at endpoints).

**Gap collapse (seed data only):**
- Raw gap roughly collapses with param-to-cell ratio (monotone decrease on
  log x-axis), but partition kinds separate vertically — geometric has
  higher wall than uniform at the same ratio under LI.
- Normalized gap (gap/free_err) does NOT collapse — massive scatter,
  especially at low ratios.

**Candidate phase barcode:** Overwhelmingly `endpoint` (62-63 of 64 cells
at d=6). Only 1-2 `D`-candidates, located near m ≈ 1.6 (close to m*).
No `H` cells at this case. The wall is decided at cell boundaries, not at
interior competition points.

## Success condition

The plan has paid off when `experiments/wall/` has figures answering:

- where the wall lives spatially (worst_cell_map, wall_excess_ribbons)
- how LI and LD differ locally (joined tables, ribbons, worst-cell shift)
- whether the wall decomposition survives at non-1/2 exponents (robustness)
- whether the wall collapses to a param-to-cell ratio (gap_collapse)
- whether sign-sequence structure predicts wall properties (E5)
