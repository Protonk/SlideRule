# Plan: Rationalize the lodestone experiment directory

## Current state

Seven scripts and a visualization, each with its own `run_case()`, column
definitions, CSV-writing, and hardcoded parameter grids:

| Script | Kinds | Grid | Outputs | Reuse logic |
|--------|-------|------|---------|-------------|
| `lodestone_sweep` | uniform, geometric | 4 sweeps hardcoded | `lodestone_summary.csv`, `lodestone_percell.csv` | none |
| `l1c_grid_sweep` | uniform, geometric | (q,d) grid hardcoded | `l1c_grid_2026-03-12/` | none |
| `l1c_stability_sweep` | uniform, geometric | depth fill + alpha check | `l1c_stability_2026-03-12/` | loads from 2 prior CSVs |
| `harmonic_diagnostic_sweep` | +harmonic, mirror_harmonic | same L1c grid | `harmonic_diagnostic_2026-03-12/` | loads from L1c + prior harmonic |
| `h1_sweep` | uniform only (implicit) | 3 sub-sweeps hardcoded | `h1a/b/c_*.csv` | none |
| `optimize_delta` | uniform only (implicit) | 10 (q,d) pairs | stdout only | none |
| `fsm_coarse` | uniform only (implicit) | ad-hoc loops | stdout only | none |
| `error_profile` | reads CSVs | none (viz only) | `error_profile.png` | — |

Problems:

1. **Four near-identical `run_case()` functions.** `lodestone_sweep`,
   `l1c_grid_sweep`, `l1c_stability_sweep`, and `harmonic_diagnostic_sweep`
   each define their own `run_case` that calls the same three lib functions
   (`best_single_intercept`, `optimize_shared_delta`, `free_per_cell_metrics`)
   and builds the same summary + percell row dicts. The only differences are
   column ordering and whether `source_run` is included.

2. **Reuse logic is fragile.** `l1c_stability_sweep` and
   `harmonic_diagnostic_sweep` load prior CSVs by hardcoded path, coerce
   types from strings, and match rows by exact key fields. This breaks if
   column sets change or prior runs are re-generated.

3. **Partition coverage is sparse.** Only 4 of 23 kinds have been swept
   (uniform, geometric, harmonic, mirror_harmonic). Extending to more kinds
   means copying yet another sweep script or hacking kind lists into an
   existing one.

4. **No shared per-case runner.** Adding a new diagnostic (e.g. delta-shape
   stats to the percell output) means patching it in 4 places.

5. **Two legacy scripts produce no CSV.** `optimize_delta` and `fsm_coarse`
   print to stdout with no structured output. Their diagnostic value is real
   but their results are unreproducible without re-running.

---

## Part 1: Shared machinery and consolidated runs

### Extract: `lodestone_runner.sage`

A single shared file at `experiments/lodestone/lodestone_runner.sage`
providing a **core-object-centered** API, with row builders layered on top:

```sage
def compute_case(q, depth, p_num, q_den, partition_kind='uniform_x',
                 layer_dependent=False):
    """Run one case and return the raw result bundle plus common derived scalars."""

def build_summary_row(case, source_run):
    """Serialize the canonical summary CSV row."""

def build_percell_rows(case, source_run):
    """Serialize the canonical per-cell CSV rows."""

SUMMARY_COLUMNS = [...]   # one canonical column list
PERCELL_COLUMNS = [...]   # one canonical column list
```

`compute_case()` should return enough structure for all remaining lodestone
scripts:

- inputs/config: `q`, `depth`, `p_num`, `q_den`, `partition_kind`,
  `layer_dependent`
- shared primitives: `paths` (and `edges` / `edge_index` if useful)
- partition helpers: `partition`, `row_map`
- raw solver outputs: `single_pol`, `opt_pol`, `free_metrics`
- common derived scalars: `single_err`, `opt_err`, `free_err`, `improve`,
  `gap`, `single_u`, `opt_u`, `free_u`, `elapsed`
- convenience counts: `n_params`, `n_paths`

This replaces the four duplicated `run_case` / `run_lodestone_case`
functions and column definitions for the sweep scripts, while still serving
the richer consumers:

- `partition_sweep.sage` uses `compute_case()` plus the row builders.
- `h1_sweep.sage` uses `compute_case()` and adds H1-specific delta-shape
  statistics locally.
- `inspect_case.sage` uses `compute_case()` and adds induced-family /
  delta-table / cell-level diagnostics locally.

That avoids both failure modes of a row-only helper:

- recomputing the same solver outputs in `h1_sweep` and `inspect_case`
- bloating the canonical CSV schema with experiment-specific fields

`source_run` should become a mandatory field in the row builders. Since
reuse logic is dropped, every row in a fresh run gets `source_run = RUN_TAG`.
The field exists for provenance (which run produced this row?) and for
future manual merges across runs, not for runtime artifact stitching. This
removes the current column-shape split between `lodestone_sweep` /
`l1c_grid_sweep` (no source_run) and the provenance-aware sweeps (optional
source_run).

### Consolidate sweeps into two scripts

**`partition_sweep.sage`** — the general-purpose sweep driver.

Configuration at the top:

```sage
KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
GRID = [(3, 4), (5, 4), (5, 6), (3, 8)]
ALPHAS = [(1, 2)]
LAYER_MODES = [False, True]
RUN_TAG = 'partition_2026-03-18'
```

Iterates the cartesian product, calls `compute_case()` for each, writes
`results/<RUN_TAG>/summary.csv` and `results/<RUN_TAG>/percell.csv`.
To add partition kinds or grid points, edit the config lists.

This replaces `lodestone_sweep`, `l1c_grid_sweep`, `l1c_stability_sweep`,
and `harmonic_diagnostic_sweep`. The reuse logic is dropped — the shared
runner and the modest sweep grids make full re-computation cheap enough that
re-running is simpler than stitching prior artifacts. At the current 4-kind
grid (32 cases), a full run is ~2-5 minutes. Scaling to all 23 kinds on
the same grid would be ~20-30 minutes — tolerable but worth noting before
committing to a large sweep.

**`h1_sweep.sage`** — stays, but simplified.

The H1 sweep has a different output schema (flat 27-column rows, delta-shape
stats, no percell split). It remains as a separate script but:
- Loads `lodestone_runner.sage` for the core computation via
  `compute_case()` to avoid duplicating the three-metric logic.
- Keeps its own `delta_shape_stats` and flat-row construction (these are
  H1-specific).
- Writes CSV to `results/` as it does now.

### Merge diagnostics into `inspect_case.sage`

`fsm_coarse.sage` and `optimize_delta.sage` are diagnostic workbenches,
not experiments. They exercise the same mathematical operations the sweep
scripts use, but their purpose is detailed inspection of a single case
rather than structured data production.

Merge both into **`inspect_case.sage`** — a single script that takes a
case configuration at the top and prints everything worth knowing about it:

- Three-metric computation (via `compute_case()` from the runner)
- Induced pattern family: size, dimension, sumset, Sidon/cover-free
  subset sizes
- Delta table: per-(state, bit) values from the optimized policy
- Cell-level H/V/D breakpoint analysis
- Exact-vs-sampled validation

Configuration at the top:

```sage
Q = 3
DEPTH = 6
P_NUM, Q_DEN = 1, 2
KIND = 'uniform_x'
LAYER_DEPENDENT = False
POLICY = 'zero'          # for pattern-family analysis
VALIDATE = True           # run exact-vs-sampled check
CELL_REPORT_BITS = None   # specific cell to inspect, or None to skip
```

The functions from `fsm_coarse.sage` (`run_experiment`, `validate`,
`cell_report`) and from `optimize_delta.sage` (induced-family diagnostics,
delta-view reporting) become local functions in this file. They stay here
rather than in `lib/` — if a future need arises to call them from tests
or other experiments, that provides real friction for a real decision.

### Delete after consolidation

| Old script | Replaced by |
|------------|-------------|
| `lodestone_sweep.sage` | `partition_sweep.sage` |
| `l1c_grid_sweep.sage` | `partition_sweep.sage` |
| `l1c_stability_sweep.sage` | `partition_sweep.sage` |
| `harmonic_diagnostic_sweep.sage` | `partition_sweep.sage` |
| `fsm_coarse.sage` | `inspect_case.sage` |
| `optimize_delta.sage` | `inspect_case.sage` |

Historical dated result directories (`l1c_grid_2026-03-12/`,
`l1c_stability_2026-03-12/`, `harmonic_diagnostic_2026-03-12/`) are deleted.
The code that generated them is in git history; `partition_sweep` can
regenerate equivalent data for any grid point.

The current flat files `results/lodestone_summary.csv` and
`results/lodestone_percell.csv` should also be moved into a historical run
directory (for example `results/lodestone_2026-03-11/{summary,percell}.csv`)
so the post-rationalized results layout has one shape instead of two.

---

## Part 2: README for what remains

After rationalization, `experiments/lodestone/` contains:

```
experiments/lodestone/
├── README.md
├── lodestone_runner.sage       shared compute_case + column definitions
├── partition_sweep.sage        general partition-comparison sweep
├── h1_sweep.sage               H1 hypothesis sweep (uniform only, delta stats)
├── inspect_case.sage           single-case diagnostic workbench
├── error_profile.sage          per-cell error profile visualization
└── results/
    ├── <RUN_TAG>/              partition_sweep output dirs
    │   ├── summary.csv
    │   └── percell.csv
    ├── lodestone_2026-03-11/   migrated legacy flat sweep artifacts
    │   ├── summary.csv
    │   └── percell.csv
    ├── h1a_gap_vs_q.csv        h1_sweep outputs
    ├── h1b_depth_scaling.csv
    ├── h1c_layer_dependent.csv
    └── error_profile.png
```

The README should document:

- **What this folder does**: Compares partition kinds under shared-delta
  optimization. The core question is whether geometric partitions achieve
  lower worst-case error than alternatives under the FSM sharing constraint.
- **Entry points**: `partition_sweep.sage` (the main driver — edit KINDS,
  GRID, ALPHAS at the top), `h1_sweep.sage` (uniform-only H1 hypothesis
  baseline), `inspect_case.sage` (detailed single-case diagnostics),
  `error_profile.sage` (per-cell visualization from a chosen run's
  `percell.csv`).
- **Shared machinery**: `lodestone_runner.sage` provides `compute_case()`
  and column definitions. All scripts load it.
- **Adding partition kinds**: Edit the KINDS list in `partition_sweep.sage`
  and re-run. The pipeline is fully kind-agnostic.
- **Results layout**: Each `partition_sweep` run creates a dated
  `results/<RUN_TAG>/` directory. H1 outputs are flat CSVs in `results/`.

---

## Implementation sequence

1. Write `lodestone_runner.sage` (extract `compute_case`, row builders,
   column defs).
2. Write `partition_sweep.sage` (config-driven, loads runner).
3. Simplify `h1_sweep.sage` to load runner for core metrics via
   `compute_case()`.
4. Write `inspect_case.sage` by merging diagnostic functions from
   `fsm_coarse.sage` and `optimize_delta.sage`.
5. Delete `lodestone_sweep.sage`, `l1c_grid_sweep.sage`,
   `l1c_stability_sweep.sage`, `harmonic_diagnostic_sweep.sage`,
   `fsm_coarse.sage`, `optimize_delta.sage`.
6. Delete historical dated result directories.
7. Move `results/lodestone_summary.csv` and `results/lodestone_percell.csv`
   into `results/lodestone_2026-03-11/` and retarget `error_profile.sage`
   to read a configurable `results/<RUN_TAG>/percell.csv`.
8. Update `SWEEP-REPORTS.md` links for the moved legacy CSVs.
9. Write `experiments/lodestone/README.md`.
10. Run `partition_sweep.sage` with the current 4-kind grid. Validate by
    comparing `single_err`, `opt_err`, `free_err` for each
    `(kind, q, depth, layer_dependent)` key against the legacy CSVs,
    within tolerance 1e-6.
11. Run tests.
