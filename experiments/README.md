# Experiments

Runnable entry points organized by topic. All scripts require SageMath;
run from project root via `./sagew experiments/<topic>/<script>.sage`.

## Subdirectories

### `lodestone/`

Partition-comparison sweeps for the lodestone program. Tests whether
geometric partitions beat uniform under shared-delta optimization.
CSV results live in `lodestone/results/`.

Scripts: `partition_sweep`, `h1_sweep`, `inspect_case`, `error_profile`.

### `ripple/`

Normalized asymptotic-behavior experiments for coastline area across
partition families. Focuses on scaled-area convergence, wobble, and
stability diagnostics.

Scripts: `stability_heatmap`, `settlers`, `divergent`.

### `stepstone/`

Chord error visualization and analysis. Explores per-cell error structure,
slope deviation geometry, and fractal crossing-count art.

Subfolders: `zoo/` (partition zoo grids), `damage/` (foreign-error ribbons),
`hazards/` (slope deviation views), `fractal/` (fractal raster rendering and
outputs).

Fractal entry points:

- `fractal/single_fractal.sage` — one partition kind to one image
- `fractal/grid_fractals.sage` — one preset grid or the full zoo

Generated fractal PNGs live in `stepstone/fractal/results/`.

## Shared utilities

- **`zoo_figure.sage`** — Zoo-grid subplot helpers: `zoo_subplots()`,
  `zoo_iter()`, `zoo_hide_unused()`, `zoo_label_edges()`.
- **`sweep_driver.sage`** — CSV and result-directory helpers: `write_csv()`,
  `result_dir()`, `subset_size_str()`.

## Generated files

Sage emits `.sage.py` files next to drivers. These are generated artifacts
and are gitignored.
