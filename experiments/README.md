# Experiments

Runnable entry points organized by topic. All scripts require SageMath;
run from project root via `./sagew experiments/<topic>/<script>.sage`.

## Subdirectories

### `lodestone/`

Partition-comparison sweeps for the lodestone program. Tests whether
geometric partitions beat uniform under shared-delta optimization.
CSV results live in `lodestone/results/`.

Scripts: `lodestone_sweep`, `l1c_grid_sweep`, `l1c_stability_sweep`,
`harmonic_diagnostic_sweep`, `h1_sweep`, `fsm_coarse`, `optimize_delta`.

### `stepstone/`

Chord error visualization and analysis. Explores per-cell error structure,
slope deviation geometry, and fractal crossing-count art.

Subfolders: `zoo/` (partition zoo grids), `damage/` (foreign-error ribbons),
`hazards/` (slope deviation and stability), `art/` (fractal raster engine).

## Shared utilities

- **`zoo_figure.sage`** — Zoo-grid subplot helpers: `zoo_subplots()`,
  `zoo_iter()`, `zoo_hide_unused()`, `zoo_label_edges()`.
- **`sweep_driver.sage`** — CSV and result-directory helpers: `write_csv()`,
  `result_dir()`, `subset_size_str()`.

## Generated files

Sage emits `.sage.py` files next to drivers. These are generated artifacts
and are gitignored.
