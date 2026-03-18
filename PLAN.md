# Plan: Restructure experiments/ into topical subdirectories

## Status (2026-03-18)

- Follow-up audit completed after the directory move/refactor.
- Verified `./sagew tests/run_tests.sage` passes (`88` tests).
- Regenerated the missing root stepstone PNG artifacts:
  - `experiments/stepstone/chord_slope_crossing.png`
  - `experiments/stepstone/integrate_coastline.png`
  - `experiments/stepstone/many_steps_miss.png`
- Additional smoke checks passed for moved/shared-helper scripts:
  - `./sagew experiments/stepstone/damage/counter_factual.sage`
  - `./sagew experiments/stepstone/zoo/radar_peaks.sage`
  - `./sagew experiments/stepstone/hazards/crossings.sage`
- No further refactor fixes were required in this pass beyond regenerating
  the expected PNG artifacts and recording verification.

## Context

The experiments/ directory grew organically: sweep drivers, visualization
scripts, legacy baselines, and a deep chord_error/ tree all sit at the same
level. The goal is a cleaner layout with:

- Topical subdirectories (no `core/` or `helpers/`)
- 2 shared utility files at the experiments/ root
- A short README explaining subdirectories
- An AGENTS.md explaining how/when to create new subdirectories
- Two exemplar subdirectories: **lodestone/** and **stepstone/**
- Results moved from `experiments/results/` into `experiments/lodestone/results/`

## Target layout

```
experiments/
├── README.md                          NEW — short orientation
├── AGENTS.md                          NEW — subdirectory creation protocol
├── zoo_figure.sage                    NEW — shared zoo-grid plotting
├── sweep_driver.sage                  NEW — shared sweep + CSV infrastructure
├── lodestone/
│   ├── lodestone_sweep.sage           MOVED from experiments/
│   ├── l1c_grid_sweep.sage            MOVED
│   ├── l1c_stability_sweep.sage       MOVED
│   ├── harmonic_diagnostic_sweep.sage MOVED
│   ├── h1_sweep.sage                  MOVED (legacy baseline)
│   ├── fsm_coarse.sage                MOVED (foundational FSM diagnostics)
│   ├── optimize_delta.sage            MOVED (shared-delta optimization)
│   └── results/                       MOVED from experiments/results/
│       ├── lodestone_summary.csv      from results/
│       ├── lodestone_percell.csv      from results/
│       ├── h1a_gap_vs_q.csv           from results/
│       ├── h1b_depth_scaling.csv      from results/
│       ├── h1c_layer_dependent.csv    from results/
│       ├── harmonic_diagnostic_2026-03-12/  from results/lodestone/
│       ├── l1c_grid_2026-03-12/             from results/lodestone/
│       └── l1c_stability_2026-03-12/        from results/lodestone/
├── stepstone/
│   ├── TILT.md                        MOVED from chord_error/
│   ├── plog_chord_argument.sage       MOVED from chord_error/
│   ├── damage/                        MOVED from chord_error/damage/
│   │   └── counter_factual.sage (+.png)
│   ├── zoo/                           MOVED from chord_error/zoo/
│   │   ├── cartesean_envelope.sage (+.png)
│   │   ├── radar_peaks.sage (+.png)
│   │   ├── polar_heatmap.sage (+.png)
│   │   └── curvature_mismatch.sage (+.png)
│   ├── chord_slope_crossing.sage      UP from chord_error/stepstones/
│   ├── many_steps_miss.sage           UP from chord_error/stepstones/
│   ├── integrate_coastline.sage       UP from chord_error/stepstones/
│   ├── art/                           UP from chord_error/stepstones/art/
│   │   ├── FRACTAL.md
│   │   ├── RASTER-FRACTAL-PLAN.md
│   │   ├── raster.sage
│   │   └── multiplexer.sage
│   └── hazards/                       UP from chord_error/stepstones/hazards/
│       ├── _slope_deviation.sage
│       ├── crossings.sage
│       ├── curated.sage
│       └── stability_heatmap.sage
```

## Key decisions

### 1. fsm_coarse.sage → lodestone/

FSM coarse diagnostics are the foundational evaluation pipeline that all
lodestone sweeps build on. `fsm_coarse` establishes how the Day evaluator
and Jukna combinatorics work; the sweeps then explore parameters. Same
story, same topic.

### 2. optimize_delta.sage → lodestone/

Shared-delta optimization is the core technique lodestone sweeps use.
`optimize_delta` is the first exploration on `uniform_x`; the sweeps
generalize across partition kinds. Same optimization pipeline, same topic.

### 3. h1_sweep.sage → lodestone/

H1a/b/c/d hypotheses are the predecessor claims that lodestone validates.
Legacy status, but topically inseparable from the lodestone program.

### 4. smoke_test.sage → DELETE

One-line wrapper (`load(pathing('tests', 'run_tests.sage'))`). The
canonical invocation is `./sagew tests/run_tests.sage`.

### 5. stepstone/ internal flattening

Inner `chord_error/stepstones/` level is eliminated to avoid
`stepstone/stepstones/`. Three loose scripts promote to stepstone/ root.
art/ and hazards/ promote one level up.

### 6. Results relocation

`experiments/results/` is deleted. Contents scatter:
- `results/lodestone_summary.csv` → `lodestone/results/`
- `results/lodestone_percell.csv` → `lodestone/results/`
- `results/h1a_gap_vs_q.csv` → `lodestone/results/`
- `results/h1b_depth_scaling.csv` → `lodestone/results/`
- `results/h1c_layer_dependent.csv` → `lodestone/results/`
- `results/lodestone/harmonic_diagnostic_2026-03-12/` → `lodestone/results/`
- `results/lodestone/l1c_grid_2026-03-12/` → `lodestone/results/`
- `results/lodestone/l1c_stability_2026-03-12/` → `lodestone/results/`
- stepstone has no CSV results (PNGs colocated with scripts)

## Shared utility files (2 files at experiments/ root)

### `zoo_figure.sage`

Extracts the repeated zoo subplot pattern found in 7 scripts:

```sage
def zoo_subplots(figsize_per_cell=(4.5, 3.5), **subplot_kw):
    """Create fig + axes grid matching PARTITION_ZOO.
    Returns (fig, axes_flat, n_rows, n_cols)."""

def zoo_iter(axes_flat):
    """Yield (name, color, kind, ax) for each zoo entry."""

def zoo_hide_unused(axes_flat):
    """Hide axes beyond len(PARTITION_ZOO)."""

def zoo_label_edges(axes, ylabel='', xlabel=''):
    """Set ylabel on left column, xlabel on bottom row."""
```

Eliminates ~15 lines of boilerplate per zoo script.

### `sweep_driver.sage`

Extracts patterns shared by 6 sweep scripts:

```sage
def result_dir(topic, tag=None):
    """Create experiments/<topic>/results/<tag>/ and return path."""

def append_csv(path, rows, header=None):
    """Append dicts-as-rows to CSV, writing header if new file."""

def subset_size_str(greedy_size, exact_size):
    """Render greedy/exact subset sizes (currently duplicated in
    fsm_coarse.sage and optimize_delta.sage)."""
```

## Implementation steps

### Step 1: Create shared utilities

Write `experiments/zoo_figure.sage` and `experiments/sweep_driver.sage`.

### Step 2: git mv all files

Use `git mv` to preserve history. Sequence:

1. `mkdir -p experiments/lodestone/results`
2. `mkdir -p experiments/stepstone`
3. Move 7 lodestone scripts into `experiments/lodestone/`
4. Move 5 root CSVs from `experiments/results/` → `experiments/lodestone/results/`
5. Move 3 timestamped dirs from `experiments/results/lodestone/` → `experiments/lodestone/results/`
6. `git mv experiments/chord_error/TILT.md experiments/stepstone/`
7. `git mv experiments/chord_error/plog_chord_argument.sage experiments/stepstone/`
8. `git mv experiments/chord_error/damage experiments/stepstone/`
9. `git mv experiments/chord_error/zoo experiments/stepstone/`
10. Promote stepstones/ contents up: move 3 loose scripts to `experiments/stepstone/`
11. `git mv experiments/chord_error/stepstones/art experiments/stepstone/`
12. `git mv experiments/chord_error/stepstones/hazards experiments/stepstone/`
13. `git rm experiments/smoke_test.sage`
14. Remove empty `experiments/chord_error/` and `experiments/results/` trees

### Step 3: Update internal references in moved scripts

Three files have absolute `pathing()` calls that must change:

| File (new location) | Old path | New path |
|---|---|---|
| `stepstone/hazards/_slope_deviation.sage` | `pathing('experiments', 'chord_error', 'stepstones', 'art', 'raster.sage')` | `pathing('experiments', 'stepstone', 'art', 'raster.sage')` |
| `stepstone/hazards/crossings.sage` | `pathing('experiments', 'chord_error', 'stepstones', 'art', 'multiplexer.sage')` | `pathing('experiments', 'stepstone', 'art', 'multiplexer.sage')` |
| `stepstone/art/multiplexer.sage` | `pathing('experiments', 'chord_error', 'stepstones', 'art', 'raster.sage')` | `pathing('experiments', 'stepstone', 'art', 'raster.sage')` |

Additionally, all lodestone sweep scripts that write CSVs via
`pathing('experiments', 'results', ...)` must be updated to point at
`pathing('experiments', 'lodestone', 'results', ...)`.

### Step 4: Refactor scripts to use shared utilities

- Zoo scripts (7 files) → load `zoo_figure.sage`, replace boilerplate with
  `zoo_subplots()`, `zoo_iter()`, `zoo_hide_unused()`, `zoo_label_edges()`
- Sweep scripts → load `sweep_driver.sage`, deduplicate `subset_size_str`,
  use `result_dir()`, use `append_csv()`

### Step 5: Write README.md and AGENTS.md

- **experiments/README.md**: ~30 lines. Subdirectory list, shared file
  descriptions, run instructions (`./sagew experiments/<topic>/script.sage`).
  (Existing README.md will be rewritten.)
- **experiments/AGENTS.md**: When to create a new subdirectory vs extend
  existing. Naming conventions. Minimum structure requirements.

### Step 6: Clean up artifacts

- Remove `.sage.py` compiled files from experiments/ tree (gitignored, so
  `git mv` won't relocate them — they'll be stale after moves)
- Remove `.DS_Store` files (already in `.gitignore`)

### Step 7: Verify

- `./sagew tests/run_tests.sage` passes (88 tests)
- Spot-check: run one lodestone script and one stepstone script
- Verify PNG/CSV outputs land in correct locations
